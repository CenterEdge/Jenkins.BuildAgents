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

setx /M PATH $(${Env:PATH} + ";${Env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\BuildTools\MSBuild\15.0\Bin\;${Env:ProgramFiles}\dotnet\")

# Install .NET Framework targeting packs
Add-Type -AssemblyName System.IO.Compression.FileSystem

if (-not (Test-Path "${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\")) {
    New-Item -ItemType Directory "${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\" | Out-Null
}

@('4.0', '4.5.2', '4.6.2', '4.7.2') | ForEach-Object {
    $tempFolder = Join-Path ${env:TEMP} "referenceassemblies"
    New-Item -ItemType Directory $tempFolder | Out-Null

    Invoke-WebRequest -UseBasicParsing https://dotnetbinaries.blob.core.windows.net/referenceassemblies/v${_}.zip -OutFile referenceassemblies.zip
    [System.IO.Compression.ZipFile]::ExtractToDirectory("referenceassemblies.zip", $tempFolder)
    Remove-Item -Force referenceassemblies.zip

    Get-ChildItem $tempFolder | ForEach-Object {
        $destination = Join-Path "${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\" $_.Name

        if (Test-Path $destination) {
            Remove-Item $destination -Recurse -Force
        }

        Move-Item $_.FullName -Destination "${Env:ProgramFiles(x86)}\Reference Assemblies\Microsoft\Framework\.NETFramework\" -Force
    }

    Remove-Item $tempFolder -Force -Recurse -ErrorAction SilentlyContinue
}

# Install .NET Core SDK 2.2 (.1xx series for MSBuild 2017 compatibility)
choco install -y dotnetcore-sdk --version=2.2.105 --no-progress
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

# Install .NET 3.5, needed for some WiX tools
Install-WindowsFeature NET-Framework-Core
