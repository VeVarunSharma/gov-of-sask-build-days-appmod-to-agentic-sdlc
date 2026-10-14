---
name: maven-diagnostics
description: Diagnose Maven reactor, dependency-resolution, plugin, Java-version, and test failures or audit Maven dependencies in this monorepo without automatically changing POM files.
---

# Maven diagnostics

Use this skill for `legacy-src/java-asset-manager` or
`capstone-src/api-java`, one root at a time.

## Guardrails

- Start read-only. Do not edit a POM, delete a cache, upgrade a version, add a
  repository, skip tests, or run a deployment goal as a diagnostic shortcut.
- Treat dependency downloads and plugin execution as networked side effects.
  Ask before running Maven when the request is only an audit.
- Never print Maven settings credentials, environment secrets, or repository
  tokens. Do not read `settings.xml` contents.
- Keep reports and temporary output out of the repository.

## Procedure

1. Read the root and module POMs, wrapper properties, nearest README, and the
   complete first Maven error.
2. Run the read-only inventory script:

   ```powershell
   .\.github\skills\maven-diagnostics\scripts\inspect-maven.ps1 -ProjectRoot legacy-src\java-asset-manager
   ```

   ```bash
   bash ./.github/skills/maven-diagnostics/scripts/inspect-maven.sh legacy-src/java-asset-manager
   ```

3. Classify the failure: wrapper/JDK, reactor/module, repository/network,
   dependency convergence, plugin lifecycle, compilation, or test.
4. If command execution is approved, prefer the wrapper and run the smallest
   command that proves the hypothesis, such as:
   - `mvnw.cmd -B -pl worker -Dtest=TestName test`
   - `./mvnw -B -pl worker dependency:tree -Dscope=runtime`
   - `./mvnw -B -pl worker help:effective-pom`
5. For a dependency audit, record direct/transitive coordinates, scope, source
   POM, version-management origin, known compatibility constraint, and the
   validation required for any proposed update.

End with evidence, root cause or ranked hypotheses, the smallest proposed
change, and an exact validation command. Do not apply upgrades unless the user
asks for implementation.
