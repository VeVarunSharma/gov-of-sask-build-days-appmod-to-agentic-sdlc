---
name: capstone-validation
description: Run and summarize the approved deterministic validation gate for one capstone source root.
---

# Capstone validation skill template

Load the approved capstone specification and identify its single selected
source root and authoritative validation command.

## Procedure

1. Confirm the specification is approved and the command is deterministic,
   local-first, and non-destructive.
2. Confirm the command does not deploy, delete, print secrets, contact a
   production endpoint, chain hidden fallback behavior, or cross source roots.
3. Record `git status --short` before validation.
4. Run only the approved command from its documented working directory.
5. Record the exit code and concise test/build counts.
6. Run `git diff --check` and record `git status --short` afterward.
7. Report **Passed**, **Failed**, or **Stopped for safety** with the first
   actionable error and changed-path summary.

## Guardrails

- Do not edit files, install unapproved tooling, retry with weaker flags,
  dispatch workflows, deploy resources, or clean unrelated output.
- Do not expose environment values, tokens, connection strings, or raw logs
  that may contain sensitive data.
- Stop if the command or observed changes exceed the approved source root.
