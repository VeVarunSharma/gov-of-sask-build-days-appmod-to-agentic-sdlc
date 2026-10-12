# Lab 00: Readiness

Complete this lab before the event. The checks report missing prerequisites with
remediation guidance; they never install software, authenticate accounts, or
create Azure resources.

## 1. Choose one application track

- **Java Asset Manager:** Windows, macOS, or Linux; JDK 8 and JDK 21; Maven
  3.8+ or the checked-in wrapper.
- **.NET BookCatalog:** Windows; .NET 10 SDK and runtimes; Visual Studio with
  MSBuild and ASP.NET/web tools; .NET Framework 4.8 targeting pack; IIS
  Express; SQL Server LocalDB.

Both tracks also need Git, authenticated GitHub CLI, the GitHub Copilot app and
entitlement, Modernize CLI, the `upgrade-agent` plugin, `gh-aw`, Docker,
Node.js, and npm. Azure CLI, an authenticated Azure context, and a
participant-controlled non-production subscription are required only for the
optional deployment path; the common readiness script reports them so teams
can choose that path safely. No additional specification CLI or framework is
required.

## 2. Run the shared check

Windows PowerShell is the primary workshop shell:

```powershell
.\scripts\readiness\check-common.ps1 -AcknowledgeCopilotApp
```

The acknowledgement records your manual verification that the GitHub Copilot
app is installed, signed in, and shows an active entitlement. Omit it to see the
required manual-check failure. If you will use your approved participant
subscription, also pass `-SubscriptionId <id>`.

Bash is supported for portable prerequisites:

```bash
./scripts/readiness/check-common.sh --acknowledge-copilot-app
```

Add `--subscription-id <id>` when a specific subscription is required.

The common script cannot inspect Copilot app UI features or plugins. Manually
confirm that a fresh session for this repository offers Plan mode and that
**Settings > Plugins** shows `upgrade-agent` installed from the
`microsoft/upgrade-agent-plugins` marketplace. Use `/agent` to confirm
`upgrade-agent:upgrade`, or confirm **Upgrade** appears in the agent picker.

## 3. Run your track check

### Java

```powershell
.\scripts\readiness\check-java.ps1
```

```bash
./scripts/readiness/check-java.sh
```

If multiple JDKs are installed, set `JAVA8_HOME` and `JAVA21_HOME` (or
`JDK8_HOME` and `JDK21_HOME`) so both are discoverable. The check only reads
versions; it does not change `JAVA_HOME`.

### .NET

```powershell
.\scripts\readiness\check-dotnet.ps1
```

Git Bash on Windows can use:

```bash
./scripts/readiness/check-dotnet.sh
```

The classic ASP.NET MVC 5 baseline cannot be built on Linux, macOS, or WSL.
Install missing Visual Studio components with Visual Studio Installer rather
than copying MSBuild target files between machines.

## 4. Validate the imported baseline

Validation may restore normal package dependencies but does not modify imported
source files.

Java:

```powershell
.\scripts\validation\validate-java.ps1
```

```bash
./scripts/validation/validate-java.sh
```

The Java validation wrapper uses `JAVA8_HOME`/`JDK8_HOME` (or PowerShell
`-JavaHome`) and fails before Maven if the selected runtime is not JDK 8.

.NET (Windows only):

```powershell
.\scripts\validation\validate-dotnet.ps1
```

```bash
./scripts/validation/validate-dotnet.sh
```

Do not continue on an uncharacterized baseline failure. Save the first error
and readiness summary for the facilitator. The imported Java baseline has one
known upstream Mockito/final-class error in
`S3FileProcessingServiceTest.downloadOriginalCopiesFileFromS3`; compare it with
the [recovery card](../../facilitator/recovery/java/known-upstream-test.md).
That exact error is accepted only as baseline characterization, not as an
application pass. Do not create an empty LocalDB MDF, disable the Java test, or
replace imported build files as a workaround.

## 5. Optional: verify your Azure resource group

Skip this section when taking the no-deployment path. Otherwise, use only an
approved participant-owned or participant-controlled non-production
subscription and the exact resource-group name, naming prefix, and safety tag
recorded for your work. Never use a facilitator's subscription, a shared
production subscription, or an unowned group. Preflight is read-only:

```powershell
.\scripts\azure\preflight.ps1 `
  -SubscriptionId <subscription-guid> `
  -ResourceGroupName <exact-resource-group> `
  -ExpectedNamePrefix <assigned-prefix> `
  -RequiredTagName workshop `
  -RequiredTagValue appmod
```

The bash equivalent is:

```bash
./scripts/azure/preflight.sh \
  --subscription-id <subscription-guid> \
  --resource-group <exact-resource-group> \
  --expected-prefix <assigned-prefix> \
  --tag-name workshop \
  --tag-value appmod
```

The cleanup helpers are documented in `scripts/azure/README.md`. They default to
a dry run, enumerate the exact group's resources, require name and tag checks,
and have no wildcard or subscription-wide delete mode. During readiness, do not
remove `-WhatIf` or pass the bash `--execute` flag.

## Exit criteria

- Required shared checks for the chosen local path pass; any optional Azure
  failure is recorded as the reason for taking the no-deployment path.
- A fresh GitHub Copilot app session opens the correct repository, offers Plan
  mode, and exposes the installed Upgrade agent.
- The selected track readiness script exits zero.
- The selected imported baseline passes or the exact documented Java upstream
  defect is reproduced and classified.
- When Azure will be used, preflight displays the expected account, tenant,
  participant subscription, exact resource group, safety tag, and resource
  list.
