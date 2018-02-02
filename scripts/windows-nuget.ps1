$ErrorActionPreference = 'Stop'

New-Item -Type Directory $Env:ProgramFiles\NuGet | Out-Null

Invoke-WebRequest -UseBasicParsing https://dist.nuget.org/win-x86-commandline/v$Env:NUGET_VERSION/nuget.exe -OutFile $Env:ProgramFiles\NuGet\nuget.exe

[Environment]::SetEnvironmentVariable("PATH", ${Env:PATH} + ";${Env:ProgramFiles}\NuGet\", "Machine")