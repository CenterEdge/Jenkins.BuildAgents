$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # Speeds up download

# Install MSBuild

$vsbuildtools = Join-Path ${env:TEMP} vs_BuildTools2022.exe
Invoke-WebRequest -UseBasicParsing https://aka.ms/vs/17/release/vs_BuildTools.exe -OutFile $vsbuildtools

# .NET Core skip first time experience, Installer won't detect DOTNET_SKIP_FIRST_TIME_EXPERIENCE if ENV is used, must use setx /M
setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

Start-Process $vsbuildtools -ArgumentList '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', '--add', 'Microsoft.VisualStudio.Workload.NetCoreBuildTools', '--add', 'Microsoft.VisualStudio.Workload.WebBuildTools', '--add', 'Microsoft.VisualStudio.Workload.VCTools', '--add', 'Microsoft.VisualStudio.Workload.VisualStudioExtensionBuildTools', '--quiet', '--norestart', '--nocache' -NoNewWindow -Wait

if (${Env:PATH}.EndsWith(';')) {
    $path = "${Env:PATH}${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\;${Env:ProgramFiles}\dotnet\;"
}
else {
    $path = "${Env:PATH};${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\;${Env:ProgramFiles}\dotnet\;"
}

setx /M PATH $path
