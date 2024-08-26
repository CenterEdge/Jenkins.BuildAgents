#!/bin/bash
sudo dnf install -y git git-lfs java-17-amazon-corretto docker
sudo usermod -aG docker ec2-user
sudo systemctl enable --now docker.service containerd.service

# Install docker-compose
dockerComposeVersion=1.23.2
sudo -i curl -L https://github.com/docker/compose/releases/download/$dockerComposeVersion/docker-compose-linux-"$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
