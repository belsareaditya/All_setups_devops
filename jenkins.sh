#!/bin/bash

# Install OpenJDK 21 JRE Headless
sudo apt-get install -y openjdk-21-jre-headless

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to package manager sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package manager repositories
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins -y

# Start and enable the service
sudo systemctl enable --now jenkins
sudo systemctl status jenkins

echo " Aditya Jenkins is install"
