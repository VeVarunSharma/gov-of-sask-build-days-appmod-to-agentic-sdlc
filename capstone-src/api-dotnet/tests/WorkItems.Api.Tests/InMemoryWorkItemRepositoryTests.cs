using WorkItems.Api;

namespace WorkItems.Api.Tests;

public class InMemoryWorkItemRepositoryTests
{
    [Fact]
    public void CreateAndUpdatePreserveIdentityAndCreationTime()
    {
        var clock = new StubTimeProvider(new DateTimeOffset(2026, 1, 1, 12, 0, 0, TimeSpan.Zero));
        var repository = new InMemoryWorkItemRepository(clock);

        var created = repository.Create(new WorkItemRequest("  Plan demo  ", null, WorkItemStatus.Todo));
        clock.UtcNow = clock.UtcNow.AddMinutes(10);
        var updated = repository.Update(
            created.Id,
            new WorkItemRequest("Plan demo", "Ready for review", WorkItemStatus.Done));

        Assert.NotNull(updated);
        Assert.Equal("Plan demo", created.Title);
        Assert.Equal(created.Id, updated.Id);
        Assert.Equal(created.CreatedAt, updated.CreatedAt);
        Assert.True(updated.UpdatedAt > created.UpdatedAt);
        Assert.Equal(WorkItemStatus.Done, updated.Status);
    }

    [Fact]
    public void GetAllReturnsItemsOrderedByCreationTime()
    {
        var clock = new StubTimeProvider(new DateTimeOffset(2026, 1, 1, 12, 0, 0, TimeSpan.Zero));
        var repository = new InMemoryWorkItemRepository(clock);

        var first = repository.Create(new WorkItemRequest("First", null, WorkItemStatus.Todo));
        clock.UtcNow = clock.UtcNow.AddMinutes(1);
        var second = repository.Create(new WorkItemRequest("Second", null, WorkItemStatus.Todo));
        clock.UtcNow = clock.UtcNow.AddMinutes(1);
        var third = repository.Create(new WorkItemRequest("Third", null, WorkItemStatus.Todo));
        clock.UtcNow = clock.UtcNow.AddMinutes(1);
        repository.Update(first.Id, new WorkItemRequest("First", "Updated", WorkItemStatus.Done));

        var ids = repository.GetAll().Select(item => item.Id).ToArray();

        Assert.Equal(new[] { first.Id, second.Id, third.Id }, ids);
    }

    [Fact]
    public void DeleteReturnsFalseForUnknownItem()
    {
        var repository = new InMemoryWorkItemRepository();
        Assert.False(repository.Delete(Guid.NewGuid()));
    }

    private sealed class StubTimeProvider(DateTimeOffset utcNow) : TimeProvider
    {
        public DateTimeOffset UtcNow { get; set; } = utcNow;
        public override DateTimeOffset GetUtcNow() => UtcNow;
    }
}
