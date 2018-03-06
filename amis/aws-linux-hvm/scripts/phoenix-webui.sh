#!/bin/sh

sleep 20

# Remove old Java
sudo yum remove -y java-1.7.0-openjdk

# Install Java and Git
# This script assumes Docker is baked into the AMI
sudo yum install -y git java-1.8.0

# Configure Docker for ephemeral storage
sudo mkdir -p /media/ephemeral0/docker
echo "OPTIONS=\"\$OPTIONS -g /media/ephemeral0/docker\"" | sudo tee -a /etc/sysconfig/docker
sudo chkconfig docker on

# Install docker-compose
dockerComposeVersion=1.16.1
sudo -i curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
