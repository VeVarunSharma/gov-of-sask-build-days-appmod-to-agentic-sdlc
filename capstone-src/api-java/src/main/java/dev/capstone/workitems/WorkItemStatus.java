package dev.capstone.workitems;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;

public enum WorkItemStatus {
	TODO("todo"),
	IN_PROGRESS("in_progress"),
	DONE("done");

	private final String value;

	WorkItemStatus(String value) {
		this.value = value;
	}

	@JsonValue
	public String value() {
		return value;
	}

	@JsonCreator
	public static WorkItemStatus fromValue(String value) {
		for (WorkItemStatus status : values()) {
			if (status.value.equals(value)) {
				return status;
			}
		}
		throw new IllegalArgumentException("Unknown work item status: " + value);
	}
}
