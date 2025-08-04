# SFI-W1 Advanced Monitoring Policy Module

## Purpose
Enforces Log Analytics integration and diagnostic settings for all AI resources (Video Indexer, Content Safety, Logic Apps AI Workflows).

## Policy Details
- **Scope:** Deploy at subscription, management group, or tenant scope (not resource group).
- **Enforced Resource Types:**
  - Microsoft.VideoIndexer/accounts
  - Microsoft.ContentSafety/accounts
  - Microsoft.Logic/workflows
- **Requirements:**
  - Log Analytics workspace integration
  - Diagnostic settings enabled

## Usage
```
bicep build SFI-W1-Def-Foundry-AdvancedMonitoring.bicep
az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-AdvancedMonitoring.json
```

## Parameters
- `policyName` (optional): Name for the policy definition

## Notes
- Ensure Log Analytics workspace exists before assignment.
- Policy uses `auditIfNotExists` effect for compliance visibility.

## Related Modules
- [Video Indexer Resource Module](../resources/videoIndexer.bicep)
- [Content Safety Resource Module](../resources/contentSafety.bicep)
- [Logic Apps AI Workflows Resource Module](../resources/logicAppsAIWorkflows.bicep)
