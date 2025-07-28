# FYP Website Docker Deployment

This repository contains a static website for the FYP project, configured for deployment on Render using Docker.

## Files Overview

- `Dockerfile` - Defines the Docker image using Nginx to serve static files
- `nginx.conf` - Nginx configuration with optimizations and security headers
- `render.yaml` - Render deployment configuration
- `.dockerignore` - Excludes unnecessary files from Docker builds
- `*.html` - Website HTML pages

## Local Development

To run the website locally using Docker:

```bash
# Build the Docker image
docker build -t fyp-website .

# Run the container
docker run -p 8080:80 fyp-website
```

Then visit `http://localhost:8080` in your browser.

## Deployment on Render

1. Push your code to a Git repository (GitHub, GitLab, etc.)
2. Connect your repository to Render
3. Render will automatically detect the `render.yaml` file and deploy using Docker
4. The website will be served on the provided Render URL

## Features

- ✅ Nginx web server for optimal performance
- ✅ Gzip compression enabled
- ✅ Security headers configured
- ✅ Error page handling
- ✅ SPA routing support (falls back to index.html)
- ✅ Optimized for static content delivery

## Website Pages

- `index.html` - Main landing page
- `Login.html` - User login page
- `Signup.html` - User registration page
- `BusinessUser.html` - Business user dashboard
- `BusinessUserSignup.html` - Business user registration
- `SystemAdmin.html` - Admin dashboard
- `Events.html` - Events listing
- `Services.html` - Services page
- `Posts.html` - Posts/Blog page
- `Leaderboard.html` - Leaderboard page
- `ManageBusiness.html` - Business management
- `ManageUsers.html` - User management
- `ManageLandingPage.html` - Landing page management
- `PendingApplications.html` - Applications management
