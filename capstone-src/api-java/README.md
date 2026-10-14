# Work items Spring Boot API

Java 21 and Spring Boot API for the capstone starter. It implements the shared
[`OpenAPI contract`](../contracts/openapi.yml) with an in-memory repository.
Data resets when the process restarts.

Run from `capstone-src\api-java`:

```powershell
.\mvnw.cmd spring-boot:run
```

Validate:

```powershell
.\mvnw.cmd -B -ntp clean verify
```

The API listens on `http://localhost:8080` by default. Override the port with
`PORT` and allowed browser origins with comma-separated
`CORS_ALLOWED_ORIGINS`. Keep server-side validation and update the contract,
React client, and tests when changing the resource shape.

See the parent [capstone starter guide](../README.md) for safety, container, and
cross-project instructions.
