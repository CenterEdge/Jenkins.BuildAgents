$ErrorActionPreference = "Stop"

#$sdksetup = Join-Path ${env:TEMP} sdksetup.exe

#Remove-Item $sdksetup -Force -ErrorAction SilentlyContinue
#Invoke-WebRequest -UseBasicParsing http://download.microsoft.com/download/B/0/C/B0C80BA3-8AD6-4958-810B-6882485230B5/standalonesdk/sdksetup.exe -OutFile $sdksetup

#if (-not (Test-Path C:\install_logs)) {
#    New-Item -ItemType Directory c:\install_logs | Out-Null
#}

#Start-Process -FilePath $sdksetup -ArgumentList /Quiet, /NoRestart, /Log, c:\install_logs\sdksetup81.log -NoNewWindow -Wait

choco install -y "windows-sdk-8.1" --no-progress
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
