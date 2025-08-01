FROM node:20-alpine

WORKDIR /app

# Install necessary build tools and dependencies
RUN apk add --no-cache python3 make g++ curl

# Install Wrangler CLI globally with platform-specific binaries
RUN npm install -g wrangler

# Copy package.json and package-lock.json
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Environment variables for Cloudflare authentication will be passed at runtime
# DO NOT set default values for sensitive information in the Dockerfile

# Default command - can be overridden at runtime
CMD ["npm", "run", "deploy:production"]
