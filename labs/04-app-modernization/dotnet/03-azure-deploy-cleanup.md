# Prepare, deploy, verify, and clean up Azure

This part uses the imported, reviewable assets:

- `legacy-src\dotnet-bookcatalog\examples\azure\main.bicep`
- `legacy-src\dotnet-bookcatalog\examples\azure\lab.mjs`

The template creates a Linux App Service plan and app, Azure SQL database, Key
Vault, user-assigned managed identity, role assignments, and outputs. The Node
helper applies a reviewed EF Core schema, grants the runtime identity CRUD
permissions only on `dbo.Books`, stores the passwordless connection string in
Key Vault, and deletes the exact dedicated group during cleanup.

> The deployment is a public, unauthenticated workshop sample. It is not a
> production architecture or security sign-off.

Do not continue without explicit subscription, cost, region, role, and public
exposure approval.

```powershell
$source = 'legacy-src\dotnet-bookcatalog\shared-legacy-app'
$project = "$source\src\BookCatalog.Web\BookCatalog.Web.csproj"
$toolRoot = 'legacy-src\dotnet-bookcatalog'
$efProject = 'shared-legacy-app\src\BookCatalog.Web\BookCatalog.Web.csproj'
$template = 'legacy-src\dotnet-bookcatalog\examples\azure\main.bicep'
$helper = 'legacy-src\dotnet-bookcatalog\examples\azure\lab.mjs'
$evidence = '.azure-lab'
New-Item -ItemType Directory -Force $evidence | Out-Null
```

## 1. Prepare: validate tools and create schema

Run local syntax and dependency checks:

```powershell
az version
node --version
node --check $helper
az bicep build --file $template --outfile "$evidence\main.json"
if ($LASTEXITCODE -ne 0) { throw "Bicep build failed." }

npm ls --prefix legacy-src\dotnet-bookcatalog --depth=0
if ($LASTEXITCODE -ne 0) {
    npm ci --prefix legacy-src\dotnet-bookcatalog
    if ($LASTEXITCODE -ne 0) { throw "Node dependency restore failed." }
}
```

Generate SQL from the reviewed EF Core migration. The helper accepts only a
schema that creates `Books` and protects repeated runs with a fingerprint.

```powershell
$schema = (Resolve-Path $evidence).Path + '\schema.sql'
Push-Location $toolRoot
try {
    dotnet ef migrations script 0 `
        --idempotent `
        --project $efProject `
        --startup-project $efProject `
        --output $schema
    if ($LASTEXITCODE -ne 0) { throw "EF Core schema generation failed." }
}
finally {
    Pop-Location
}

Select-String -Path $schema -Pattern 'CREATE TABLE \[(dbo\]\.\[)?Books\]'
```

Review the SQL. It may create EF migration history, `Books`, constraints, and
seed rows. It must not drop an existing business schema, add SQL logins, or
contain a password.

## 2. Decide: select and prove the Azure scope

Use the facilitator-approved subscription and region. The template configures
the signed-in Microsoft Entra user as Azure SQL administrator, so this path
requires a user identity rather than a service principal.

```powershell
az login
$subscriptionId = Read-Host 'Approved Azure subscription ID'
az account set --subscription $subscriptionId

$account = az account show `
    --query '{id:id,name:name,tenantId:tenantId,user:user.name}' `
    --output json | ConvertFrom-Json
if ($account.id -ne $subscriptionId) {
    throw "The selected subscription does not match approval."
}
$account | Format-List

$signedIn = az ad signed-in-user show `
    --query '{id:id,userPrincipalName:userPrincipalName}' `
    --output json | ConvertFrom-Json
if (-not $signedIn.id -or -not $signedIn.userPrincipalName) {
    throw "A Microsoft Entra user is required for the lab SQL administrator."
}

$location = Read-Host 'Facilitator-approved Azure region'
if ([string]::IsNullOrWhiteSpace($location)) {
    throw "An approved region is required."
}

$nameSeed = ("$env:USERNAME-" + (Get-Date -Format 'MMddHHmm')).ToLower() `
    -replace '[^a-z0-9-]', ''
$resourceGroup = "rg-bookcatalog-$nameSeed"
if ($resourceGroup -notmatch '^rg-bookcatalog-[a-z0-9-]+$') {
    throw "Resource-group name does not match the helper safety rule."
}

az group create `
    --name $resourceGroup `
    --location $location `
    --tags workshop=dotnet-modernization owner=$env:USERNAME `
    --output table
if ($LASTEXITCODE -ne 0) { throw "Resource-group creation failed." }
```

The deployment needs permission to create the resources and Key Vault role
assignments. Policy and provider restrictions can also block the selected SKU
or public endpoints. Do not elevate yourself or choose a broader role merely to
finish the lab.

## 3. Plan: run and review Bicep what-if

```powershell
az deployment group what-if `
    --resource-group $resourceGroup `
    --template-file $template `
    --parameters `
        administratorObjectId=$($signedIn.id) `
        administratorName=$($signedIn.userPrincipalName) `
        appServiceSku=B1 `
    --result-format FullResourcePayloads
if ($LASTEXITCODE -ne 0) {
    throw "What-if failed. Use the no-deployment path; do not deploy."
}
```

Review the result with another participant or facilitator. It should be limited
to the dedicated group and include:

- one user-assigned identity;
- one Key Vault with RBAC;
- one Azure SQL logical server, database, and lab firewall rule;
- one Linux App Service plan and web app; and
- Key Vault Secrets User for the runtime identity plus Key Vault Secrets
  Officer for the signed-in lab administrator.

**Stop** if what-if shows deletion/replacement outside this group, an
unapproved SKU/region, password authentication, a different administrator, or
unexpected resources.

## 4. Execute: deploy infrastructure and bootstrap data

Capture the deployment output object exactly as returned. The helper validates
the group name, resource names, subscription, identity IDs, and database name.

```powershell
$deploymentName = "bookcatalog-" + (Get-Date -Format 'yyyyMMddHHmmss')
$outputsJson = az deployment group create `
    --name $deploymentName `
    --resource-group $resourceGroup `
    --template-file $template `
    --parameters `
        administratorObjectId=$($signedIn.id) `
        administratorName=$($signedIn.userPrincipalName) `
        appServiceSku=B1 `
    --query properties.outputs `
    --output json
if ($LASTEXITCODE -ne 0) { throw "Infrastructure deployment failed." }
$outputsJson | Set-Content "$evidence\outputs.json" -Encoding utf8

$outputs = Get-Content "$evidence\outputs.json" -Raw | ConvertFrom-Json
if ($outputs.resourceGroup.value -ne $resourceGroup) {
    throw "Deployment outputs do not match the dedicated group."
}
```

Get your public IPv4 address. Never use `0.0.0.0` as the client address.

```powershell
$clientIp = (Invoke-RestMethod 'https://api.ipify.org').Trim()
$parsedIp = $null
if (-not [System.Net.IPAddress]::TryParse($clientIp, [ref]$parsedIp) -or
    $parsedIp.AddressFamily -ne
        [System.Net.Sockets.AddressFamily]::InterNetwork) {
    throw "A public IPv4 address is required."
}

node $helper bootstrap "$evidence\outputs.json" $clientIp "$evidence\schema.sql"
if ($LASTEXITCODE -ne 0) { throw "Database bootstrap failed." }
```

The helper creates a temporary firewall rule for only that IPv4 address,
connects with the Azure CLI user's Entra token, applies the schema to an empty
database, grants the managed identity access to `dbo.Books`, stores
`ConnectionStrings--BookCatalogContext`, and removes the temporary rule.

If bootstrap fails, inspect the complete aggregate error. Check the firewall
rules and remove only the `workshop-...` rule from your failed run. Do not grant
schema-owner rights to the runtime identity and do not switch to a SQL password.

## 5. Publish App Service

Build a clean Release publish directory:

```powershell
$publish = (Resolve-Path $evidence).Path + '\publish'
$zip = (Resolve-Path $evidence).Path + '\bookcatalog.zip'
Remove-Item $publish -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $zip -Force -ErrorAction SilentlyContinue

dotnet publish $project -c Release -o $publish
if ($LASTEXITCODE -ne 0) { throw "Publish failed." }
Compress-Archive -Path "$publish\*" -DestinationPath $zip -Force

az webapp deploy `
    --resource-group $resourceGroup `
    --name $outputs.appName.value `
    --src-path $zip `
    --type zip `
    --clean true `
    --restart true `
    --output table
if ($LASTEXITCODE -ne 0) { throw "App Service publish failed." }
```

Do not set `InitializeDatabase=true` in Azure. Infrastructure bootstrap owns
schema creation; the app runtime has only table CRUD permissions.

## 6. Verify: configuration, identity, smoke, and persistence

Do not print the secret value. Check metadata and identity assignment:

```powershell
az keyvault secret show `
    --vault-name $outputs.keyVaultName.value `
    --name ConnectionStrings--BookCatalogContext `
    --query '{id:id,enabled:attributes.enabled}' `
    --output table

az webapp identity show `
    --resource-group $resourceGroup `
    --name $outputs.appName.value `
    --query userAssignedIdentities `
    --output json
```

Run an HTTP smoke test against the fully qualified output URL:

```powershell
$appUrl = $outputs.appUrl.value
if ($appUrl -notmatch '^https://') { throw "Expected an HTTPS app URL." }

$response = Invoke-WebRequest "$appUrl/Books" -UseBasicParsing
if ($response.StatusCode -ne 200) { throw "Azure HTTP smoke test failed." }
if ($response.Content -notmatch 'Book Catalog') {
    throw "Azure response did not contain the catalog heading."
}
Write-Host "Verified $appUrl"
```

Use a browser for the data smoke test:

1. Confirm the seeded active catalog loads and the inactive Matrix row is
   hidden.
2. Create a uniquely named active cloud book.
3. Edit its title and confirm the changed value.
4. Restart the app:

   ```powershell
   az webapp restart `
       --resource-group $resourceGroup `
       --name $outputs.appName.value
   ```

5. Reload the site and confirm the edit persists.
6. Delete the test book.

If the app returns 500, use App Service logs and the first exception. Common
causes are managed identity selection, role propagation, an absent Key Vault
secret, or a schema/bootstrap failure. Do not expose the secret while
troubleshooting.

## 7. Exact cleanup

> Cleanup deletes every resource in the dedicated group. First confirm the
> outputs, subscription, and `workshop=dotnet-modernization` tag.

For a successful deployment, use the imported safety-checked helper:

```powershell
node $helper cleanup "$evidence\outputs.json" --confirm-delete
if ($LASTEXITCODE -ne 0) { throw "Cleanup is not complete." }
```

Verify independently:

```powershell
$exists = az group exists --name $resourceGroup --output tsv
if ($exists -ne 'false') {
    throw "The exact lab resource group still exists: $resourceGroup"
}
```

Key Vault can retain recoverable soft-deleted metadata after group deletion.
The helper does not purge it. Do not purge without separate authorization.

### Cleanup when deployment never produced outputs

If group creation succeeded but what-if/deployment failed before
`.azure-lab\outputs.json` existed, verify the tag and delete only the recorded
group:

```powershell
$tag = az group show `
    --name $resourceGroup `
    --query tags.workshop `
    --output tsv
if ($tag -ne 'dotnet-modernization') {
    throw "Refuse to delete a group without the workshop tag."
}

az group delete --name $resourceGroup --yes
if ($LASTEXITCODE -ne 0) { throw "Resource-group deletion failed." }

if ((az group exists --name $resourceGroup --output tsv) -ne 'false') {
    throw "The exact lab resource group still exists: $resourceGroup"
}
```

## No-deployment completion path

Use this path when cost approval, policy, quota, provider availability, public
network restrictions, SQL administrator rights, or role-assignment permissions
block Azure.

1. Complete and record all local verification from the previous part.
2. Run `node --check`, `az bicep build`, and schema generation locally.
3. Run what-if only if authorized. Preserve its real result or the first error.
4. Do not weaken networking, add a password, change the administrator, grant a
   broader role, or move regions/SKUs without approval.
5. Delete the exact tagged group if one was created.
6. Create `.azure-lab\no-deployment.md` with:
   - date and selected subscription name/ID (no tokens);
   - attempted command and stage;
   - exact policy/quota/role/cost blocker with secret values removed;
   - local build, smoke, CRUD, and persistence evidence;
   - Bicep/Node/schema validation results;
   - what-if status; and
   - cleanup command and final `az group exists` result.

This is a valid lab completion. It is not a successful deployment, and the
record must say so.
