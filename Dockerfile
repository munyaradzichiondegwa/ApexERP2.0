# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Install Python (required by wasm-tools for native compilation) + cleanup for smaller layers
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install wasm-tools early for better caching (before copying source)
RUN dotnet workload install wasm-tools

# Copy csproj/sln first for restore caching (NuGet deps don't change often)
COPY *.sln ./
COPY src/ApexERP.Web/*.csproj ./src/ApexERP.Web/
RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj

# Copy full source after restore
COPY . ./

# Publish the Blazor WebAssembly project (trimmed self-contained if enabled in csproj)
RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj -c Release -o /out --no-restore

# Serve stage using nginx
FROM nginx:alpine AS final

# Install gettext for env var substitution in nginx config
RUN apk add --no-cache gettext

# Copy the published static files (wwwroot) to nginx's document root
COPY --from=build /out/wwwroot /usr/share/nginx/html

# Create nginx config template (with ${PORT} placeholder)
RUN echo "server { \
    listen \${PORT:-10000}; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    try_files \$uri \$uri/ /index.html =404; \
    location / { \
        root /usr/share/nginx/html; \
        index index.html index.htm; \
        try_files \$uri \$uri/ =404; \
    } \
}" > /etc/nginx/conf.d/default.conf.template

# Create entrypoint script to substitute env vars and start nginx
RUN echo '#!/bin/sh \
    envsubst "\${PORT}" < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf \
    exec nginx -g "daemon off;"' > /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Render expects the container to listen on the PORT environment variable (usually 10000)
EXPOSE 10000

# Use entrypoint for dynamic config
ENTRYPOINT ["/docker-entrypoint.sh"]