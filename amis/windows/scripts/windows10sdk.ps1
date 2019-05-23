# $ErrorActionPreference = 'Stop'

# $sdksetup = Join-Path ${env:TEMP} sdksetup.exe

# Remove-Item $sdksetup -Force -ErrorAction SilentlyContinue
# Invoke-WebRequest -UseBasicParsing http://download.microsoft.com/download/2/1/2/2122BA8F-7EA6-4784-9195-A8CFB7E7388E/StandaloneSDK/sdksetup.exe -OutFile $sdksetup

# if (-not (Test-Path C:\install_logs)) {
#     New-Item -ItemType Directory c:\install_logs | Out-Null
# }

# Start-Process -FilePath $sdksetup -ArgumentList /Quiet, /NoRestart, /Log, c:\install_logs\sdksetup10.log -NoNewWindow -Wait

choco install -y "windows-sdk-10.0" --no-progress
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}
