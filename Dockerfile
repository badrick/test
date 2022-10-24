# Prepare base image with ASP.NET 6 runtime
FROM mcr.microsoft.com/dotnet/aspnet:6.0-bullseye-slim AS base
WORKDIR /app

# Prepare build image with .NET 6 SDK
FROM mcr.microsoft.com/dotnet/sdk:6.0-bullseye-slim AS build
WORKDIR /src

# Restore NuGet packages for all projects
COPY ["Test.sln", "."]
COPY ["Test/Test.csproj", "src/Test/"]
RUN dotnet restore

# Build and test all projects
COPY . .
RUN dotnet build -c Release -o /app/build
RUN dotnet test

# Publish Web project only
FROM build AS publish
ARG VERSION
RUN dotnet publish "src/Test/Test.csproj" -c Release -o /app/publish

# Build final image with output from publish
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Test.dll"]