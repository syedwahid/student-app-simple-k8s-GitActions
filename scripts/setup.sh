#!/bin/bash
echo "=== Local Student App Setup ==="

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker."
    exit 1
fi

echo "1. Installing dependencies..."
cd src
npm ci

echo "2. Building Docker image..."
docker build -t student-app:latest .

echo "3. Starting container..."
docker run -d --name student-app -p 9393:9393 student-app:latest

echo "✅ Application is running at http://localhost:9393"
echo "✅ Health check: curl http://localhost:9393/api/health"
echo "✅ To stop: docker stop student-app && docker rm student-app"