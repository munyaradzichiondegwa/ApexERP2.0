# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Install Python (required by wasm-tools for native compilation)
RUN apt-get update && apt-get install -y python3 && ln -s /usr/bin/python3 /usr/bin/python

# Copy everything
COPY . ./

# Install wasm-tools for size optimization
RUN dotnet workload install wasm-tools

# Restore and publish the Blazor WebAssembly project
RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj
RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj -c Release -o /out

# Serve stage using nginx
FROM nginx:alpine AS final
# Copy the published static files (wwwroot) to nginx's document root
COPY --from=build /out/wwwroot /usr/share/nginx/html

# Render expects the container to listen on the PORT environment variable (usually 10000)
# Create an nginx config that listens on that port and supports SPA routing
RUN echo "server { \
    listen \${PORT:-10000}; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    try_files \$uri \$uri/ /index.html =404; \
}" > /etc/nginx/conf.d/default.conf

EXPOSE 10000

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]