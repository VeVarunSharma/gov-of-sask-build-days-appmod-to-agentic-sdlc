# Azure participant safety scripts

These helpers target a participant's own subscription. They require explicit
subscription and resource-group values, display the resolved account context,
and never provision resources.

Preflight is read-only:

```powershell
.\scripts\azure\preflight.ps1 -SubscriptionId <id> -ResourceGroupName <exact-name> `
  -ExpectedNamePrefix <prefix> -RequiredTagName workshop -RequiredTagValue appmod
```

```bash
./scripts/azure/preflight.sh --subscription-id <id> --resource-group <exact-name> \
  --expected-prefix <prefix> --tag-name workshop --tag-value appmod
```

Cleanup defaults to a dry run. It will only delete the exact resource group
after its name and required tag match, and after the caller supplies both an
execute flag and an exact confirmation value:

```powershell
.\scripts\azure\cleanup.ps1 ... -Execute -ConfirmResourceGroup <exact-name> -WhatIf
# Remove -WhatIf only after reviewing the output.
```

```bash
./scripts/azure/cleanup.sh ... --what-if               # explicit dry run
./scripts/azure/cleanup.sh ... --execute --confirm-resource-group <exact-name>
```

No wildcard or subscription-wide deletion is implemented.
`-WhatIf` is PowerShell's native what-if mode; bash uses the explicit
`--what-if` dry-run option. Neither preflight script changes Azure state.
