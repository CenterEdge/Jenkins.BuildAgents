Param(
    [string]
    [Parameter(Mandatory=$true)]
    $AgentName,

    [string]
    [Parameter(Mandatory=$true)]
    $Secret,

    [switch]
    $Register
)

# For Hyper-V agents, this script can be set as an automatic boot task

if (-not $Register) {
    Add-Type -Assembly System.Web

    $agentFile = "${env:TMP}/agent.jar"
    Remove-Item $agentFile -ErrorAction SilentlyContinue
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    Invoke-WebRequest -UseBasicParsing "https://jenkins.centeredgesoftware.com/jnlpJars/agent.jar" -OutFile $agentFile
    Unblock-File $agentFile
    java -jar $agentFile -jnlpUrl "https://jenkins.centeredgesoftware.com/computer/$([System.Web.HttpUtility]::UrlPathEncode($AgentName))/slave-agent.jnlp" -secret $Secret -workDir "C:\Jenkins"
} else {
    $trigger = New-ScheduledTaskTrigger -AtStartup
    $user = "NT AUTHORITY\SYSTEM"
    $action = New-ScheduledTaskAction -WorkingDirectory $PSScriptRoot -Execute (Get-Command powershell).Source -Argument "-Command `"& .\$($MyInvocation.MyCommand.Name) -AgentName '$AgentName' -Secret $Secret`""
    $settings = New-ScheduledTaskSettingsSet -ExecutionTimeLimit 0 -RestartCount 100 -RestartInterval 0:1:0

    Register-ScheduledTask -TaskName "Jenkins Agent" -Trigger $trigger -Action $action -User $user -Settings $settings

    Start-ScheduledTask -TaskName "Jenkins Agent"
}
