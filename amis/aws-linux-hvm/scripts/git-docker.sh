#!/bin/bash

# Remove old Java
sudo yum remove -y java-1.7.0-openjdk

# Install Java and Git
sudo yum update -y
sudo yum install -y git git-lfs

# Install Docker
sudo amazon-linux-extras install docker java-openjdk11
sudo systemctl enable docker

# Ensure Docker access for ec2-user
sudo usermod -a -G docker ec2-user

# Install docker-compose
dockerComposeVersion=1.23.2
sudo -i curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
