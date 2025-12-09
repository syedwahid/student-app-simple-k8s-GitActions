#!/bin/bash
echo "=== Setting up Student App VM ==="

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y docker.io docker-compose
systemctl enable docker
systemctl start docker

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt-get install -y nodejs

# Create app directory
mkdir -p /opt/student-app
cd /opt/student-app

echo "✅ VM setup complete!"