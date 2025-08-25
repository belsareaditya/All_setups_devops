#!/bin/bash


# Update system
apt-get update -y
apt-get upgrade -y

# Install prerequisites
apt-get install -y ca-certificates curl gnupg lsb-release

# Remove any old Docker packages
apt-get remove -y docker docker-engine docker.io containerd runc || true

# Add Docker’s official GPG key
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
> /etc/apt/sources.list.d/docker.list

# Install Docker Engine
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable --now docker

# --- Permissions Section ---

# Add current user to docker group
if ! getent group docker >/dev/null; then
  groupadd docker
fi
usermod -aG docker "$USER"

# Allow all users to access Docker socket (⚠️ insecure, but requested)
chmod 666 /var/run/docker.sock

# Refresh group membership so current shell gets docker access
newgrp docker <<EONG
echo "Docker group refreshed for user: $USER"
docker ps
EONG

# Test Docker
docker run --rm hello-world || true

echo "✅ Docker installed"
echo "✅ Current user '$USER' added to docker group"
echo "⚠️ /var/run/docker.sock set to world-writable (all users can access Docker)"
