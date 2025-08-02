# SFI-W1 Content Safety Policy Module

## Purpose
Enforces diagnostic logging, managed identity, and network restrictions for Content Safety resources.

## Policy Details
- **Scope:** Deploy at subscription, management group, or tenant scope (not resource group).
- **Enforced Resource Type:** Microsoft.ContentSafety/accounts
- **Requirements:**
  - Diagnostic logging
  - Managed identity
  - Network restrictions

## Usage
```
bicep build SFI-W1-Def-Foundry-ContentSafety.bicep
az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-ContentSafety.json
```

## Parameters
- `policyName` (optional): Name for the policy definition

## Notes
- Policy uses `auditIfNotExists` effect for compliance visibility.

## Related Modules
- [Content Safety Resource Module](../resources/contentSafety.bicep)
