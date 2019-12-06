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
