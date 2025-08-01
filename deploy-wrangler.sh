#!/bin/bash

# Cloudflare Workers API with D1 Database - Direct Wrangler Deployment Script
# This script handles deployment directly using Wrangler CLI

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

# Check if Wrangler is installed
if ! command -v wrangler &> /dev/null; then
  echo "Wrangler CLI not found. Installing globally..."
  npm install -g wrangler
fi

# Set environment variables for Wrangler
export CLOUDFLARE_API_TOKEN
export CLOUDFLARE_ACCOUNT_ID

echo "Deploying to Cloudflare Workers production environment..."

# Deploy to production
wrangler deploy --env production

if [ $? -ne 0 ]; then
  echo "Error: Deployment failed!"
  exit 1
fi

echo "=== Deployment completed successfully! ==="
echo "Your API is now live on Cloudflare Workers."
