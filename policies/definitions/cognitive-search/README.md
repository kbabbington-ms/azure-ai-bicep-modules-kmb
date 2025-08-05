# Azure Cognitive Search Policy Definitions - SFI-W1 Compliance

This directory contains Azure Policy definitions for Azure Cognitive Search services implementing SFI-W1 security and compliance standards.

## Table of Contents

- [Overview](#overview)
- [Policy Definitions](#policy-definitions)
- [Architecture](#architecture)
- [Deployment](#deployment)
- [Compliance](#compliance)
- [Troubleshooting](#troubleshooting)

## Overview

These policies implement comprehensive security and compliance controls for Azure Cognitive Search services based on the SFI-W1 framework. They ensure proper configuration of network security, data protection, identity management, resource governance, and monitoring.

### Key Features

- **Zero-Trust Network Architecture**: Private endpoint requirements and secure communication
- **Data Protection**: Customer-managed encryption keys with Key Vault integration
- **Identity Management**: Managed identity enforcement for secure access
- **Resource Governance**: SKU restrictions and resource standards
- **Secure Communication**: HTTPS enforcement and authentication controls
- **Monitoring**: Comprehensive diagnostic settings and audit logging

### Compliance Standards

- SFI-W1 (Secure Foundation Initiative - Wave 1)
- Azure Trusted Signing (AzTS)
- NIST 800-53
- ISO 27001
- SOC 2 Type II
- FedRAMP
- GDPR

## Policy Definitions

### 1. SFI-W1-Def-Search-RequirePrivateEndpoints.bicep

**Purpose**: Ensures Azure Cognitive Search services are configured with private endpoints for secure network access.

**Description**: This policy audits or denies creation of Cognitive Search services that do not have private endpoint connections configured. It supports zero-trust architecture by ensuring all access goes through private network paths.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedLocations`: Approved Azure regions
- `excludedResourceGroups`: Resource groups to exclude
- `minPrivateEndpoints`: Minimum number of required private endpoints

**Policy Rule**: Evaluates Search services for private endpoint configuration and validates connection state.

### 2. SFI-W1-Def-Search-RequireCustomerManagedKeys.bicep

**Purpose**: Enforces customer-managed encryption keys for data protection in Azure Cognitive Search.

**Description**: This policy ensures that Cognitive Search services use customer-managed keys stored in Azure Key Vault for encryption at rest. It validates Key Vault configuration and key rotation settings.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude
- `allowedKeyVaultLocations`: Approved Key Vault regions
- `requireKeyRotation`: Whether to require automatic key rotation

**Policy Rule**: Validates encryption configuration and Key Vault integration.

### 3. SFI-W1-Def-Search-RequireManagedIdentity.bicep

**Purpose**: Ensures Cognitive Search services use managed identities for secure authentication.

**Description**: This policy enforces the use of system-assigned or user-assigned managed identities for Azure Cognitive Search services, eliminating the need for stored credentials.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude
- `requiredIdentityType`: Required managed identity type

**Policy Rule**: Validates managed identity configuration and type.

### 4. SFI-W1-Def-Search-RestrictSKUs.bicep

**Purpose**: Controls and restricts SKU usage for cost management and compliance.

**Description**: This policy restricts the creation of Cognitive Search services to approved SKU tiers and implements approval workflows for high-tier SKUs that may require additional security review.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedSKUs`: List of approved SKU names
- `highTierSKUs`: SKUs requiring special approval
- `excludedResourceGroups`: Resource groups to exclude

**Policy Rule**: Validates SKU selection against approved lists and high-tier restrictions.

### 5. SFI-W1-Def-Search-RequireHTTPS.bicep

**Purpose**: Enforces secure communication protocols for Cognitive Search services.

**Description**: This policy ensures that Azure Cognitive Search services are configured to require HTTPS for all communications and disables local authentication methods when specified.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude
- `requireDisableLocalAuth`: Whether to require disabling local authentication
- `allowedNetworkDefaultActions`: Approved network access default actions

**Policy Rule**: Validates HTTPS configuration and authentication settings.

### 6. SFI-W1-Def-Search-RequireDiagnosticSettings.bicep

**Purpose**: Ensures comprehensive logging and monitoring for Cognitive Search services.

**Description**: This policy automatically configures diagnostic settings for Azure Cognitive Search services to ensure proper logging, monitoring, and compliance audit trails.

**Parameters**:
- `effect`: Policy effect (AuditIfNotExists/DeployIfNotExists/Disabled)
- `logAnalyticsWorkspaceId`: Target Log Analytics workspace
- `storageAccountId`: Target storage account for logs
- `eventHubAuthorizationRuleId`: Target Event Hub for streaming
- `requiredLogCategories`: Required log categories to enable
- `logRetentionDays`: Number of days to retain logs
- `diagnosticSettingsName`: Name for diagnostic settings

**Policy Rule**: Deploys or audits diagnostic settings configuration with specified log categories and retention.

## Architecture

### Network Security Model

```
┌─────────────────────────────────────────────────┐
│                Azure Virtual Network            │
│  ┌─────────────────────────────────────────────┐│
│  │              Private Subnet                 ││
│  │  ┌─────────────────────────────────────────┐││
│  │  │           Private Endpoint              │││
│  │  │  ┌─────────────────────────────────────┐│││
│  │  │  │     Cognitive Search Service        ││││
│  │  │  │                                     ││││
│  │  │  │  ┌─────────────────────────────────┐││││
│  │  │  │  │         Search Index            │││││
│  │  │  │  │    (Customer Managed Keys)      │││││
│  │  │  │  └─────────────────────────────────┘││││
│  │  │  └─────────────────────────────────────┘│││
│  │  └─────────────────────────────────────────┘││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

### Data Protection Architecture

```
┌─────────────────────────────────────────────────┐
│                Azure Key Vault                  │
│  ┌─────────────────────────────────────────────┐│
│  │           Customer Managed Key              ││
│  │              (with rotation)                ││
│  └─────────────────────────────────────────────┘│
└─────────────────┬───────────────────────────────┘
                  │ Encryption Key
                  ▼
┌─────────────────────────────────────────────────┐
│            Cognitive Search Service              │
│  ┌─────────────────────────────────────────────┐│
│  │              Search Index                   ││
│  │           (Encrypted at Rest)               ││
│  └─────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────┐│
│  │             Search Documents               ││
│  │           (Encrypted at Rest)               ││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## Deployment

### Prerequisites

1. **Azure PowerShell** or **Azure CLI** installed
2. **Contributor** or **Owner** role on target subscription
3. **Policy Contributor** role for policy deployment
4. **Log Analytics workspace** (for monitoring policies)
5. **Azure Key Vault** (for encryption policies)

### Deployment Steps

#### 1. Deploy Individual Policy Definitions

```powershell
# Deploy all Cognitive Search policy definitions
$resourceGroupName = "rg-governance-prod"
$location = "eastus"

# Deploy private endpoints policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RequirePrivateEndpoints.bicep" `
    -Verbose

# Deploy customer-managed keys policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RequireCustomerManagedKeys.bicep" `
    -Verbose

# Deploy managed identity policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RequireManagedIdentity.bicep" `
    -Verbose

# Deploy SKU restrictions policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RestrictSKUs.bicep" `
    -Verbose

# Deploy HTTPS requirements policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RequireHTTPS.bicep" `
    -Verbose

# Deploy diagnostic settings policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-Search-RequireDiagnosticSettings.bicep" `
    -Verbose
```

#### 2. Deploy Policy Initiative

```powershell
# Deploy the comprehensive Cognitive Search initiative
New-AzSubscriptionDeployment `
    -Location $location `
    -TemplateFile "..\initiatives\cognitive-search\SFI-W1-Ini-Search.bicep" `
    -Verbose
```

#### 3. Assign Policy Initiative

```powershell
# Assign the initiative to a subscription
$subscriptionId = "your-subscription-id"
$initiativeId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-Search"

$assignment = New-AzPolicyAssignment `
    -Name "SFI-W1-CognitiveSearch-Assignment" `
    -DisplayName "SFI-W1 Cognitive Search Compliance" `
    -Description "Comprehensive Cognitive Search security and compliance controls" `
    -PolicySetDefinition $initiativeId `
    -Scope "/subscriptions/$subscriptionId" `
    -PolicyParameterObject @{
        privateEndpointsEffect = "Audit"
        encryptionEffect = "Audit"
        identityEffect = "Audit"
        skuRestrictionEffect = "Deny"
        httpsEffect = "Audit"
        diagnosticsEffect = "DeployIfNotExists"
        logAnalyticsWorkspaceId = "/subscriptions/$subscriptionId/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod"
        allowedLocations = @("eastus", "eastus2", "westus2")
        allowedSKUs = @("basic", "standard", "standard2", "standard3")
        highTierSKUs = @("standard3")
    }
```

### Using Azure CLI

```bash
# Deploy policy definitions
az deployment group create \
    --resource-group rg-governance-prod \
    --template-file ./SFI-W1-Def-Search-RequirePrivateEndpoints.bicep

# Deploy initiative
az deployment sub create \
    --location eastus \
    --template-file ../initiatives/cognitive-search/SFI-W1-Ini-Search.bicep

# Assign initiative
az policy assignment create \
    --name "SFI-W1-CognitiveSearch-Assignment" \
    --display-name "SFI-W1 Cognitive Search Compliance" \
    --policy-set-definition $initiativeId \
    --scope "/subscriptions/$subscriptionId" \
    --params '{
        "privateEndpointsEffect": {"value": "Audit"},
        "encryptionEffect": {"value": "Audit"},
        "identityEffect": {"value": "Audit"},
        "skuRestrictionEffect": {"value": "Deny"},
        "httpsEffect": {"value": "Audit"},
        "diagnosticsEffect": {"value": "DeployIfNotExists"}
    }'
```

## Compliance

### SFI-W1 Requirements Mapping

| Policy | SFI-W1 Control | Description |
|--------|----------------|-------------|
| RequirePrivateEndpoints | Network Security | Implements zero-trust network architecture |
| RequireCustomerManagedKeys | Data Protection | Ensures customer control over encryption keys |
| RequireManagedIdentity | Identity Management | Eliminates credential-based authentication |
| RestrictSKUs | Resource Governance | Controls service tier usage and costs |
| RequireHTTPS | Secure Communication | Enforces encrypted communication |
| RequireDiagnosticSettings | Monitoring | Ensures comprehensive audit logging |

### Compliance Dashboard

Use Azure Policy Compliance dashboard to monitor:
- **Overall Compliance Score**: Percentage of compliant resources
- **Policy Assignment Status**: Success/failure of policy evaluations  
- **Non-Compliant Resources**: Resources requiring remediation
- **Compliance Trends**: Historical compliance tracking

### Remediation

For non-compliant resources:

1. **Audit Policies**: Review compliance reports and identify violations
2. **Manual Remediation**: Update resources to meet policy requirements
3. **Automated Remediation**: Use DeployIfNotExists policies for automatic fixes
4. **Exemptions**: Create policy exemptions for legitimate exceptions

## Troubleshooting

### Common Issues

#### 1. Policy Assignment Failures

**Symptom**: Policy assignment creation fails
**Solution**: 
- Verify sufficient permissions (Policy Contributor role)
- Check policy definition exists and is valid
- Validate parameter values and types

#### 2. Compliance Evaluation Delays

**Symptom**: Policy compliance not updating
**Solution**:
- Wait for evaluation cycle (up to 24 hours)
- Trigger manual evaluation: `Start-AzPolicyComplianceScan`
- Check Activity Log for evaluation errors

#### 3. DeployIfNotExists Policy Failures

**Symptom**: Automatic remediation not working
**Solution**:
- Verify managed identity has sufficient permissions
- Check resource provider registration
- Review deployment logs in Activity Log

#### 4. False Positive Compliance Issues

**Symptom**: Compliant resources showing as non-compliant
**Solution**:
- Verify policy logic and conditions
- Check for resource property case sensitivity
- Review policy rule evaluation order

### Debug Commands

```powershell
# Check policy assignment status
Get-AzPolicyAssignment -Scope "/subscriptions/$subscriptionId" | Where-Object {$_.Properties.DisplayName -like "*Cognitive Search*"}

# Get compliance state
Get-AzPolicyState -SubscriptionId $subscriptionId -PolicyAssignmentName "SFI-W1-CognitiveSearch-Assignment"

# Trigger compliance evaluation
Start-AzPolicyComplianceScan -SubscriptionId $subscriptionId

# Get policy events
Get-AzPolicyEvent -SubscriptionId $subscriptionId -Top 100 | Where-Object {$_.PolicyDefinitionName -like "*Search*"}
```

### Support Resources

- **Azure Policy Documentation**: https://docs.microsoft.com/azure/governance/policy/
- **Cognitive Search Security**: https://docs.microsoft.com/azure/search/search-security-overview
- **SFI-W1 Guidelines**: Internal security framework documentation
- **Azure Support**: Create support ticket for complex policy issues

---

## Contributing

When adding new policies or modifying existing ones:

1. Follow SFI-W1 naming conventions
2. Include comprehensive parameter validation
3. Add detailed metadata and compliance mappings
4. Update documentation and deployment scripts
5. Test thoroughly in development environment

## License

This project is licensed under the MIT License - see the LICENSE file for details.
