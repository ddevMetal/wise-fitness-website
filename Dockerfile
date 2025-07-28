# Use the official Nginx image as the base image
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# Copy all HTML files to the Nginx web directory
COPY *.html /usr/share/nginx/html/

# Copy any static assets (handle if website file exists)
COPY . /tmp/staging/
RUN if [ -f /tmp/staging/website ]; then cp /tmp/staging/website /usr/share/nginx/html/; fi && \
    rm -rf /tmp/staging

# Copy the default nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chmod -R 755 /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/ || exit 1

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
