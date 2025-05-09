#!/bin/bash
set -e

echo "Starting full setup: Jenkins + Terraform + Docker + Kubectl + Helm"

# Update system and install base tools
sudo apt-get update -y
sudo apt-get install -y git curl unzip gnupg apt-transport-https ca-certificates software-properties-common lsb-release

# ---------------------------------
# Install Java (Jenkins requirement)
# ---------------------------------
sudo apt install -y openjdk-17-jre-headless

# ---------------------------------
# Install Jenkins
# ---------------------------------
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | \
  gpg --dearmor | \
  sudo tee /usr/share/keyrings/jenkins-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.gpg] https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y jenkins

# ---------------------------------
# Install Terraform
# ---------------------------------
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
  sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y terraform

# ---------------------------------
# Install Docker
# ---------------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Add Jenkins and Ubuntu users to docker group
sudo usermod -aG docker jenkins
sudo usermod -aG docker ubuntu

# ---------------------------------
# Install kubectl
# ---------------------------------
curl -LO "https://dl.k8s.io/release/$(curl -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
curl -LO "https://dl.k8s.io/release/stable.txt"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# ---------------------------------
# Install Helm
# ---------------------------------
HELM_VERSION="v3.12.3"
wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
tar -zxvf helm-${HELM_VERSION}-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/helm
rm -rf helm-${HELM_VERSION}-linux-amd64.tar.gz linux-amd64

# ---------------------------------
# AWS CLI
# ---------------------------------
sudo apt-get install -y awscli

# ---------------------------------
# Done
# ---------------------------------
echo 'All tools installed successfully.'
echo 'Starting Jenkins service...'
sudo systemctl start jenkins
sudo systemctl enable jenkins

echo 'Jenkins is installed and running.'
echo 'Default Jenkins password:'
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
sudo systemctl daemon-reload
sudo systemctl start jenkins
sudo systemctl enable jenkins
