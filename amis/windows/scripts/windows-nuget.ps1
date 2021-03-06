$ErrorActionPreference = 'Stop'

New-Item -Type Directory $Env:ProgramFiles\NuGet | Out-Null

[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -UseBasicParsing https://dist.nuget.org/win-x86-commandline/v$Env:NUGET_VERSION/nuget.exe -OutFile $Env:ProgramFiles\NuGet\nuget.exe

if (${Env:PATH}.EndsWith(';')) {
    $path = "${Env:PATH}${Env:ProgramFiles}\NuGet\"
}
else {
    $path = "${Env:PATH};${Env:ProgramFiles}\NuGet\"
}

[Environment]::SetEnvironmentVariable("PATH", $path, "Machine")
