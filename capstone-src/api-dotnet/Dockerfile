FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY WorkItems.slnx ./
COPY src/WorkItems.Api/WorkItems.Api.csproj src/WorkItems.Api/
COPY tests/WorkItems.Api.Tests/WorkItems.Api.Tests.csproj tests/WorkItems.Api.Tests/
RUN dotnet restore
COPY . .
RUN dotnet publish src/WorkItems.Api/WorkItems.Api.csproj -c Release -o /app --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "WorkItems.Api.dll"]
