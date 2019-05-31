# Note: this requires HyperV, which means that we must be on:
# - A HyperV VM which has virtualization extensions and MAC spoofing enabled, and which has fixed memory
# - Have HyperV installed on the VM
# This script cannot be used for AWS images

# Unfortunately, Docker for Windows, a.k.a Docker Desktop, seems to have problems running inside a VM
# So we're manually installing the different sub-components and using a External Hyper-V switch instead of NAT

$ErrorActionPreference = "Stop"

# These are the key parts of docker on windows
choco install -y docker-cli docker-machine docker-compose --no-progress

# Add a HyperV switch so the Linux VM used for Linux Docker containers can talk to it's host, and pull images from the internet
$hostNetAdapter = Get-NetAdapter -Physical | Select-Object -First 1 -ExpandProperty Name;
if ( $null -eq (Get-VMSwitch -Name DockerNAT -ErrorAction SilentlyContinue) ){
    New-VMSwitch DockerNAT -NetAdapterName $hostNetAdapter | Out-Null
}

# Create the Docker Linux VM, and set it to start automatically
if ( $null -eq (docker-machine ls --filter name=docker-vm | ConvertFrom-String)[1] ){
    docker-machine create -d hyperv --hyperv-virtual-switch "DockerNAT" --hyperv-memory 2048 --hyperv-cpu-count 2 docker-vm
    Get-VM -Name docker-vm | Set-VM -AutomaticStartAction Start

    # For the dcoker command tow work correctly, we need a few environment variables set. docker-machine cn provide the PowerShell to set these up
    & docker-machine env docker-vm | Invoke-Expression

    # The line above only sets the environment variables at the session level. We need then to be for the local machine, or after a reboot we won't be able
    # to use docker commands
    Get-ChildItem -Path env: |
        Where-Object -Property Name -Like docker* |
        ForEach-Object { [System.Environment]::SetEnvironmentVariable($_.Name, $_.Value, [System.EnvironmentVariableTarget]::Machine) }
}
