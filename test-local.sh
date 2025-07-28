#!/bin/bash

# Test script for local Docker development
# Run this script to build and test the website locally

echo "🚀 Building Wise Fitness Website..."

# Build the Docker image
if ! docker build -t wise-fitness-website .; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Docker image built successfully!"

# Run the container
echo "🌐 Starting container on port 8080..."
docker run -d -p 8080:80 --name wise-fitness-test wise-fitness-website

echo "🎉 Website is running at: http://localhost:8080"
echo "🔍 To view logs: docker logs wise-fitness-test"
echo "🛑 To stop: docker stop wise-fitness-test && docker rm wise-fitness-test"

# Test health check
sleep 5
if curl -f http://localhost:8080/health > /dev/null 2>&1; then
    echo "✅ Health check passed!"
else
    echo "⚠️  Health check failed - check the logs"
fi
