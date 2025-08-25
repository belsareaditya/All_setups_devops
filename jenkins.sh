#!/bin/bash
set -euo pipefail

# Update system
sudo apt-get update -y

# Install the latest OpenJDK (provided by Ubuntu as default-jdk)
sudo apt-get install -y default-jdk

# Show installed Java version
echo "------------------------------------"
java -version
echo "✅ Java installed successfully!"
echo "------------------------------------"

# Download Jenkins GPG key
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add Jenkins repository to package manager sources
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Install Jenkins
sudo apt-get install -y jenkins

# Enable and start Jenkins service
sudo systemctl enable --now jenkins.service

# Show Jenkins status
echo "------------------------------------"
systemctl status jenkins.service --no-pager
echo "✅ Jenkins installed and running!"
echo "------------------------------------"
