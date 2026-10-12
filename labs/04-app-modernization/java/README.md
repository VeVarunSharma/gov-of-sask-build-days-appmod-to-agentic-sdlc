<!-- markdownlint-disable MD013 -->

# Lab 04: Modernize the Java Asset Manager

Modernize the imported two-module Asset Manager from Java 8 and Spring Boot
2.7 to Java 21 and Spring Boot 3, replace its external services with Azure
managed services, containerize both processes, and optionally deploy them to
Azure Container Apps in your own subscription.

| Lab detail | Value |
| --- | --- |
| Track | Java |
| Source | `legacy-src/java-asset-manager` |
| Suggested time | 90-120 minutes; deployment adds 20-40 minutes |
| Starting point | Imported baseline at the commit shown in `README.local.md` |
| Completion | Verified modernization, with either deployment evidence or a documented deployment blocker |

This lab extends the contract-first workflow from
[Lab 01](../../01-spec-driven-development/README.md):

> **Specify and approve -> Assess -> Create and reconcile plan -> Execute -> Verify**

GitHub Copilot Plan mode and the human-approved durable specification define
intent, constraints, acceptance criteria, allowed paths, validation, and stop
conditions. `modernize assess` then adds repository evidence.
`modernize plan create` proposes the specialized technical modernization
sequence. The Upgrade agent performs the reviewed Java/Spring
runtime/framework execution after that proposal is reconciled with the
specification. Work incrementally; do not ask an agent to rewrite the
application in one pass.

## Outcomes

You will:

1. create and obtain human approval for a durable modernization specification
   using the Lab 01 Plan-mode method;
2. characterize the baseline, including its known upstream test error;
3. run `modernize assess` without inventing or paraphrasing its output;
4. reconcile assessment evidence and target-platform decisions with the
   approved specification;
5. create and reconcile a specialized technical plan with
   `modernize plan create`;
6. use the current upgrade-agent plugin to move to Java 21, Spring Boot 3, and
   the required `javax` to `jakarta` APIs;
7. replace RabbitMQ with Azure Service Bus and AWS S3 with Azure Blob Storage;
8. replace production PostgreSQL password authentication with Microsoft Entra
   managed identity;
9. add health endpoints and container images for the web and worker modules;
10. verify locally, then optionally deploy to Azure Container Apps; and
11. prove that every workshop Azure resource was removed.

## Safety and scope

- Run commands from the **monorepo root** unless a step explicitly changes
  directory.
- Make application changes only under `legacy-src/java-asset-manager`.
- Store the durable contract at
  `specs/java-asset-manager-modernization.md` and supporting workshop evidence
  under `specs/work/java-modernization/`.
- Never commit credentials, connection strings, access keys, database
  passwords, access tokens, or generated `.env` files.
- Use a participant-owned subscription and a dedicated resource group. Do not
  deploy into a shared or production resource group.
- Keep the `dev` profile useful for local work. Production must use managed
  identity; local PostgreSQL may continue to use a local-only password.
- Commit or stash unrelated work before allowing an agent to edit files.

> [!IMPORTANT]
> Agent and tool output is a proposal. A generated plan is not approval and is
> not a second specification. Reconcile every plan and diff with the durable
> specification. Before execution, review scope, allowed paths, security and
> data handling, cost, validation, stop conditions, deployment boundaries, and
> cleanup. Stop when a command changes files outside the allowed paths,
> introduces secrets, removes behavior without an approved decision, or cannot
> explain a failing check.

## Target architecture

The target has two independently deployed containers:

- **web:** public ingress; upload, list, view, and delete operations;
- **worker:** no public ingress; consumes image-processing messages and writes
  thumbnails;
- **Azure Blob Storage:** original images and `_thumbnail` objects;
- **Azure Service Bus:** image-processing queue and dead-letter behavior;
- **Azure Database for PostgreSQL Flexible Server:** image metadata;
- **managed identity:** Azure SDK authentication and production database
  authentication; and
- **Spring Boot Actuator:** liveness and readiness endpoints used by Container
  Apps probes.

The exact Spring Boot 3 patch, Spring Cloud Azure release train, and Azure SDK
versions must be selected by the installed modernization tooling and recorded
in the plan. Do not copy version numbers from an example without checking
compatibility.

## 0. Prepare the workspace

### Check tools

From the monorepo root:

```powershell
git status --short
java -version
.\legacy-src\java-asset-manager\mvnw.cmd -version
modernize --help
copilot --version
docker version
az version
azd version
gh auth status
```

macOS/Linux wrapper equivalent:

```bash
./legacy-src/java-asset-manager/mvnw -version
```

**Stop condition:** do not continue on the local path until JDK 21, Docker,
Modernize CLI, GitHub CLI, and GitHub Copilot are available. Azure CLI and
Azure Developer CLI are required only for the optional deployment path. JDK 8
is recommended for reproducing the original runtime exactly, but the known
test characterization below is still valid if the baseline is first run on
JDK 21 and the selected JDK is recorded.

### Create the durable specification and evidence directory

```powershell
New-Item -ItemType Directory -Force specs\work\java-modernization | Out-Null
if (-not (Test-Path 'specs\java-asset-manager-modernization.md')) {
  Copy-Item specs\templates\change-specification.md `
    specs\java-asset-manager-modernization.md
}
```

```bash
mkdir -p specs/work/java-modernization
if [ ! -f specs/java-asset-manager-modernization.md ]; then
  cp specs/templates/change-specification.md \
    specs/java-asset-manager-modernization.md
fi
```

Create `specs/work/java-modernization/baseline.md`. Record commands, JDK and
Maven versions, pass/fail state, and only the relevant error summary. Do not
paste credentials or full environment dumps.

The durable specification is the only required contract artifact. If the
target-platform trade-offs need more detail than the specification can carry,
optionally create
`specs/work/java-modernization/adr-001-target-platform.md` from the ADR
template and link it from the specification. Do not create an ADR only to
complete a checklist.

Before assessment, use a fresh GitHub Copilot Plan-mode session and the
[Lab 01 method](../../01-spec-driven-development/README.md) to refine
`specs/java-asset-manager-modernization.md`:

```text
Using the Lab 01 contract-first method, refine
specs/java-asset-manager-modernization.md for modernizing only
legacy-src/java-asset-manager.

Define the user-visible intent, preserved behavior, constraints, non-goals,
Given/When/Then acceptance criteria, exact allowed paths, primary local
validation, security and data boundaries, cost and deployment constraints,
cleanup obligations, and stop conditions. The target direction is Java 21,
Spring Boot 3, Azure managed services, and two containers, but do not invent
repository facts or create a technical execution plan. Do not edit application
code.
```

Challenge the draft as a skeptical maintainer, remove placeholders, commit it,
and record human approval. The Plan-mode conversation is working context; the
committed specification is the durable contract. **Stop** if it is missing,
unapproved, or ambiguous. Do not add another requirements framework to
compensate.

**Specify checkpoint:** record the specification path and commit, reviewer and
approval date, selected source root, baseline command, unresolved blockers, and
confirmation that implementation has not started.

## 1. Assess

### 1.1 Characterize the imported baseline

Run the reactor tests:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml test
```

```bash
./legacy-src/java-asset-manager/mvnw -B -ntp \
  -f ./legacy-src/java-asset-manager/pom.xml test
```

The imported upstream baseline has one known test issue:

| Module | Expected baseline characterization |
| --- | --- |
| `web` | Compiles; contains no tests |
| `worker` | Discovers four tests |
| Known error | `downloadOriginalCopiesFileFromS3` attempts to mock final class `software.amazon.awssdk.core.ResponseInputStream`; the baseline Mockito configuration cannot create that mock |
| Other worker tests | Three complete successfully when this known error is the only failure |

This is a **known upstream test-harness limitation**, not proof that the
download behavior works. Capture the actual result. Do not change the test yet.

Confirm that the reactor can package while tests are skipped:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml -DskipTests package
```

```bash
./legacy-src/java-asset-manager/mvnw -B -ntp \
  -f ./legacy-src/java-asset-manager/pom.xml -DskipTests package
```

#### Checkpoint A

- `baseline.md` names the selected JDK.
- Packaging succeeds.
- The only accepted test error is the exact final-class Mockito error above.

**Stop condition:** if compilation fails, no tests are discovered, or another
test fails, stop and ask a coach to compare your checkout with
`legacy-src/java-asset-manager/README.local.md`. Do not modernize an
unexplained baseline.

### 1.2 Run the Modernize assessment

The current CLI accepts an explicit source and output path:

```powershell
modernize assess `
  --source .\legacy-src\java-asset-manager `
  --output-path .\specs\work\java-modernization\assessment `
  --format markdown
```

```bash
modernize assess \
  --source ./legacy-src/java-asset-manager \
  --output-path ./specs/work/java-modernization/assessment \
  --format markdown
```

Use local delegation, the default. Do not add `--delegate cloud` during the
workshop unless your organization has explicitly approved cloud delegation.

The CLI determines report filenames and content. Open the files it reports and
record their actual relative paths in `baseline.md`.

> [!NOTE]
> An expected example such as “Java 8 and Spring Boot 2.7 were detected” is
> **illustrative**, not captured Modernize output. Preserve the generated
> report as the source of truth.

Review the assessment against repository evidence:

- parent reactor and two modules in `pom.xml`;
- Java 8 and Spring Boot 2.7.18 in the parent POM;
- `javax.servlet`, `javax.persistence`, and `javax.annotation` imports;
- Java SE `javax.imageio` imports, which do **not** move to Jakarta;
- RabbitMQ configuration and listeners;
- AWS SDK S3 clients in both modules;
- PostgreSQL username/password properties;
- one known worker test error and no web tests; and
- upload, list, view, delete, message, thumbnail, and metadata behavior.

#### Checkpoint B

- Assessment files exist under the chosen output directory.
- Unsupported claims are annotated in your notes rather than silently
  accepted.
- No application source has changed.

## 2. Reconcile evidence and record technical decisions

Reconcile the generated assessment with
`specs/java-asset-manager-modernization.md`. Record the target-platform
decisions in that specification or, when the trade-offs need a separate
record, in the optional linked `adr-001-target-platform.md`. The approved
specification remains the requirements contract; assessment findings provide
evidence and risks.

In the GitHub Copilot app, open the repository and use Agent mode with this
prompt:

```text
Reconcile the generated assessment with
specs/java-asset-manager-modernization.md. Update only that file and, if it is
already linked from the specification, the optional
specs/work/java-modernization/adr-001-target-platform.md.

Use evidence from legacy-src/java-asset-manager and the generated assessment.
Preserve the approved intent and identify every contradiction. If evidence
requires a change to intent, constraints, acceptance criteria, allowed paths,
validation, security/cost boundaries, or stop conditions, report it and stop
for Plan-mode revision and human reapproval.

The approved target is Java 21, a compatible Spring Boot 3.x release, Azure
Blob Storage, Azure Service Bus, Azure Database for PostgreSQL Flexible Server
with production managed identity authentication, two Azure Container Apps, and
Actuator health probes.

Preserve upload/list/view/delete behavior, the message payload meaning,
thumbnail naming with the _thumbnail suffix, metadata persistence, and a local
development path. Explicitly state that Java SE javax.imageio remains javax,
while Java EE APIs required by Spring Boot 3 move to jakarta.

Confirm measurable acceptance criteria, allowed paths, non-goals, rollback,
deployment cost/safety constraints, stop conditions, exact cleanup, and a
no-deployment completion route. Do not edit application code or create a
competing specification.
```

The specification, and optional ADR when used, must resolve these choices:

| Decision | Required outcome |
| --- | --- |
| Runtime/framework | Java 21 and a recorded compatible Spring Boot 3.x patch |
| Namespace | Migrate Servlet, Persistence, and Annotation APIs to `jakarta`; retain Java SE `javax.imageio` |
| Storage | Blob Storage with the same object-key and content-type behavior |
| Messaging | One Service Bus queue with explicit completion/retry/dead-letter behavior |
| Database auth | Managed identity in Azure; no production database password |
| Identity shape | Prefer a user-assigned identity when a stable PostgreSQL principal must be shared by web and worker; record a different choice if approved |
| Deployment | Public web app, internal worker app, same Container Apps environment |
| Local development | Local credentials or emulators are allowed only in an ignored/local profile |

### Checkpoint C

- The durable specification and any optional ADR have no placeholders.
- Every acceptance criterion has a reproducible check.
- Cost, data migration, identity ownership, and cleanup are explicit.

**Stop condition:** do not execute an upgrade while an open question can change
the target version, data handling, identity model, resource ownership, allowed
paths, security, cost, acceptance criteria, validation, stop conditions, or
cleanup. Reapprove the durable specification if its contract changed.

## 3. Plan

### 3.1 Create the specialized technical modernization plan

Use the Modernize CLI plan interface from the monorepo root:

```powershell
$assessmentReport = Read-Host `
  'Enter the actual assessment report path printed by modernize'
if (-not (Test-Path $assessmentReport -PathType Leaf)) {
  throw "Assessment report does not exist: $assessmentReport"
}

modernize plan create `
  "Modernize Asset Manager from Java 8 and Spring Boot 2.7 to Java 21 and a compatible Spring Boot 3 release; then replace RabbitMQ with Azure Service Bus, AWS S3 with Azure Blob Storage, and production PostgreSQL password authentication with managed identity; add health endpoints, containerize web and worker, and prepare but do not run Azure Container Apps deployment. Follow the approved durable specification." `
  --source .\legacy-src\java-asset-manager `
  --plan-name java-azure-modernization `
  --language java `
  --assess-file-path $assessmentReport
```

```bash
read -r -p "Enter the actual assessment report path printed by modernize: " \
  assessment_report
test -f "$assessment_report"

modernize plan create \
  "Modernize Asset Manager from Java 8 and Spring Boot 2.7 to Java 21 and a compatible Spring Boot 3 release; then replace RabbitMQ with Azure Service Bus, AWS S3 with Azure Blob Storage, and production PostgreSQL password authentication with managed identity; add health endpoints, containerize web and worker, and prepare but do not run Azure Container Apps deployment. Follow the approved durable specification." \
  --source ./legacy-src/java-asset-manager \
  --plan-name java-azure-modernization \
  --language java \
  --assess-file-path "$assessment_report"
```

Review the actual plan location reported by the CLI. Do not assume a filename.
The generated plan and task file are proposals, not approval and not a second
requirements contract.

### 3.2 Reconcile the generated plan with the approved specification

Use the GitHub Copilot app to review the actual generated plan artifacts:

```text
Review the Modernize CLI plan and task artifacts reported for
java-azure-modernization against:
- specs/java-asset-manager-modernization.md
- any optional ADR linked from the specification
- the actual Modernize assessment
- legacy-src/java-asset-manager

Treat the generated plan as a technical proposal subordinate to the approved
specification. Report conflicts before editing. Update only the generated plan
artifacts. Do not weaken or silently reinterpret acceptance criteria.

Separate the work into bounded phases: Java/Spring runtime and framework,
Service Bus, Blob Storage, PostgreSQL managed identity, health endpoints,
containers, deployment preparation, optional deployment, verification, and
cleanup. The Upgrade agent will execute only the reviewed runtime/framework
phase. Each phase must name exact allowed paths, validation, rollback or
containment, and stop conditions.

Review identity, secrets, data handling, public exposure, Azure cost and role
gates, no-deployment behavior, and exact resource-group cleanup. Preserve Java
SE javax.imageio, and require behavior-valid repair of the known
ResponseInputStream test. Do not execute any task.
```

Before approval, verify:

- scope and editable paths match the durable specification;
- both modules and the parent POM are covered;
- Java 21, Spring Boot 3.x, dependency compatibility, and Jakarta boundaries
  are explicit;
- runtime/framework work is isolated for Upgrade-agent execution;
- every service migration has tests and a rollback boundary;
- security, identity, data, and secret handling match the approved contract;
- cost and deployment remain explicitly gated and optional;
- validation and stop conditions are present after every phase; and
- the no-deployment route and exact cleanup are included.

If reconciliation would change the durable contract, return to Plan mode,
revise and reapprove the specification first. Do not keep competing
requirements in the generated plan.

### 3.3 Install and select the current upgrade agent

In the GitHub Copilot app command interface:

```text
/plugin marketplace add microsoft/upgrade-agent-plugins
/plugin install upgrade-agent@upgrade-agent-plugins
```

Use `/agent` and select **upgrade**. The plugin starts its Upgrade MCP server
automatically; do not add a separate MCP configuration.

If the marketplace is already registered, keep the existing registration and
install or update the plugin through the app's plugin UI.

### Checkpoint D

- The generated plan is recorded as a proposal and reconciled with the approved
  durable specification and any linked optional ADR.
- Scope, allowed paths, security, cost, validation, stop conditions, optional
  deployment, and cleanup have human review.
- Runtime upgrade and cloud-service work are separate, and the runtime phase is
  assigned to the Upgrade agent.
- Each service migration has its own tests and rollback boundary.
- Deployment is an explicit opt-in phase.

## 4. Execute

Before each phase, save a checkpoint:

```powershell
git status --short
git add legacy-src\java-asset-manager `
  specs\java-asset-manager-modernization.md `
  specs\work\java-modernization
git commit -m "checkpoint: <phase name>"
```

If your workshop policy does not permit commits, record the clean starting SHA
and keep a reviewed diff after each phase.

### 4.1 Upgrade Java and Spring Boot

Return to the selected **upgrade** agent. Approve execution only after reviewing
its mapping to the reconciled Modernize plan and approved specification:

```text
Execute the reviewed Java 21 and Spring Boot 3.x upgrade plan for
legacy-src/java-asset-manager. Work incrementally across the parent, web, and
worker modules.

Before editing, map the proposed stages to the approved acceptance criteria and
the reviewed runtime/framework tasks. Cite exact allowed paths, validation, and
stop conditions, and report any conflict instead of choosing a new
requirement. Wait for approval of that mapping.

After approval, run the Maven reactor tests after each coherent step. Repair
the known ResponseInputStream test so that it verifies download behavior
without relying on an unsupported final-class mock. Do not migrate storage,
messaging, database authentication, containers, or Azure infrastructure in
this phase. Stop if a required target dependency is incompatible rather than
silently changing the approved target.
```

Review the mapping for scope, paths, security/data boundaries, validation, and
stop conditions. Approve one increment at a time and inspect each diff before
continuing.

Verify:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml clean test
```

```bash
./legacy-src/java-asset-manager/mvnw -B -ntp \
  -f ./legacy-src/java-asset-manager/pom.xml clean test
```

Inspect namespaces:

```powershell
git grep -n -E "javax\.(servlet|persistence|annotation)" -- `
  legacy-src/java-asset-manager
git grep -n "javax\.imageio" -- legacy-src/java-asset-manager
```

The first search must return no production imports. The second may return Java
SE image APIs.

#### Checkpoint E

The reactor tests pass on JDK 21, the parent POM records Java 21 and Spring
Boot 3.x, and no cloud-service migration is mixed into the diff.

### 4.2 Migrate RabbitMQ to Azure Service Bus

Use the default coding agent in the GitHub Copilot app:

```text
Implement only the approved RabbitMQ-to-Azure-Service-Bus phase in
legacy-src/java-asset-manager.

Preserve the ImageProcessingMessage JSON meaning and the upload-to-thumbnail
flow. Replace RabbitTemplate, @RabbitListener, Rabbit configuration, and AMQP
dependencies in both modules with a compatible Azure Service Bus Java/Spring
integration. Use DefaultAzureCredential in the Azure profile and externalize
the fully qualified namespace and queue name. Do not add connection strings or
secrets. Define explicit success completion, retry, and dead-letter behavior.
Keep local development testable. Add unit or integration-boundary tests that
do not require a live Azure subscription. Do not change storage or database
code. Run the reactor tests and summarize the diff.
```

Verify that no RabbitMQ production dependency or API remains:

```powershell
git grep -n -E "spring-rabbit|spring-boot-starter-amqp|RabbitTemplate|RabbitListener|spring\.rabbitmq" `
  -- legacy-src/java-asset-manager
```

Review configuration for namespace and queue **names**, not secrets.

#### Checkpoint F

Tests pass, the message contract is tested, and failure handling has a
documented dead-letter outcome.

### 4.3 Migrate AWS S3 to Azure Blob Storage

```text
Implement only the approved AWS-S3-to-Azure-Blob-Storage phase in
legacy-src/java-asset-manager.

Replace AWS SDK clients and configuration in web and worker with current Azure
Blob Storage SDK APIs. Authenticate the Azure profile with
DefaultAzureCredential. Externalize account endpoint and container name.
Preserve upload, list, view, delete, content type, original object keys, and
the _thumbnail naming convention. Preserve the local-file development path.
Update the existing S3-focused tests into provider-neutral or Blob-focused
behavior tests. Do not change Service Bus, database, containers, or
infrastructure. Run the reactor tests and summarize the diff.
```

Verify:

```powershell
git grep -n -E "software\.amazon|aws\.|S3Client|AwsS3" `
  -- legacy-src/java-asset-manager
```

Renaming public classes is optional, but AWS SDK imports, credentials, and
configuration must be gone. Tests must cover original and thumbnail keys.

#### Checkpoint G

Reactor tests pass, no AWS credentials or SDK dependency remains, and local
storage still works.

### 4.4 Migrate PostgreSQL production authentication

```text
Implement only the approved PostgreSQL password-to-managed-identity phase in
legacy-src/java-asset-manager.

For the Azure profile, use the current supported Spring Cloud Azure/Azure
Identity passwordless JDBC integration for Azure Database for PostgreSQL
Flexible Server. Use DefaultAzureCredential or the supported JDBC
authentication plugin selected by the compatible dependency train. Do not
store or require a production database password. Keep a separate local
development profile that can use local PostgreSQL credentials supplied through
environment variables. Externalize host, database, and principal names. Add
configuration tests proving that the Azure profile has no password property.
Do not provision Azure or change application behavior.
```

Search tracked files:

```powershell
git grep -n -E "spring\.datasource\.password|postgres.*password|DB_PASSWORD" `
  -- legacy-src/java-asset-manager
```

Any match must be confined to an explicitly local-only example with a
placeholder, never an Azure profile or real value.

#### Checkpoint H

Tests pass, Azure configuration has no database password, and the approved
specification or its linked optional ADR names the PostgreSQL principal and
grant owner.

### 4.5 Add health endpoints

```text
Add production-ready health endpoints to both modules in
legacy-src/java-asset-manager using Spring Boot Actuator.

Expose liveness and readiness groups with minimal details. The web module may
serve management endpoints on its application port. Give the worker an
internal management HTTP port suitable for Container Apps probes while keeping
the worker without public ingress. Include health contributors or readiness
checks for required dependencies without exposing credentials or sensitive
details. Add tests for endpoint availability and status mapping. Do not add
Azure infrastructure.
```

Expected endpoint contract:

| Process | Liveness | Readiness |
| --- | --- | --- |
| web | `/actuator/health/liveness` | `/actuator/health/readiness` |
| worker | same paths on its internal management port | same paths on its internal management port |

#### Checkpoint I

Health tests pass, and unauthenticated health output contains no environment,
credential, or connection details.

### 4.6 Containerize the two modules

```text
Containerize the modernized Java application under
legacy-src/java-asset-manager.

Create separate reproducible multi-stage Dockerfiles for web and worker using
Java 21 build and runtime images. Build from the reactor root, run as a
non-root user, copy only required artifacts, define the correct web and worker
ports, and add a focused .dockerignore. Do not bake credentials into images.
Use Actuator paths for health checks where supported. Add concise container
run instructions without changing files outside this application.
```

Build from the monorepo root, adjusting filenames only if the reviewed plan
recorded different names:

```powershell
docker build -f legacy-src\java-asset-manager\Dockerfile.web `
  -t asset-manager-web:lab legacy-src\java-asset-manager
docker build -f legacy-src\java-asset-manager\Dockerfile.worker `
  -t asset-manager-worker:lab legacy-src\java-asset-manager
docker image inspect asset-manager-web:lab `
  --format '{{.Config.User}} {{.Config.ExposedPorts}}'
docker image inspect asset-manager-worker:lab `
  --format '{{.Config.User}} {{.Config.ExposedPorts}}'
```

```bash
docker build -f legacy-src/java-asset-manager/Dockerfile.web \
  -t asset-manager-web:lab legacy-src/java-asset-manager
docker build -f legacy-src/java-asset-manager/Dockerfile.worker \
  -t asset-manager-worker:lab legacy-src/java-asset-manager
docker image inspect asset-manager-web:lab \
  --format '{{.Config.User}} {{.Config.ExposedPorts}}'
docker image inspect asset-manager-worker:lab \
  --format '{{.Config.User}} {{.Config.ExposedPorts}}'
```

**Stop condition:** do not continue if either image runs as root, contains a
secret, cannot start with external configuration, or omits its health port.

## 5. Verify before deployment

Run the complete local gate:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml clean verify
git grep -n -E "AKIA|aws_secret|SharedAccessKey=|AccountKey=|spring\.datasource\.password" `
  -- legacy-src/java-asset-manager
git diff --check
git status --short
```

The credential search must have no production-secret match. Investigate every
result; placeholders in clearly local examples are not proof of a leak.

### Verification table

Record evidence in `specs/work/java-modernization/verification.md`.

| Area | Required check | Pass condition |
| --- | --- | --- |
| Baseline | Original `test` and skip-test package commands | Known error characterized; package succeeds |
| Runtime | `clean verify` under JDK 21 | Reactor succeeds |
| Framework | Parent POM and dependency tree | Spring Boot 3.x; compatible Azure dependencies |
| Namespace | `git grep` checks | Jakarta where required; Java SE `javax.imageio` retained |
| Messaging | Unit/contract tests and dependency search | Service Bus behavior tested; RabbitMQ removed |
| Storage | Upload/list/view/delete and key tests | Blob behavior and thumbnails preserved; AWS SDK removed |
| Database | Azure-profile config test and secret search | Managed identity path; no production password |
| Health | Endpoint tests | Both processes expose liveness/readiness |
| Containers | Two builds and image inspection | Both build, run non-root, and expose expected ports |
| Scope | `git status` and diff review | Only approved Java app/evidence files changed |

### Checkpoint J

Every non-deployment row is green before Azure provisioning.

## 6. Deploy to Azure Container Apps (optional)

Azure deployment is optional because policy, quota, networking, or role
assignment may block it. Code modernization is not blocked by Azure access.

### 6.1 Prepare an isolated resource group

Choose your own values:

```powershell
$env:AZURE_SUBSCRIPTION_ID = "<subscription-guid>"
$env:AZURE_LOCATION = "canadacentral"
$env:AZURE_RESOURCE_GROUP = "appmod-<alias>-java"
$env:AZURE_RESOURCE_PREFIX = "appmod-<alias>"

az login
az account set --subscription $env:AZURE_SUBSCRIPTION_ID
az group create `
  --subscription $env:AZURE_SUBSCRIPTION_ID `
  --name $env:AZURE_RESOURCE_GROUP `
  --location $env:AZURE_LOCATION `
  --tags workshop=appmod

.\scripts\azure\preflight.ps1 `
  -SubscriptionId $env:AZURE_SUBSCRIPTION_ID `
  -ResourceGroupName $env:AZURE_RESOURCE_GROUP `
  -ExpectedNamePrefix $env:AZURE_RESOURCE_PREFIX `
  -RequiredTagName workshop `
  -RequiredTagValue appmod
```

```bash
export AZURE_SUBSCRIPTION_ID="<subscription-guid>"
export AZURE_LOCATION="canadacentral"
export AZURE_RESOURCE_GROUP="appmod-<alias>-java"
export AZURE_RESOURCE_PREFIX="appmod-<alias>"

az login
az account set --subscription "$AZURE_SUBSCRIPTION_ID"
az group create \
  --subscription "$AZURE_SUBSCRIPTION_ID" \
  --name "$AZURE_RESOURCE_GROUP" \
  --location "$AZURE_LOCATION" \
  --tags workshop=appmod

./scripts/azure/preflight.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --expected-prefix "$AZURE_RESOURCE_PREFIX" \
  --tag-name workshop \
  --tag-value appmod
```

Read the account, tenant, subscription, exact resource group, safety tag, and
existing-resource list printed by preflight.

**Stop condition:** stop immediately if any resolved value is not yours or the
group already contains unrelated resources.

### 6.2 Generate and review deployment assets

In the GitHub Copilot app:

```text
Prepare an Azure Developer CLI deployment for the modernized application in
legacy-src/java-asset-manager. Generate Bicep and azure.yaml for an existing,
dedicated resource group in the participant's subscription.

Deploy separate web and worker Azure Container Apps, Azure Container Registry,
Blob Storage, Service Bus queue, and Azure Database for PostgreSQL Flexible
Server. Assign the approved managed identity. Grant least-privilege data-plane
roles for Blob and Service Bus and configure PostgreSQL Microsoft Entra
authentication and database grants. Enable external ingress only for web.
Configure liveness/readiness probes, secret references only where Azure
requires them, diagnostic settings if available, resource tags
workshop=appmod, and outputs needed for smoke tests.

Do not run azd or az commands. Do not create a new subscription or select a
resource group. Keep all deployment assets under
legacy-src/java-asset-manager/infra plus azure.yaml.
```

Review:

- all resource names are parameterized and scoped to the exact resource group;
- web alone has external ingress;
- role assignments are least privilege;
- image tags are immutable or traceable;
- PostgreSQL firewall/network choices match your policy;
- no password is generated for application use;
- outputs include web URL and resource names; and
- cleanup is resource-group scoped.

Run Bicep validation or `azd provision --preview` if supported by your installed
version. Preview output is environment-specific; do not copy illustrative
resource IDs into evidence.

### 6.3 Deploy

Run Azure Developer CLI from the application directory:

```powershell
Push-Location .\legacy-src\java-asset-manager
try {
  azd auth login
  azd env new java-appmod
  azd env set AZURE_SUBSCRIPTION_ID $env:AZURE_SUBSCRIPTION_ID
  azd env set AZURE_LOCATION $env:AZURE_LOCATION
  azd env set AZURE_RESOURCE_GROUP $env:AZURE_RESOURCE_GROUP
  azd up
}
finally {
  Pop-Location
}
```

```bash
(
  cd ./legacy-src/java-asset-manager
  azd auth login
  azd env new java-appmod
  azd env set AZURE_SUBSCRIPTION_ID "$AZURE_SUBSCRIPTION_ID"
  azd env set AZURE_LOCATION "$AZURE_LOCATION"
  azd env set AZURE_RESOURCE_GROUP "$AZURE_RESOURCE_GROUP"
  azd up
)
```

Do not approve a fallback that embeds storage keys, Service Bus connection
strings, or a PostgreSQL password in application settings.

### 6.4 Smoke test

Use the actual web URL emitted by the deployment:

```powershell
$webUrl = "<https://actual-web-fqdn>"
Invoke-RestMethod "$webUrl/actuator/health/liveness"
Invoke-RestMethod "$webUrl/actuator/health/readiness"
Invoke-WebRequest "$webUrl/" -UseBasicParsing
```

```bash
web_url="<https://actual-web-fqdn>"
curl --fail --silent --show-error "$web_url/actuator/health/liveness"
curl --fail --silent --show-error "$web_url/actuator/health/readiness"
curl --fail --silent --show-error "$web_url/" >/dev/null
```

Then use the UI to upload one non-sensitive test image. Verify:

1. upload returns success;
2. the original appears in the list and can be viewed;
3. the worker produces the `_thumbnail` object;
4. metadata exists in PostgreSQL;
5. the Service Bus active message count returns to zero;
6. no unexpected dead-letter message exists; and
7. delete removes the original, thumbnail, and metadata.

Save resource names, timestamps, HTTP status, and pass/fail results. Do not save
tokens, secrets, or connection strings.

## 7. No-deployment completion path

If policy, quota, network access, region capacity, role assignment, or
PostgreSQL Microsoft Entra administration prevents deployment:

1. stop provisioning; do not weaken identity or networking controls;
2. create `specs/work/java-modernization/deployment-blocker.md`;
3. record the exact command, sanitized error code/message, subscription and
   region (not credentials), owner, and next action;
4. complete Checkpoints A-J;
5. validate generated Bicep/`azure.yaml` as far as your tooling permits;
6. include the reviewed `azd up` and smoke-test plan without claiming it ran;
7. run cleanup if any resource was created; and
8. mark deployment criteria **not run - blocked**, not passed.

This route counts as lab completion when all local modernization checks pass,
the deployment assets are reviewable, the blocker is evidenced, and Azure
cleanup verification is complete.

## 8. Cleanup and exact verification

Cleanup is mandatory even if deployment failed partway.

### Preview

```powershell
.\scripts\azure\cleanup.ps1 `
  -SubscriptionId $env:AZURE_SUBSCRIPTION_ID `
  -ResourceGroupName $env:AZURE_RESOURCE_GROUP `
  -ExpectedNamePrefix $env:AZURE_RESOURCE_PREFIX `
  -RequiredTagName workshop `
  -RequiredTagValue appmod `
  -WhatIf
```

```bash
./scripts/azure/cleanup.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --expected-prefix "$AZURE_RESOURCE_PREFIX" \
  --tag-name workshop \
  --tag-value appmod \
  --what-if
```

Confirm that every listed resource belongs to this lab.

### Delete the exact resource group

```powershell
.\scripts\azure\cleanup.ps1 `
  -SubscriptionId $env:AZURE_SUBSCRIPTION_ID `
  -ResourceGroupName $env:AZURE_RESOURCE_GROUP `
  -ExpectedNamePrefix $env:AZURE_RESOURCE_PREFIX `
  -RequiredTagName workshop `
  -RequiredTagValue appmod `
  -Execute `
  -ConfirmResourceGroup $env:AZURE_RESOURCE_GROUP `
  -Confirm:$false
```

```bash
./scripts/azure/cleanup.sh \
  --subscription-id "$AZURE_SUBSCRIPTION_ID" \
  --resource-group "$AZURE_RESOURCE_GROUP" \
  --expected-prefix "$AZURE_RESOURCE_PREFIX" \
  --tag-name workshop \
  --tag-value appmod \
  --execute \
  --confirm-resource-group "$AZURE_RESOURCE_GROUP"
```

### Prove deletion completed

The cleanup scripts submit asynchronous deletion. Wait and verify:

```powershell
az group wait `
  --subscription $env:AZURE_SUBSCRIPTION_ID `
  --name $env:AZURE_RESOURCE_GROUP `
  --deleted
$exists = az group exists `
  --subscription $env:AZURE_SUBSCRIPTION_ID `
  --name $env:AZURE_RESOURCE_GROUP
if ($exists -ne "false") {
  throw "Cleanup verification failed: resource group still exists."
}
Write-Host "Cleanup verified: resource group does not exist."
```

```bash
az group wait \
  --subscription "$AZURE_SUBSCRIPTION_ID" \
  --name "$AZURE_RESOURCE_GROUP" \
  --deleted
test "$(az group exists \
  --subscription "$AZURE_SUBSCRIPTION_ID" \
  --name "$AZURE_RESOURCE_GROUP")" = "false"
echo "Cleanup verified: resource group does not exist."
```

Record the exact group name, deletion completion time, and final `false`
result. A submitted deletion request alone is not completion.

## Final verification

| Requirement | Evidence |
| --- | --- |
| Baseline characterized | `baseline.md` with known upstream error distinguished from new failures |
| Assessment preserved | Actual Modernize report path and review notes |
| Durable contract approved | `specs/java-asset-manager-modernization.md` with recorded human approval |
| Decisions reconciled | Assessment evidence and recorded architecture decisions agree with the durable specification |
| Technical plan reviewed | Generated Modernize proposal reconciled for scope, paths, security, cost, validation, stop conditions, deployment, and cleanup |
| Java/Spring upgrade | JDK 21 `clean verify`; Spring Boot 3.x in POM |
| Jakarta migration | No old Java EE namespaces; `javax.imageio` intentionally retained |
| Azure services | Provider-specific tests and dependency/config searches |
| Managed identity | Azure profile contains no database password or SDK secret |
| Health | Liveness/readiness tests for web and worker |
| Containers | Two non-root images build |
| Deployment | Smoke evidence, or documented no-deployment blocker |
| Cleanup | `az group exists` returns `false` |

The lab is complete only when every applicable row has evidence and `git
status --short` contains no unexplained files.

## Troubleshooting

### `modernize` is not found

Open a new terminal after installation and run `modernize --help`. Windows
installs normally add `%LOCALAPPDATA%\Programs\modernize` to `PATH`. Do not
invent assessment files when the CLI is unavailable; record the blocker.

### Upgrade agent is unavailable

Run the two `/plugin` commands again, then use `/agent` to select **upgrade**.
If organization policy blocks marketplace plugins, stop before
runtime/framework execution and record the blocker. Preserve the approved
specification, assessment, and reconciled technical plan; do not silently
substitute a second executor or claim the runtime upgrade completed.

### Baseline test fails on `ResponseInputStream`

This is the expected upstream limitation described in Checkpoint A. After the
runtime upgrade, replace the unsupported final-class mock with a behavior-valid
test seam or real stream construction. Do not merely disable the test.

### Every `javax` import was changed

Revert changes to Java SE APIs such as `javax.imageio`. Only APIs moved from
Java EE to Jakarta EE should use `jakarta`.

### Service Bus messages remain active or dead-lettered

Check settlement mode, queue name, identity role assignment, deserialization,
and retry policy. Do not add a connection string as a shortcut. Inspect one
sanitized dead-letter reason before retrying.

### Blob operations return 403

Check the identity assigned to the correct container app, the storage account
endpoint, and data-plane role scope. Management-plane Contributor does not
automatically grant Blob data access.

### PostgreSQL authentication fails

Confirm the managed identity has a Microsoft Entra principal in the database,
the database username/principal matches the configuration, grants were applied,
TLS is enabled, and the selected JDBC passwordless integration matches the
Spring Boot dependency train.

### Container Apps readiness never succeeds

Compare the probe port and path with the module's management port. Ensure
readiness does not expose details and does not become permanently unhealthy
because an optional dependency is unavailable.

### Azure deployment is blocked

Use the no-deployment completion path. Do not change regions repeatedly,
request broad roles, or deploy into another person's resource group without
approval.

## Current interface references

- [Modernize CLI](https://github.com/microsoft/modernize-cli)
- [Upgrade agent plugin](https://github.com/microsoft/upgrade-agent-plugins/tree/main/plugins/upgrade-agent)
- [Java upgrade quickstart](https://learn.microsoft.com/azure/developer/github-copilot-app-modernization/quickstart-upgrade)
- [Azure Container Apps Java overview](https://learn.microsoft.com/azure/container-apps/java-overview)
- [Passwordless authentication with Spring Cloud Azure](https://learn.microsoft.com/azure/developer/java/spring-framework/migrate-postgresql-to-passwordless-connection)
