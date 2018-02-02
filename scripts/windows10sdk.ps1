$ErrorActionPreference = 'Stop'

Invoke-WebRequest -UseBasicParsing http://download.microsoft.com/download/2/1/2/2122BA8F-7EA6-4784-9195-A8CFB7E7388E/StandaloneSDK/sdksetup.exe -OutFile sdksetup.exe

Start-Process -FilePath "sdksetup.exe" -ArgumentList /Quiet, /NoRestart, /Log, c:\install_logs\sdksetup.log -NoNewWindow -Wait