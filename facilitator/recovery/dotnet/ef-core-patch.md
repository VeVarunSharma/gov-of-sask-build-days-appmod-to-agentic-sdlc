# Small patch card: EF Core registration and guarded migration

Use only when the learner already has an EF Core `ApplicationDbContext`, a
valid `BookCatalogContext` connection string, and an initial migration. Adapt
the namespace. Do not add this code to the legacy EF6 project.

```diff
+using BookCatalog.Web.Models;
+using Microsoft.EntityFrameworkCore;

 var builder = WebApplication.CreateBuilder(args);
+builder.Services.AddDbContext<ApplicationDbContext>(options =>
+    options.UseSqlServer(
+        builder.Configuration.GetConnectionString("BookCatalogContext")
+        ?? throw new InvalidOperationException(
+            "ConnectionStrings:BookCatalogContext is required.")));

 var app = builder.Build();
+
+if (builder.Configuration.GetValue<bool>("InitializeDatabase"))
+{
+    using var scope = app.Services.CreateScope();
+    var db = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
+    await db.Database.MigrateAsync();
+}
```

Required review:

- Development can set `InitializeDatabase=true`.
- Production and the imported Bicep set it to `false`.
- No `EnsureDeleted` or unconditional migration exists.
- The Azure runtime identity is not expected to run DDL.
- Seed values are deterministic.

After adapting the patch, run `dotnet ef database update` from
`legacy-src\dotnet-bookcatalog` so the local tool manifest is discovered, then
run the Release build and restart-persistence check.
