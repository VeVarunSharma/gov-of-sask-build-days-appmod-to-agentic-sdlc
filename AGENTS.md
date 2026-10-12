# Repository agent map

Use this file as a routing map, not a complete operating manual.

## Read in this order

1. Read the root [README](README.md) for repository purpose and boundaries.
2. Read this guide, then the nearest `AGENTS.md` on the path to the files you
   will change. A local guide provides details for that subtree.
3. Follow the linked lab, specification, script, or customization guidance for
   the task.

## Find the right guidance

| Area | Start here |
| --- | --- |
| Participant flow | [Lab index](labs/README.md) |
| Requirements and acceptance criteria | [Specifications](specs/README.md) |
| Environment checks | [Readiness scripts](scripts/readiness/README.md) |
| Repeatable local gates | [Validation scripts](scripts/validation/README.md) |
| Repository-wide Copilot guidance | [Copilot instructions](.github/copilot-instructions.md) |
| Path-scoped customization | [Instructions](.github/instructions/README.md) |
| Custom agents and reusable skills | [Agents](.github/agents/README.md) · [Skills](.github/skills/README.md) |
| CI and agentic automation | [Workflow guidance](.github/workflows/README.md) |

## Source roots

Work in one selected Java or .NET modernization track unless the request
explicitly requires broader scope.

| Source | Purpose |
| --- | --- |
| [`legacy-src/java-asset-manager/`](legacy-src/java-asset-manager/) | Imported Java modernization baseline |
| [`legacy-src/dotnet-bookcatalog/`](legacy-src/dotnet-bookcatalog/) | Imported .NET modernization baseline |
| [`capstone-src/web-react/`](capstone-src/web-react/) | Capstone web client |
| [`capstone-src/api-java/`](capstone-src/api-java/) | Capstone Java API |
| [`capstone-src/api-dotnet/`](capstone-src/api-dotnet/) | Capstone .NET API |

## Repository-wide invariants

- **Respect imported boundaries.** Preserve provenance, notices, structure, and
  unrelated behavior under `legacy-src/`. Put greenfield participant work under
  `capstone-src/` unless a lab explicitly changes an imported application.
- **Use safe data.** Never commit secrets, credentials, tenant or participant
  data, private configuration, or real customer data. Use inert examples and
  visibly synthetic fixtures.
- **Prove changes deterministically.** Use the smallest documented readiness or
  validation gate that covers the change, record the command and observable
  result, and treat deterministic CI as merge authority. Agent judgment is not
  a passing gate.
- **Protect generated automation.** Edit `gh-aw` Markdown sources, not generated
  `*.lock.yml` workflow files. Regenerate locks with the repository-pinned
  tooling and review the resulting diff.
- **Escalate cross-cutting work.** Changes spanning tracks, shared contracts,
  repository automation, or multiple source roots require explicit scope,
  broader review, and every affected deterministic gate.
