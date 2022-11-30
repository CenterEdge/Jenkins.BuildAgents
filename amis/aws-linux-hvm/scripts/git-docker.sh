#!/bin/bash

sudo yum install -y git git-lfs
sudo amazon-linux-extras install java-openjdk11 docker
# Autostart / Ensure Docker access for ec2-user
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install docker-compose
dockerComposeVersion=1.23.2
sudo -i curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
