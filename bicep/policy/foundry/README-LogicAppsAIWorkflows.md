# SFI-W1 Logic Apps AI Workflows Policy Module

## Purpose
Enforces secure connections, logging, and resource tagging for Logic Apps orchestrating AI workflows.

## Policy Details
- **Scope:** Deploy at subscription, management group, or tenant scope (not resource group).
- **Enforced Resource Type:** Microsoft.Logic/workflows
- **Requirements:**
  - Secure connections
  - Logging
  - Resource tagging

## Usage
```
bicep build SFI-W1-Def-Foundry-LogicAppsAIWorkflows.bicep
az deployment sub create --location <location> --template-file SFI-W1-Def-Foundry-LogicAppsAIWorkflows.json
```

## Parameters
- `policyName` (optional): Name for the policy definition

## Notes
- Policy uses `auditIfNotExists` effect for compliance visibility.

## Related Modules
- [Logic Apps AI Workflows Resource Module](../resources/logicAppsAIWorkflows.bicep)
