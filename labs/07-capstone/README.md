# Lab 07: Capstone

Combine one or more pathways into a small, demonstrable outcome. Your team
chooses the domain; the workshop does not assign a service, ministry, or policy
area. Keep the slice low risk, use synthetic data, and make the engineering
evidence as important as the demo.

## Outcomes

By the end of the capstone, your team will have:

- a reviewed problem statement, user group, constraints, and acceptance
  criteria;
- one thin end-to-end demo slice;
- repository instructions plus an agent or skill appropriate to the work;
- repeatable build, test, and safety evidence;
- a short demo with known limitations; and
- optional Azure or GitHub Agentic Workflow (`gh-aw`) evidence when approved.

## Choose and combine pathways

| Pathway | Start here | Primary outcome |
| --- | --- | --- |
| A. Deepen modernization | [Modernization deep dive](pathways/01-modernization-deep-dive.md) | Extend the Java or .NET application selected in Lab 04 without reopening the whole migration. |
| B. Build a public-service app | [React plus API](pathways/02-public-service-app.md) | Turn the domain-neutral React starter and either API into a polished Government of Saskatchewan-relevant demo. |
| C. Automate an engineering pain point | [Advanced `gh-aw`](pathways/03-agentic-workflow.md) | Build a guarded workflow that produces an auditable engineering outcome. |

The paths are combinable. For example, a team can add a focused feature to its
modernized application, improve the user experience with the React starter,
and create a workflow that checks the feature's acceptance evidence. Do not
combine paths by expanding beyond what can be validated and demonstrated.

## Safety boundary

The capstone is a workshop prototype, not a production service or policy
decision system.

- Use invented names, identifiers, addresses, records, and scenarios. Do not
  copy real resident, employee, client, case, health, justice, tax, or benefits
  data.
- Do not determine or recommend eligibility, entitlement, enforcement,
  sentencing, health treatment, employment, licensing, or other high-stakes
  outcomes.
- Prefer informational, inventory, coordination, status, and internal
  engineering scenarios. A human remains accountable for every decision.
- Do not add credentials, tokens, connection strings, production endpoints, or
  unrestricted telemetry to the repository.
- Treat prompts, issues, pull requests, uploaded files, and model output as
  untrusted input. Validate them before use.
- Stop when a requested feature needs production data, an unapproved external
  system, broad repository permissions, or an unreviewed Azure deployment.

Safe example domains include a provincial facility maintenance board, public
park amenity inventory, non-emergency road-work communication planner,
government website content review queue, or internal application upgrade
dashboard. These are examples only; participants select their own domain.

## 1. Frame the capstone

Copy the [specification template](starter/capstone-spec.md) to
`specs/capstone/<team-name>.md`. Replace every marked placeholder and record a
human approval before implementation.

Answer these questions:

1. **Problem:** What observable problem is worth improving?
2. **Users:** Who directly uses the slice, and who is affected by it?
3. **Constraints:** What time, platform, data, accessibility, security, and
   scope limits apply?
4. **Acceptance:** What must a reviewer see or run to call the slice complete?
5. **Privacy:** What data is needed, what is prohibited, and how is synthetic
   data recognizable?
6. **Security:** What are the trust boundaries, abuse cases, secrets rules,
   authorization assumptions, and stop conditions?
7. **Demo slice:** What is the smallest end-to-end journey that proves value in
   three minutes?

Keep one authoritative validation command or a short ordered command list in
the specification. Do not use a command that silently deploys, deletes, or
contacts a production system.

## 2. Add repository guidance

Use the starter assets as patterns, not as unchecked policy:

- copy
  [`capstone.instructions.md`](starter/capstone.instructions.md) to
  `.github/instructions/capstone.instructions.md` and narrow `applyTo`;
- copy
  [`capstone-review.agent.md`](starter/capstone-review.agent.md) to
  `.github/agents/<team-name>-capstone-review.agent.md`;
- copy the
  [`capstone-validation` skill](starter/capstone-validation/SKILL.md) to
  `.github/skills/<team-name>-capstone-validation/SKILL.md`; and
- keep the approved specification under `specs/capstone/`.

The specification defines the outcome. Instructions define durable repository
rules. An agent defines a bounded persona and tools. A skill defines a reusable
procedure. Do not put all four concerns into one oversized prompt.

Start a new Copilot session after adding or changing agents and skills. Confirm
the selected agent exposes only the tools it needs and the skill appears in
References/context when invoked.

## Challenge menu

Choose one level as the team's committed scope. Higher levels include the
lower-level evidence but not necessarily every optional item.

### Beginner

- Complete one pathway with one happy-path demo journey.
- Write an approved specification with three to five acceptance criteria.
- Adapt the capstone instructions to one source root.
- Use the read-only review agent before implementation.
- Add or update at least one automated test and run the pathway's required
  validation.
- Explain privacy, security, accessibility, and known limitations in the demo.

### Intermediate

- Combine two pathways or add an error/empty-state journey.
- Create a domain-specific validation skill with a deterministic command.
- Add accessibility checks for keyboard use, labels, focus, contrast, and
  understandable error text.
- Add contract, integration, or persistence coverage beyond the happy path.
- Produce a container build or a reviewed deployment plan.
- Make the demo traceable from acceptance criterion to evidence.

### Advanced

- Combine all three pathways or create a production-shaped boundary without
  claiming production readiness.
- Add least-privilege identity, structured audit evidence, and threat-model
  mitigations.
- Build a guarded `gh-aw` workflow with explicit activation, tool/network
  allowlists, quotas, no-op behavior, and safe outputs.
- Add resilience or observability evidence without recording personal or
  secret data.
- Run an approved disposable Azure deployment, verify it, and prove exact
  cleanup.

## Required deliverables

Submit links or repository paths for:

1. the approved capstone specification;
2. the changed application or workflow files;
3. the capstone instructions and any agent or skill used;
4. automated tests and the exact validation output or run link;
5. a short architecture or data-flow sketch;
6. privacy, security, accessibility, and limitation notes;
7. the demo script; and
8. Azure cleanup or `gh-aw` audit evidence when those options were used.

Do not include tokens, secret values, generated dependency folders, build
outputs, resident data, or raw logs that may contain sensitive values.

## Required validation

Run the exact gate for every selected pathway:

- [Pathway A validation](pathways/01-modernization-deep-dive.md#required-validation)
- [Pathway B validation](pathways/02-public-service-app.md#required-validation)
- [Pathway C validation](pathways/03-agentic-workflow.md#required-validation)

Also run from the repository root:

```powershell
git diff --check
git status --short
```

Review every changed path. Build output, local environment files, credentials,
and unrelated tracks must not be present.

## Optional Azure deployment and cleanup

Azure is never required for capstone completion. Continue only with approved
subscription, region, budget, role, resource-group name, and public exposure.
Run the repository [preflight helper](../../scripts/azure/README.md), review an
infrastructure what-if or equivalent plan, and deploy only to an isolated,
tagged resource group.

Cleanup must default to a dry run and target the exact resource group. Record
the final `az group exists` result. A policy, quota, role, or cost blocker plus
complete local evidence is a valid no-deployment outcome; weakening security is
not.

## Optional `gh-aw` integration

Teams on Pathway A or B can add a bounded workflow from Pathway C. Compile and
inspect it, but do not dispatch a write-capable run unless the repository is a
disposable workshop fork and a maintainer explicitly approves the trigger.
Generated lock files are build artifacts: never edit them by hand.

## Demo checklist

- [ ] State the problem, users, selected pathway level, and non-goals.
- [ ] Show the approved acceptance criteria.
- [ ] Demonstrate one complete journey with synthetic data.
- [ ] Demonstrate one validation, error, empty, or no-op behavior.
- [ ] Show the most relevant automated test and its real result.
- [ ] Explain privacy, security, accessibility, and trust boundaries.
- [ ] Show the agent/skill/workflow boundary rather than only its output.
- [ ] Name one known limitation and one sensible next step.
- [ ] If Azure was used, show the cleanup evidence.
- [ ] If `gh-aw` was used, show compile, audit, safe-output, and no-op evidence.

## Judging rubric

Score each category from 0 to 4 for a maximum of 24.

<!-- markdownlint-disable MD013 -->

| Category | 0 | 2 | 4 |
| --- | --- | --- | --- |
| Problem and users | Unclear | Plausible but broad | Specific, evidence-led, and bounded |
| Working slice | No usable journey | Partial or happy path only | Polished end-to-end slice with failure handling |
| Engineering quality | No repeatable gate | Build/tests partly repeatable | Focused design, tests, and reproducible validation |
| Responsible delivery | Safety absent | Risks listed | Privacy, security, accessibility, and human oversight shape the design |
| Agentic practice | Unbounded prompt | Some reusable guidance | Specs, instructions, agents/skills/workflows have clear least-privilege roles |
| Evidence and demo | Claims without proof | Some evidence | Acceptance criteria map directly to observed results and limitations |

<!-- markdownlint-enable MD013 -->

Ties should favor the safer, smaller, better-evidenced solution rather than the
largest feature set.

## Completion

The capstone is complete when the selected slice works locally, all selected
pathway gates pass, required deliverables are present, safety boundaries remain
intact, and the team can demonstrate the result without relying on real
personal data or an unverified claim.
