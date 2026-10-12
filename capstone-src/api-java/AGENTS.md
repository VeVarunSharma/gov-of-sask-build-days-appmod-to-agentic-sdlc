# Java API local guide

Agents should read the repository [root guide](../../AGENTS.md) plus this
nearest local guide; do not assume one file automatically overrides another.

## Scope map

- `pom.xml` defines the Java 21/Spring Boot API and its test dependencies.
- `src/main/java/dev/capstone/workitems/` contains HTTP, validation, CORS, and
  the thread-safe in-memory repository.
- `src/main/resources/application.properties` holds non-secret defaults.
- `src/test/` contains repository and HTTP application tests.
- The shared API shape is owned by
  [`../contracts/openapi.yml`](../contracts/openapi.yml).

## Work and validate

Use `capstone-src\api-java` as the working directory:

```powershell
.\mvnw.cmd -B -ntp clean verify
.\mvnw.cmd spring-boot:run
```

On macOS/Linux use `./mvnw`; CI may use installed `mvn -B -ntp test`. There is
no separate lint target, so `clean verify` is the local build-and-test gate.

## Boundaries

- Keep controllers thin, Bean Validation at the API boundary, and repository
  behavior deterministic. The in-memory data intentionally resets on restart.
- Do not edit generated `target/` content or commit logs, credentials, tokens,
  connection strings, production data, or participant data.
- Keep secrets out of `application.properties`. Configure `PORT` and
  comma-separated `CORS_ALLOWED_ORIGINS` through the environment; do not
  broaden CORS without an approved browser origin.

## More detail

Follow the [Java instructions](../../.github/instructions/java.instructions.md),
the [capstone starter guide](../README.md), and the
[React plus API pathway](../../labs/07-capstone/pathways/02-public-service-app.md).
Keep approved requirements under [specifications](../../specs/README.md).
Escalate shared-contract, React, deployment, or multi-root changes to the root
guide and read every affected local guide.
