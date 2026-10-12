---
applyTo: "legacy-src/java-asset-manager/**/*.java,legacy-src/java-asset-manager/**/pom.xml,capstone-src/api-java/**/*.java,capstone-src/api-java/pom.xml"
---

# Java and Maven

- Identify the owning Maven reactor before editing. The imported application is
  a Java 8, Spring Boot 2.7 multi-module build rooted at
  `legacy-src/java-asset-manager/pom.xml`; the capstone API is independent.
- Preserve the imported baseline's Java version and framework unless an
  approved modernization specification explicitly changes them.
- Keep web and worker responsibilities separate. Do not copy fixes between
  modules without tracing the behavior and dependency in each module.
- Prefer focused unit tests next to the affected module. Test observable
  behavior, failure paths, and boundary values; do not require live cloud
  services in unit tests.
- Run Maven from the owning root. For the imported app use
  `mvnw.cmd -B test` on Windows or `./mvnw -B test` on macOS/Linux. For the
  capstone API use `mvnw.cmd -B test` or `./mvnw -B test` when its wrapper is
  present, otherwise `mvn -B test`.
- Do not edit generated `target/` content or add credentials to
  `application.properties`.
