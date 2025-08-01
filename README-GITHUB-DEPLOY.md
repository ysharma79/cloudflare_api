# Deploying Cloudflare Workers API Directly from GitHub

This guide explains how to set up continuous deployment from GitHub to Cloudflare Workers for your D1 API project.

## Setup Process

### 1. Push Your Code to GitHub

```bash
# Initialize Git repository (if not already done)
git init

# Add all files
git add .

# Commit changes
git commit -m "Initial commit"

# Add GitHub remote (replace with your repository URL)
git remote add origin https://github.com/yourusername/your-repo-name.git

# Push to GitHub
git push -u origin main
```

### 2. Set Up GitHub Secrets

In your GitHub repository:
1. Go to **Settings** > **Secrets and variables** > **Actions**
2. Add the following secrets:
   - `CLOUDFLARE_API_TOKEN`: Your Cloudflare API token
   - `CLOUDFLARE_ACCOUNT_ID`: Your Cloudflare account ID

### 3. GitHub Actions Workflow

A GitHub Actions workflow file has been created at `.github/workflows/deploy.yml`. This workflow:
- Runs when you push to the main branch
- Sets up Node.js v20
- Installs dependencies
- Deploys to Cloudflare Workers using the official Cloudflare Wrangler action

### 4. D1 Database Migrations

For D1 database migrations, you have two options:

#### Option 1: Automatic migrations during deployment
Add this step to your GitHub Actions workflow:

```yaml
- name: Apply D1 migrations
  uses: cloudflare/wrangler-action@v3
  with:
    apiToken: ${{ secrets.CLOUDFLARE_API_TOKEN }}
    accountId: ${{ secrets.CLOUDFLARE_ACCOUNT_ID }}
    command: d1 migrations apply cloudflare-d1-api-db-production --env production
```

#### Option 2: Manual migrations via Cloudflare Dashboard
1. Go to **Cloudflare Dashboard** > **Workers & Pages** > **D1**
2. Select your database
3. Go to the **Migrations** tab
4. Apply pending migrations

## Alternative: Direct Integration with Cloudflare Pages

For an even more streamlined approach:

1. **Log in to Cloudflare Dashboard**
   - Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
   - Navigate to "Workers & Pages"

2. **Create a New Pages Project**
   - Click "Create application"
   - Select "Pages"
   - Click "Connect to Git"

3. **Connect Your GitHub Account**
   - Authorize Cloudflare to access your GitHub repositories
   - Select your repository from the list

4. **Configure Build Settings**
   - **Framework preset**: None
   - **Build command**: `npm install`
   - **Build output directory**: Leave blank (deploy entire project)

5. **Environment Variables**
   - Add your environment variables in the Cloudflare dashboard

6. **Advanced Settings**
   - Enable "D1 Database Bindings"
   - Add your D1 database binding with variable name `DB`

## Benefits of GitHub-to-Cloudflare Deployment

- **Automated Deployments**: Changes are automatically deployed when you push to GitHub
- **Version Control**: Full history of deployments tied to commits
- **Collaboration**: Multiple team members can contribute without needing Wrangler setup
- **Preview Deployments**: Automatically create preview environments for pull requests
- **Rollbacks**: Easily roll back to previous versions if needed

## Monitoring and Troubleshooting

- View deployment logs in GitHub Actions or Cloudflare Dashboard
- Monitor your Worker's performance in the Cloudflare Dashboard
- Check D1 database queries and performance in the D1 section of the dashboard
