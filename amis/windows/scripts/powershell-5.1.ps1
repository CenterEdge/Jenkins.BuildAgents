$ErrorActionPreference = "Stop"

Invoke-WebRequest -UseBasicParsing https://download.microsoft.com/download/6/F/5/6F5FF66C-6775-42B0-86C4-47D41F2DA187/Win8.1AndW2K12R2-KB3191564-x64.msu -OutFile Win8.1AndW2K12R2-KB3191564-x64.msu

if (-not (Test-Path C:\install_logs)) {
    New-Item -ItemType Directory c:\install_logs | Out-Null
}

Start-Process "wusa.exe" -ArgumentList "Win8.1AndW2K12R2-KB3191564-x64.msu", /Quiet, /NoRestart, /Log:c:\install_logs\ps51.log -NoNewWindow -Wait
