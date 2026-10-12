# Facilitator resources

Use this area to operate the workshop without replacing participant work or
presenting prepared evidence as participant evidence.

## Start here

- [Single-room delivery guide](guide/): readiness, agenda, staffing,
  checkpoints, Azure safety, demos, acceptance, and closeout.
- [Recovery index and failure matrix](recovery/): symptom-led, non-destructive
  diagnosis and recovery.
- [Reference-solution index](reference-solutions/): verified acceptance shapes
  for Copilot customization, Java, .NET, `gh-aw`, QA, and the capstone.
- [Participant lab index](../labs/): the instructions participants follow.
- [Readiness and validation scripts](../scripts/): deterministic checks used by
  the guide and labs.

## Participant flow at a glance

- Lab 01 uses GitHub Copilot app Plan mode to create one human-approved durable
  specification.
- [Lab 02](../labs/02-copilot-instructions/) explains how repository-wide,
  path-specific, root, and local guidance work together; the facilitator should
  not invent a precedence rule.
- Lab 04 uses Modernize CLI for assessment and technical planning, then the
  Upgrade agent for reviewed, bounded execution.

## Operating rule

Reference solutions are comparison material, not checkpoint restores. Preserve
the participant's branch and diff, diagnose the first failed checkpoint, and
apply only the smallest relevant recovery card. Never copy a complete prepared
source tree over participant work.
