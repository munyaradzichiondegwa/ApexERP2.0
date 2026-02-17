# ---------- BUILD STAGE ----------
    FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
    WORKDIR /app
    
    # Copy everything
    COPY . .
    
    # Restore and publish
    RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj
    RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj -c Release -o /publish
    
    # ---------- RUNTIME STAGE ----------
    FROM nginx:alpine
    WORKDIR /usr/share/nginx/html
    
    # Copy published Blazor output
    COPY --from=build /publish/wwwroot .
    
    # Expose port
    EXPOSE 80
    
    CMD ["nginx", "-g", "daemon off;"]
    