# Azure Document Intelligence Policy Definitions - SFI-W1 Compliance

This directory contains Azure Policy definitions for Azure Document Intelligence (Form Recognizer) services implementing SFI-W1 security and compliance standards.

## Table of Contents

- [Overview](#overview)
- [Policy Definitions](#policy-definitions)
- [Architecture](#architecture)
- [Deployment](#deployment)
- [Compliance](#compliance)
- [Troubleshooting](#troubleshooting)

## Overview

These policies implement comprehensive security and compliance controls for Azure Document Intelligence services based on the SFI-W1 framework. They ensure proper configuration of network security, identity management, resource governance, and monitoring for AI-powered document processing.

### Key Features

- **Zero-Trust Network Architecture**: Private endpoint requirements and network restrictions
- **Identity Management**: Managed identity enforcement for secure access
- **Resource Governance**: SKU restrictions and service standards
- **Network Security**: Custom domains and secure authentication
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

### 1. SFI-W1-Def-DocIntel-RequirePrivateEndpoints.bicep

**Purpose**: Ensures Azure Document Intelligence services are configured with private endpoints for secure network access.

**Description**: This policy audits or denies creation of Document Intelligence services that do not have private endpoint connections configured. It supports zero-trust architecture by ensuring all access goes through private network paths, critical for document processing workloads handling sensitive data.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedLocations`: Approved Azure regions for service deployment
- `excludedResourceGroups`: Resource groups to exclude from policy evaluation
- `minPrivateEndpoints`: Minimum number of required private endpoints

**Policy Rule**: Evaluates Document Intelligence services for private endpoint configuration and validates connection state and network isolation.

### 2. SFI-W1-Def-DocIntel-RequireManagedIdentity.bicep

**Purpose**: Ensures Document Intelligence services use managed identities for secure authentication.

**Description**: This policy enforces the use of system-assigned or user-assigned managed identities for Azure Document Intelligence services, eliminating the need for stored credentials and supporting zero-trust authentication patterns.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `requiredIdentityType`: Required managed identity type (SystemAssigned/UserAssigned)

**Policy Rule**: Validates managed identity configuration and ensures proper identity assignment for secure access to dependent services.

### 3. SFI-W1-Def-DocIntel-RestrictSKUs.bicep

**Purpose**: Controls and restricts SKU usage for cost management and compliance.

**Description**: This policy restricts the creation of Document Intelligence services to approved SKU tiers, ensuring cost control and compliance with organizational standards for AI service usage.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedSKUs`: List of approved SKU names (F0, S0)
- `excludedResourceGroups`: Resource groups to exclude from restrictions

**Policy Rule**: Validates SKU selection against approved lists and prevents deployment of unauthorized service tiers.

### 4. SFI-W1-Def-DocIntel-RequireNetworkRestrictions.bicep

**Purpose**: Enforces secure network configuration and authentication controls.

**Description**: This policy ensures that Azure Document Intelligence services are configured with proper network restrictions, custom domains, and secure authentication methods to prevent unauthorized access to document processing capabilities.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `allowedNetworkDefaultActions`: Approved network access default actions
- `requireDisableLocalAuth`: Whether to require disabling local authentication
- `requireCustomDomain`: Whether to require custom domain configuration

**Policy Rule**: Validates network access configuration, authentication settings, and custom domain requirements.

### 5. SFI-W1-Def-DocIntel-RequireDiagnosticSettings.bicep

**Purpose**: Ensures comprehensive logging and monitoring for Document Intelligence services.

**Description**: This policy automatically configures diagnostic settings for Azure Document Intelligence services to ensure proper logging, monitoring, and compliance audit trails for AI document processing activities.

**Parameters**:
- `effect`: Policy effect (AuditIfNotExists/DeployIfNotExists/Disabled)
- `logAnalyticsWorkspaceId`: Target Log Analytics workspace for centralized logging
- `storageAccountId`: Target storage account for long-term log retention
- `eventHubAuthorizationRuleId`: Target Event Hub for real-time log streaming
- `requiredLogCategories`: Required log categories to enable for compliance
- `logRetentionDays`: Number of days to retain diagnostic logs
- `diagnosticSettingsName`: Name for diagnostic settings configuration

**Policy Rule**: Deploys or audits diagnostic settings configuration with specified log categories, retention policies, and multi-destination logging.

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
│  │  │  │    Document Intelligence Service    ││││
│  │  │  │         (Form Recognizer)           ││││
│  │  │  │                                     ││││
│  │  │  │  ┌─────────────────────────────────┐││││
│  │  │  │  │       Document Processing       │││││
│  │  │  │  │       (Private Access)          │││││
│  │  │  │  └─────────────────────────────────┘││││
│  │  │  └─────────────────────────────────────┘│││
│  │  └─────────────────────────────────────────┘││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

### Identity and Access Architecture

```
┌─────────────────────────────────────────────────┐
│               Azure Active Directory            │
│  ┌─────────────────────────────────────────────┐│
│  │           Managed Identity                  ││
│  │        (System or User Assigned)           ││
│  └─────────────────┬───────────────────────────┘│
└─────────────────────┼───────────────────────────┘
                      │ Secure Authentication
                      ▼
┌─────────────────────────────────────────────────┐
│         Document Intelligence Service            │
│  ┌─────────────────────────────────────────────┐│
│  │            Custom Models                    ││
│  │          (Managed Access)                   ││
│  └─────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────┐│
│  │         Document Processing                 ││
│  │         (Zero-Trust Access)                 ││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

## Deployment

### Prerequisites

1. **Azure PowerShell** or **Azure CLI** installed
2. **Contributor** or **Owner** role on target subscription
3. **Policy Contributor** role for policy deployment
4. **Log Analytics workspace** (for monitoring policies)
5. **Virtual Network and Private DNS** (for private endpoint policies)

### Deployment Steps

#### 1. Deploy Individual Policy Definitions

```powershell
# Deploy all Document Intelligence policy definitions
$resourceGroupName = "rg-governance-prod"
$location = "eastus"

# Deploy private endpoints policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-DocIntel-RequirePrivateEndpoints.bicep" `
    -Verbose

# Deploy managed identity policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-DocIntel-RequireManagedIdentity.bicep" `
    -Verbose

# Deploy SKU restrictions policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-DocIntel-RestrictSKUs.bicep" `
    -Verbose

# Deploy network restrictions policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-DocIntel-RequireNetworkRestrictions.bicep" `
    -Verbose

# Deploy diagnostic settings policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-DocIntel-RequireDiagnosticSettings.bicep" `
    -Verbose
```

#### 2. Deploy Policy Initiative

```powershell
# Deploy the comprehensive Document Intelligence initiative
New-AzSubscriptionDeployment `
    -Location $location `
    -TemplateFile "..\initiatives\document-intelligence\SFI-W1-Ini-DocIntel.bicep" `
    -Verbose
```

#### 3. Assign Policy Initiative

```powershell
# Assign the initiative to a subscription
$subscriptionId = "your-subscription-id"
$initiativeId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-DocIntel"

$assignment = New-AzPolicyAssignment `
    -Name "SFI-W1-DocumentIntelligence-Assignment" `
    -DisplayName "SFI-W1 Document Intelligence Compliance" `
    -Description "Comprehensive Document Intelligence security and compliance controls" `
    -PolicySetDefinition $initiativeId `
    -Scope "/subscriptions/$subscriptionId" `
    -PolicyParameterObject @{
        privateEndpointsEffect = "Audit"
        identityEffect = "Audit"
        skuRestrictionEffect = "Deny"
        networkRestrictionsEffect = "Audit"
        diagnosticsEffect = "DeployIfNotExists"
        logAnalyticsWorkspaceId = "/subscriptions/$subscriptionId/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod"
        allowedLocations = @("eastus", "eastus2", "westus2")
        allowedSKUs = @("F0", "S0")
        requireDisableLocalAuth = $true
        requireCustomDomain = $true
    }
```

### Using Azure CLI

```bash
# Deploy policy definitions
az deployment group create \
    --resource-group rg-governance-prod \
    --template-file ./SFI-W1-Def-DocIntel-RequirePrivateEndpoints.bicep

# Deploy initiative
az deployment sub create \
    --location eastus \
    --template-file ../initiatives/document-intelligence/SFI-W1-Ini-DocIntel.bicep

# Assign initiative
az policy assignment create \
    --name "SFI-W1-DocumentIntelligence-Assignment" \
    --display-name "SFI-W1 Document Intelligence Compliance" \
    --policy-set-definition $initiativeId \
    --scope "/subscriptions/$subscriptionId" \
    --params '{
        "privateEndpointsEffect": {"value": "Audit"},
        "identityEffect": {"value": "Audit"},
        "skuRestrictionEffect": {"value": "Deny"},
        "networkRestrictionsEffect": {"value": "Audit"},
        "diagnosticsEffect": {"value": "DeployIfNotExists"}
    }'
```

## Compliance

### SFI-W1 Requirements Mapping

| Policy | SFI-W1 Control | Description |
|--------|----------------|-------------|
| RequirePrivateEndpoints | Network Security | Implements zero-trust network architecture for AI services |
| RequireManagedIdentity | Identity Management | Eliminates credential-based authentication |
| RestrictSKUs | Resource Governance | Controls service tier usage and AI capabilities |
| RequireNetworkRestrictions | Secure Communication | Enforces network security and custom domains |
| RequireDiagnosticSettings | Monitoring | Ensures comprehensive audit logging for AI operations |

### Data Privacy and AI Ethics

Document Intelligence services process sensitive documents containing personal and business information. These policies ensure:

- **Data Residency**: Private endpoints keep data within controlled network boundaries
- **Access Control**: Managed identities provide secure, auditable access
- **Audit Trail**: Comprehensive logging tracks all document processing activities
- **Network Isolation**: Private endpoints prevent unauthorized data exfiltration

### Compliance Dashboard

Monitor compliance using Azure Policy dashboard:
- **Resource Compliance**: Track compliant vs non-compliant Document Intelligence services
- **Policy Violations**: Identify and remediate security gaps
- **Audit Reports**: Generate compliance reports for security reviews
- **Trend Analysis**: Monitor compliance improvements over time

## Troubleshooting

### Common Issues

#### 1. Private Endpoint Configuration

**Symptom**: Policy reports non-compliance for private endpoints
**Solution**: 
- Verify private endpoint is properly connected
- Check private DNS zone configuration
- Ensure network security group rules allow traffic
- Validate private endpoint approval status

#### 2. Managed Identity Assignment

**Symptom**: Services failing managed identity validation
**Solution**:
- Verify managed identity is properly assigned
- Check identity type matches policy requirements
- Ensure managed identity has necessary permissions
- Review Azure AD configuration

#### 3. Custom Domain Requirements

**Symptom**: Policy violations for custom domain configuration
**Solution**:
- Configure custom subdomain for the service
- Verify DNS CNAME record configuration
- Check SSL certificate validity
- Ensure custom domain is properly validated

#### 4. Diagnostic Settings Deployment

**Symptom**: DeployIfNotExists policy not creating diagnostic settings
**Solution**:
- Verify managed identity has correct permissions
- Check Log Analytics workspace accessibility
- Review storage account configuration
- Validate Event Hub authorization rules

### Debug Commands

```powershell
# Check Document Intelligence service configuration
$resourceGroupName = "rg-docai-prod"
$serviceName = "doc-intelligence-service"

# Get service details
$service = Get-AzCognitiveServicesAccount -ResourceGroupName $resourceGroupName -Name $serviceName

# Check private endpoints
$service.NetworkAcls
$service.PrivateEndpointConnections

# Check managed identity
$service.Identity

# Check diagnostic settings
Get-AzDiagnosticSetting -ResourceId $service.Id

# Get policy compliance state
Get-AzPolicyState -ResourceId $service.Id
```

### Performance Considerations

- **Private Endpoints**: May add slight latency but provide security benefits
- **Diagnostic Logging**: Monitor log volume to manage costs
- **Network Restrictions**: Ensure legitimate traffic can reach the service
- **Authentication**: Managed identity authentication may require token refresh

### Support Resources

- **Document Intelligence Documentation**: https://docs.microsoft.com/azure/applied-ai-services/form-recognizer/
- **Azure Policy Troubleshooting**: https://docs.microsoft.com/azure/governance/policy/troubleshoot/
- **Private Endpoint Configuration**: https://docs.microsoft.com/azure/private-link/
- **Azure Support**: Create support ticket for complex policy or service issues

---

## Best Practices

### Security Recommendations

1. **Use System-Assigned Managed Identity** when possible for simplified identity management
2. **Enable Private Endpoints** for all production Document Intelligence services
3. **Configure Custom Domains** to support enterprise security requirements
4. **Monitor Processing Activities** through comprehensive diagnostic logging
5. **Implement Network Restrictions** to prevent unauthorized access

### Cost Optimization

1. **Use F0 (Free) Tier** for development and testing environments
2. **Monitor API Call Volumes** to optimize SKU selection
3. **Set up Alerts** for unusual processing activity
4. **Review Log Retention** policies to balance compliance and costs

### Operational Excellence

1. **Automate Policy Deployment** using infrastructure as code
2. **Regular Compliance Reviews** to identify and address violations
3. **Document Exemptions** with proper business justification
4. **Test Policy Changes** in non-production environments first

## Contributing

When adding new policies or modifying existing ones:

1. Follow SFI-W1 naming conventions: `SFI-W1-Def-DocIntel-[PolicyName]`
2. Include comprehensive parameter validation and metadata
3. Add detailed compliance framework mappings
4. Update documentation with deployment examples
5. Test thoroughly in development environment before production

## License

This project is licensed under the MIT License - see the LICENSE file for details.
