<!-- markdownlint-disable MD013 -->

# Illustrative Java modernization decisions

These examples show decision quality. They are not generated tool output and
do not prescribe dependency patch versions.

## Runtime and framework

- **Decision:** target Java 21 and a compatible Spring Boot 3.x patch selected
  by the installed upgrade tooling.
- **Reason:** Java 21 is the workshop target; Spring Boot 3 requires Java 17 or
  later and Jakarta APIs.
- **Constraint:** record the exact patch and dependency train in the accepted
  plan before execution.
- **Revisit signal:** a required library has no supported combination with the
  selected patch.

## Namespace migration

- **Decision:** move Servlet, Persistence, and Annotation APIs from `javax` to
  `jakarta`.
- **Exclusion:** keep Java SE `javax.imageio`.
- **Validation:** source search plus a clean reactor build and tests.

## Messaging

- **Decision:** replace RabbitMQ with one Azure Service Bus queue while
  preserving the image-processing message meaning.
- **Success:** settle only after thumbnail generation and metadata update
  complete.
- **Failure:** bounded retries followed by dead-lettering with a diagnosable
  reason.
- **Authentication:** managed identity in Azure; local development uses an
  explicitly local configuration.

## Storage

- **Decision:** replace S3 with Azure Blob Storage.
- **Compatibility:** preserve original object keys, content types, and the
  `_thumbnail` suffix.
- **Authentication:** managed identity in Azure.
- **Rollback:** provider changes remain isolated behind the storage
  abstraction until verification completes.

## PostgreSQL authentication

- **Decision:** use a user-assigned managed identity shared by web and worker
  when a stable database principal is required.
- **Reason:** the database principal remains stable across Container App
  revisions and can receive explicit grants.
- **Trade-off:** lifecycle and role assignment of the identity must be managed.
- **Local development:** local-only credentials may be supplied through
  ignored environment configuration.

## Health and deployment

- **Decision:** expose minimal Actuator liveness and readiness endpoints for
  both processes.
- **Deployment:** two Container Apps in one environment; web has external
  ingress, worker does not.
- **Safety:** deploy only into an exact participant-owned resource group tagged
  `workshop=appmod`.
- **Completion alternative:** if deployment is blocked, validate code,
  containers, and infrastructure statically, record the blocker, and verify
  that no Azure resource group remains.
