FROM node:20-alpine

WORKDIR /app

# Install Wrangler CLI globally
RUN npm install -g wrangler

# Copy package.json and package-lock.json
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Copy the rest of the application
COPY . .

# Set environment variables for Cloudflare authentication
# These will be provided at runtime via Docker environment variables
ENV CLOUDFLARE_API_TOKEN=""
ENV CLOUDFLARE_ACCOUNT_ID=""

# Default command - can be overridden at runtime
CMD ["npm", "run", "deploy:production"]
