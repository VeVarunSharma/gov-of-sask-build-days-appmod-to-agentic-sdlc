# Java asset manager modernization assessment

## Current state

The imported application is a Maven reactor with `web` and `worker` modules.
The root `legacy-src/java-asset-manager/pom.xml` declares Java 8 and Spring Boot
2.7.18. Runtime behavior spans local storage, Amazon S3, RabbitMQ, and the two
module-specific Spring applications.

## Goals and non-goals

The goal is to identify incremental framework and runtime modernization phases
while preserving upload and background-processing behavior. Replacing storage,
messaging, or cloud providers and changing product behavior are non-goals.

## Constraints

The imported source must remain recognizable, both modules must stay buildable,
secrets must remain external, and each phase needs a deterministic validation
step that does not require a live cloud service.

## Dependencies

The Spring Boot parent, Java language level, Maven wrapper, web module, and
worker module are coupled through the root reactor. Framework compatibility
must be checked before changing Java or Spring generations.

## Risks

Major risks are Jakarta namespace changes, library compatibility, configuration
drift between modules, and tests that accidentally require S3 or RabbitMQ.

## Options

One option is a single framework jump; it has a large rollback and diagnosis
surface. The preferred option separates characterization tests, JDK uplift,
dependency remediation, and framework uplift into independently validated
phases.

## Recommendation

Start with behavior characterization and dependency evidence. Upgrade one
compatibility boundary at a time and keep provider changes out of the framework
upgrade.

## Phases

1. Record baseline commands and add deterministic boundary tests.
2. Produce a dependency and plugin compatibility inventory.
3. Upgrade the JDK within the current framework's supported range.
4. Upgrade Spring Boot and address namespace/API changes.
5. Re-run full reactor and manual behavior checks.

## Validation

Run `mvnw.cmd -B test` on Windows or `./mvnw -B test` on macOS/Linux from
`legacy-src/java-asset-manager` after each code-bearing phase. Record any
external-service simulation used by tests.

## Rollback

Keep each phase in a reviewable commit and revert the failing phase rather than
mixing framework, provider, and product changes.

## Open decisions

Maintainers must approve the target Java and Spring Boot versions, supported
deployment environment, and whether any live-service integration suite is
required.

## Evidence

- `legacy-src/java-asset-manager/pom.xml`
- `legacy-src/java-asset-manager/web/pom.xml`
- `legacy-src/java-asset-manager/worker/pom.xml`
- `legacy-src/java-asset-manager/README.local.md`
