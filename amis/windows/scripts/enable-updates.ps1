$ErrorActionPreference = "Stop"

# Enable Windows Updates to support some later installations, on demand only

if (-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU)) {
    New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate -Name AU -Value "" -Force | Out-Null

    New-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions -PropertyType "dword" -Value 2 | Out-Null
} else {
    Set-ItemProperty -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU -Name AUOptions -Value 2
}

wuauclt /detectnow # Detect updates
