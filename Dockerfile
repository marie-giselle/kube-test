#See https://aka.ms/customizecontainer to learn how to customize your debug container and how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app

RUN apt-get update \
    && apt-get install -y curl jq 

EXPOSE 8000

ENV ASPNETCORE_ENVIRONMENT=Development

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["Health.csproj", "."]
RUN dotnet restore "./Health.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Health.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Health.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:8000
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Health.dll"]