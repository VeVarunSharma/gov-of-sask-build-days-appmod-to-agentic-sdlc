# Lab 01: Spec-driven development with Plan mode

Turn one small modernization need into a reviewed, durable specification before
asking an agent to change application code. You will use GitHub Copilot app Plan
mode to inspect a legacy application, clarify the intended change, refine a
bounded plan, and prepare a GitHub issue for a later `gh-aw` agentic workflow.

## Outcomes

By the end of this lab, you will have:

- inspected one application without changing it;
- refined a plan through questions and explicit human answers;
- created one durable change specification at
  `specs/<short-change-name>.md`;
- recorded testable acceptance criteria, editable paths, validation, and stop
  conditions; and
- created a human-approved, bounded GitHub issue for a later issue-to-PR
  `gh-aw` workflow.

## Choose a track

Complete one track. Do not modify the imported application in this lab.

- **Java**
  - Source root: `legacy-src/java-asset-manager`
  - Windows validation: `.\mvnw.cmd -B test`
  - macOS/Linux validation: `./mvnw -B test`
- **.NET**
  - Source root: `legacy-src/dotnet-bookcatalog/shared-legacy-app`
  - Developer PowerShell validation:
    `msbuild BookCatalog.sln -restore -p:Configuration=Release`

Run the selected validation command before planning the change. If it cannot
run because a documented prerequisite is unavailable, record the exact command,
error or missing prerequisite, and a reproducible manual check. Do not report a
passing baseline that you did not observe.

## Required and optional artifacts

This lab requires exactly one repository specification:

- `specs/<short-change-name>.md`, based on the
  [change specification template](../../specs/templates/change-specification.md).

The short change name should be specific and stable, such as
`java-upload-validation` or `dotnet-remove-user-agent`.

The [ADR](../../specs/templates/architecture-decision-record.md),
[test strategy](../../specs/templates/test-strategy.md), and
[implementation task breakdown](../../specs/templates/implementation-task-breakdown.md)
templates are optional references. A later exercise will decide when to create
those additional artifacts; they are not required for this lab. The GitHub issue
is created from the approved specification with the
[autonomous issue body template](../../specs/templates/autonomous-issue-body.md).

Completed [Java](../../specs/examples/java-upload-validation.md) and
[.NET](../../specs/examples/dotnet-remove-user-agent.md) examples show the
expected level of detail.

## Exercise

### 1. Start a fresh Plan-mode session

Open this repository in the GitHub Copilot app. Start a new session configured
for Plan mode using the option available in your version of the app. Do not
reuse an implementation conversation: a fresh session makes the evidence,
assumptions, and approval boundary easier to review.

Begin with a no-edit instruction:

```text
We are planning only. Inspect <source-root> without editing any file or running
commands that change repository state. Find one small modernization-relevant
behavior gap. Trace the current behavior from entry point to dependency, cite
exact paths and symbols, identify existing tests and the validation command,
and list uncertainties. Do not implement, scaffold, install, or commit anything.
```

Check the cited paths and symbols yourself. Choose a change that can be reviewed
independently and completed without redesigning the application.

### 2. Ask and answer clarifying questions

Planning is a conversation, not a one-shot prompt. Ask Copilot to expose missing
decisions before it generates a final plan:

```text
Before finalizing a plan, ask me the clarifying questions needed to remove
ambiguity about the user-visible problem, desired outcomes, compatibility and
security constraints, failure behavior, edge cases, scope, validation, and
conditions that must stop implementation. Do not guess an answer that requires
a product or maintainer decision.
```

Answer each question with a concrete decision or mark it as an unresolved
question that blocks implementation. Ask follow-up questions when an answer
changes scope. Keep repository facts separate from human decisions.

### 3. Refine the bounded plan

Once the important questions are answered, request a complete plan:

```text
Refine the plan using the repository evidence and my answers. Include:
1. the current problem and affected users;
2. observable outcomes and explicit non-goals;
3. functional and non-functional constraints;
4. normal, failure, boundary, and compatibility edge cases;
5. independently testable Given/When/Then acceptance criteria;
6. the exact allowed file or directory paths;
7. one primary validation command run from <source-root>; and
8. stop conditions for ambiguity, scope escape, failed baseline, missing
   prerequisites, secrets, destructive actions, or validation failure.
Keep the change implementation-neutral where possible. Cite evidence. Do not
edit files or implement the plan.
```

The allowed paths must be narrow enough to prevent unrelated cleanup but broad
enough to include the expected implementation and tests. A stop condition
instructs a later agent to halt and report rather than improvise outside the
approved contract.

### 4. Review the generated plan

Read the complete plan in the session. Do not treat generated text as approved
merely because it is detailed. Ask Copilot to challenge it:

```text
Review this plan as a skeptical maintainer. Identify unsupported assumptions,
ambiguous outcomes, missing failure or privacy cases, untestable acceptance
criteria, path-scope escapes, validation gaps, and any step that could exceed
the requested change. Cite the affected plan section. Do not implement.
```

Resolve every finding or record why the risk is accepted. Confirm that:

- every outcome maps to one or more acceptance criteria;
- constraints and non-goals define the change boundary;
- important edge and failure cases have expected behavior;
- allowed paths cover all anticipated changes and nothing unrelated;
- the validation command is valid for the selected track; and
- stop conditions prevent guessing or unsafe scope expansion.

### 5. Persist the durable change specification

A plan displayed in a chat or session is working context. It can be revised,
lost, or unavailable to a later workflow. It is not the durable contract.
The committed `specs/<short-change-name>.md` file is the repository-owned source
of intent that people and later automation can review without the planning
conversation.

Ask Copilot to convert the reviewed plan into the required template:

```text
Using the reviewed plan and our recorded answers, produce the complete Markdown
for specs/<short-change-name>.md using
specs/templates/change-specification.md. Preserve evidence citations, outcomes,
constraints, edge cases, numbered requirements, Given/When/Then acceptance
criteria, allowed paths, the primary validation command, non-goals, unresolved
questions, and stop conditions. Mark unknowns; do not invent facts. This request
is only for the specification artifact. Do not change application code.
```

Save the resulting Markdown at `specs/<short-change-name>.md` through the
documentation-editing method available to you, or copy it into that file
yourself. Review the diff and ensure that the only repository change is the
specification. Commit the specification so that its history and approval input
are durable. Creating this documentation artifact is not permission to begin
implementation.

### 6. End planning without implementation

Conclude the Plan-mode session without asking Copilot to execute the plan.
Product interfaces vary, so use the available method to leave or close the
planning session. Do not switch into an implementation flow, accept source-code
edits, install dependencies, or run an issue-to-PR workflow.

Record these handoff facts for the reviewer:

- the specification path and commit;
- the selected source root and observed baseline;
- any unresolved questions or accepted risks; and
- confirmation that no implementation started.

### 7. Pass the human approval gate

A participant or maintainer, not the drafting agent, must review the committed
specification. The reviewer checks the problem, outcomes, constraints, edge
cases, acceptance criteria, allowed paths, validation command, and stop
conditions.

Do not create the execution issue until the reviewer approves the specification.
Record the reviewer's name and approval date for the issue body. If the reviewer
requests a change, update and recommit the specification, then obtain approval
for the revised version.

### 8. Create the bounded GitHub issue

After human approval, start a non-implementation request in the GitHub Copilot
app:

```text
Prepare a GitHub issue from the approved
specs/<short-change-name>.md specification, following
specs/templates/autonomous-issue-body.md. Show the proposed title and body for
review before creation. Preserve the exact source root, primary validation
command, allowed paths, acceptance criteria, exclusions, stop conditions,
specification link, and human approval record. Do not implement the issue,
assign an agent, or trigger a workflow.
```

Review the proposed issue as if the implementer cannot access the Plan-mode
session. Create it only when it is complete. The issue is the bounded execution
contract used by later `gh-aw` workflows and must include:

- a link to the committed `specs/<short-change-name>.md`;
- one exact source root;
- one primary validation command;
- an explicit allowlist of editable paths;
- testable acceptance criteria;
- explicit exclusions and stop conditions; and
- the human reviewer's name and approval date.

Leave the issue unassigned and do not trigger automation during this lab.

## Verification

Before completing the lab:

1. Confirm the selected baseline command was run from the source root, or that
   the exact blocking prerequisite and manual check were recorded.
2. Use `git diff --name-only <baseline>...HEAD` or the equivalent comparison to
   confirm the specification is the only committed lab artifact and no
   application code changed.
3. Open every relative link in the specification and issue body.
4. Search the specification and issue for unresolved placeholders such as
   `{{placeholder}}`, `TBD`, and `TODO`.
5. Verify every outcome and requirement maps to at least one acceptance
   criterion.
6. Verify the acceptance criteria cover normal, failure, boundary, and relevant
   compatibility behavior.
7. Confirm every anticipated implementation or test path is inside the allowed
   path list.
8. Copy the validation command from the specification and confirm it targets the
   selected source root.
9. Confirm the issue repeats the exclusions, stop conditions, and human approval
   record.
10. Re-read the committed specification and issue without relying on the
    planning chat. A later implementer must have enough information to proceed
    safely or stop.

## Completion criteria

The lab is complete when:

- repository evidence supports the stated current behavior;
- one committed `specs/<short-change-name>.md` captures the approved intent;
- outcomes, constraints, edge cases, acceptance criteria, allowed paths,
  validation, and stop conditions are explicit;
- a human has approved the committed specification;
- the bounded GitHub issue contains no unresolved placeholders;
- validation evidence or a precise environment limitation is recorded; and
- Plan mode ended without implementation or automation starting.
