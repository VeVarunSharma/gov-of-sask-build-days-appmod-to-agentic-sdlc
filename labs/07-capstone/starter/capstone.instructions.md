---
applyTo: "capstone-src/**"
---

# Capstone implementation instructions template

> Starter template: copy to `.github/instructions/capstone.instructions.md`,
> replace the marked values, and narrow `applyTo` to the selected source root.

- Treat `{specs/capstone/<team-name>.md}` as the approved source of truth.
- Work only in `{selected source root}` and its explicitly allowed evidence
  paths. Do not inspect or edit another language track.
- Use synthetic workshop data. Do not add real personal, case, employee,
  resident, health, justice, tax, licensing, benefits, or production data.
- Do not implement high-stakes eligibility or recommendation logic.
- Preserve server-side validation, least privilege, accessibility, and
  existing accepted behavior.
- Never commit secrets, `.env.local`, tokens, connection strings, deployment
  outputs, dependency folders, or build artifacts.
- Implement one acceptance criterion at a time. Run `{smallest affected test}`
  after each coherent change.
- Before completion, run `{authoritative validation command}` and report the
  actual result. Do not claim a command, deployment, cleanup, or agent action
  succeeded without evidence.
- Stop when work requires an unapproved path, external system, Azure scope,
  permission, destructive action, or weakened safeguard.
