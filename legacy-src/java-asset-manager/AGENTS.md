# Java Asset Manager local guide

Agents should read the repository [root guide](../../AGENTS.md) plus this
nearest local guide; do not assume one file automatically overrides another.

## Scope map

- `pom.xml` is the Java 8/Spring Boot 2.7 reactor entry point.
- `web/` owns the MVC upload, storage, metadata, and messaging flow.
- `worker/` consumes image-processing messages and creates thumbnails.
- `scripts/` contains local and Azure lifecycle helpers; `doc-media/` and the
  imported READMEs are workshop source material.

## Work and validate

Use `legacy-src\java-asset-manager` as the working directory:

```powershell
.\mvnw.cmd -B -ntp -DskipTests package
.\mvnw.cmd -B -ntp test
```

On macOS/Linux use `./mvnw` with the same arguments. There is no separate lint
target. Packaging is the build gate; the test command characterizes a known
upstream defect: one worker test cannot mock final
`software.amazon.awssdk.core.ResponseInputStream`. Do not report a full test
pass; only accept that exact error with the other three worker tests passing.

## Boundaries

- Preserve imported provenance, licenses, Java/framework versions, and
  unrelated behavior unless an approved modernization specification says
  otherwise. Keep `web` and `worker` responsibilities separate.
- Do not edit generated `target/` content or commit logs, environment files,
  credentials, access keys, tokens, connection strings, or real data.
- Keep secrets out of both modules' `application.properties`. Local service
  passwords stay local; Azure deployment or cleanup requires explicit scope,
  permissions, cost approval, and observed cleanup.

## More detail

Follow the [Java instructions](../../.github/instructions/java.instructions.md)
and, for deployment scripts, the
[infrastructure instructions](../../.github/instructions/infrastructure.instructions.md).
Start with the [Java modernization lab](../../labs/04-app-modernization/java/README.md)
and keep approved evidence under the locations it defines using the
[specification guidance](../../specs/README.md). Escalate shared contracts,
automation, or changes outside this imported root to the root guide.
