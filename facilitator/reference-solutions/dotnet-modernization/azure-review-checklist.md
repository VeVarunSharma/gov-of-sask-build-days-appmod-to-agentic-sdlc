# Azure facilitator review checklist

## Before resource creation

- [ ] Local Release build, CRUD, validation, and restart persistence passed.
- [ ] Subscription ID/name, tenant, region, cost, public exposure, and owner
      were approved.
- [ ] The signed-in identity is the intended Microsoft Entra user and can be
      SQL administrator.
- [ ] The learner understands role-assignment creation can require elevated
      Azure permissions and will not self-elevate.
- [ ] `main.bicep`, `lab.mjs`, and generated schema were reviewed.
- [ ] The group name starts `rg-bookcatalog-` and will have
      `workshop=dotnet-modernization`.

## What-if gate

- [ ] Change scope is only the dedicated group.
- [ ] Resources are limited to App Service, Azure SQL, Key Vault,
      user-assigned identity, firewall rule, and required role assignments.
- [ ] No SQL password, system-assigned identity substitution, or unexpected
      deletion/replacement appears.
- [ ] Region and B1/S0 costs are approved.

## Bootstrap and publish

- [ ] `outputs.json` is the actual `properties.outputs` object and matches the
      selected subscription/group.
- [ ] The public client address is one IPv4 address, not `0.0.0.0`.
- [ ] The helper's temporary `workshop-...` firewall rule is removed.
- [ ] Azure SQL contains the reviewed schema marker and runtime principal.
- [ ] Runtime has CRUD on `dbo.Books`, not DDL/schema-owner.
- [ ] Key Vault contains `ConnectionStrings--BookCatalogContext`; its value is
      never displayed or committed.
- [ ] App Service uses the expected user-assigned identity and
      `InitializeDatabase=false`.

## Verification

- [ ] The fully qualified `https://` output URL returns 200 and the catalog.
- [ ] Seed/filter/order checks pass.
- [ ] Cloud create/edit passes.
- [ ] The edit survives `az webapp restart`.
- [ ] The learner removes the cloud test record.

## Cleanup

- [ ] The helper is called with the actual outputs and `--confirm-delete`.
- [ ] `az group exists --name $resourceGroup` returns `false` for the exact
      recorded group.
- [ ] Soft-deleted Key Vault metadata is not purged without authorization.
- [ ] Local `.azure-lab` artifacts are not committed.

## Valid no-deployment completion

- [ ] The blocker is real and classified as cost, policy, quota/provider,
      networking, SQL administrator, or role permission.
- [ ] The learner did not weaken a control or add credentials.
- [ ] Local verification, Bicep/Node/schema checks, and available what-if
      evidence are complete.
- [ ] Any created group is deleted after verifying its workshop tag.
- [ ] The record explicitly says deployment and cloud smoke tests did not run.
