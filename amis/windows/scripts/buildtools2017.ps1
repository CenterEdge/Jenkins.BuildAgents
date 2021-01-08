$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue' # Speeds up download

# Install MSBuild

$vsbuildtools = Join-Path ${env:TEMP} vs_BuildTools.exe
Invoke-WebRequest -UseBasicParsing https://aka.ms/vs/15/release/vs_BuildTools.exe -OutFile $vsbuildtools

# .NET Core skip first time experience, Installer won't detect DOTNET_SKIP_FIRST_TIME_EXPERIENCE if ENV is used, must use setx /M
setx /M DOTNET_SKIP_FIRST_TIME_EXPERIENCE 1

Start-Process $vsbuildtools -ArgumentList `
    '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', `
    '--add', 'Microsoft.VisualStudio.Workload.NetCoreBuildTools', `
    '--add', 'Microsoft.VisualStudio.Workload.WebBuildTools', `
    '--add', 'Microsoft.VisualStudio.Workload.VCTools', `
    '--add', 'Microsoft.VisualStudio.Workload.VisualStudioExtensionBuildTools', `
    '--quiet', '--norestart', '--nocache' `
    -NoNewWindow -Wait

if (${env:set_msbuild2017_path} -ne "false") {
    setx /M PATH $(${Env:PATH} + ";${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\;${Env:ProgramFiles}\dotnet\;")
}

# Install .NET Core SDK 2.2 (.1xx series for MSBuild 2017 compatibility)
choco install -y dotnetcore-sdk --version=2.2.107 --no-progress
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
