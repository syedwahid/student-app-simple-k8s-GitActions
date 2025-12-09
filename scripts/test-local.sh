#!/bin/bash
echo "🧪 Testing Student App Locally"

# Test 1: Check files
echo "1. Checking files..."
if [ -f "src/package.json" ]; then
    echo "✅ src/package.json exists"
else
    echo "❌ src/package.json missing"
    exit 1
fi

if [ -f "src/student-app.js" ]; then
    echo "✅ src/student-app.js exists"
else
    echo "❌ src/student-app.js missing"
    exit 1
fi

# Test 2: Install dependencies
echo "2. Installing dependencies..."
cd src
npm install --no-audit --no-fund
if [ $? -eq 0 ]; then
    echo "✅ Dependencies installed"
else
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Test 3: Test Node.js app
echo "3. Testing Node.js app..."
timeout 5 node student-app.js &
APP_PID=$!
sleep 2
if curl -s http://localhost:9393/api/health > /dev/null; then
    echo "✅ Application is running"
    kill $APP_PID 2>/dev/null
else
    echo "❌ Application failed to start"
    kill $APP_PID 2>/dev/null
    exit 1
fi

# Test 4: Test Docker build
echo "4. Testing Docker build..."
cd ..
docker build -t student-app-test ./src
if [ $? -eq 0 ]; then
    echo "✅ Docker build successful"
else
    echo "❌ Docker build failed"
    exit 1
fi

echo ""
echo "🎉 All local tests passed!"
echo "Ready to push to GitHub for deployment."