<!-- markdownlint-disable MD013 -->

# Java modernization verification checklist

Use actual participant evidence. Do not mark a check passed from a prompt,
plan, or illustrative example.

## Contract, assessment, and technical plan

- [ ] `specs/java-asset-manager-modernization.md` was created with the Lab 01
      Plan-mode method and approved before modernization tooling ran.
- [ ] Baseline JDK, Maven, package result, and test result are recorded.
- [ ] The only accepted baseline error is the final-class
      `ResponseInputStream` mock error.
- [ ] Actual Modernize assessment files are preserved.
- [ ] Current-state claims cite repository evidence.
- [ ] Assessment evidence is reconciled with the durable specification and any
      linked optional ADR; any contract change was reapproved.
- [ ] The durable specification and any optional ADR contain no template
      placeholders.
- [ ] Target Spring Boot 3 patch and Azure dependency train are recorded.
- [ ] The generated Modernize plan is treated as a proposal and reconciled for
      scope, allowed paths, security, cost, validation, stop conditions,
      deployment boundaries, no-deployment behavior, and cleanup.
- [ ] The Upgrade agent is assigned only the reviewed runtime/framework phase.

## Implementation

- [ ] Parent reactor targets Java 21.
- [ ] Both modules build and test on JDK 21.
- [ ] The known upstream test was repaired or replaced, not disabled.
- [ ] Required old Java EE imports moved to Jakarta.
- [ ] Java SE `javax.imageio` remains unchanged.
- [ ] RabbitMQ dependencies, APIs, and configuration are absent.
- [ ] Service Bus settlement, retry, and dead-letter behavior are tested.
- [ ] AWS SDK imports and credentials are absent.
- [ ] Blob CRUD, content type, and thumbnail naming are tested.
- [ ] Azure PostgreSQL configuration has no application password.
- [ ] Managed identity principal and database grant owner are documented.
- [ ] Liveness and readiness endpoints work for web and worker.
- [ ] Two container images build and run as non-root.

## Deployment or blocker

- [ ] Resource group belongs to the participant and is tagged
      `workshop=appmod`.
- [ ] Only the web Container App has public ingress.
- [ ] Managed identity has least-privilege data-plane roles.
- [ ] Smoke test covers upload, view, thumbnail, metadata, queue drain, and
      delete.
- [ ] If deployment did not run, the blocker contains sanitized evidence and
      no pass claim.

## Cleanup

- [ ] Cleanup dry run lists only workshop resources.
- [ ] Exact-name confirmation was used.
- [ ] `az group wait --deleted` completed.
- [ ] `az group exists` returned `false`.

## Scope review

- [ ] No unrelated lab, .NET, workflow, or imported attribution file changed.
- [ ] No secret-like value appears in tracked files.
- [ ] `git diff --check` succeeds.
