<!-- markdownlint-disable MD013 -->

# Recovery index and failure matrix

Recovery is symptom-led and non-destructive. Preserve participant work, find
the first failed checkpoint, and apply the smallest safe correction. The
[facilitator runbook](../guide/) defines room triage and escalation timing.

## Before changing anything

Run from the repository root and save the sanitized output:

```powershell
git status --short
git --no-pager diff
git --no-pager log -8 --oneline
git rev-parse HEAD
```

If the diff is large, save only the selected source and evidence paths to a
local patch file, review it for secrets, and create a recovery branch:

```powershell
git diff -- <selected-paths> > participant-recovery.diff
git switch -c recovery/<track>-<phase>
```

Do not use `git reset --hard`, force-push, delete untracked participant files,
copy a complete reference tree, disable tests, ignore exit codes, or introduce
credentials. Re-run the narrow failed check first, then the documented full
gate.

## Recovery cards

| Area | Index or card | Use |
| --- | --- | --- |
| Java | [Java recovery](java/) | Checkpoints A-J, focused prompts, and Azure partial deployment |
| Java upstream test | [Known upstream test](java/known-upstream-test.md) | `ResponseInputStream` Mockito characterization and safe seam |
| .NET | [.NET recovery](dotnet/) | Baseline through Azure cleanup recovery ladder |
| ASP.NET Core host | [Host patch card](dotnet/aspnet-core-host-patch.md) | Small host/view/static-file correction after comparison |
| EF Core | [EF Core patch card](dotnet/ef-core-patch.md) | Small DI/model/migration correction after comparison |
| Acceptance comparison | [Reference index](../reference-solutions/) | Compare outcomes and evidence; never restore participant source |

These cards are guidance and small patches, not complete applications. Confirm
their assumptions against the participant's current diff before use.

## Failure matrix

| Area and symptom | Diagnose first | Safe recovery | Escalate when |
| --- | --- | --- | --- |
| Java/JDK: wrong bytecode, `JAVA_HOME`, or toolchain | `java -version`; wrapper `-version`; `JAVA8_HOME`/`JAVA21_HOME`; selected checkpoint | Set the shell/session JDK explicitly; rerun the wrapper; keep JDK 8 baseline evidence separate from JDK 21 modernization | Required JDK cannot be installed by the workstation owner or toolchain selection remains inconsistent |
| Java upstream test: `ResponseInputStream` final-class mock error | Compare the exact worker test and error with the [known card](java/known-upstream-test.md); confirm three other tests complete | Preserve characterization; later replace only the invalid mock with a behavior-valid seam or real stream | Compilation fails, tests are missing, another test fails, or the error differs |
| Maven: restore, plugin, TLS, proxy, or cache failure | Wrapper version, first transfer error, proxy, repository URL, disk, and network status | Stop parallel retries; use approved proxy/cache; retry the narrow module after network recovery; never vendor a local repository | Artifact source is unapproved, checksum differs, credentials are requested, or outage is room-wide |
| .NET/Visual Studio/MSBuild: web targets or targeting pack missing | Developer PowerShell, `msbuild -version`, Visual Studio Installer components, first build error | Add ASP.NET/web workload, MSBuild, .NET Framework 4.8 targeting tools, and IIS Express through Visual Studio Installer; rerun Release validation | Installer/admin access is unavailable or copied target files are proposed |
| .NET LocalDB: instance missing, attach/startup failure | `sqllocaldb info MSSQLLocalDB`; connection string; first SQL error; data-file ownership | Install/repair LocalDB; use the documented instance and disposable lab database; preserve participant data and connection evidence | A business database, unknown MDF, destructive migration, or elevated server role is involved |
| NuGet: restore source/auth/version failure | `nuget sources`, first restore error, project/package references, proxy/network | Restore from approved sources; clear only the specific corrupt package/cache entry; keep versions aligned with the reviewed plan | Private-feed credentials, broad source changes, or dependency upgrades are required |
| Docker: daemon unavailable, pull/build/port failure | `docker version`; disk; architecture; first build error; `docker ps`; port owner | Start the approved daemon; free an owned port; rebuild one image; use cached approved base images; keep Dockerfiles and context scoped | Privileged daemon changes, untrusted images, registry credentials, or room-wide pull limits are involved |
| Modernize CLI: not found, assessment/plan fails, output differs | `modernize --version` or `--help`; exact source/output; network; generated path; first error | Fix PATH/install through the approved method; rerun with one explicit source/output; preserve actual generated filenames and content | Cloud delegation is requested without approval, output crosses roots, or a fake report is proposed |
| Copilot app/plugin: entitlement, context, agent, or install missing | App identity versus `gh auth status`; active entitlement; correct fork; new session; Settings > Plugins; `/agent` | Reopen the repository/session; close competing app/CLI instances; reinstall only the approved plugin/marketplace; keep least tools | Account/organization policy denies access, plugin asks for broader permissions, or identity cannot be reconciled |
| GitHub permissions: fork, push, issue, PR, secret, or Actions denied | `gh auth status`; `gh repo view`; fork owner; branch protection; actor role; organization policy | Use the participant fork, correct account, or maintainer-approved disposable repo; keep write exercises as previews when denied | Production access, admin elevation, bypass, token sharing, or policy exception is proposed |
| `gh-aw` compile: source/schema/actionlint or lock drift | `gh aw --version`; source frontmatter; pinned v0.89.21; compile error; generated diff | Use the pinned release; fix the Markdown source; recompile only named workflows; inspect locks; never hand-edit locks | Installed release cannot match, schema migration is needed, or conventional `ci-*.yml` files change |
| `gh-aw` run: no-op, auth, trigger, log, or safe-output failure | Actor/event/item, secret presence without value exposure, audit/log/outcomes, protected paths, exact validation | Treat valid no-op as safe; disable the workflow, preserve audit, close unwanted draft PR, and correct source through review | Unexpected write, suspected token exposure, protected-file mutation, production target, or missing audit evidence occurs |
| Azure policy/quota/region/cost denial | Resolved tenant/subscription/group, policy message, quota, SKU/region, budget approval, what-if | Record the real blocker and use no-deployment completion; choose another SKU/region only with owner and cost approval | A workaround weakens policy/security, uses a shared subscription, or lacks cost ownership |
| Azure RBAC/identity: 403, role propagation, database login | Exact principal/client ID, scope, assigned data/control roles, Key Vault/database grants, first service error | Correct the least-privilege role at the narrow scope; wait and re-query actual assignment; keep managed identity/passwordless design | Owner/User Access Administrator, secrets, broad public access, or schema-owner runtime access is proposed |
| Azure deployment: partial resources or unhealthy app | Deployment operation, outputs, logs, health paths/ports, image tag, exact resource group | Stop retries; capture sanitized failure; dry-run exact-group cleanup; fix locally; redeploy only after reviewed evidence | Resource ownership is unclear, data may be destroyed, or deletion is blocked |
| Cleanup: group remains, lock/policy denial, wrong name/tag | `.azure-lab`/tool outputs; subscription; exact group ID; required tag; dry-run resource list | Run the repository cleanup helper with exact confirmation; wait; verify `az group exists` returns `false` | Name/tag mismatch, unknown resources, deletion lock, policy denial, or result remains `true` |

If `gh aw compile --actionlint` reports an actionlint **tooling** error, rerun
with `--verbose`, inspect the exact emitted actionlint command, and run that
command separately. Accept only a zero exit with no findings. Do not convert a
real workflow finding into a tooling exception or hand-edit the generated lock.

## Package and network discipline

Maven and NuGet restores may contact approved package ecosystems. Do not
repeatedly clear all caches, switch to an unknown mirror, disable TLS, or copy
another participant's package/cache directories. A room-wide package failure is
a venue/network incident, not forty independent source defects.

## Safe checkpoint restore

When the participant has commits, inspect only the phase-owned paths:

```powershell
git --no-pager log --oneline --decorate -12
git --no-pager diff <good-checkpoint>..HEAD -- <phase-owned-paths>
git restore --source <good-checkpoint> -- <phase-owned-paths>
```

Use `git restore` only after the saved patch and recovery branch exist and the
participant agrees on the exact files. If there are no commits, use the
Copilot app/source-control diff to revert selected hunks or apply one of the
small cards above. Never overwrite the whole source root.

## Escalation packet

Provide the owning coach or service owner:

- participant/team and selected track;
- repository/fork and branch, without tokens;
- last passing checkpoint and exact failing command;
- first relevant error and sanitized versions;
- `git status --short` and affected paths;
- recovery attempts and their results;
- for GitHub: actor, repository, item/run ID, and audit link;
- for Azure: tenant/subscription label, exact resource-group ID, deployment
  operation, policy/quota/RBAC error, and cleanup state; and
- requested decision: repair, safe alternate path, policy owner, or stop.

Do not paste secrets, full environment dumps, connection strings, access
tokens, personal data, or sensitive logs into issues or the room channel.
