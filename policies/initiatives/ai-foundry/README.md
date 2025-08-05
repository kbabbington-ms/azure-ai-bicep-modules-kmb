# Azure AI Foundry Governance Policies

This directory contains comprehensive Azure Policy definitions and initiatives for securing and governing Azure AI Foundry hubs and projects according to SFI-W1 standards.

## 📋 Overview

Azure AI Foundry is Microsoft's unified platform for building, deploying, and managing AI solutions. These policies ensure that AI Foundry hubs and projects meet enterprise security, compliance, and governance requirements.

## 🏗️ Policy Architecture

### Policy Definitions

Located in `policies/definitions/ai-foundry/`:

| Policy | Purpose | Resource Type | Effect Options |
|--------|---------|---------------|----------------|
| **SFI-W1-Def-AIFoundry-RequirePrivateEndpoints** | Enforce private endpoint connectivity | Microsoft.MachineLearningServices/workspaces | Audit, Deny, Disabled |
| **SFI-W1-Def-AIFoundry-RequireCustomerManagedKeys** | Require customer-managed encryption keys | Microsoft.MachineLearningServices/workspaces | Audit, Deny, Disabled |
| **SFI-W1-Def-AIFoundry-DisablePublicNetworkAccess** | Disable public network access | Microsoft.MachineLearningServices/workspaces | Audit, Deny, Disabled |
| **SFI-W1-Def-AIFoundry-RequireUserAssignedIdentity** | Require user-assigned managed identity | Microsoft.MachineLearningServices/workspaces | Audit, Deny, Disabled |
| **SFI-W1-Def-AIFoundry-DisableComputeLocalAuth** | Disable local authentication on compute | Microsoft.MachineLearningServices/workspaces | Audit, Deny, Disabled |
| **SFI-W1-Def-AIFoundry-RequireDiagnosticSettings** | Require comprehensive diagnostic logging | Microsoft.MachineLearningServices/workspaces | AuditIfNotExists, DeployIfNotExists, Disabled |

### Policy Initiative

Located in `policies/initiatives/ai-foundry/`:

- **SFI-W1-Ini-AIFoundry**: Comprehensive initiative combining all AI Foundry policies with modular control groups

## 🔒 Security Controls

### Network Security
- **Private Endpoints**: Ensures all AI Foundry hubs use private connectivity
- **Public Network Access**: Disables public internet access to AI resources
- **Zero Trust Architecture**: Enforces network isolation and secure communication

### Data Protection
- **Customer-Managed Keys**: Requires bring-your-own-key (BYOK) encryption
- **Key Rotation**: Enforces automatic key rotation policies
- **Data Sovereignty**: Ensures data remains in approved regions

### Identity & Access Management
- **Managed Identity**: Requires user-assigned managed identities
- **Authentication**: Disables local authentication in favor of Azure AD
- **Role-Based Access**: Supports granular RBAC controls

### Compute Security
- **Secure Compute**: Disables local authentication on compute instances
- **Cluster Security**: Ensures secure configuration of compute clusters
- **Runtime Security**: Enforces secure runtime environments

### Monitoring & Compliance
- **Diagnostic Settings**: Comprehensive logging to Log Analytics, Storage, and Event Hubs
- **Audit Trail**: Complete audit trail for all AI operations
- **Compliance Reporting**: Support for multiple compliance frameworks

## 🚀 Deployment Guide

### Prerequisites

1. **Azure Subscription** with appropriate permissions
2. **Resource Groups** for AI Foundry resources
3. **Log Analytics Workspace** for monitoring (recommended)
4. **Key Vault** for customer-managed keys (if required)

### Step 1: Deploy Policy Definitions

```bash
# Deploy all AI Foundry policy definitions
az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-RequirePrivateEndpoints.bicep"

az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-RequireCustomerManagedKeys.bicep"

az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-DisablePublicNetworkAccess.bicep"

az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-RequireUserAssignedIdentity.bicep"

az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-DisableComputeLocalAuth.bicep"

az deployment sub create \
  --location "East US" \
  --template-file "policies/definitions/ai-foundry/SFI-W1-Def-AIFoundry-RequireDiagnosticSettings.bicep"
```

### Step 2: Deploy Policy Initiative

```bash
# Update subscription ID in the initiative template first
# Then deploy the comprehensive initiative
az deployment sub create \
  --location "East US" \
  --template-file "policies/initiatives/ai-foundry/SFI-W1-Ini-AIFoundry.bicep" \
  --parameters @ai-foundry-parameters.json
```

### Step 3: Assign Policy Initiative

```bash
# Assign to subscription
az policy assignment create \
  --name "AI-Foundry-Compliance" \
  --display-name "SFI-W1 AI Foundry Compliance Initiative" \
  --policy-set-definition "/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-AIFoundry" \
  --scope "/subscriptions/{subscription-id}" \
  --params @assignment-parameters.json
```

## ⚙️ Configuration Parameters

### Example Parameters File (ai-foundry-parameters.json)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "allowedLocations": {
      "value": ["eastus", "eastus2", "westus2", "westeurope"]
    },
    "privateEndpointsEffect": {
      "value": "Audit"
    },
    "encryptionEffect": {
      "value": "Audit"
    },
    "publicNetworkAccessEffect": {
      "value": "Deny"
    },
    "identityEffect": {
      "value": "Audit"
    },
    "computeAuthEffect": {
      "value": "Audit"
    },
    "diagnosticsEffect": {
      "value": "DeployIfNotExists"
    },
    "logAnalyticsWorkspaceId": {
      "value": "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"
    },
    "minPrivateEndpoints": {
      "value": 1
    },
    "requireKeyRotation": {
      "value": true
    },
    "logRetentionDays": {
      "value": 365
    }
  }
}
```

### Assignment Parameters (assignment-parameters.json)

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "enableNetworkSecurity": {
      "value": true
    },
    "enableDataProtection": {
      "value": true
    },
    "enableIdentityManagement": {
      "value": true
    },
    "enableComputeSecurity": {
      "value": true
    },
    "enableMonitoring": {
      "value": true
    },
    "allowedLocations": {
      "value": ["eastus", "eastus2", "westus2", "westeurope"]
    },
    "logAnalyticsWorkspaceId": {
      "value": "/subscriptions/{subscription-id}/resourceGroups/{rg-name}/providers/Microsoft.OperationalInsights/workspaces/{workspace-name}"
    }
  }
}
```

## 🔍 Monitoring & Compliance

### Compliance Dashboard

Use Azure Policy Compliance dashboard to monitor:
- **Overall Compliance Score**: Percentage of compliant resources
- **Policy Violations**: Detailed view of non-compliant resources
- **Remediation Tasks**: Automated remediation status
- **Compliance Trends**: Historical compliance data

### Log Analytics Queries

Common queries for AI Foundry governance monitoring:

```kusto
// AI Foundry Hub Activity
AzureActivity
| where CategoryValue == "Administrative"
| where ResourceProvider == "Microsoft.MachineLearningServices"
| where Resource contains "workspace"
| summarize count() by bin(TimeGenerated, 1h), OperationNameValue

// Policy Compliance Events
AzurePolicyEvaluationDetails
| where PolicyDefinitionName startswith "SFI-W1-Def-AIFoundry"
| summarize ComplianceCount = count() by PolicyDefinitionName, ComplianceState
| order by PolicyDefinitionName
```

### Alerts & Notifications

Set up alerts for:
- **Policy Violations**: Non-compliant AI Foundry resources
- **Security Events**: Unauthorized access attempts
- **Configuration Changes**: Modifications to AI Foundry hubs
- **Compliance Drift**: Degradation in compliance scores

## 🛠️ Troubleshooting

### Common Issues

1. **Policy Assignment Failures**
   - Verify subscription permissions
   - Check policy definition deployment status
   - Validate parameter values

2. **Compliance Evaluation Delays**
   - Policy evaluation occurs every 24 hours by default
   - Use compliance scans for immediate evaluation
   - Check resource provider registration

3. **Remediation Task Failures**
   - Verify managed identity permissions
   - Check resource locks
   - Review deployment logs

### Support Resources

- **Microsoft Documentation**: [Azure AI Foundry Governance](https://github.com/MicrosoftDocs/azure-ai-docs)
- **Azure Policy Documentation**: [Policy as Code](https://docs.microsoft.com/azure/governance/policy/)
- **SFI-W1 Framework**: Internal security framework documentation

## 📚 Additional Resources

### Related Policies
- [Azure OpenAI Policies](../azure-openai/)
- [Cognitive Services Policies](../cognitive-services/)
- [Machine Learning Policies](../machine-learning/)

### Compliance Frameworks
- **SFI-W1**: Security Framework Initiative Wave 1
- **NIST 800-53**: National Institute of Standards and Technology
- **ISO 27001**: Information Security Management
- **SOC 2**: Service Organization Control 2
- **FedRAMP**: Federal Risk and Authorization Management Program

### Training & Certification
- [Azure AI Fundamentals](https://docs.microsoft.com/learn/certifications/azure-ai-fundamentals/)
- [Azure Security Engineer](https://docs.microsoft.com/learn/certifications/azure-security-engineer/)
- [Azure Policy Workshop](https://docs.microsoft.com/learn/modules/intro-to-governance/)

---

## 📝 Change Log

| Version | Date | Description |
|---------|------|-------------|
| 2.0.0 | 2024-01-XX | Complete recreation based on Microsoft documentation |
| 1.0.0 | 2024-01-XX | Initial policy framework creation |

## 🤝 Contributing

For policy updates and improvements:
1. Follow SFI-W1 naming conventions
2. Base changes on official Microsoft documentation
3. Test policies in development environment
4. Update documentation and examples
5. Submit changes through proper review process

---

*This documentation is maintained as part of the SFI-W1 Azure Policy compliance framework.*
