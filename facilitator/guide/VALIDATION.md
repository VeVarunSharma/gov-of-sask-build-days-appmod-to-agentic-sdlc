# End-to-end validation

Validated on 2026-10-11 from the repository root. Result: **GO for the
documented local workshop paths; no repository blocker remains.** Live Azure
deployment and live write-capable GitHub workflow execution were not performed.

## Outcomes

| Area | Command or check | Outcome |
| --- | --- | --- |
| Repository hygiene | `git diff --check`, documentation whitespace scan, generated-directory/log scan, `git status --short` | Pass. Added ignore rules and removed local build, dependency, cache, and log output. |
| Provenance | `UPSTREAM_SOURCES.yml` destination checks plus pinned raw GitHub license retrieval | Pass. All four pinned revisions resolved; imported Java and .NET licenses match upstream; declared import destinations exist. |
| Markdown | Offline local link/fragment scan and YAML frontmatter parse | Pass for 103 workshop Markdown files and 27 frontmatter files. The imported Java upstream README remains excluded from local-link checking because it references files outside the pinned subtree, matching CI policy. |
| Script syntax | PowerShell parser over all `*.ps1`; `bash -n` over all `*.sh` | Pass. |
| Readiness | PowerShell and Bash common/Java/.NET readiness scripts | Scripts executed read-only. .NET: 8/8 pass. Common: Modernize CLI unavailable. Java: JDK 21 and Maven wrapper pass; host JDK 8 unavailable. |
| Legacy Java package | `maven:3.9.9-eclipse-temurin-8` container, `mvn -B -ntp -Dmaven.test.skip=true clean package` | Pass on JDK 8. |
| Legacy Java characterization | Same JDK 8 container, `mvn -B -ntp test` | Expected upstream failure reproduced exactly: `S3FileProcessingServiceTest.downloadOriginalCopiesFileFromS3`, final-class `ResponseInputStream` Mockito error, and `Tests run: 4, Failures: 0, Errors: 1, Skipped: 0`. |
| Legacy .NET Framework | Short `W:` mapping, `scripts\validation\validate-dotnet.ps1 -Configuration Release` using Visual Studio 18 MSBuild | Pass; `BookCatalog.Web.dll` built. |
| React capstone | `npm ci --no-audit --no-fund`, `npm run lint`, `npm test`, `npm run build` | Pass; 2 tests. Lint reports one non-blocking `set-state-in-effect` warning. |
| Java capstone | `mvnw.cmd -B -ntp clean verify` with JDK 21 | Pass; 3 tests and packaged JAR. |
| .NET capstone | `dotnet test ...WorkItems.Api.Tests.csproj --configuration Release --nologo` | Pass; 2 tests. |
| OpenAPI | `npx --yes @redocly/cli@2.10.0 lint capstone-src/contracts/openapi.yml --extends minimal` | Valid. Redocly reports 14 non-blocking starter warnings for localhost servers, missing summaries, and explicit security declarations. |
| GitHub Actions | `actionlint -color` | Pass for conventional and generated workflows. |
| Agentic workflows | `gh aw compile --strict --validate --no-check-update`; `gh aw validate --strict --no-check-update` | Pass for all four Markdown workflows. A second compile produced identical lock hashes and no generated-file drift. |
| Monorepo consistency | Documented-path scan plus execution of documented root-relative validation commands | Pass. Participant-created output paths under `specs/` were treated as intentional future artifacts. |
| Facilitator material | Local link/fragment scan covering facilitator references and recovery cards | Pass. |
| Secrets | Assignment-pattern and known credential/private-key signature scans over source and documentation | Pass. Generated dummy `COPILOT_API_KEY` placeholders are not credentials. |

## Defects fixed during validation

- Regenerated all four `gh-aw` locks with pinned CLI v0.89.21 and retained the
  compiler-generated `agentics-maintenance.yml`; repeated compilation is
  deterministic.
- Added repository ignore rules and removed unexpected validation logs,
  dependency folders, caches, and build outputs.
- Removed documentation trailing whitespace that would fail the documentation
  workflow and restored missing final newlines in workshop-authored files.
- Marked compiler-owned workflow outputs as generated in `.gitattributes`.
- Consolidated participant navigation, track selection, no-deployment routes,
  preview-version guidance, provenance, and maintainer instructions without
  changing application or workflow behavior.

## Refinement validation

Validated on 2026-10-11 after the instruction and lab refinement:

- no legacy specification-framework directory, configuration, or command
  remains;
- Lab 01 requires GitHub Copilot app Plan mode and exactly one durable
  specification, while ADR, test-strategy, and task-breakdown artifacts remain
  optional;
- Lab 04 consistently gates Upgrade-agent execution on an approved
  specification, actual `modernize assess` evidence, and a human-reviewed
  `modernize plan create` proposal;
- the root guide remains a routing map, the global Copilot baseline points to
  root, nearest local, and matching path instructions, and exactly six local
  `AGENTS.md` files plus the root guide exist;
- Lab 02 describes complementary guidance layers without claiming automatic
  precedence;
- participant navigation, prerequisites, official and optional agendas, and
  facilitator checkpoints agree; and
- the spec-to-backlog and issue-to-PR contracts retain the source
  specification, source root, allowed/protected paths, one authoritative
  validation command, acceptance criteria, exclusions, and stop conditions.

Refinement checks observed:

| Check | Result |
| --- | --- |
| `npx --yes markdownlint-cli2@0.18.1 "**/*.md"` with repository configuration | Pass: 108 in-scope Markdown files, 0 errors. Four generated, pinned-upstream, or third-party files are explicitly excluded. |
| Changed-document whitespace/final-newline scan | Pass: 117 files. |
| Offline local link and fragment scan | Pass: 281 targets across 111 Markdown files; the pinned Java upstream README is excluded consistently with CI. |
| YAML frontmatter and `applyTo` routing checks | Pass: 27 frontmatter files and six positive/negative instruction-routing sets. |
| `actionlint -color` | Pass with actionlint v1.7.12. |
| `gh aw compile ... --strict --validate --no-check-update` and `gh aw validate ... --strict --no-check-update` | Pass for all four workflow sources with v0.89.21; only the two contract-related locks regenerated. |
| Second strict compile plus SHA-256 comparison | Pass: no generated lock or maintenance-workflow drift. |

## Known upstream defect

The imported Java baseline cannot pass its full JDK 8 test suite because its
Mockito configuration cannot mock final
`software.amazon.awssdk.core.ResponseInputStream`. Packaging succeeds when
tests are skipped, and the exact single-error characterization above matches
the dedicated CI job and recovery card. This is baseline evidence, not an
application pass.

## Environmental limitations and unperformed checks

- `modernize` is not installed. Modernize CLI commands and generated
  assessments/plans were not executed; their documentation and surrounding
  scripts were checked statically.
- Host JDK 8 and system Maven are absent. The legacy Java checks used the
  pinned Maven/JDK 8 container; the checked-in wrappers were also detected.
- No Azure resource was created, changed, deployed, smoke-tested, or deleted.
  Azure preflight/cleanup scripts were syntax-checked and reviewed for exact
  subscription, resource-group, prefix, tag, dry-run, and confirmation guards.
- No GitHub Actions or write-capable `gh-aw` workflow was dispatched.
- On Windows, `gh aw compile --actionlint` reported a CLI tooling integration
  exit code 3. Direct `actionlint` v1.7.12 and strict `gh aw validate` both
  passed, so this is recorded as an environment/tool integration limitation,
  not workflow success from the failed invocation.

## Go/no-go blockers

No unresolved repository defect blocks local workshop delivery. Live
Modernize, Azure, and write-capable workflow outcomes remain **not performed**
and must not be represented as successful.
