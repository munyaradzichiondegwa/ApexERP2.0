# ---------- BUILD STAGE ----------
    FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
    WORKDIR /app
    
    # Restore dependencies (caching)
    COPY src/ApexERP.Web/*.csproj src/ApexERP.Web/
    RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj
    
    # Copy all source and publish
    COPY . .
    RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj -c Release -o /publish
    
    # ---------- RUNTIME STAGE ----------
    FROM nginx:alpine
    # Remove default nginx files
    RUN rm -rf /usr/share/nginx/html/*
    
    # Copy the entire wwwroot folder from the publish output
    COPY --from=build /publish/wwwroot/ /usr/share/nginx/html/
    
    # Copy your custom nginx config
    COPY nginx.conf /etc/nginx/conf.d/default.conf
    
    EXPOSE 80
    CMD ["nginx", "-g", "daemon off;"]