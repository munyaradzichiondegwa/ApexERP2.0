# ---------- BUILD STAGE ----------
    FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
    WORKDIR /app
    
    # Copy project files first (better layer caching)
    COPY src/ApexERP.Web/*.csproj src/ApexERP.Web/
    RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj
    
    # Copy everything else
    COPY . .
    
    # Publish release build
    RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj \
        -c Release \
        -o /publish
    
    # ---------- RUNTIME STAGE ----------
    FROM nginx:alpine
    WORKDIR /usr/share/nginx/html
    
    # Remove default nginx static files
    RUN rm -rf ./*
    
    # Copy full published wwwroot content
    COPY --from=build /publish/wwwroot/ .
    
    # Copy custom nginx config for SPA routing
    COPY nginx.conf /etc/nginx/conf.d/default.conf
    
    EXPOSE 80
    
    CMD ["nginx", "-g", "daemon off;"]
    