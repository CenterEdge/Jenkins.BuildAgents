#$pkgParams = Get-PackageParameters
<#
.SYNOPSIS
Install jenkins agent as a windows service
.PARAMETER jenkinsMainbaseUrl
External URL to your jenkins server
.PARAMETER jenkinsMainBaseUrlInternal
Internal URL to your jenkins server
.PARAMETER nodeName
The name of the node you configured on Jenkins
.PARAMETER privateKey
The secret for the JNLP connection
.PARAMETER workspaceRootFolder
The folder where the service will be installed. This is the root folder for the workspace.
.EXAMPLE .\jenkins-agent-install.ps1 -jenkinsMainBaseUrlInternal  "https://172.31.31.228"  -jenkinsMainbaseUrl "https://jenkins.centeredgesoftware.com" -nodeName "<REDACTED>" -privateKey "<REDACTED>" -workspaceRootFolder "C:\Jenkins" -userName "<REDACTED>" -userPass "<REDACTED>"
#>
param(
  [string]$jenkinsMainbaseUrl,
  [string]$jenkinsMainBaseUrlInternal,
  [string]$nodeName,
  [string]$privateKey,
  [string]$workspaceRootFolder,
  [string]$userName,
  [string]$userPass
)

$ErrorActionPreference = "Stop"

Function Install-JenkinsBuildAgent {
  param(
    [string]$jenkinsMainbaseUrl,
    [string]$jenkinsMainBaseUrlInternal,
    [string]$nodeName,
    [string]$privateKey,
    [string]$workspaceRootFolder,
    [string]$userName,
    [string]$userPass
  )

  $javaHomePath = ${env:JAVA_HOME}

  if ($javaHomePath -eq "") {
    Write-Host -ForegroundColor Red "Java is not properly setup. Aborting."
  }

  if (!($javaHomePath.EndsWith("\") -or $javaHomePath.EndsWith("/"))) {
    $javaHomePath = $javaHomePath + "\"
  }

  Write-Host -ForegroundColor Cyan "Using Java from ${javaHomePath}."

  # save current working directory
  Push-Location -StackName jenkinsBuildAgentInstall

  try {

      $jnlpUrl = "$jenkinsMainBaseUrlInternal/computer/$nodeName/jenkins-agent.jnlp"
      $jarUrl = "$jenkinsMainbaseUrl/jnlpJars/agent.jar"

      $svc=Get-Service "jenkinsagent-${nodeName}" -ErrorAction SilentlyContinue

      if ($null -ne $svc) {
        Stop-Service $svc -ErrorAction SilentlyContinue
      }

      Write-Host " - Creating workspace" -ForegroundColor Green

      if ((Test-Path $workspaceRootFolder) -eq $False) {
        New-Item -Path $workspaceRootFolder -ItemType "Directory"
      }

      Set-Location $workspaceRootFolder
      [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
      Write-Host " - Downloading Jenkins files" -ForegroundColor Green
      Invoke-WebRequest $jarUrl -OutFile "agent.jar" -Verbose

      Write-Host " - Downloading WinSW (Jenkins Agent Service Wrapper)" -ForegroundColor Green
      Invoke-WebRequest "https://github.com/winsw/winsw/releases/download/v2.11.0/WinSW.NET4.exe" -OutFile "jenkins-agent.exe" -Verbose

      Write-Host " - Configuring Jenkins Agent Service" -ForegroundColor Green
      #jenkins-agent.exe.config
@'
  <!-- see http://support.microsoft.com/kb/936707 -->
  <configuration>
    <runtime>
      <generatePublisherEvidence enabled="false"/>
    </runtime>
    <startup>
      <supportedRuntime version="v4.0" />
      <supportedRuntime version="v2.0" />
    </startup>
  </configuration>
'@ | Out-File "jenkins-agent.exe.config" -Encoding Ascii

      #jenkins-agent.xml
@"
  <!--
  The MIT License

  Copyright (c) 2004-2017, Sun Microsystems, Inc., Kohsuke Kawaguchi, Oleg Nenashev and other contributors

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
  -->

  <!--
    Windows service definition for Jenkins agent.
    This service is powered by the WinSW project: https://github.com/kohsuke/winsw/

    You can find more information about available options here: https://github.com/kohsuke/winsw/blob/master/doc/xmlConfigFile.md
    Configuration examples are available here: https://github.com/kohsuke/winsw/tree/master/examples

    To uninstall, run "jenkins-agent.exe stop" to stop the service, then "jenkins-agent.exe uninstall" to uninstall the service.
    Both commands don't produce any output if the execution is successful.
  -->
  <service>
    <id>jenkinsagent-${nodeName}</id>
    <name>Jenkins agent (jenkinsagent-${nodeName})</name>
    <description>This service runs an agent for Jenkins automation server.</description>
    <!--
      if you'd like to run Jenkins with a specific version of Java, specify a full path to java.exe.
      The following value assumes that you have java in your PATH.
    -->
    <!--<executable>C:\Program Files (x86)\Java\jre1.8.0_151\bin\java.exe</executable>-->
    <executable>${env:JAVA_HOME}\bin\java.exe</executable>
    <arguments>-Xrs  -jar "%BASE%\agent.jar" -jnlpUrl ${jnlpUrl} -secret ${privateKey}</arguments>
    <!--
      interactive flag causes the empty black Java window to be displayed.
      I'm still debugging this.
    <interactive />
    -->
    <logmode>rotate</logmode>

    <delayedAutoStart/>

    <onfailure action="restart" />
    <onfailure action="reboot" />

    <serviceaccount>
      <!--<domain>YOURDOMAIN</domain>-->
      <user>${userName}</user>
      <password>${userPass}</password>
      <allowservicelogon>true</allowservicelogon>
    </serviceaccount>

    <!--
      If uncommented, download the Remoting version provided by the Jenkins master.
      Enabling for HTTP implies security risks (e.g. replacement of JAR via DNS poisoning). Use on your own risk.
      NOTE: This option may fail to work correctly (e.g. if Jenkins is located behind HTTPS with untrusted certificate).
      In such case the old agent version will be used; you can replace agent.jar manually or to specify another download URL.
    -->
    <download from="${jarUrl}" to="%BASE%\agent.jar"/>

    <!--
      In the case WinSW gets terminated and leaks the process, we want to abort
      these runaway JAR processes on startup to prevent "Agent is already connected errors" (JENKINS-28492).
    -->
    <extensions>
      <!-- This is a sample configuration for the RunawayProcessKiller extension. -->
      <extension enabled="true"
                className="winsw.Plugins.RunawayProcessKiller.RunawayProcessKillerExtension"
                id="killOnStartup">
        <pidfile>%BASE%\jenkins_agent.pid</pidfile>
        <stopTimeout>5000</stopTimeout>
        <stopParentFirst>false</stopParentFirst>
      </extension>
    </extensions>

    <!-- See referenced examples for more options -->

  </service>
"@ | Out-File "jenkins-agent.xml" -Encoding Ascii


      if ($null -eq $svc) {
        Write-Host " - Installing Jenkins Agent Service" -ForegroundColor Green
        Invoke-Expression "./jenkins-agent.exe install"
        $svc=Get-Service "jenkinsagent-${nodeName}"
      }

      Write-Host " - Starting Jenkins Agent Service" -ForegroundColor Green
      Start-Service $svc

  }
  finally {
      # set location back to where we started
      Pop-Location -StackName jenkinsBuildAgentInstall
  }

}

Install-JenkinsBuildAgent -jenkinsMainBaseUrlInternal $jenkinsMainBaseUrlInternal -jenkinsMainbaseUrl $jenkinsMainbaseUrl -nodeName $nodeName -privateKey $privateKey -workspaceRootFolder $workspaceRootFolder -userName $userName -userPass $userPass
