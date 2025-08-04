# SFI-W1 Video Indexer Policy Module

## Purpose
Enforces tagging, encryption at rest, and private endpoint requirement for Video Indexer resources.

## Policy Details
- **Scope:** Deploy at subscription, management group, or tenant scope (not resource group).
- **Enforced Resource Type:** Microsoft.VideoIndexer/accounts
- **Requirements:**
  - Tagging
  - Encryption at rest
  - Private endpoint

## Usage
```
bicep build SFI-W1-Def-Foundry-VideoIndexer.bicep
az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-VideoIndexer.json
```

## Parameters
- `policyName` (optional): Name for the policy definition

## Notes
- Policy uses `auditIfNotExists` effect for compliance visibility.

## Related Modules
- [Video Indexer Resource Module](../resources/videoIndexer.bicep)
