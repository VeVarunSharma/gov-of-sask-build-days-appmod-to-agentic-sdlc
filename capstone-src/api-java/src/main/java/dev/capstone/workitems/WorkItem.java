package dev.capstone.workitems;

import java.time.Instant;
import java.util.UUID;

public record WorkItem(
		UUID id,
		String title,
		String description,
		WorkItemStatus status,
		Instant createdAt,
		Instant updatedAt) {
}
