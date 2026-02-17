# Stage 1: Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /app

# Copy everything
COPY . ./

# Restore and publish only the Web project
RUN dotnet restore src/ApexERP.Web/ApexERP.Web.csproj
RUN dotnet publish src/ApexERP.Web/ApexERP.Web.csproj -c Release -o /out

# Stage 2: Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app

# Copy published output
COPY --from=build /out .

# Tell ASP.NET to listen on the Render-provided port
ENV ASPNETCORE_URLS=http://+:10000
ENV ASPNETCORE_ENVIRONMENT=Production

EXPOSE 10000

ENTRYPOINT ["dotnet", "ApexERP.Web.dll"]
