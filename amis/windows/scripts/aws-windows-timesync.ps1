$ErrorActionPreference = 'Stop'

Start-Service W32Time

w32tm /config /manualpeerlist:169.254.169.123 /syncfromflags:manual /update