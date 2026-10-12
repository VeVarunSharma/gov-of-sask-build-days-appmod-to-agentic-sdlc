# Capstone greenfield starter

This starter gives teams a small, domain-neutral application to rename and
extend. The React client can use either API because both implement
[`contracts/openapi.yml`](contracts/openapi.yml). Data is held in memory and
resets whenever an API restarts.

Start with the
[capstone lab](../labs/07-capstone/README.md), especially the safety boundary,
specification, required evidence, and
[React plus API pathway](../labs/07-capstone/pathways/02-public-service-app.md).
The team selects the domain. Use visibly synthetic data and do not build
high-stakes eligibility or decision logic.

## Architecture

```text
web-react (React + TypeScript + Vite)
        |
        | HTTP JSON selected with VITE_API_BASE_URL
        v
api-java (Spring Boot, :8080)  OR  api-dotnet (ASP.NET Core, :8081)
        |
        v
thread-safe in-memory WorkItem repository
```

Both APIs expose:

- `GET /health`
- `GET|POST /api/work-items`
- `GET|PUT|DELETE /api/work-items/{id}`

`WorkItem` is deliberately generic: `id`, `title`, `description`, `status`,
`createdAt`, and `updatedAt`. Rename it to fit the capstone domain before
adding production infrastructure.

## Prerequisites

- Node.js 24+ and npm
- Java 21 (Maven is supplied through the wrapper)
- .NET SDK 10
- Docker (optional)

## Run with the Java API

From `capstone-src`:

```powershell
cd api-java
.\mvnw.cmd spring-boot:run
```

In another terminal:

```powershell
cd web-react
Copy-Item .env.example .env.local
npm ci --no-audit --no-fund
npm run dev
```

The default frontend setting points to Java at `http://localhost:8080`.

## Run with the .NET API

From `capstone-src`:

```powershell
dotnet run --project api-dotnet\src\WorkItems.Api
```

Create `web-react\.env.local` with:

```dotenv
VITE_API_BASE_URL=http://localhost:8081
```

Then run `npm ci --no-audit --no-fund` and `npm run dev` in `web-react`.

## Local configuration

| Project | Setting | Default |
| --- | --- | --- |
| React | `VITE_API_BASE_URL` | `http://localhost:8080` |
| Java | `PORT` | `8080` |
| Java | `CORS_ALLOWED_ORIGINS` | `http://localhost:5173` |
| .NET | `--urls` / `ASPNETCORE_URLS` | `http://localhost:8081` locally |
| .NET | `Cors__AllowedOrigins` | `http://localhost:5173` |

Comma-separate multiple allowed origins for either API.

## Test and build

```powershell
cd web-react
npm ci --no-audit --no-fund
npm run lint
npm test
npm run build

cd ..\api-java
.\mvnw.cmd -B -ntp clean verify

cd ..\api-dotnet
dotnet restore WorkItems.slnx
dotnet build WorkItems.slnx --configuration Release --no-restore --nologo
dotnet test WorkItems.slnx --configuration Release --no-build --nologo
```

Run only the selected API gate for participant completion. Repository
maintainers should run both API gates when changing the shared contract.

## Containers

Run from `capstone-src`:

```powershell
docker build -t capstone-java-api .\api-java
docker build -t capstone-dotnet-api .\api-dotnet
docker build --build-arg `
  VITE_API_BASE_URL=http://localhost:8080 `
  -t capstone-web .\web-react
```

The API images listen on port `8080`; the web image listens on port `80`.
Supply CORS and API URL values appropriate for the browser-visible host when
running containers.

## Project guides

- [React client](web-react/README.md)
- [Spring Boot API](api-java/README.md)
- [ASP.NET Core API](api-dotnet/README.md)

Do not commit `.env.local`, generated build output, dependency folders, or
deployment output.
