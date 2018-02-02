$ErrorActionPreference = 'Stop'

# Install MSBuild

Invoke-WebRequest -UseBasicParsing https://download.visualstudio.microsoft.com/download/pr/100196686/e64d79b40219aea618ce2fe10ebd5f0d/vs_BuildTools.exe -OutFile vs_BuildTools.exe

# .NET Core skip first time experience, Installer won't detect DOTNET_SKIP_FIRST_TIME_EXPERIENCE if ENV is used, must use setx /M
setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

Start-Process vs_BuildTools.exe -ArgumentList `
    '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', `
    '--add', 'Microsoft.VisualStudio.Workload.NetCoreBuildTools', `
    '--add', 'Microsoft.VisualStudio.Workload.WebBuildTools', `
    '--quiet', '--norestart', '--nocache' `
    -NoNewWindow -Wait

setx /M PATH $(${Env:PATH} + ";${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\")

# Install .NET Framework targeting packs
#Add-Type -AssemblyName System.IO.Compression.FileSystem

#@('4.0', '4.5.2', '4.6.2', '4.7.1') | ForEach-Object {
#    Invoke-WebRequest -UseBasicParsing https://dotnetbinaries.blob.core.windows.net/referenceassemblies/v${_}.zip -OutFile referenceassemblies.zip
#    [System.IO.Compression.ZipFile]::ExtractToDirectory("referenceassemblies.zip", "${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\")
#    Remove-Item -Force referenceassemblies.zip
#}
