#!/bin/bash

# Set the GitHub repository URL as a variable
GH_REPO=https://github.com/shonifari/tech264-java-app

# Echo statement to indicate the start of the update and upgrade process
echo "[UPDATE & UPGRADE PACKAGES]"

# Update package list
echo "Updating package list..."
sudo apt-get update -y

# Upgrade all installed packages
echo "Upgrading installed packages..."
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

# Install Java 17
echo "Installing Java 17..."
sudo DEBIAN_FRONTEND=noninteractive apt install openjdk-17-jdk -y

# Set Java home environment variable and update the PATH
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

# Install Maven by downloading and extracting the binary
echo "Downloading and installing Apache Maven..."
wget https://dlcdn.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz

# Extract Maven to the /opt directory
echo "Extracting Maven to /opt directory..."
sudo tar -xvzf apache-maven-*.tar.gz -C /opt

# Move extracted Maven to a more appropriate directory
echo "Moving Maven to /opt/maven..."
sudo mv /opt/apache-maven-* /opt/maven

# Export Maven environment variables
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH

# Optionally, you can make Maven variables persistent by uncommenting the following lines:
# echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile.d/maven.sh
# echo "export PATH=\$M2_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
# sudo chmod +x /etc/profile.d/maven.sh
# source /etc/profile.d/maven.sh

# Check Maven version to verify installation
echo "Checking Maven version..."
mvn -version

# Cleanup by removing the downloaded Maven tar.gz file
echo "Cleaning up the downloaded Maven tarball..."
rm apache-maven-*.tar.gz

# Export database connection details
export DB_USER="java-app"
export DB_PASS="password"
export DB_HOST=jdbc:mysql://${DATABASE_IP}:3306/library

# Clone the GitHub repository using the provided token for authentication
echo "Cloning the repository from GitHub..."
git clone https://shonifari:${GH_TOKEN}@github.com/shonifari/tech264-java-app.git repo

# Navigate into the cloned project directory
cd repo/LibraryProject2

# Wait for a few seconds to ensure the database is ready
echo "Waiting for 5 seconds..."
sleep 5s

# Build the project using Maven
echo "Building the project with Maven..."
mvn clean package

# Start the Spring Boot application
echo "Starting the Spring Boot application..."
mvn spring-boot:start

# Final message indicating script completion
echo "[PROCESS COMPLETED] Application setup and start completed."
