package dev.capstone.workitems;

import java.net.URI;
import java.util.List;
import java.util.UUID;

import jakarta.validation.Valid;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/work-items")
public class WorkItemController {
	private final InMemoryWorkItemRepository repository;

	public WorkItemController(InMemoryWorkItemRepository repository) {
		this.repository = repository;
	}

	@GetMapping
	public List<WorkItem> getAll() {
		return repository.findAll();
	}

	@GetMapping("/{id}")
	public ResponseEntity<WorkItem> getById(@PathVariable UUID id) {
		return ResponseEntity.of(repository.findById(id));
	}

	@PostMapping
	public ResponseEntity<WorkItem> create(@Valid @RequestBody WorkItemRequest request) {
		WorkItem created = repository.create(request);
		return ResponseEntity.created(URI.create("/api/work-items/" + created.id())).body(created);
	}

	@PutMapping("/{id}")
	public ResponseEntity<WorkItem> update(
			@PathVariable UUID id,
			@Valid @RequestBody WorkItemRequest request) {
		return ResponseEntity.of(repository.update(id, request));
	}

	@DeleteMapping("/{id}")
	public ResponseEntity<Void> delete(@PathVariable UUID id) {
		return repository.delete(id) ? ResponseEntity.noContent().build() : ResponseEntity.notFound().build();
	}
}
