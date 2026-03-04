#!/bin/bash

# Check for Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker and try again."
    exit 1
fi

# Check for Docker Compose
if ! command -v docker-compose &> /dev/null; then
    echo "Error: Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

echo "Cleaning up any conflicting containers..."
# Remove conflicting khoj-computer if it exists (it has a fixed name in docker-compose.yml)
docker rm -f khoj-computer &> /dev/null

echo "Starting Khoj deployment..."

# Run Docker Compose
docker-compose up -d --remove-orphans

if [ $? -eq 0 ]; then
    echo "Khoj has been deployed successfully!"
    echo "Access it at http://localhost:42110"
else
    echo "Error: Failed to deploy Khoj."
    exit 1
fi
