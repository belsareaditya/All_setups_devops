#!/usr/bin/env bash
set -euo pipefail

# Variables
TRIVY_VERSION="0.18.3"
TRIVY_PKG="trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz"

# Download Trivy release
wget -q "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/${TRIVY_PKG}"

# Extract
tar -xzf "${TRIVY_PKG}"

# Move binary to /usr/local/bin (already in PATH)
sudo mv trivy /usr/local/bin/

# Cleanup
rm -f "${TRIVY_PKG}"

# Verify installation
trivy --version

# Final message
echo "✅ Trivy ${TRIVY_VERSION} installed successfully! - Aditya 🚀"
