package dev.capstone.workitems;

import java.time.Clock;
import java.time.Instant;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.springframework.stereotype.Repository;

@Repository
public class InMemoryWorkItemRepository {
	private final ConcurrentMap<UUID, WorkItem> items = new ConcurrentHashMap<>();
	private final Clock clock;

	public InMemoryWorkItemRepository() {
		this(Clock.systemUTC());
	}

	InMemoryWorkItemRepository(Clock clock) {
		this.clock = clock;
	}

	public List<WorkItem> findAll() {
		return items.values().stream()
				.sorted(Comparator.comparing(WorkItem::createdAt))
				.toList();
	}

	public Optional<WorkItem> findById(UUID id) {
		return Optional.ofNullable(items.get(id));
	}

	public WorkItem create(WorkItemRequest request) {
		Instant now = clock.instant();
		WorkItem item = new WorkItem(
				UUID.randomUUID(),
				request.title().trim(),
				request.description(),
				request.status(),
				now,
				now);
		items.put(item.id(), item);
		return item;
	}

	public Optional<WorkItem> update(UUID id, WorkItemRequest request) {
		return Optional.ofNullable(items.computeIfPresent(id, (ignored, existing) -> new WorkItem(
				existing.id(),
				request.title().trim(),
				request.description(),
				request.status(),
				existing.createdAt(),
				clock.instant())));
	}

	public boolean delete(UUID id) {
		return items.remove(id) != null;
	}
}
