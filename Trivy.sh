#!/bin/bash

# Install prerequisites
sudo apt-get update
sudo apt-get install -y wget apt-transport-https gnupg lsb-release

# Add Aqua Security’s Trivy repo key
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null

# Add Trivy apt repo
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
  | sudo tee /etc/apt/sources.list.d/trivy.list

# Update repos and install Trivy
sudo apt-get update
sudo apt-get install -y trivy

# Verify
trivy --version

echo "✅ Trivy installed successfully via apt repo - Aditya 🚀"
