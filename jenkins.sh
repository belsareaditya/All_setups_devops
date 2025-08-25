# Update package index
sudo apt update

# Install Java runtime dependencies required by Jenkins (OpenJDK 21 + fontconfig)
sudo apt install fontconfig openjdk-21-jre

# Verify Java installation
java -version


# Download and install the Jenkins repository GPG key to the system keyring
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins apt repository (stable) to sources list
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Refresh package index with the newly added Jenkins repository
sudo apt-get update

# Install Jenkins
sudo apt-get install jenkins
