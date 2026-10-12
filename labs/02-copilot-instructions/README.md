# Lab 02: Copilot instructions and agent guidance

Customize GitHub Copilot for a monorepo without turning one technology's rules
into another technology's mistakes. You will trace every guidance source for
one file, improve one path-specific instruction, add one useful local pointer,
and prove the result in a fresh Copilot session.

## Outcomes

By the end of this lab, you can:

- explain the complementary roles of the global Copilot baseline,
  path-specific instructions, and root and co-located `AGENTS.md` files;
- trace the guidance that applies to a selected file without inventing an
  automatic precedence rule;
- choose an `applyTo` glob that does not cross Java, .NET, and React roots;
- keep `AGENTS.md` files concise through progressive disclosure; and
- verify both matching and non-matching behavior in a fresh Copilot session.

## The repository guidance model

Treat the repository as the system of record. Prompts can be forgotten and
sessions can end; reviewed files, commands, links, and CI remain available to
people and agents.

- [`.github/copilot-instructions.md`](../../.github/copilot-instructions.md)
  is the globally important repository baseline for GitHub Copilot coding,
  cloud-agent, and pull-request-review experiences. Keep short rules there that
  remain true across the repository, such as safety boundaries, approval
  expectations, and deterministic validation.
- [`.github/instructions/*.instructions.md`](../../.github/instructions/)
  provides path-specific Copilot guidance selected by `applyTo` frontmatter.
  Put technology, toolchain, command, and file-pattern rules there when they
  become accurate only for matching paths.
- The root [`AGENTS.md`](../../AGENTS.md) is the concise repository map. It
  points to source-root boundaries, shared invariants, and deeper guidance.
- A co-located `AGENTS.md` progressively discloses local context: the nearest
  component map, commands, durable invariants, and pointers that would bloat
  the root map.

These files are complementary. Do not claim that one automatically overrides
another. For a task, collect the global baseline, every matching path-specific
instruction, the root guide, and the nearest local guide. Follow compatible
guidance together; if two instructions conflict, stop and resolve the conflict
instead of assuming precedence.

This model follows four harness-engineering principles:

1. **Map, not manual.** Keep the root guide short and route readers to the
   authoritative detail.
2. **Progressive disclosure.** Add detail near the code that needs it rather
   than loading every task with every rule.
3. **Repository as system of record.** Store durable guidance beside the code,
   specifications, and commands it describes.
4. **Executable feedback loops.** Pair instructions with exact local commands
   and deterministic CI so a claim can be checked.

## Understand `applyTo`

A path-specific file begins with YAML frontmatter:

```markdown
---
applyTo: "capstone-src/api-java/src/test/**/*.java"
---

# Test guidance

- Write an observable, path-appropriate rule here.
```

`applyTo` globs are evaluated from the repository root. A comma-separated
string may contain multiple globs, but a single rooted glob is easier to
reason about for this exercise. More than one instruction file may match, so
matching rules must be compatible.

## Exercise

### 1. Select one file and trace all guidance

Choose one existing test file:

- Java:
  `capstone-src/api-java/src/test/java/dev/capstone/workitems/InMemoryWorkItemRepositoryTests.java`
- .NET:
  `capstone-src/api-dotnet/tests/WorkItems.Api.Tests/InMemoryWorkItemRepositoryTests.cs`
- React:
  `capstone-src/web-react/src/App.test.tsx`

Before editing, make a guidance trace with these four rows:

1. the global
   [Copilot baseline](../../.github/copilot-instructions.md);
2. the repository [root `AGENTS.md`](../../AGENTS.md);
3. the nearest co-located `AGENTS.md`:
   [Java](../../capstone-src/api-java/AGENTS.md),
   [.NET](../../capstone-src/api-dotnet/AGENTS.md), or
   [React](../../capstone-src/web-react/AGENTS.md); and
4. every file in
   [`.github/instructions/`](../../.github/instructions/) whose `applyTo`
   matches the selected file.

For each row, record one applicable rule or pointer and the evidence that makes
it relevant. Open every linked manifest, contract, source path, and validation
command before accepting the claim. This is the guidance-routing check: verify
the root guide and the nearest local guide explicitly rather than assuming a
product-specific discovery or precedence behavior.

### 2. Create or refine one path-specific instruction

Copy
[`starter/test-guidance.instructions.md`](starter/test-guidance.instructions.md)
to `.github/instructions/<track>-test-guidance.instructions.md`, or refine an
equivalent test instruction created by your group. Replace the marked values
and keep three to five concise rules that:

1. name the existing test framework or local convention;
2. point to the production behavior, contract, or existing test seam to use;
3. state an exact deterministic validation command and working directory;
4. prohibit live cloud, network, production-data, or timing dependencies; and
5. complement the existing language instruction instead of repeating it.

Use exactly one of these rooted scopes:

```text
capstone-src/api-java/src/test/**/*.java
capstone-src/api-dotnet/tests/**/*.cs
capstone-src/web-react/src/**/*.test.tsx
```

Do not broaden the glob merely to make an instruction appear in Copilot
context.

### 3. Add one local map entry or invariant

Open the nearest co-located `AGENTS.md` from your guidance trace. Add **one**
concise bullet that closes a real local gap, such as:

- a pointer to the established test seam; or
- a durable invariant that applies throughout that component.

Use the
[co-located guide worksheet](starter/co-located-agents-addition.md) before
editing. Do not copy the new path-specific rules into `AGENTS.md`, restate the
root guide, or turn the local guide into a manual. One useful pointer or
invariant is enough.

### 4. Restart and verify matching behavior

Save the files and start a **new Copilot session** so the repository context is
fresh. Add the selected test file to the session and ask:

```text
Without editing files, propose one additional test for this file. First list
the repository guidance you consulted: the global Copilot baseline, the root
AGENTS.md, the nearest local AGENTS.md, and every matching path-specific
instruction. Then cite the production behavior or contract to verify and the
smallest deterministic validation command.
```

In the response and its References or context details, verify:

- the global baseline was consulted;
- both the root and nearest local guides were read;
- the existing language instruction and your test instruction match;
- the proposed test follows the local pointer or invariant; and
- every cited path and command exists.

Reference displays vary across Copilot experiences. Record what the product
actually shows; do not infer an unseen precedence rule.

### 5. Verify non-matching behavior

Start another fresh session or clear the previous file context. Select a test
file from a different technology track and repeat the prompt.

Confirm that:

- your new path-specific instruction does not match or influence the answer;
- the other track's nearest local `AGENTS.md` and language instruction are
  used instead; and
- repository-wide guidance remains appropriate for both tracks.

If context appears cached, close and reopen the repository or start another
session. Fix an incorrect `applyTo`; do not widen it to hide a routing problem.

### 6. Explain what belongs globally

Write two or three sentences with your evidence:

- name one rule that belongs in `.github/copilot-instructions.md` because it is
  accurate across coding, cloud-agent, and review work; and
- explain why your test rule and local `AGENTS.md` addition do **not** belong
  there.

The expected answer distinguishes a stable repository-wide invariant from
technology-specific behavior and local navigation.

## Completion checklist

- [ ] The guidance trace includes the global baseline, root guide, nearest
      local guide, and all matching `applyTo` files.
- [ ] The instruction filename ends in `.instructions.md`.
- [ ] YAML frontmatter begins and ends with `---`.
- [ ] `applyTo` is quoted and rooted in exactly one intended source tree.
- [ ] The instruction contains three to five actionable, compatible rules.
- [ ] The co-located `AGENTS.md` change is one concise pointer or invariant.
- [ ] All referenced paths and commands exist or are explicitly future-facing.
- [ ] A fresh matching-file session uses the expected guidance.
- [ ] A fresh non-matching-file session does not use the new path instruction.
- [ ] The evidence explains what belongs globally and why.
- [ ] `git diff --check` reports no whitespace errors.

After completing the exercise, facilitators can compare the work with the
[path-specific reference](../../facilitator/reference-solutions/copilot/lab-02/capstone-java-test-guidance.instructions.md)
and the
[co-located guide reference](../../facilitator/reference-solutions/copilot/lab-02/capstone-java-agents-addition.md).
