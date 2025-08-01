# Cloudflare Workers API with D1 Database

This project implements a simple REST API using Cloudflare Workers with D1 database integration. It provides endpoints for storing and retrieving data.

## Features

- GET `/items` - Retrieve all items from the database
- GET `/items/:id` - Retrieve a specific item by ID
- POST `/items` - Create a new item in the database

## Setup Instructions

### Prerequisites

- Node.js and npm installed
- Cloudflare account
- Wrangler CLI installed (`npm install -g wrangler`)
- Authenticated with Cloudflare (`wrangler login`)
- Docker and Docker Compose (for containerized deployment)

### Installation

1. Clone this repository
2. Install dependencies:
   ```
   npm install
   ```

### D1 Database Setup

1. Create a D1 database:
   ```
   wrangler d1 create cloudflare-d1-api-db
   ```

2. Update the `wrangler.toml` file with your database ID (replace the placeholder-id):
   ```toml
   [[d1_databases]]
   binding = "DB"
   database_name = "cloudflare-d1-api-db"
   database_id = "your-database-id-here"
   ```

### Development

Run the project locally:
```
npm run dev
```

### Deployment

Deploy to Cloudflare Workers:
```
npm run deploy
```

### Docker Deployment

#### Development Environment

1. Build and start the development container:
   ```
   docker-compose up cloudflare-api-dev --build
   ```

2. The API will be available at `http://localhost:8787` for local testing

#### Production Deployment

1. Create a `.env` file with your Cloudflare credentials (copy from `.env.example`):
   ```
   cp .env.example .env
   # Edit .env with your actual Cloudflare API token and account ID
   ```

2. Deploy to production using Docker:
   ```
   # For newer Docker versions (recommended)
   docker compose run --rm cloudflare-api-prod
   
   # For older Docker versions
   docker-compose run --rm cloudflare-api-prod
   ```

   This will build and deploy your Worker directly to Cloudflare's production environment.

3. Alternatively, you can use the deployment script (recommended):
   ```
   # Make sure the script is executable
   chmod +x deploy.sh
   
   # Run the deployment script
   npm run deploy:script
   # or directly with
   ./deploy.sh
   ```
   
   **Note:** With newer Docker versions, use `docker compose` (with a space) instead of `docker-compose` (with a hyphen)
   
   This script handles the entire deployment process including environment variable validation.
   
4. You can also use the individual npm scripts:
   ```
   # Build the production Docker image
   npm run docker:build
   
   # Deploy to production
   npm run docker:deploy
   ```

4. Your API will be available at the URL provided in the deployment output

## API Usage

### Get all items

```
GET /items
```

Response:
```json
{
  "success": true,
  "items": [
    {
      "id": 1,
      "name": "Example Item",
      "description": "This is an example item",
      "created_at": "2023-10-02T12:00:00.000Z"
    }
  ]
}
```

### Get item by ID

```
GET /items/1
```

Response:
```json
{
  "success": true,
  "item": {
    "id": 1,
    "name": "Example Item",
    "description": "This is an example item",
    "created_at": "2023-10-02T12:00:00.000Z"
  }
}
```

### Create a new item

```
POST /items
Content-Type: application/json

{
  "name": "New Item",
  "description": "This is a new item"
}
```

Response:
```json
{
  "success": true,
  "item": {
    "id": 2,
    "name": "New Item",
    "description": "This is a new item",
    "created_at": "2023-10-02T12:05:00.000Z"
  }
}
```
