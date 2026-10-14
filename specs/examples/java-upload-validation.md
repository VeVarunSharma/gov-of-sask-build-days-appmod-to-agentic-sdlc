# Java example: enforce the documented image upload policy

> Reference example only. It does not authorize changes to the imported source.

## Metadata

- **Owner:** Workshop application team
- **Status:** Reference example — not approved for execution
- **Source root:** `legacy-src/java-asset-manager`
- **Related issue:** Not created

## Problem and outcomes

The upload page says images up to 10 MB are supported, but
`web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java`
only rejects empty files before calling `StorageService.uploadObject`. Browser
attributes in `web/src/main/resources/templates/upload.html` are not a
server-side policy.

The change should enforce the displayed contract at the web boundary. This
creates a clear, tested input policy that can be carried into a later Spring
Boot modernization without changing storage implementations.

Success means invalid uploads never reach `StorageService`, while valid image
uploads retain the current success flow.

## Functional requirements

- **FR-1:** Accept a non-empty JPEG, PNG, or GIF no larger than 10 MiB.
- **FR-2:** Reject an unsupported type or oversized file before calling
  `StorageService.uploadObject`.
- **FR-3:** Redirect a rejected upload to `/storage/upload` with a stable,
  user-safe error.

## Constraints and out of scope

- **Allowed paths:**
  - `legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/`
  - `legacy-src/java-asset-manager/web/src/test/java/com/microsoft/migration/assets/controller/`
  - `legacy-src/java-asset-manager/web/src/main/resources/templates/upload.html`
- **Primary validation command:** `./mvnw -B test`
- Preserve the route, form field name, successful redirect, and
  `StorageService` interface.
- Add no production dependency and do not inspect file contents beyond supplied
  metadata.

### Exclusions (out of scope)

- Storage changes, malware scanning, image decoding, global multipart
  configuration, and unrelated modernization.

## Edge cases

| Type | Condition | Expected behavior |
| --- | --- | --- |
| Normal | Supported non-empty image at or below 10 MiB | Existing upload success flow is preserved. |
| Failure | Unsupported content type | Storage is not called and a stable error is returned. |
| Boundary | Supported image is exactly 10 MiB | The upload is accepted. |
| Boundary | File is empty or larger than 10 MiB | Storage is not called and a stable error is returned. |
| Compatibility | Existing route, field name, and storage interface | Their contracts remain unchanged. |

## Acceptance criteria

### AC-1: Valid upload

- **Given** a non-empty PNG file of exactly 10 MiB or less
- **When** it is posted as `file` to `/storage/upload`
- **Then** `StorageService.uploadObject` is called once and the response follows
  the existing success redirect
- **Verification:** Focused controller test with a mocked `StorageService`

### AC-2: Unsupported type

- **Given** a non-empty file whose content type is not JPEG, PNG, or GIF
- **When** it is posted to `/storage/upload`
- **Then** storage is not called and the upload page receives a stable
  unsupported-type error
- **Verification:** Controller test asserts the redirect, message, and zero
  storage calls

### AC-3: Oversized upload

- **Given** an allowed image whose reported size exceeds 10 MiB
- **When** it is posted to `/storage/upload`
- **Then** storage is not called and the upload page receives a stable size
  error
- **Verification:** Boundary controller tests cover exactly 10 MiB and one byte
  over the limit

## Non-functional requirements

- **NFR-1:** Validate without reading the upload stream. Verify with a
  controller test and code review.
- **NFR-2:** Do not include file contents, paths, or exception text in rejection
  messages. Assert the flash messages.
- **NFR-3:** Add no production dependency. Review the `pom.xml` diff.

## Assumptions, dependencies, and risks

Client-supplied content type can be inaccurate. This small change enforces the
documented request contract but is not malware or content verification; the
limitation is explicit and deeper inspection remains out of scope.

Validation belongs at the web controller before the storage abstraction because
that is the narrowest boundary shared by current storage modes. A reusable
policy component would require new repository evidence and approval.

## Plan-mode review checkpoint

### Evidence

- **Current behavior:**
  `legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java`
  checks for an empty upload before calling `StorageService.uploadObject`.
- **Existing tests:** Controller test coverage must be confirmed in
  `legacy-src/java-asset-manager/web/src/test/`.
- **Baseline validation evidence:** Not recorded for this non-executable
  reference example; a real specification must record the command result or an
  exact prerequisite blocker before approval.

### Unresolved questions

- None in the illustrative scope. A real planning session must verify the
  existing tests and baseline result.

### Boundary and validation review

- [x] Evidence and the intended behavior are linked.
- [x] Allowed paths contain the anticipated implementation and tests.
- [x] One primary validation command is stated.
- [x] Acceptance criteria cover normal, failure, and boundary behavior.
- [x] Exclusions prevent storage and broader modernization work.

### Stop conditions

Stop and request human guidance if repository evidence differs, validation
cannot run, another path or dependency must change, content inspection becomes
required, credentials or production resources are needed, or the route,
storage interface, or accepted image policy would change.

### Human approval

- [ ] Execution approval is intentionally not granted for this reference.
- **Reviewer:** Not applicable — reference example
- **Approval date:** Not applicable — reference example
- **Approved specification commit:** Not applicable — reference example
