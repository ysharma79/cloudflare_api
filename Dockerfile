# Use Node.js 20 on Ubuntu (instead of Alpine) for better compatibility
FROM node:20

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json
COPY package.json package-lock.json* ./

# Install dependencies
RUN npm install

# Install Wrangler CLI globally
RUN npm install -g wrangler@latest

# Copy the rest of the application
COPY . .

# Create a deployment script that will be run at container startup
RUN echo '#!/bin/bash\n\
echo "Deploying to Cloudflare Workers..."\n\
if [ -z "$CLOUDFLARE_API_TOKEN" ] || [ -z "$CLOUDFLARE_ACCOUNT_ID" ]; then\n\
  echo "Error: Required environment variables CLOUDFLARE_API_TOKEN and CLOUDFLARE_ACCOUNT_ID must be set."\n\
  exit 1\n\
fi\n\
\n\
# Apply migrations first\n\
npx wrangler d1 migrations apply cloudflare-d1-api-db-production --env production\n\
\n\
# Then deploy the worker\n\
npx wrangler deploy --env production\n\
\n\
echo "Deployment completed successfully!"' > /app/deploy.sh \
    && chmod +x /app/deploy.sh

# Environment variables for Cloudflare authentication will be passed at runtime
# DO NOT set default values for sensitive information in the Dockerfile

# Default command - run the deployment script
CMD ["/app/deploy.sh"]
