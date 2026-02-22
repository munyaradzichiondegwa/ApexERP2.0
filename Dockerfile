# Use Nginx Alpine as base
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy Blazor publish output
COPY ./publish/wwwroot/ /usr/share/nginx/html/

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]