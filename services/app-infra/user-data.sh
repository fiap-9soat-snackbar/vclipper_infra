#!/bin/bash

# Update and install required packages
echo "#################### Updating and installing required packages: wget, apt-transport-https, gpg, curl, and unzip ####################"
apt-get update
apt-get install -y wget apt-transport-https gpg curl unzip

# Add Adoptium official GPG key
echo "#################### Adding Adoptium official GPG key ####################"
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list

# Update packages list and install Eclipse Temurin 21 JDK
echo "#################### Updating packages list and installing Eclipse Temurin 21 JDK ####################"
apt-get update
apt-get install -y temurin-21-jdk

# Add Java path to environment
echo "#################### Adding Java path to environment ####################"
echo 'JAVA_HOME="/usr/lib/jvm/temurin-21-jdk-amd64"' | tee -a /etc/environment
export JAVA_HOME="/usr/lib/jvm/temurin-21-jdk-amd64"

# Install Maven
echo "#################### Installing Maven ####################"
cd /tmp
wget https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz
tar -xf apache-maven-3.9.9-bin.tar.gz
mv apache-maven-3.9.9 /opt/maven
chown -R root:root /opt/maven

# Set up Maven environment variables
echo "#################### Setting up Maven environment variables ####################"
echo 'M2_HOME="/opt/maven"' | tee -a /etc/environment
export M2_HOME="/opt/maven"
echo 'M2="/opt/maven/bin"' | tee -a /etc/environment
export M2="/opt/maven/bin"
echo 'MAVEN_HOME="/opt/maven"' | tee -a /etc/environment
export MAVEN_HOME="/opt/maven"
export PATH=$M2_HOME/bin:$PATH

ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Download VClipper application from repository
echo "#################### Downloading VClipper application from repository ####################"
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app

# Set HOME environment variable for git
export HOME=/root
git clone --depth 1 https://github.com/fiap-9soat-snackbar/vclipper_processing.git

chown -R ubuntu:ubuntu /home/ubuntu/app
cd vclipper_processing

# Build application
echo "#################### Building VClipper application ####################"
mvn -q clean package -DskipTests

# Install Docker
echo "#################### Installing Docker ####################"
echo "#################### Updating and installing required packages: ca-certificates, curl and gnupg ####################" 
apt-get update
apt-get install -y ca-certificates curl gnupg

echo "#################### Adding Docker official GPG key ####################"
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo "#################### Adding Docker repository ####################"
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker packages
echo "#################### Installing Docker packages ####################"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "#################### Adding ubuntu user to docker group ####################"
usermod -aG docker ubuntu
newgrp docker

# Update .env with production AWS configuration
echo "#################### Updating .env with AWS configuration ####################"
cat > .env << 'ENVEOF'
# ===========================================
# VClipper Processing Service Environment Variables
# ===========================================

# ===========================================
# Server Configuration
# ===========================================
SERVER_PORT=8080

# ===========================================
# Database Configuration
# ===========================================
DB_HOST=mongodb
DB_PORT=27017
MONGODB_DATABASE=vclipper
MONGODB_USER=vclipperuser
MONGODB_PASSWORD=vclipper01

# MongoDB Authentication
MONGO_INITDB_ROOT_USERNAME=mongodbadmin
MONGO_INITDB_ROOT_PASSWORD=admin
MONGO_INITDB_DATABASE=vclipper

# ===========================================
# File Upload Configuration
# ===========================================
MAX_FILE_SIZE=500MB
MAX_REQUEST_SIZE=500MB

# ===========================================
# VClipper Processing Configuration
# ===========================================
VCLIPPER_MAX_FILE_SIZE_BYTES=524288000
VCLIPPER_ALLOWED_FORMATS=mp4,avi,mov,wmv,flv,webm
VCLIPPER_DOWNLOAD_EXPIRATION_MINUTES=60
VCLIPPER_RETRY_MAX_ATTEMPTS=3
VCLIPPER_RETRY_INITIAL_DELAY=30
VCLIPPER_RETRY_MAX_DELAY=300

# ===========================================
# Logging Configuration
# ===========================================
LOG_LEVEL_ROOT=INFO
LOG_LEVEL_VCLIPPER=DEBUG
LOG_LEVEL_SPRING_WEB=INFO
LOG_LEVEL_MONGODB=DEBUG

# ===========================================
# AWS Configuration (Production)
# ===========================================
AWS_ACCOUNT_ID=668309122622
AWS_REGION=us-east-1
AWS_S3_BUCKET=vclipper-video-storage-dev
AWS_SQS_PROCESSING_QUEUE_URL=https://sqs.us-east-1.amazonaws.com/668309122622/vclipper-video-processing-dev
AWS_SNS_SUCCESS_TOPIC_ARN=arn:aws:sns:us-east-1:668309122622:vclipper-video-processing-success-dev
AWS_SNS_FAILURE_TOPIC_ARN=arn:aws:sns:us-east-1:668309122622:vclipper-video-processing-failure-dev

# ===========================================
# Docker Configuration
# ===========================================
MOUNT_AWS_CREDENTIALS=/home/ubuntu/.aws
JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
ENVEOF

# Set proper ownership
chown ubuntu:ubuntu .env

# Run application
echo "#################### Running VClipper application ####################"
sudo -u ubuntu docker compose up -d --build
echo "VClipper application running on http://localhost:8080"
echo "Health check available at: http://localhost:8080/actuator/health"

# EOF
