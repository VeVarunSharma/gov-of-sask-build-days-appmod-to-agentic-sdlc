# Change specification: Java image upload validation

## Metadata

- **Owner:** Workshop participant and reviewer
- **Status:** Draft - awaiting human review
- **Source root:** `legacy-src/java-asset-manager`
- **Related issue:** Not created

## Problem and outcomes

### Problem

An upload user is offered an image form, but a non-empty upload can reach
storage regardless of its declared content type. The
[upload form](../legacy-src/java-asset-manager/web/src/main/resources/templates/upload.html)
uses `accept="image/*"` and describes JPG, PNG, GIF, and other types.
[`S3Controller.uploadObject`](../legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java)
checks only `file.isEmpty()` before calling
[`StorageService.uploadObject`](../legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/service/StorageService.java).

The [S3 implementation](../legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/service/AwsS3Service.java)
stores the object, sends a processing message, and saves metadata. The
[local implementation](../legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/service/LocalFileStorageService.java)
stores the file and sends a processing message. The
[worker](../legacy-src/java-asset-manager/worker/src/main/java/com/microsoft/migration/assets/worker/service/AbstractFileProcessingService.java)
later attempts to decode the image. This specification does not claim that
declared content type proves the file is an image.

### Desired outcomes

1. Users see that JPEG, PNG, and GIF are the accepted upload types.
2. Before either storage implementation is called, the web boundary rejects
   missing or unsupported declared content types with a stable, safe message.
3. Focused tests capture the contract for later modernization without changing
   existing successful uploads or unrelated application behavior.

### Success measures

- Automated controller tests demonstrate accepted and rejected types and
  verify the relevant storage calls and redirects.
- The form wording and file picker advertise only JPEG, PNG, and GIF.

## Functional requirements

| ID | Requirement | Evidence or rationale |
| --- | --- | --- |
| FR-1 | For a non-empty file received by the controller, accept declared media types `image/jpeg`, `image/png`, and `image/gif`, matching type and subtype case-insensitively and allowing valid media-type parameters. | These are the formats selected for this change; the current form does not define the complete set. |
| FR-2 | Reject a missing, malformed, or unsupported declared content type before calling `StorageService.uploadObject`; redirect to `/storage/upload` with a stable, user-safe error. | The current controller checks only empty files. |
| FR-3 | Preserve the existing empty-file response, successful storage call and redirect, and `IOException` handling for storage failures. | `S3Controller.uploadObject` defines these existing behaviors. |
| FR-4 | Update the upload form's wording and file picker to identify only JPEG, PNG, and GIF, while retaining the existing form route and field name. | The existing form advertises `image/*` and other unspecified types. |
| FR-5 | Retain the current multipart file and request limits without promising that an exactly-at-limit file reaches the controller. | [Multipart configuration](../legacy-src/java-asset-manager/web/src/main/resources/application.properties) sets both limits to `10MB`; multipart request overhead also consumes request space. |

## Constraints and out of scope

### Constraints

- **Allowed paths for a future implementation:**
  - `legacy-src/java-asset-manager/web/src/main/java/com/microsoft/migration/assets/controller/S3Controller.java`
  - `legacy-src/java-asset-manager/web/src/main/resources/templates/upload.html`
  - `legacy-src/java-asset-manager/web/src/test/java/com/microsoft/migration/assets/controller/`
- **Primary validation command:** From `legacy-src/java-asset-manager` with
  JDK 8 selected, run `.\mvnw.cmd -B -ntp test`.
- **Focused validation:** From the same root, run
  `.\mvnw.cmd -B -ntp -pl web test` and report its result separately.
- **Compatibility:** Keep `POST /storage/upload`, field `file`, the existing
  success and empty-file flows, storage interface, and current multipart
  configuration. Preserve existing behavior for storage `IOException`s.
- **Dependencies:** Add no dependencies or framework/runtime upgrades.
- **Data and security:** Use synthetic fixtures; do not expose file content,
  filename, paths, or exception text in the new type-rejection message.
  Validate the declared media type only, without reading file contents.

### Exclusions (out of scope)

- Changes to storage services, worker code or tests, messaging, database,
  multipart configuration, or upload size enforcement.
- File signature or image decoding checks, malware scanning, and claims that
  declared type validation establishes file safety.
- Framework, JDK, dependency, infrastructure, or unrelated modernization.
- Fixing, suppressing, deleting, or disabling the known upstream worker test.

## Edge cases

| Type | Condition | Expected behavior |
| --- | --- | --- |
| Normal | Non-empty JPEG, PNG, or GIF has an allowed declared type. | Call storage once and preserve the current success redirect. |
| Boundary | Allowed type has mixed case or valid parameters. | Treat it as the corresponding allowed type. |
| Failure | Declared type is missing, malformed, or unsupported. | Do not call storage; redirect to the upload page with the stable rejection message. |
| Boundary | The file is empty. | Preserve the existing empty-file rejection, with no storage call. |
| Failure | Storage throws `IOException` for an accepted upload. | Preserve the existing storage-error flow. |
| Compatibility | A multipart request is rejected before the controller because of configured limits. | Preserve existing framework behavior; do not promise an exact accepted file-size boundary. |

## Acceptance criteria

### AC-1: Accepted declared image types

- **Given** a non-empty file with declared `image/jpeg`, `image/png`, or
  `image/gif`, including case variants and valid parameters
- **When** it is submitted as `file` to `/storage/upload`
- **Then** storage is called once with the file and the existing success
  redirect and flash message are preserved
- **Verification:** Focused controller tests exercise all three types,
  case-insensitive matching, and parameters with mocked storage.

### AC-2: Rejected declared types

- **Given** a non-empty file with a missing, malformed, or unsupported declared
  content type
- **When** it is submitted to `/storage/upload`
- **Then** storage is not called, and the response redirects to
  `/storage/upload` with the same stable, user-safe type-rejection message
- **Verification:** Focused controller tests cover each category and assert
  the redirect, flash message, and zero storage calls.

### AC-3: Existing behavior

- **Given** an empty file, or an allowed non-empty file whose storage operation
  throws `IOException`
- **When** it is submitted to `/storage/upload`
- **Then** the current respective empty-file or storage-error response is
  preserved; an empty file never reaches storage
- **Verification:** Focused controller tests assert the existing messages,
  redirects, and storage interactions.

### AC-4: Upload form

- **Given** the upload form is displayed
- **When** a user reads its guidance or opens the file picker
- **Then** the form advertises JPEG, PNG, and GIF only, and still posts field
  `file` to `/storage/upload`
- **Verification:** Inspect the template and its rendered form, or use a
  focused template test.

### AC-5: Limits and validation

- **Given** the change is complete
- **When** its diff and validation results are reviewed
- **Then** multipart configuration is unchanged, focused web tests pass, and
  the full reactor result is reported without treating the characterized
  upstream worker error as a pass
- **Verification:** Review the diff and run both commands above.

## Non-functional requirements

| ID | Quality | Testable requirement | Verification |
| --- | --- | --- | --- |
| NFR-1 | Reliability | Missing, malformed, and unsupported declared types never reach storage. | Focused tests verify zero calls. |
| NFR-2 | Privacy | The new rejection message contains no file content, filename, path, or exception text. | Assert the message in focused tests. |
| NFR-3 | Maintainability | No production or test dependency is added. | Review the Maven project-file diff. |
| NFR-4 | Scope | Type checking does not read or decode the upload stream. | Focused tests and code review. |

## Assumptions, dependencies, and risks

| Item | Type | Validation or mitigation |
| --- | --- | --- |
| Declared content type is supplied by the client and can be spoofed. | Risk | Document the limitation; content verification is out of scope. |
| Multipart parsing can reject a request before the controller. | Dependency | Retain the existing limits and avoid claiming an exact file-size boundary. |
| The reactor has a known upstream Mockito error in one worker test. | Risk | Run the focused web tests and full reactor; characterize the exact worker error separately and stop for new or changed failures. |

## Plan-mode review checkpoint

### Evidence

- **Current behavior:** `S3Controller.uploadObject` checks empty files, then
  calls `StorageService.uploadObject`; its S3 and local implementations have
  the separate storage and messaging effects described above.
- **Existing tests:** No web tests were found under `web/src/test`. The
  existing [worker test class](../legacy-src/java-asset-manager/worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java)
  has four tests and does not cover the web controller.
- **Baseline validation evidence:** The parent session ran
  `.\scripts\validation\validate-java.ps1` from the repository root with
  JDK 8. The reactor reported 4 tests, 0 failures, 1 error, and 0 skipped:
  `S3FileProcessingServiceTest.downloadOriginalCopiesFileFromS3` cannot mock
  the final AWS SDK `ResponseInputStream`. The wrapper failed; this is a
  characterized baseline defect, not a pass. The primary command above is the
  equivalent reactor test invocation from the source root.

### Unresolved questions

None identified for the stated scope. Human review and approval remain
outstanding; this draft does not authorize implementation.

### Boundary and validation review

- Evidence paths and symbols have been checked against the repository.
- Allowed paths cover the intended controller, form, and focused tests.
- Validation uses the owning reactor and reports the known worker error.
- Criteria cover success, failure, boundary, and compatibility behavior.
- Storage, worker, dependency, and multipart changes are excluded.

### Stop conditions

Stop and request human guidance if:

- repository evidence contradicts this specification or a material behavior
  decision is unclear;
- a required change would escape the allowed paths or exclusions;
- a prerequisite is missing, or focused web tests fail;
- the full reactor has any additional failure or a different worker error;
- validation requires a secret, production resource, destructive action,
  dependency or schema change, or a public API change; or
- an acceptance criterion cannot be met without expanding the contract.

### Human approval

- **Review:** Pending; no execution approval has been granted.
- **Reviewer:** Not yet assigned.
- **Approval date:** Not yet recorded.
- **Approved specification commit:** Not yet recorded.

Change **Status** to `Approved` only after a human records review and approval
against the committed specification. Approval authorizes preparation of an
issue, not implementation.
