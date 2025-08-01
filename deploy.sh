#!/bin/bash

# Cloudflare Workers API with D1 Database - Production Deployment Script
# This script handles the Docker-based deployment to Cloudflare Workers

# Check if .env file exists
if [ ! -f .env ]; then
  echo "Error: .env file not found!"
  echo "Please create a .env file with your Cloudflare credentials."
  echo "You can copy the template from .env.example"
  exit 1
fi

# Load environment variables
source .env

# Check if required environment variables are set
if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then
  echo "Error: Required environment variables not set!"
  echo "Please make sure CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID are set in your .env file."
  exit 1
fi

echo "=== Starting Cloudflare Workers API Production Deployment ==="
echo "Building and deploying with Docker..."

# Check if docker command is available
if ! command -v docker &> /dev/null; then
  echo "Error: Docker is not installed or not in your PATH!"
  exit 1
fi

# Check which Docker Compose command to use
if docker compose version &> /dev/null; then
  # New Docker Compose syntax
  echo "Using new Docker Compose syntax (docker compose)..."
  echo "Building Docker image with no cache..."
  docker compose build --no-cache cloudflare-api-prod
  echo "Running deployment..."
  docker compose run --rm cloudflare-api-prod
else
  # Try old Docker Compose syntax
  if docker-compose --version &> /dev/null; then
    echo "Using old Docker Compose syntax (docker-compose)..."
    echo "Building Docker image with no cache..."
    docker-compose build --no-cache cloudflare-api-prod
    echo "Running deployment..."
    docker-compose run --rm cloudflare-api-prod
  else
    echo "Docker Compose not found. Falling back to direct Docker commands..."
    # Build the Docker image
    docker build -t cloudflare-d1-api-production .
    
    if [ $? -ne 0 ]; then
      echo "Error: Docker build failed!"
      exit 1
    fi
    
    echo "Docker image built successfully."
    echo "Deploying to Cloudflare Workers..."
    
    # Run the Docker container to deploy to Cloudflare
    docker run --rm \
      -e CLOUDFLARE_API_TOKEN="$CLOUDFLARE_API_TOKEN" \
      -e CLOUDFLARE_ACCOUNT_ID="$CLOUDFLARE_ACCOUNT_ID" \
      cloudflare-d1-api-production
  fi
fi

if [ $? -ne 0 ]; then
  echo "Error: Deployment failed!"
  exit 1
fi

echo "=== Deployment completed successfully! ==="
echo "Your API is now live on Cloudflare Workers."
