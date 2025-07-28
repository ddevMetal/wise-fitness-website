# Wise Fitness Website

This repository contains a static website for the Wise Fitness platform, configured for deployment on Render using Docker with Firebase integration.

## 🚀 Features

- **Static Website**: HTML-based fitness platform
- **Firebase Integration**: User authentication and data storage
- **Docker Deployment**: Optimized for Render hosting
- **Security**: HTTPS, security headers, and CSP configured
- **Performance**: Nginx with gzip compression and caching

## 📁 Files Overview

- `Dockerfile` - Docker image using Nginx to serve static files
- `nginx.conf` - Nginx configuration with Firebase support and security
- `render.yaml` - Render deployment configuration
- `firebase-config.js` - Centralized Firebase configuration
- `.dockerignore` - Excludes unnecessary files from Docker builds
- `*.html` - Website HTML pages

## 🔥 Firebase Configuration

The website uses Firebase for:
- **Authentication**: User login/signup
- **Firestore**: Data storage
- **Hosting**: Static content delivery

Firebase configuration is centralized in `firebase-config.js` for maintainability.

## 💻 Local Development

To run the website locally using Docker:

```bash
# Build the Docker image
docker build -t wise-fitness-website .

# Run the container
docker run -p 8080:80 wise-fitness-website
```

Then visit `http://localhost:8080` in your browser.

## 🚀 Deployment on Render

1. **Connect Repository**: Connect this GitHub repository to Render
2. **Auto-Deploy**: Render will automatically detect `render.yaml` and deploy
3. **Firebase**: Ensure Firebase project is properly configured and accessible
4. **Domain**: Access your website on the provided Render URL

### Render Configuration

The `render.yaml` includes:
- ✅ Docker-based deployment
- ✅ Health checks
- ✅ Auto-deploy on main branch
- ✅ Production environment variables

## 🔧 Technical Features

- ✅ Nginx web server for optimal performance
- ✅ Gzip compression enabled
- ✅ Security headers configured (CSP, HSTS, etc.)
- ✅ Firebase-compatible Content Security Policy
- ✅ Error page handling
- ✅ SPA routing support (falls back to index.html)
- ✅ Rate limiting protection
- ✅ Health check endpoint (/health)

## 📱 Website Pages

- `index.html` - Main landing page
- `Login.html` - User login page  
- `Signup.html` - User registration page
- `BusinessUser.html` - Business user dashboard
- `BusinessUserSignup.html` - Business user registration
- `SystemAdmin.html` - Admin dashboard
- `Events.html` - Events management
- `Posts.html` - Posts management
- `Services.html` - Services page
- `Leaderboard.html` - User leaderboard

## 🔒 Security

- Content Security Policy configured for Firebase
- Security headers enabled
- Rate limiting implemented
- HTTPS enforcement ready

## 🐛 Troubleshooting

- **Firebase Connection Issues**: Check network connectivity and API keys
- **Deploy Failures**: Check Render logs for Docker build errors
- **Performance Issues**: Monitor Nginx access logs
- `Events.html` - Events listing
- `Services.html` - Services page
- `Posts.html` - Posts/Blog page
- `Leaderboard.html` - Leaderboard page
- `ManageBusiness.html` - Business management
- `ManageUsers.html` - User management
- `ManageLandingPage.html` - Landing page management
- `PendingApplications.html` - Applications management
