$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue" # Speeds up download

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls10 -bor [Net.SecurityProtocolType]::Tls11 -bor [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -UseBasicParsing "https://upgrades.pfestore.com/crystalreports/2008fp31/CRRuntime_12_3_mlb.msi" -OutFile "CRRuntime_12_3_mlb.msi"

Start-Process "msiexec.exe" -ArgumentList "/i", "CRRuntime_12_3_mlb.msi", "/quiet", "/qn", "/norestart" -NoNewWindow -Wait
