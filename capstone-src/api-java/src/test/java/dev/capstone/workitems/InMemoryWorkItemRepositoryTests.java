package dev.capstone.workitems;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.UUID;

import org.junit.jupiter.api.Test;

class InMemoryWorkItemRepositoryTests {
	private final Clock clock = Clock.fixed(Instant.parse("2026-01-01T12:00:00Z"), ZoneOffset.UTC);
	private final InMemoryWorkItemRepository repository = new InMemoryWorkItemRepository(clock);

	@Test
	void createsAndUpdatesAWorkItemWhilePreservingIdentity() {
		WorkItem created = repository.create(new WorkItemRequest("  Plan demo  ", null, WorkItemStatus.TODO));
		WorkItem updated = repository.update(
				created.id(),
				new WorkItemRequest("Plan demo", "Ready for review", WorkItemStatus.DONE)).orElseThrow();

		assertThat(created.title()).isEqualTo("Plan demo");
		assertThat(updated.id()).isEqualTo(created.id());
		assertThat(updated.createdAt()).isEqualTo(created.createdAt());
		assertThat(updated.description()).isEqualTo("Ready for review");
		assertThat(updated.status()).isEqualTo(WorkItemStatus.DONE);
	}

	@Test
	void deletingAnUnknownWorkItemReportsFalse() {
		assertThat(repository.delete(UUID.randomUUID())).isFalse();
	}
}
