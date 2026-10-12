---
applyTo: "scripts/azure/**,infrastructure/**,infra/**,**/*.bicep,**/*.tf,**/*.tfvars"
---

# Infrastructure and operational automation

- Default to inspection, validation, or dry-run behavior. Require explicit
  approval before deployment, deletion, role assignment, policy changes, or
  cost-bearing resource creation.
- Parameterize subscription, tenant, region, resource names, and SKU. Never
  embed credentials, access keys, tokens, or participant-specific identifiers.
- Make scripts fail fast, quote paths, validate required tools, and return a
  non-zero exit code on failure. PowerShell scripts should use
  `Set-StrictMode -Version Latest` and `$ErrorActionPreference = 'Stop'`; Bash
  scripts should use `set -euo pipefail`.
- Prefer idempotent operations and show what will change. Document cleanup,
  expected cost, required permissions, and safe rerun behavior.
- Treat generated plans and CLI output as potentially sensitive. Redact secret
  values and do not commit state files, deployment outputs, or environment
  caches.
