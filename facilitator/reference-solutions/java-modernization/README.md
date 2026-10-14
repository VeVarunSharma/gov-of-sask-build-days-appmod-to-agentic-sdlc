<!-- markdownlint-disable MD013 -->

# Java modernization facilitator reference

This directory describes the expected **shape and evidence** of a successful
Java lab. It is not a replacement application tree and must not be copied over
a participant's work.

Participant instructions: [Java modernization lab](../../../labs/04-app-modernization/java/)

## How to use this reference

1. Ask the participant to explain the current checkpoint and show its evidence.
2. Compare behavior and validation, not exact generated code.
3. Use the recovery guidance only for the smallest blocked phase.
4. Do not claim that illustrative output came from Modernize or Azure.

## Verified imported baseline

Repository evidence:

| Observation | Evidence |
| --- | --- |
| Maven reactor | `legacy-src/java-asset-manager/pom.xml` includes `web` and `worker` |
| Runtime target | Parent POM sets Java 8 |
| Framework | Parent POM uses Spring Boot 2.7.18 |
| Web behavior | `web/.../controller/S3Controller.java` supports list, upload, view, and delete |
| Messaging | Web sends and both modules listen through Spring AMQP/RabbitMQ APIs |
| Storage | Web and worker use AWS SDK `S3Client`; both have local-file implementations |
| Metadata | Both modules use Spring Data JPA and PostgreSQL |
| Namespace work | Servlet, persistence, and annotation imports use old Java EE namespaces |
| Namespace exclusion | Image processing uses Java SE `javax.imageio`, which remains valid on Java 21 |
| Test inventory | Web has no tests; worker has one four-test class |

Author validation on 2026-10-10 used Microsoft OpenJDK 21.0.10 and Maven
3.9.9:

- `-DskipTests package` completed successfully.
- `test` discovered four worker tests.
- three tests completed;
- `downloadOriginalCopiesFileFromS3` errored because the baseline test attempts
  to mock final AWS SDK class `ResponseInputStream`.

This is characterization evidence, not a promise that every environment prints
the same log. The participant must capture their own result. A different
compile error or test failure is not an accepted baseline.

## Expected phase boundaries

| Phase | Allowed concerns | Required exit evidence |
| --- | --- | --- |
| Runtime/framework | Java, Spring Boot, Jakarta, build/test dependencies | JDK 21 reactor tests pass |
| Messaging | RabbitMQ to Service Bus | Message contract and settlement/dead-letter tests |
| Storage | S3 to Blob Storage | CRUD, content-type, and thumbnail-key tests |
| Database auth | Azure PostgreSQL password to managed identity | Azure profile has no password |
| Health | Actuator and probes | Liveness/readiness tests for both modules |
| Containers | Two Java 21 images | Non-root image inspection and startup configuration |
| Deployment | Bicep/azd and participant subscription | Smoke evidence or evidenced blocker |
| Cleanup | Dedicated tagged resource group | `az group exists` returns `false` |

Reject a big-bang diff that makes failures impossible to attribute.

## Acceptable design variation

Generated solutions do not need identical class names. They do need the
following contracts:

### Service Bus

- one externally configured queue;
- a stable serialized message meaning;
- explicit success settlement;
- bounded retry and dead-letter behavior;
- `DefaultAzureCredential` or compatible managed-identity integration in
  Azure; and
- no tracked connection string.

### Blob Storage

- original and thumbnail objects preserve key naming;
- content type survives upload and download;
- list, view, upload, and delete remain available;
- the worker can read originals and write thumbnails;
- local development remains possible; and
- no tracked account key or SAS token.

### PostgreSQL

- production uses Microsoft Entra authentication through the supported
  passwordless JDBC/Spring integration;
- application configuration does not contain a production password;
- the selected identity has an explicit database principal and grants;
- local credentials are isolated to local configuration; and
- both modules agree on schema ownership and migration behavior.

### Container Apps

- web and worker are separate apps;
- only web has external ingress;
- the worker's management port remains internal;
- health probes match actual ports and paths;
- least-privilege Blob and Service Bus data roles are assigned;
- image tags are traceable; and
- every resource is in the participant's dedicated tagged resource group.

## Illustrative assessment summary

The following is **illustrative**, not Modernize output:

> The application is a Java 8/Spring Boot 2.7 Maven reactor with two deployable
> modules. Framework modernization requires Java 21, Spring Boot 3-compatible
> dependencies, and targeted Jakarta namespace changes. Cloud modernization
> replaces RabbitMQ and AWS S3 integrations while preserving the asynchronous
> thumbnail workflow. Production authentication should use managed identity.

Facilitators must compare the participant's saved assessment to source
evidence. Never substitute the paragraph above for a failed assessment.

## Review questions

Ask the participant:

1. Which `javax` packages moved, and why did `javax.imageio` not move?
2. What event causes a Service Bus message to complete, retry, or dead-letter?
3. How is the `_thumbnail` key derived and tested?
4. Which identity connects to PostgreSQL, and who grants it database access?
5. Why can management-plane Contributor be insufficient for Blob data?
6. Which Container App is public?
7. What evidence proves cleanup finished rather than merely started?

## Reference artifacts

- [Illustrative decisions](illustrative-decisions.md)
- [Verification checklist](verification-checklist.md)
