<!-- markdownlint-disable MD013 -->

# Java modernization recovery

Use these procedures only after identifying the last verified checkpoint in
the [participant lab](../../../labs/04-app-modernization/java/). Recovery
should preserve participant work and apply the smallest correction possible.
Do not replace the application with a prepared tree.

## Recovery rules

1. Save the current diff before restoring anything.
2. Identify the first failed checkpoint, not the latest visible symptom.
3. Restore only files owned by that phase.
4. Re-run the phase's narrow check, then the reactor check.
5. Never recover by adding credentials or disabling tests.

## Capture the current state

From the monorepo root:

```powershell
git status --short
git diff -- legacy-src\java-asset-manager `
  specs\work\java-modernization > java-recovery.diff
git rev-parse HEAD
```

```bash
git status --short
git diff -- legacy-src/java-asset-manager \
  specs/work/java-modernization > java-recovery.diff
git rev-parse HEAD
```

`java-recovery.diff` is local recovery evidence. Review it for secrets before
sharing it.

## Checkpoint map

| Checkpoint | Expected state | First recovery action |
| --- | --- | --- |
| A | Baseline characterized; package succeeds | Compare imported baseline with `README.local.md` |
| B | Assessment saved; no app edits | Re-run `modernize assess` with explicit source/output |
| C | Durable spec and recorded decisions reconciled | Restore the approved spec, then reapply evidence-backed decisions in the spec or linked optional ADR and reapprove contract changes |
| D | Generated technical plan reconciled | Compare the proposal with the durable spec; split big-bang tasks and restore missing scope, path, security, cost, validation, stop, deployment, and cleanup gates |
| E | Java 21/Spring Boot 3 tests pass | Use upgrade agent only on runtime/framework diff |
| F | Service Bus phase passes | Revert messaging-only files and reapply focused prompt |
| G | Blob phase passes | Revert storage-only files and reapply focused prompt |
| H | Managed-identity database config passes | Remove Azure password fallback; fix identity config |
| I | Health endpoints pass | Align actual ports, paths, and health groups |
| J | Local gate and images pass | Fix the first failing row in the verification table |

## Restore a phase safely

If the participant committed checkpoints:

```powershell
git --no-pager log --oneline --decorate -12
git --no-pager diff <good-checkpoint>..HEAD -- legacy-src\java-asset-manager
```

Create a recovery branch before selective restore:

```powershell
git switch -c recovery/java-<phase>
git restore --source <good-checkpoint> -- <phase-owned-paths>
```

Do not run `git reset --hard` in a shared workshop checkout.

If checkpoints were not committed, save `java-recovery.diff`, then use the
GitHub Copilot app's diff viewer to revert only the files from the failed
phase.

## Focused recovery prompts

### Runtime/framework mixed with cloud migrations

```text
Review the current diff under legacy-src/java-asset-manager. Keep only changes
required for Java 21, Spring Boot 3.x, compatible build/test dependencies, and
the required Jakarta namespaces. Revert storage, messaging, database,
container, and infrastructure changes. Preserve Java SE javax.imageio. Do not
edit outside this application. Run the reactor tests.
```

### RabbitMQ removal broke the message contract

```text
Repair only the messaging phase. Derive the previous
ImageProcessingMessage contract from git history, preserve its JSON meaning,
and adapt producer and consumer to Azure Service Bus. Add tests for
serialization, successful settlement, retry, and dead-letter behavior. Do not
change storage or database code.
```

### Blob migration changed key behavior

```text
Repair only the storage phase. Restore the previous external behavior for
upload, list, view, delete, content type, and the _thumbnail key convention,
then implement those behaviors through Azure Blob Storage with
DefaultAzureCredential. Preserve local-file development and add behavior
tests. Do not change messaging or database code.
```

### Database migration added a password fallback

```text
Remove production PostgreSQL password authentication from the Azure profile.
Use the supported managed-identity/passwordless JDBC integration for the
selected Spring Boot and Spring Cloud Azure versions. Keep local credentials
only in a clearly local profile supplied through environment variables. Add a
test that the Azure profile has no password property.
```

### Worker probe fails

```text
Inspect only worker Actuator and container settings. Align the internal
management HTTP port, liveness/readiness paths, Docker exposed port, and
Container Apps probes. Keep the worker without public ingress. Do not make an
optional dependency permanently fail readiness.
```

## Known baseline test recovery

See [known-upstream-test.md](known-upstream-test.md). The correct recovery is a
behavior-valid test seam or real stream, not `@Disabled`, test deletion, or
globally skipping tests.

## Azure partial-deployment recovery

1. Stop retrying `azd up`.
2. Capture a sanitized error and list the exact resource group.
3. Run the shared cleanup script in dry-run mode.
4. Verify that every listed resource belongs to the participant.
5. Delete with the exact confirmation value.
6. Wait for deletion and require `az group exists` to return `false`.
7. Continue through the no-deployment completion path.

Do not hand-delete individual resources first; dependencies can make the
remaining state harder to reason about.

## Escalate instead of patching when

- a requested role assignment exceeds the lab's least-privilege design;
- an agent proposes a storage key, Service Bus connection string, or database
  password as the Azure fix;
- deployment resolves to the wrong subscription or resource group;
- a data/schema migration could destroy participant data;
- the target Spring Boot release is incompatible with a required dependency;
  or
- the failure differs from the documented baseline and cannot be reproduced.
