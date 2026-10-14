namespace WorkItems.Api;

public sealed record WorkItem(
    Guid Id,
    string Title,
    string? Description,
    WorkItemStatus Status,
    DateTimeOffset CreatedAt,
    DateTimeOffset UpdatedAt);

public sealed record WorkItemRequest(
    string Title,
    string? Description,
    WorkItemStatus? Status);

public enum WorkItemStatus
{
    Todo,
    InProgress,
    Done
}
