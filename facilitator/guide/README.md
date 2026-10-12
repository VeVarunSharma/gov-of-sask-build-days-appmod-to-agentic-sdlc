<!-- markdownlint-disable MD013 -->

# Single-room facilitator runbook

This runbook supports one room of up to 40 participants. Participants complete
[Lab 00](../../labs/00-readiness/) before arrival, choose one modernization
track, and work in a fork or other disposable workshop repository. The
participant [lab index](../../labs/) remains the source of truth.

## Delivery principles

1. Evidence before action: ask for the command, first error, diff, and last
   passing checkpoint.
2. One track per participant or pair: Java or .NET, not both.
3. Contract before tooling: use Lab 01 Plan mode to approve one durable spec,
   then use Modernize CLI to assess and create a technical plan, reconcile that
   proposal, and review Upgrade-agent execution before deployment.
4. Participant-owned cloud only: no shared, production, or facilitator
   subscription.
5. Local completion is valid: policy, quota, RBAC, or cost can make deployment
   optional or blocked.
6. Preserve work: use branches, commits, stashes, and small patches; never
   replace a participant tree with a reference solution.
7. Model output is a proposal. A human reviews every command, diff, safe
   output, deployment, and deletion.

## Staffing and room layout

For 21-40 participants, use five roles where possible:

| Role | Primary responsibility |
| --- | --- |
| Lead facilitator | Timebox, room announcements, safety stops, and show-and-tell |
| Java coach | Maven/JDK, Spring, container, and Java recovery |
| .NET coach | Visual Studio/MSBuild/LocalDB, EF Core, and .NET recovery |
| Platform coach | Copilot app/plugins, GitHub permissions, `gh-aw`, Docker, and Azure |
| Roving coach/scribe | Queue triage, checkpoint board, evidence, and accessibility/logistics |

With fewer coaches, keep the lead out of long workstation debugging and combine
the roving/platform roles first. Seat Java and .NET participants in visible
zones. Maintain a public board with participant or team name, track, current
checkpoint, blocker category, coach, and next update time. Do not put tokens,
subscription IDs, tenant details, or personal data on the board.

## Pre-event readiness

### Seven to three days before

- Confirm the repository default branch, event tag or commit, license, and
  access model.
- Require one fork per participant or pair unless an approved disposable
  organization repository is provided. Grant the least role needed; do not
  grant organization administration for the workshop.
- Ask participants to clone their fork, add the workshop repository as
  `upstream`, and complete [Lab 00](../../labs/00-readiness/).
- Collect only pass/fail summaries and blocker categories. Never collect
  credentials or full environment dumps.
- Confirm venue power, display, microphones, accessible seating, guest Wi-Fi,
  VPN/proxy behavior, and a second network path.
- Pre-download approved installers and package caches where licensing permits.
  Do not distribute credentials, container registry tokens, or copied package
  folders.
- Decide whether Azure deployment and live `gh-aw` runs are allowed. The
  default is local validation plus compile/preview only.

### Facilitator repository check

From a clean facilitator clone:

```powershell
git status --short
git rev-parse HEAD
gh auth status
gh repo view --json nameWithOwner,isFork,parent
```

Run the common and both track readiness checks on representative Windows
machines. Run the portable Java checks on every supported operating system:

```powershell
.\scripts\readiness\check-common.ps1 -AcknowledgeCopilotApp
.\scripts\readiness\check-java.ps1
.\scripts\readiness\check-dotnet.ps1
```

Validate the imported baselines:

```powershell
.\scripts\validation\validate-java.ps1
.\scripts\validation\validate-dotnet.ps1
```

The Java baseline has a documented upstream test limitation. Review the
[Java reference](../reference-solutions/java-modernization/) and
[known-test recovery card](../recovery/java/known-upstream-test.md) before
classifying it. The classic .NET baseline is Windows-only.

### Repository and fork setup

Participants should be able to show:

```powershell
git remote -v
git status --short
gh auth status
gh repo view --json nameWithOwner,isFork,parent
```

Require a participant-owned branch before edits. Protect or avoid the default
branch. Confirm the participant can push to the fork and create a draft pull
request, but do not require a live PR or workflow run merely to prove access.
If a participant cannot fork, use an approved disposable repository with a
named owner and cleanup plan; never fall back to the production repository.

### Copilot app and plugin check

Each participant manually confirms:

- the GitHub Copilot app opens the correct fork and shows an active entitlement;
- the signed-in GitHub identity matches `gh auth status`;
- a fresh repository session offers Plan mode;
- repository instructions appear in a new session;
- **Settings > Plugins** allows the
  `microsoft/upgrade-agent-plugins` marketplace;
- `upgrade-agent` is installed and `/agent` shows
  `upgrade-agent:upgrade`, or **Upgrade** appears in the picker; and
- `modernize --help` and `copilot --version` run from a terminal.

If **Install** remains visible, close other Visual Studio, VS Code, and Copilot
CLI instances, reopen the app, and retry. Do not broaden plugin permissions or
switch accounts until the identity mismatch is understood.

### `gh-aw` preview and version check

The checked-in workflow locks were generated with `gh aw version v0.89.21`.
The CLI and workflow schema are evolving; a different release can change
generated locks, validation, or supported frontmatter.

```powershell
gh aw --version
```

Do not upgrade or recompile all locks during the event. Use the pinned release
for the labs, or keep the exercise to source review and `--help` previews.
Never hand-edit `.lock.yml` files. A deliberate version change requires a
separate reviewed change, full recompilation, `actionlint`, and lock-diff
review. Live write-capable runs are restricted to disposable workshop forks.

## Track selection

Complete selection during readiness:

| Choose Java when | Choose .NET when |
| --- | --- |
| JDK 8 and 21 plus Maven/wrapper checks pass | Windows, Visual Studio/MSBuild, .NET 10, and LocalDB checks pass |
| The participant wants Spring/Java and two-container modernization | The participant wants ASP.NET MVC/EF modernization |
| Docker and local ports are available | The classic MVC 5 Release baseline builds |

If neither baseline passes, pair the participant with a ready workstation or
use the planning/review portions of Labs 01-03, 05-07. Do not consume the event
repairing an unmanaged workstation, and do not claim Lab 04 completion.

## Optional expanded delivery agenda

The official 10:00 AM-3:00 PM event agenda is in the
[root participant README](../../README.md#event-agenda). The schedule below is
an optional extended 09:00-17:00 delivery format for a future or separately
scheduled full day. It keeps Azure deployment optional and treats Lab 04 as the
main hands-on block. For the complete .NET track or a full Java cloud migration,
use this expanded format or schedule additional lab time.

| Time | Activity | Room checkpoint |
| --- | --- | --- |
| 09:00-09:25 | Lab 00 confirmation, safety, track seating | Fork, branch, Copilot app, and baseline status visible |
| 09:25-10:00 | [Lab 01](../../labs/01-spec-driven-development/) | One durable specification plus human approval boundary |
| 10:00-10:30 | [Lab 02](../../labs/02-copilot-instructions/) | Global/path/local trace plus matching and non-matching evidence |
| 10:30-11:05 | [Lab 03](../../labs/03-custom-agents-and-skills/) | Bounded agent and read-only skill evidence |
| 11:05-11:15 | Break and blocker reset | Coaches reassign unresolved blockers |
| 11:15-12:25 | Lab 04 assess and reconcile technical plan | Reviewed Modernize CLI assessment and plan |
| 12:25-13:05 | Lunch | No unattended deployments or workflow runs |
| 13:05-14:35 | Lab 04 execute and local verify | Smallest changed phase passes locally |
| 14:35-15:25 | [Labs 05](../../labs/05-agentic-workflows/) and [06](../../labs/06-automated-qa/) | Compile/inspect or preview; no production write |
| 15:25-15:35 | Break and cleanup call | Stop new cloud creation |
| 15:35-16:30 | [Lab 07](../../labs/07-capstone/) | Thin slice, validation, and demo script |
| 16:30-17:00 | Show-and-tell and closeout | Evidence, limitations, cleanup, and next step |

Announce hard stops at lunch, 15:25, and 16:30. A participant who is behind
moves to the documented no-deployment or no-live-run route rather than skipping
verification.

## Coach prompts and checkpoints

Use questions that elicit evidence instead of taking the keyboard:

### Opening and Labs 01-03

```text
Show the one durable specification produced from the Lab 01 Plan-mode session.
Where are the exact source root, authoritative validation command, allowed
paths, and stop conditions? Which statement is repository evidence and which
is an assumption?
```

```text
Show the instruction or skill in Copilot References/context. Now select a
non-matching file and prove that the scoped guidance does not apply.
```

Checkpoint: a human can explain the boundary; the source-control view contains
only intended documentation/customization changes.

### Lab 04

```text
Show the approved durable specification from the Lab 01 Plan-mode method.
Which intent, constraints, acceptance criteria, allowed paths, validation, and
stop conditions are authoritative? Now show the Modernize CLI assessment
evidence and generated technical plan. Where did you reconcile scope, security,
cost, validation, stop conditions, deployment boundaries, and cleanup before
reviewing Upgrade-agent execution?
```

```text
Name the last passing checkpoint and the first failing command. Show the first
error and current diff. Which single phase owns the failing files?
```

```text
Ask Copilot to repair only that phase, preserve the listed behavior, avoid
secrets and other tracks, and run the smallest phase check before the full
gate. Review the proposed command and diff before approval.
```

Checkpoint: Java progresses through A-J in the
[Java lab](../../labs/04-app-modernization/java/); .NET progresses through
Specify, Assess, Plan, Execute, and Verify in the
[.NET lab](../../labs/04-app-modernization/dotnet/). A broad rewrite, hidden
test failure, generated plan treated as approval, password fallback, or
unrelated-track edit is a room stop.

### Labs 05-06

```text
Explain the trigger, actor, permissions, tools, network, limits, protected
paths, validation, safe output, no-op, audit, disable, and rollback behavior.
What prevents untrusted issue, PR, test, or log text from expanding scope?
```

Checkpoint: the participant can distinguish deterministic CI from agentic
judgment, generated locks have no unreviewed drift, and no write-capable run
targets a production repository.

### Capstone demo prompt

```text
In three minutes: state the user and non-goals, show one acceptance criterion,
demonstrate one successful journey and one failure/empty/no-op behavior, run or
show the exact validation evidence, explain the agent/cloud boundary, then
name one limitation and next step.
```

## Room triage

Use a four-minute first response:

1. **Stabilize:** stop retries, deployment, or agent execution.
2. **Capture:** command, first error, versions, `git status --short`, and last
   passing checkpoint. Sanitize before sharing.
3. **Classify:** workstation/tooling, repository/baseline, participant change,
   GitHub/Copilot, container/package, Azure, or venue/network.
4. **Route:** link the [failure matrix](../recovery/), assign one coach, and
   state the next update time.

Escalate a blocker to the lead after 10 minutes or two unsuccessful focused
attempts. At 20 minutes, move the participant to a safe alternate path while a
coach continues offline. Never have several coaches issue conflicting edits.

## Venue and network contingency

| Condition | Safe event response |
| --- | --- |
| Wi-Fi degraded | Stop installs, restores, image pulls, deployments, and live runs; use cached dependencies and local review exercises |
| Internet unavailable | Continue specs, instructions, agents/skills, source review, local builds already restored, and prepared screenshots; record external checks as blocked |
| GitHub unavailable | Work on local branches; do not simulate issues, PRs, or workflow results as real evidence |
| Azure unavailable | Use local verification and the documented no-deployment route; do not switch to an unknown subscription |
| Power interruption | Save editors, stop new writes, preserve diffs, and resume from the last verified checkpoint |
| Projector/demo failure | Use the checkpoint board and participant screen rotation; never ask participants to expose tokens or account pages |

Prepared screenshots must be clearly labeled illustrative. They cannot satisfy
participant acceptance or deployment evidence.

## Azure guardrails and cleanup

Azure work is optional and uses only a participant-owned subscription,
approved region/SKU/budget, unique naming prefix, and dedicated tagged resource
group. Before creation, require the participant to show the resolved tenant,
subscription, exact resource-group name, expected prefix, and tag with the
[preflight helper](../../scripts/azure/README.md).

Stop and use the no-deployment path when policy, quota, RBAC, region, cost, or
role-assignment approval blocks the reviewed design. Never:

- assign Owner or User Access Administrator as a workshop workaround;
- add a database password, storage key, SAS token, or connection string to
  source control;
- broaden public access, client IP ranges, or runtime database privileges;
- deploy into a shared, existing, production, or ambiguously owned group; or
- change region/SKU repeatedly without owner and cost approval.

Deployment completion requires the reviewed plan/what-if, exact tool-reported
outputs, healthy application status, one real smoke journey, persistence or
message behavior where applicable, and confirmation that the intended managed
identity and least-privilege roles are in use. A successful deployment command
alone is not acceptance. Sanitize URLs and logs before presenting them.

Cleanup starts before show-and-tell. Run the cleanup helper in dry-run mode,
review every resource and the required tag, then execute only with the exact
resource-group confirmation. Completion requires:

```powershell
az group exists --name <exact-resource-group> --output tsv
```

The result must be `false`. “Delete requested” is not completion. Escalate
locks, policy denials, or persistent deletion to the subscription owner with
the exact resource-group ID; do not delete similarly named resources.

## Expected participant artifacts

Generated filenames can vary by tool version. Tool-reported paths and observed
results are authoritative; participants must not create fake reports to satisfy
this table.

| Lab | Minimum evidence |
| --- | --- |
| 00 | Common and selected-track readiness result, manual Plan-mode and Upgrade-agent check, baseline validation result, and Azure preflight/no-Azure decision |
| 01 | One human-approved durable change specification created from Plan mode, plus baseline evidence |
| 02 | One scoped `.instructions.md`, matching References/context evidence, and a non-matching check |
| 03 | One read-only bounded review agent, selected diagnostic skill output, and unchanged selected source root |
| 04 Java | Approved durable spec, baseline, generated Modernize CLI assessment, reconciled technical plan, reviewed Upgrade-agent execution, phase tests, local/image verification, and deployment or blocker plus cleanup |
| 04 .NET | Approved durable spec, baseline, generated Modernize CLI assessment, reconciled technical plan, reviewed Upgrade-agent execution, Release/local behavior evidence, and Azure deployment or no-deployment plus cleanup |
| 05 | Reviewed workflow sources and generated locks, pinned-version compile/validation evidence, no-op/safety explanation, and optional disposable-run audit |
| 06 | Reviewed QA/remediation sources and locks, deterministic CI distinction, compile/validation evidence, and optional disposable-run audit |
| 07 | Approved capstone spec, scoped instructions/agent/skill, thin slice, tests and validation, architecture/safety/limitations, demo script, and optional cleanup/audit |

Use the [reference index](../reference-solutions/) to compare acceptance shape,
not exact generated code or output.

## Facilitator acceptance checklist

Before declaring the event complete:

- [ ] Every participant used a fork/disposable repository and one selected
  track.
- [ ] Readiness and the selected imported baseline were evidenced or the
  blocker was recorded.
- [ ] Copilot entitlement, repository context, and required plugin discovery
  were checked manually.
- [ ] Human approval preceded implementation or write-capable automation.
- [ ] Each completed lab has the minimum artifacts above and real validation
  evidence.
- [ ] No participant claims fabricated Modernize, Copilot, GitHub, CI, or Azure
  output.
- [ ] No secrets, personal data, production endpoints, build outputs, or
  unrelated-track changes are staged.
- [ ] `gh-aw` locks were compiler-owned and the pinned-version caveat was
  observed.
- [ ] Every Azure participant either did not deploy, documented the blocker, or
  proved exact resource-group deletion with `false`.
- [ ] Live workflow runs, if any, used approved disposable forks and have audit
  evidence.
- [ ] Show-and-tell covered problem, evidence, failure behavior, safety,
  limitations, and next step.
- [ ] Participants know where their fork, branch, issue/PR, evidence, and
  cleanup record live.

## Show-and-tell and closeout

Select four to six teams across tracks. Give each three minutes plus one minute
for a question. Favor a smaller, well-evidenced outcome over a larger
unverified one. A safe no-op or no-deployment result can be a strong demo.

Close in this order:

1. announce the stop on new deployments and write-capable runs;
2. verify Azure cleanup and close unwanted draft PRs/branches without erasing
   audit history;
3. run `git status --short` and review staged/untracked files for secrets and
   generated output;
4. record incomplete work, blockers, owners, and safe next actions;
5. remind participants that workshop prototypes are not production approvals;
6. archive sanitized feedback, timings, incident categories, and version
   notes; and
7. publish only reviewed links and participant-approved screenshots.

For failures, continue with the [recovery index](../recovery/). For acceptance
comparisons, use the [facilitator references](../reference-solutions/).
