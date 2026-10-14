using System.Text.Json;
using System.Text.Json.Serialization;
using WorkItems.Api;

var builder = WebApplication.CreateBuilder(args);

builder.Services.ConfigureHttpJsonOptions(options =>
{
    options.SerializerOptions.Converters.Add(
        new JsonStringEnumConverter(JsonNamingPolicy.SnakeCaseLower, allowIntegerValues: false));
});
builder.Services.AddOpenApi();
builder.Services.AddSingleton<IWorkItemRepository, InMemoryWorkItemRepository>();

var allowedOrigins = builder.Configuration["Cors:AllowedOrigins"]?
    .Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries)
    ?? ["http://localhost:5173"];

builder.Services.AddCors(options =>
{
    options.AddPolicy("Frontend", policy =>
        policy.WithOrigins(allowedOrigins)
            .AllowAnyHeader()
            .WithMethods("GET", "POST", "PUT", "DELETE", "OPTIONS"));
});

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors("Frontend");

app.MapGet("/health", () => Results.Ok(new { status = "ok" }));

var workItems = app.MapGroup("/api/work-items");

workItems.MapGet("", (IWorkItemRepository repository) => Results.Ok(repository.GetAll()));

workItems.MapGet("/{id:guid}", (Guid id, IWorkItemRepository repository) =>
    repository.Get(id) is { } item ? Results.Ok(item) : Results.NotFound());

workItems.MapPost("", (WorkItemRequest request, IWorkItemRepository repository) =>
{
    var validation = Validate(request);
    if (validation is not null)
    {
        return validation;
    }

    var created = repository.Create(request);
    return Results.Created($"/api/work-items/{created.Id}", created);
});

workItems.MapPut("/{id:guid}", (Guid id, WorkItemRequest request, IWorkItemRepository repository) =>
{
    var validation = Validate(request);
    if (validation is not null)
    {
        return validation;
    }

    return repository.Update(id, request) is { } updated ? Results.Ok(updated) : Results.NotFound();
});

workItems.MapDelete("/{id:guid}", (Guid id, IWorkItemRepository repository) =>
    repository.Delete(id) ? Results.NoContent() : Results.NotFound());

app.Run();

static IResult? Validate(WorkItemRequest request)
{
    if (string.IsNullOrWhiteSpace(request.Title))
    {
        return Results.ValidationProblem(new Dictionary<string, string[]>
        {
            ["title"] = ["Title is required."]
        });
    }

    if (request.Title.Length > 200)
    {
        return Results.ValidationProblem(new Dictionary<string, string[]>
        {
            ["title"] = ["Title must be 200 characters or fewer."]
        });
    }

    if (request.Description?.Length > 2000)
    {
        return Results.ValidationProblem(new Dictionary<string, string[]>
        {
            ["description"] = ["Description must be 2000 characters or fewer."]
        });
    }

    if (request.Status is null)
    {
        return Results.ValidationProblem(new Dictionary<string, string[]>
        {
            ["status"] = ["Status is required."]
        });
    }

    return null;
}

public partial class Program;
