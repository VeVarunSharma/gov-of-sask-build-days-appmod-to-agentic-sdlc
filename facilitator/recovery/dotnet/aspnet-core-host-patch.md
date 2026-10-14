# Small patch card: ASP.NET Core MVC host

Use only when the converted project already has a minimal `Program.cs` and is
missing standard MVC/static-file/default-route wiring. Adapt namespaces and do
not overwrite valid Key Vault or EF configuration.

```diff
 var builder = WebApplication.CreateBuilder(args);
+builder.Services.AddControllersWithViews();

 var app = builder.Build();
+if (!app.Environment.IsDevelopment())
+{
+    app.UseExceptionHandler("/Home/Error");
+    app.UseHsts();
+}
+
+app.UseHttpsRedirection();
+app.UseStaticFiles();
+app.UseRouting();
+
+app.MapControllerRoute(
+    name: "default",
+    pattern: "{controller=Books}/{action=Index}/{id?}");

 app.Run();
```

After adapting the patch:

```powershell
dotnet build legacy-src\dotnet-bookcatalog\shared-legacy-app\BookCatalog.sln `
    -c Release
```

Then smoke `/Books`. This patch does not migrate controllers, Razor views,
errors, data access, or configuration.
