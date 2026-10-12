using System.Collections.Concurrent;

namespace WorkItems.Api;

public interface IWorkItemRepository
{
    IReadOnlyCollection<WorkItem> GetAll();
    WorkItem? Get(Guid id);
    WorkItem Create(WorkItemRequest request);
    WorkItem? Update(Guid id, WorkItemRequest request);
    bool Delete(Guid id);
}

public sealed class InMemoryWorkItemRepository(TimeProvider? timeProvider = null) : IWorkItemRepository
{
    private readonly ConcurrentDictionary<Guid, WorkItem> _items = new();
    private readonly TimeProvider _timeProvider = timeProvider ?? TimeProvider.System;

    public IReadOnlyCollection<WorkItem> GetAll() =>
        _items.Values.OrderBy(item => item.CreatedAt).ToArray();

    public WorkItem? Get(Guid id) => _items.GetValueOrDefault(id);

    public WorkItem Create(WorkItemRequest request)
    {
        var now = _timeProvider.GetUtcNow();
        var item = new WorkItem(
            Guid.NewGuid(),
            request.Title.Trim(),
            request.Description,
            request.Status!.Value,
            now,
            now);
        _items[item.Id] = item;
        return item;
    }

    public WorkItem? Update(Guid id, WorkItemRequest request)
    {
        while (_items.TryGetValue(id, out var existing))
        {
            var updated = existing with
            {
                Title = request.Title.Trim(),
                Description = request.Description,
                Status = request.Status!.Value,
                UpdatedAt = _timeProvider.GetUtcNow()
            };

            if (_items.TryUpdate(id, updated, existing))
            {
                return updated;
            }
        }

        return null;
    }

    public bool Delete(Guid id) => _items.TryRemove(id, out _);
}
