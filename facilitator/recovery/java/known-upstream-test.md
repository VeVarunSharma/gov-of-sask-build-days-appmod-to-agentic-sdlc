<!-- markdownlint-disable MD013 -->

# Known upstream worker test error

## Symptom

The imported test
`worker/src/test/java/com/microsoft/migration/assets/worker/service/S3FileProcessingServiceTest.java`
attempts to mock `software.amazon.awssdk.core.ResponseInputStream`.

With the imported Mockito configuration, the
`downloadOriginalCopiesFileFromS3` test can error with:

```text
Cannot mock/spy class software.amazon.awssdk.core.ResponseInputStream
Mockito cannot mock/spy because:
 - final class
```

The wording is an expected example; compare the participant's actual output.

## Characterization

- The error occurs while arranging the mock.
- It does not establish whether download behavior is correct.
- The other three methods in the class can complete.
- The web module has no tests in the imported baseline.
- A skip-test package can still succeed.

## Acceptable modernization fixes

Prefer, in order:

1. construct a real SDK response stream around controlled test bytes;
2. introduce a narrow provider abstraction and test observable file-copy
   behavior through that seam; or
3. use a supported test double strategy compatible with the selected modern
   dependencies.

The repaired test should verify that expected bytes reach the destination,
not merely that a client method was called.

## Unacceptable fixes

- deleting or disabling the test;
- globally skipping tests;
- catching and ignoring the Mockito exception;
- enabling broad mocking behavior without explaining why it is safe; or
- marking the baseline error as an application pass.

## Verification

Run from the monorepo root:

```powershell
.\legacy-src\java-asset-manager\mvnw.cmd -B -ntp `
  -f .\legacy-src\java-asset-manager\pom.xml clean test
```

```bash
./legacy-src/java-asset-manager/mvnw -B -ntp \
  -f ./legacy-src/java-asset-manager/pom.xml clean test
```

The modernization checkpoint requires all reactor tests to pass on JDK 21.
