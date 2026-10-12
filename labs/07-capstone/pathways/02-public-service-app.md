# Pathway B: Build a polished public-service app

Turn the domain-neutral starter in [`capstone-src`](../../../capstone-src/) into
a Government of Saskatchewan-relevant prototype. Use the React client plus
exactly one API: Spring Boot **or** ASP.NET Core.

The team selects the domain. Keep it informational or operational rather than
making a high-stakes decision. Use synthetic records that are visibly fictional.

## Suggested low-risk shapes

- provincial facility maintenance or inspection follow-up board;
- park amenity inventory and update queue;
- non-emergency road-work communication planner;
- public website content review tracker; or
- internal application modernization action register.

Do not build benefits, justice, health, tax, licensing, employment, or
enforcement eligibility scoring. Do not imply that a prototype is an official
Government of Saskatchewan service.

## Starter contract

Both APIs implement
[`capstone-src/contracts/openapi.yml`](../../../capstone-src/contracts/openapi.yml)
and expose:

- `GET /health`;
- `GET|POST /api/work-items`; and
- `GET|PUT|DELETE /api/work-items/{id}`.

Data is in memory and resets when the API restarts. Rename `WorkItem` only when
you update the contract, selected API, React client, and tests together. Do not
modify both APIs unless cross-implementation parity is itself an accepted
deliverable.

## Build the demo slice

1. Choose one direct user and one three-minute journey.
2. Define domain language, synthetic example data, empty/error states, and
   accessibility expectations in the capstone specification.
3. Select Java on port `8080` or .NET on port `8081`.
4. Adapt the React client without embedding environment-specific URLs.
5. Preserve server-side validation; client validation is an additional user
   experience, not the security boundary.
6. Add tests for the happy path and at least one rejected or missing case.
7. Verify responsive layout, keyboard use, visible focus, form labels, status
   announcements, understandable errors, and color contrast.

## Challenge choices

### Beginner

- Rename the experience and domain labels without breaking the API contract.
- Polish list, create, update, delete, loading, empty, and error states.
- Add one React test and one selected-API test.

### Intermediate

- Evolve the contract with one domain field and consistent validation.
- Add filtering, status summaries, accessible confirmation, or optimistic
  feedback with a safe failure path.
- Build both selected containers and document local configuration.

### Advanced

- Add approved persistence, identity, audit, observability, or resilience
  boundaries without using real data.
- Add contract tests and a reviewed Azure deployment plan.
- Integrate a bounded `gh-aw` quality or release-readiness workflow.

## Run locally

For Java, start from `capstone-src`:

```powershell
cd api-java
.\mvnw.cmd spring-boot:run
```

In a second terminal from the repository root:

```powershell
cd capstone-src\web-react
Copy-Item .env.example .env.local
npm ci --no-audit --no-fund
npm run dev
```

For .NET, start from the repository root:

```powershell
dotnet run --project capstone-src\api-dotnet\src\WorkItems.Api
```

Set the React API URL for .NET:

```powershell
Set-Content capstone-src\web-react\.env.local `
  'VITE_API_BASE_URL=http://localhost:8081'
cd capstone-src\web-react
npm ci --no-audit --no-fund
npm run dev
```

The React development server uses `http://localhost:5173`. The starter APIs
allow that origin by default.

## Required validation

Run the React gate:

```powershell
cd capstone-src\web-react
npm ci --no-audit --no-fund
npm run lint
npm test
npm run build
```

Then run exactly one API gate.

Java:

```powershell
cd capstone-src\api-java
.\mvnw.cmd -B -ntp clean verify
```

.NET:

```powershell
cd capstone-src\api-dotnet
dotnet restore WorkItems.slnx
dotnet build WorkItems.slnx --configuration Release --no-restore --nologo
dotnet test WorkItems.slnx --configuration Release --no-build --nologo
```

Finally, run the app and verify `/health`, the accepted journey, a rejected
input, a missing record, and restart behavior. Because the starter is in
memory, reset-on-restart is expected unless persistence is an approved
deliverable.

## Optional containers and Azure

Use the tested container commands in the
[`capstone-src` guide](../../../capstone-src/README.md). An Azure deployment is
optional and requires reviewed infrastructure, exact scope, cost approval,
synthetic data, and proven cleanup. The starter does not include production
authentication or production-ready persistence; deployment does not change
that fact.
