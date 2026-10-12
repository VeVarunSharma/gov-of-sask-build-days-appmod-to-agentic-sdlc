---
applyTo: "capstone-src/api-java/src/test/**/*.java"
---

# Capstone Java test guidance

- Use JUnit and the Spring test support already declared in
  `capstone-src/api-java/pom.xml`; extend the existing repository or
  application-context test seam before adding another test harness.
- Trace expected behavior to the matching class under
  `capstone-src/api-java/src/main/java/dev/capstone/workitems/` and keep HTTP
  assumptions aligned with `capstone-src/contracts/openapi.yml`.
- Keep tests independent of live databases, Azure resources, the network,
  wall-clock timing, and test execution order.
- Run `.\mvnw.cmd -B -ntp clean verify` on Windows or
  `./mvnw -B -ntp clean verify` on macOS/Linux from
  `capstone-src/api-java`, and report the observable result.
