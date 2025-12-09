#!/bin/bash
echo "🧹 Cleaning up..."

# Stop and remove Docker containers
echo "1. Cleaning Docker containers..."
docker stop student-app-test 2>/dev/null || true
docker rm student-app-test 2>/dev/null || true

# Remove Docker images
echo "2. Cleaning Docker images..."
docker rmi student-app:latest 2>/dev/null || true
docker rmi student-app-test 2>/dev/null || true

# Remove node_modules
echo "3. Cleaning node_modules..."
rm -rf src/node_modules 2>/dev/null || true

# Remove Terraform files
echo "4. Cleaning Terraform files..."
cd terraform
terraform destroy -auto-approve 2>/dev/null || true
rm -rf .terraform terraform.tfstate* 2>/dev/null || true
cd ..

echo "✅ Cleanup complete!"