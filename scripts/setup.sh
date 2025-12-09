#!/bin/bash
echo "=== Student App Setup ==="

# Build Docker image
echo "1. Building Docker image..."
docker build -t student-app:latest ./src

# Run container
echo "2. Starting container..."
docker run -d --name student-app -p 9393:9393 student-app:latest

echo "✅ Application is running at http://localhost:9393"
echo "✅ Health check: curl http://localhost:9393/api/health"