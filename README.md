# Government of Saskatchewan Build Day

## Modern App Development with GitHub Copilot

| Event detail | Value |
| --- | --- |
| Date | Wednesday, November 4, 2026 |
| Time | 10:00 AM to 3:00 PM |
| Location | Regina; venue confirmation pending |
| Organizer | Ve Sharma, Solution Engineer, Microsoft |
| Coaches | Ve Sharma and Rajeev Kalamthodi |
| Audience | Government of Saskatchewan developers and local partners |
| Level | Beginner to intermediate, with an optional advanced capstone |
| Capacity | Up to 40 participants |

This hands-on workshop uses one repository and the GitHub Copilot app to move
from readiness and a reviewed Plan-mode specification through application
modernization, guarded agentic workflows, automated quality assurance, and a
capstone. Java and .NET are equal, first-class tracks. Choose one application
track during readiness and stay with it for the modernization work; completing
both is not required.

## One repository, one flow

Clone or fork this repository once. Run commands from the repository root
unless a lab explicitly changes the working directory. Imported applications,
participant labs, specifications, Copilot customization, automation, capstone
starters, and facilitator material remain together so that links and validation
commands use one checkout.

Follow the labs in this order:

1. [Readiness](labs/00-readiness/)
2. [Plan mode and a durable specification](labs/01-spec-driven-development/)
3. [Copilot instructions](labs/02-copilot-instructions/)
4. [Custom agents and skills](labs/03-custom-agents-and-skills/)
5. [Application modernization](labs/04-app-modernization/) — choose
   [Java](labs/04-app-modernization/java/) or
   [.NET](labs/04-app-modernization/dotnet/)
6. [Agentic SDLC with `gh-aw`](labs/05-agentic-workflows/)
7. [Deterministic CI and agentic QA](labs/06-automated-qa/)
8. [Capstone](labs/07-capstone/)

The [lab index](labs/) is the participant navigation page.

## How Copilot guidance is routed

Repository-wide guidance, path-specific instructions, and root or co-located
`AGENTS.md` files are complementary sources of context. Gather the guidance
that applies to the file being changed and stop to resolve conflicts rather
than assuming that one source automatically overrides another. [Lab 02
explains and verifies this instruction model](labs/02-copilot-instructions/)
without requiring participants to memorize it during setup.

## Choose an application track

| Track | Starting source | Platform requirement | Modernization target |
| --- | --- | --- | --- |
| Java Asset Manager | [`legacy-src/java-asset-manager`](legacy-src/java-asset-manager/) | Windows, macOS, or Linux; JDK 8 and JDK 21 | Java 21, Spring Boot 3, updated dependencies, containers, and an Azure-ready design |
| .NET BookCatalog | [`legacy-src/dotnet-bookcatalog`](legacy-src/dotnet-bookcatalog/) | **Windows required** for the classic ASP.NET MVC 5 baseline, Visual Studio/MSBuild, .NET Framework 4.8, LocalDB, and .NET 10 | Modern ASP.NET Core/EF Core, containers, and an Azure-ready design |

The .NET application is **BookCatalog**, imported from
`microsoft/dotnet-modernization-for-beginners`; it is not ContosoUniversity.
The imported sources are starting states, not generated checkpoints. Preserve
their attribution and change only the track selected by your team.

### Known Java baseline defect

The imported Java baseline has one known upstream test error:
`S3FileProcessingServiceTest.downloadOriginalCopiesFileFromS3` attempts to mock
the final AWS SDK `ResponseInputStream` class. JDK 8 packaging can succeed with
tests skipped, while the baseline full test run reports one error. Do not call
that error an application pass or hide it by deleting/disabling the test. Use
the [known upstream test recovery card](facilitator/recovery/java/known-upstream-test.md);
the modernization target is a behavior-valid test suite passing on JDK 21.

## Modernization tools in the GitHub Copilot app

The modernization lab uses two related tools after Lab 01 produces one
human-approved durable specification:

- **Modernize CLI** (`modernize`) for repository assessment and technical
  planning. Install it before the event and verify `modernize --help`.
- **Upgrade agent plugin** for guided implementation in the GitHub Copilot
  app. Open **Settings > Plugins**, add the
  `microsoft/upgrade-agent-plugins` marketplace, approve it, and install
  `upgrade-agent`. Start a new session and use `/agent` to confirm
  `upgrade-agent:upgrade`, or select **Upgrade** from the agent picker.

Use the generated assessment and technical plan as proposals. Reconcile them
with the approved specification, then review scope, architecture, security,
cost, validation, and cleanup before approving Upgrade-agent execution. Do not
invent tool output when a tool is unavailable; record the blocker and complete
the documented review/local-validation route instead.

## Agentic workflows and deterministic CI

Conventional `ci-*.yml` GitHub Actions run fixed, reproducible commands and
remain the merge authority. The Markdown `gh-aw` workflows investigate
evidence, propose bounded changes, create advisory reviews or draft pull
requests through safe outputs, and no-op when evidence is weak. They do not
replace, approve, suppress, or weaken deterministic CI.

GitHub Agentic Workflows is a **public-preview** technology. The checked-in
workflow locks were generated with `gh aw version v0.89.21`; other releases may
change schema, validation, or generated YAML. Use the pinned release for these
labs, never hand-edit `.lock.yml` files, and treat a version upgrade as a
separate reviewed maintenance change. Live write-capable runs are optional and
restricted to a disposable workshop fork with explicit approval.

## Event agenda

| Time | Session | Participant checkpoint |
| --- | --- | --- |
| 10:00-10:10 | Welcome and safety | Success and no-production rule |
| 10:10-10:20 | The North Star | See the one-repository, agentic SDLC flow |
| 10:20-10:35 | Modernization | Connect outcomes to engineering evidence |
| 10:35-10:50 | [Lab 00: readiness](labs/00-readiness/) and track selection | Fork/branch, Copilot app, selected baseline, and blockers recorded |
| 10:50-11:10 | [Lab 01: Plan mode and durable specification](labs/01-spec-driven-development/) | One human-approved durable specification; no application edits |
| 11:10-11:25 | [Lab 02: Copilot instructions](labs/02-copilot-instructions/) | Guidance trace plus matching and non-matching evidence |
| 11:25-11:40 | [Lab 03: agents and skills](labs/03-custom-agents-and-skills/) | Bounded agent and reusable skill |
| 11:40-12:00 | [Lab 04: Modernize assessment and technical plan](labs/04-app-modernization/) | Reviewed assessment and reconciled technical plan |
| 12:00-12:30 | Lunch | No unattended deployments or workflow runs |
| 12:30-1:45 | Lab 04: Upgrade execution | Reviewed slice passes locally |
| 1:45-2:05 | [Lab 05: agentic SDLC](labs/05-agentic-workflows/) | Compile/inspect guarded `gh-aw` sources and locks |
| 2:05-2:25 | [Lab 06: automated QA](labs/06-automated-qa/) | Explain deterministic CI versus agentic review/remediation |
| 2:25-2:45 | [Lab 07: capstone](labs/07-capstone/) | Thin slice, validation evidence, and demo script |
| 2:45-3:00 | Closeout | Evidence, limits, cleanup, and next step |

Timeboxes are checkpoints, not permission to skip validation. If setup,
policy, quota, or permissions block a cloud or live-workflow step, use the
documented local/no-live-run completion path.

## Capstone choices

Teams may choose one pathway or combine a small, validated slice of several:

1. [Deepen the selected modernization](labs/07-capstone/pathways/01-modernization-deep-dive.md).
2. [Build a public-service prototype](labs/07-capstone/pathways/02-public-service-app.md)
   from the domain-neutral React starter and either the Java or .NET API.
3. [Automate an engineering pain point](labs/07-capstone/pathways/03-agentic-workflow.md)
   with a guarded `gh-aw` workflow.

Use synthetic data and avoid high-stakes eligibility, enforcement, health,
employment, licensing, or benefits decisions. Azure deployment and live
`gh-aw` execution are optional; a tested local slice plus a reviewed deployment
plan or compile/audit evidence is a valid completion path.

## Azure ownership, deployment, and cleanup

Azure is optional for workshop completion. If you deploy, you must use an
approved **participant-owned or participant-controlled non-production
subscription** with a known budget, quota, role, region, exact resource-group
name, naming prefix, and safety tag. Do not use a facilitator's subscription,
a shared production subscription, or an unowned resource group.

Run the [Azure preflight helper](scripts/azure/) before creation, review
what-if/plan output, and keep all resources in one isolated tagged group.
Cleanup is part of the deployment exercise even after a partial failure:
preview the exact deletion, confirm the exact group, execute cleanup, and
record `az group exists` returning `false`. A policy, quota, role, cost, or
ownership blocker plus complete local evidence is a valid no-deployment result;
weakening security or claiming an unperformed deployment is not.

## Prerequisites

Everyone needs:

- a GitHub account able to fork or use an approved disposable repository;
- GitHub Copilot Pro, Pro+, Business, or Enterprise entitlement;
- the GitHub Copilot app, Git, and authenticated GitHub CLI;
- Modernize CLI and the `upgrade-agent` plugin;
- the pinned `gh-aw` extension used by this repository;
- Docker Desktop or another compatible container runtime; and
- Node.js and npm for the capstone starter.

Install only the Java or .NET toolchain for your selected track. Azure CLI,
login, and a participant-controlled subscription are required only for the
optional Azure path. Complete [Lab 00](labs/00-readiness/) before the event and
bring the first failing check if the readiness script does not pass.
No additional specification CLI or framework is required.

## Repository map

```text
legacy-src/                 # Imported Java and .NET starting applications
capstone-src/               # React plus Java/.NET greenfield starter
labs/                       # Participant flow, 00 through 07
specs/                      # Durable specification templates and examples
scripts/                    # Readiness, validation, and Azure helpers
facilitator/                # Runbook, recovery cards, and references
.github/
  instructions/             # Path-scoped Copilot guidance
  agents/                   # Repository custom agents
  skills/                   # Reusable diagnostic/review skills
  workflows/                # Deterministic CI and gh-aw sources/locks
```

## Facilitator, validation, and maintenance

- [Facilitator index](facilitator/)
- [Single-room facilitator runbook](facilitator/guide/)
- [Recovery matrix](facilitator/recovery/)
- [Reference solutions](facilitator/reference-solutions/)
- [End-to-end validation report](facilitator/guide/VALIDATION.md)
- [Contributor and maintenance guide](CONTRIBUTING.md)

The validation report records what was actually run, the known Java upstream
defect, and checks not performed (including live Azure deployment and live
write-capable workflows). Do not turn static review into a runtime success
claim.

## License and attribution

Workshop-authored material is licensed under the root [MIT License](LICENSE).
Imported Java and .NET snapshots retain their own license files. See
[Third-party notices](THIRD_PARTY_NOTICES.md) for attribution and
[`UPSTREAM_SOURCES.yml`](UPSTREAM_SOURCES.yml) for pinned source revisions,
import paths, and the explicitly excluded unlicensed source.

Primary upstream references:

- [Agentic Modernization Workshop](https://github.com/Azure-Samples/Agentic-Modernization-Workshop)
- [Java migration samples](https://github.com/Azure-Samples/java-migration-copilot-samples)
- [.NET Modernization for Beginners](https://github.com/microsoft/dotnet-modernization-for-beginners)
- [Modernize CLI](https://github.com/microsoft/modernize-cli)
- [Upgrade agent plugin](https://github.com/microsoft/upgrade-agent-plugins/tree/main/plugins/upgrade-agent)
- [GitHub Agentic Workflows](https://github.github.com/gh-aw/)
