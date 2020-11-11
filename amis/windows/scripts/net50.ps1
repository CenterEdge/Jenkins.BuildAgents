[Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12

Invoke-WebRequest -UseBasicParsing -Uri https://download.visualstudio.microsoft.com/download/pr/2892493e-df43-409e-af68-8b14aa75c029/53156c889fc08f01b7ed8d7135badede/dotnet-sdk-5.0.100-win-x64.exe -OutFile .\dotnet-sdk-5.0.100-win-x64.exe

.\dotnet-sdk-5.0.100-win-x64.exe /install /quiet /norestart
