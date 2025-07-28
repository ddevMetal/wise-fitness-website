# Use the official Nginx image as the base image
FROM nginx:alpine

# Copy all HTML files to the Nginx web directory
COPY *.html /usr/share/nginx/html/

# Copy the default nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 80
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]
