#!/bin/bash

# Remove old Java
sudo yum remove -y java-1.7.0-openjdk

# Install Java and Git
# This script assumes Docker is baked into the AMI
sudo yum install -y git git-lfs java-1.8.0

# Ensure Docker access for ec2-user
sudo gpasswd -a ec2-user docker

# Install docker-compose
dockerComposeVersion=1.21.2
sudo -i curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
