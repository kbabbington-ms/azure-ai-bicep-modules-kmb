# Azure Cognitive Services Policy Definitions - SFI-W1 Compliance

This directory contains Azure Policy definitions for Azure Cognitive Services implementing SFI-W1 security and compliance standards. These policies cover general Cognitive Services excluding Azure OpenAI and Document Intelligence, which have their own specialized policy sets.

## Table of Contents

- [Overview](#overview)
- [Policy Definitions](#policy-definitions)
- [Architecture](#architecture)
- [Deployment](#deployment)
- [Compliance](#compliance)
- [Troubleshooting](#troubleshooting)

## Overview

These policies implement comprehensive security and compliance controls for Azure Cognitive Services based on the SFI-W1 framework. They ensure proper configuration of network security, data protection, identity management, resource governance, secure communication, data residency, and monitoring for AI services.

### Covered Services

- **Computer Vision**: Image analysis and OCR capabilities
- **Text Analytics**: Language understanding and sentiment analysis  
- **Speech Services**: Speech-to-text and text-to-speech
- **Face API**: Facial recognition and analysis
- **Custom Vision**: Custom image classification models
- **LUIS**: Language understanding intelligent service
- **QnA Maker**: Question and answer knowledge bases
- **Translator**: Text translation services
- **Anomaly Detector**: Time-series anomaly detection
- **Personalizer**: AI-powered personalization

### Key Features

- **Zero-Trust Network Architecture**: Private endpoint requirements and secure communication
- **Data Protection**: Customer-managed encryption keys with Key Vault integration
- **Identity Management**: Managed identity enforcement for secure access
- **Resource Governance**: SKU restrictions and service approval workflows
- **Secure Communication**: HTTPS enforcement and authentication controls
- **Data Residency**: Geographic restrictions for data processing
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

### 1. SFI-W1-Def-CogSvc-RequirePrivateEndpoints.bicep

**Purpose**: Ensures Azure Cognitive Services are configured with private endpoints for secure network access.

**Description**: This policy audits or denies creation of Cognitive Services that do not have private endpoint connections configured. It excludes OpenAI and Form Recognizer services which have dedicated policies. Supports zero-trust architecture by ensuring AI services are only accessible through private network paths.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedLocations`: Approved Azure regions for service deployment
- `excludedResourceGroups`: Resource groups to exclude from policy evaluation
- `minPrivateEndpoints`: Minimum number of required private endpoints
- `allowedKinds`: Approved Cognitive Services kinds to evaluate

**Policy Rule**: Evaluates Cognitive Services for private endpoint configuration while excluding OpenAI and Form Recognizer services.

### 2. SFI-W1-Def-CogSvc-RequireCustomerManagedKeys.bicep

**Purpose**: Enforces customer-managed encryption keys for data protection in Azure Cognitive Services.

**Description**: This policy ensures that Cognitive Services use customer-managed keys stored in Azure Key Vault for encryption at rest. It validates Key Vault configuration, key rotation settings, and supports compliance with data sovereignty requirements.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `allowedKeyVaultLocations`: Approved Key Vault regions for encryption keys
- `requireKeyRotation`: Whether to require automatic key rotation

**Policy Rule**: Validates encryption configuration, Key Vault integration, and key management practices.

### 3. SFI-W1-Def-CogSvc-RequireManagedIdentity.bicep

**Purpose**: Ensures Cognitive Services use managed identities for secure authentication.

**Description**: This policy enforces the use of system-assigned or user-assigned managed identities for Azure Cognitive Services, eliminating the need for stored credentials and supporting zero-trust authentication patterns.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `requiredIdentityType`: Required managed identity type (SystemAssigned/UserAssigned)

**Policy Rule**: Validates managed identity configuration and ensures proper identity assignment for secure access to dependent services.

### 4. SFI-W1-Def-CogSvc-RestrictSKUs.bicep

**Purpose**: Controls and restricts SKU usage for cost management and compliance.

**Description**: This policy restricts the creation of Cognitive Services to approved SKU tiers and implements approval workflows for high-tier SKUs and restricted service kinds that may require additional security review or have ethical implications.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedSKUs`: List of approved SKU names for general use
- `highTierSKUs`: SKUs requiring special approval (S3, S4)
- `restrictedKinds`: Service kinds requiring special approval (Face, CustomVision, PersonalizerChatCompletion)
- `excludedResourceGroups`: Resource groups to exclude from restrictions

**Policy Rule**: Validates SKU selection and service kind against approved lists and implements approval workflows for restricted services.

### 5. SFI-W1-Def-CogSvc-RequireHTTPS.bicep

**Purpose**: Enforces secure communication protocols for Cognitive Services.

**Description**: This policy ensures that Azure Cognitive Services are configured to require HTTPS for all communications, disable local authentication methods, and configure secure network access patterns.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `requireDisableLocalAuth`: Whether to require disabling local authentication
- `requireCustomSubdomain`: Whether to require custom subdomain configuration
- `allowedNetworkDefaultActions`: Approved network access default actions

**Policy Rule**: Validates HTTPS configuration, authentication settings, and network access controls.

### 6. SFI-W1-Def-CogSvc-RestrictDataResidency.bicep

**Purpose**: Enforces data residency and sovereignty requirements for Cognitive Services.

**Description**: This policy ensures that data processing services comply with geographic restrictions and data sovereignty requirements. It identifies services that process personal or sensitive data and restricts their deployment to approved regions.

**Parameters**:
- `effect`: Policy effect (Audit/Deny/Disabled)
- `allowedLocations`: General approved Azure regions
- `dataProcessingKinds`: Service kinds requiring strict data residency
- `dataProcessingLocations`: Restricted locations for data processing services
- `excludedResourceGroups`: Resource groups to exclude from evaluation
- `requireRestrictOutboundAccess`: Whether to require restricting outbound access

**Policy Rule**: Validates service location against data residency requirements and implements geographic restrictions for sensitive data processing.

### 7. SFI-W1-Def-CogSvc-RequireDiagnosticSettings.bicep

**Purpose**: Ensures comprehensive logging and monitoring for Cognitive Services.

**Description**: This policy automatically configures diagnostic settings for Azure Cognitive Services to ensure proper logging, monitoring, and compliance audit trails for AI operations. Supports multi-destination logging for comprehensive observability.

**Parameters**:
- `effect`: Policy effect (AuditIfNotExists/DeployIfNotExists/Disabled)
- `logAnalyticsWorkspaceId`: Target Log Analytics workspace for centralized logging
- `storageAccountId`: Target storage account for long-term log retention
- `eventHubAuthorizationRuleId`: Target Event Hub for real-time log streaming
- `requiredLogCategories`: Required log categories for compliance (Audit, RequestResponse, Trace)
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
│  │  │        Private Endpoints Zone           │││
│  │  │  ┌─────────────────────────────────────┐│││
│  │  │  │      Computer Vision Service        ││││
│  │  │  └─────────────────────────────────────┘│││
│  │  │  ┌─────────────────────────────────────┐│││
│  │  │  │       Text Analytics Service        ││││
│  │  │  └─────────────────────────────────────┘│││
│  │  │  ┌─────────────────────────────────────┐│││
│  │  │  │        Speech Service               ││││
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
│  │         Customer Managed Keys              ││
│  │           (with rotation)                   ││
│  └─────────────────┬───────────────────────────┘│
└─────────────────────┼───────────────────────────┘
                      │ Encryption Keys
                      ▼
┌─────────────────────────────────────────────────┐
│             Cognitive Services                   │
│  ┌─────────────────────────────────────────────┐│
│  │           Computer Vision                   ││
│  │         (Encrypted at Rest)                 ││
│  └─────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────┐│
│  │          Text Analytics                     ││
│  │         (Encrypted at Rest)                 ││
│  └─────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────┐│
│  │            Speech Services                  ││
│  │         (Encrypted at Rest)                 ││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘
```

### Data Residency Model

```
┌─────────────────────────────────────────────────┐
│                   US East                       │
│  ┌─────────────────────────────────────────────┐│
│  │        General AI Services                  ││
│  │    (Computer Vision, Translator)            ││
│  └─────────────────────────────────────────────┘│
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│              Restricted Regions                 │
│                (US East, West Europe)           │
│  ┌─────────────────────────────────────────────┐│
│  │       Data Processing Services              ││
│  │   (Text Analytics, Face, Speech)            ││
│  │        (PII/Sensitive Data)                 ││
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
6. **Virtual Network and Private DNS** (for private endpoint policies)

### Deployment Steps

#### 1. Deploy Individual Policy Definitions

```powershell
# Deploy all Cognitive Services policy definitions
$resourceGroupName = "rg-governance-prod"
$location = "eastus"

# Deploy private endpoints policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RequirePrivateEndpoints.bicep" `
    -Verbose

# Deploy customer-managed keys policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RequireCustomerManagedKeys.bicep" `
    -Verbose

# Deploy managed identity policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RequireManagedIdentity.bicep" `
    -Verbose

# Deploy SKU restrictions policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RestrictSKUs.bicep" `
    -Verbose

# Deploy HTTPS requirements policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RequireHTTPS.bicep" `
    -Verbose

# Deploy data residency policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RestrictDataResidency.bicep" `
    -Verbose

# Deploy diagnostic settings policy
New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile ".\SFI-W1-Def-CogSvc-RequireDiagnosticSettings.bicep" `
    -Verbose
```

#### 2. Deploy Policy Initiative

```powershell
# Deploy the comprehensive Cognitive Services initiative
New-AzSubscriptionDeployment `
    -Location $location `
    -TemplateFile "..\initiatives\cognitive-services\SFI-W1-Ini-CogSvc.bicep" `
    -Verbose
```

#### 3. Assign Policy Initiative

```powershell
# Assign the initiative to a subscription
$subscriptionId = "your-subscription-id"
$initiativeId = "/subscriptions/$subscriptionId/providers/Microsoft.Authorization/policySetDefinitions/SFI-W1-Ini-CogSvc"

$assignment = New-AzPolicyAssignment `
    -Name "SFI-W1-CognitiveServices-Assignment" `
    -DisplayName "SFI-W1 Cognitive Services Compliance" `
    -Description "Comprehensive Cognitive Services security and compliance controls" `
    -PolicySetDefinition $initiativeId `
    -Scope "/subscriptions/$subscriptionId" `
    -PolicyParameterObject @{
        privateEndpointsEffect = "Audit"
        encryptionEffect = "Audit"
        identityEffect = "Audit"
        skuRestrictionEffect = "Deny"
        httpsEffect = "Audit"
        dataResidencyEffect = "Audit"
        diagnosticsEffect = "DeployIfNotExists"
        logAnalyticsWorkspaceId = "/subscriptions/$subscriptionId/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-prod"
        allowedLocations = @("eastus", "eastus2", "westus2", "westeurope")
        allowedSKUs = @("F0", "S0", "S1", "S2")
        highTierSKUs = @("S3", "S4")
        restrictedKinds = @("Face", "CustomVision.Training", "PersonalizerChatCompletion")
        dataProcessingKinds = @("TextAnalytics", "Face", "SpeechServices", "LUIS", "QnAMaker", "Translator")
        dataProcessingLocations = @("eastus", "westeurope")
    }
```

### Using Azure CLI

```bash
# Deploy policy definitions
az deployment group create \
    --resource-group rg-governance-prod \
    --template-file ./SFI-W1-Def-CogSvc-RequirePrivateEndpoints.bicep

# Deploy initiative
az deployment sub create \
    --location eastus \
    --template-file ../initiatives/cognitive-services/SFI-W1-Ini-CogSvc.bicep

# Assign initiative
az policy assignment create \
    --name "SFI-W1-CognitiveServices-Assignment" \
    --display-name "SFI-W1 Cognitive Services Compliance" \
    --policy-set-definition $initiativeId \
    --scope "/subscriptions/$subscriptionId" \
    --params '{
        "privateEndpointsEffect": {"value": "Audit"},
        "encryptionEffect": {"value": "Audit"},
        "identityEffect": {"value": "Audit"},
        "skuRestrictionEffect": {"value": "Deny"},
        "httpsEffect": {"value": "Audit"},
        "dataResidencyEffect": {"value": "Audit"},
        "diagnosticsEffect": {"value": "DeployIfNotExists"}
    }'
```

## Compliance

### SFI-W1 Requirements Mapping

| Policy | SFI-W1 Control | Description |
|--------|----------------|-------------|
| RequirePrivateEndpoints | Network Security | Implements zero-trust network architecture for AI services |
| RequireCustomerManagedKeys | Data Protection | Ensures customer control over encryption keys |
| RequireManagedIdentity | Identity Management | Eliminates credential-based authentication |
| RestrictSKUs | Resource Governance | Controls service tier usage and AI capabilities |
| RequireHTTPS | Secure Communication | Enforces encrypted communication |
| RestrictDataResidency | Data Sovereignty | Controls geographic data processing |
| RequireDiagnosticSettings | Monitoring | Ensures comprehensive audit logging |

### AI Ethics and Responsible AI

These policies support responsible AI practices by:

- **Restricting High-Risk Services**: Face API and Personalizer require special approval
- **Data Residency Controls**: Ensuring sensitive data processing stays in approved regions
- **Audit Logging**: Comprehensive tracking of AI service usage and decisions
- **Access Controls**: Managed identities provide secure, auditable access patterns
- **Network Isolation**: Private endpoints prevent unauthorized data access

### Service-Specific Considerations

#### Face API
- **High-Risk Service**: Requires special approval due to biometric data processing
- **Data Residency**: Must be deployed in restricted regions only
- **Enhanced Monitoring**: Additional logging requirements for compliance

#### Text Analytics
- **PII Detection**: Processes potentially sensitive text data
- **Data Residency**: Geographic restrictions for data processing
- **Encryption**: Customer-managed keys required for sensitive workloads

#### Speech Services
- **Voice Data**: Processes biometric voice patterns
- **Real-time Processing**: Special considerations for streaming data
- **Data Retention**: Strict requirements for voice data handling

### Compliance Dashboard

Monitor compliance using Azure Policy dashboard:
- **Service Coverage**: Track policy coverage across all Cognitive Services
- **Risk Assessment**: Identify high-risk services and their compliance status
- **Geographic Compliance**: Monitor data residency violations
- **Authentication Security**: Track managed identity adoption

## Troubleshooting

### Common Issues

#### 1. Service Kind Exclusions

**Symptom**: Policies incorrectly targeting OpenAI or Document Intelligence
**Solution**: 
- Verify service `kind` property filtering
- Check policy logic excludes `OpenAI` and `FormRecognizer`
- Review ARM template resource type filtering

#### 2. Data Residency Violations

**Symptom**: Services deployed in non-compliant regions
**Solution**:
- Review `dataProcessingKinds` parameter configuration
- Validate `dataProcessingLocations` restrictions
- Check regional service availability
- Consider using policy exemptions for legitimate business needs

#### 3. High-Tier SKU Restrictions

**Symptom**: Legitimate high-tier deployments being blocked
**Solution**:
- Implement approval workflow for high-tier SKUs
- Use policy exemptions with proper business justification
- Configure resource group exclusions for approved scenarios
- Document approval process for S3/S4 tier services

#### 4. Customer-Managed Key Configuration

**Symptom**: Services failing encryption policy validation
**Solution**:
- Verify Key Vault accessibility from service region
- Check Key Vault permissions for managed identity
- Validate key rotation configuration
- Ensure proper Key Vault firewall rules

### Debug Commands

```powershell
# Check Cognitive Services configuration
$services = Get-AzCognitiveServicesAccount

# Examine specific service
$service = Get-AzCognitiveServicesAccount -ResourceGroupName "rg-ai-prod" -Name "cogsvc-prod"

# Check service kind and SKU
$service.Kind
$service.Sku.Name

# Check private endpoints
$service.NetworkAcls
$service.PrivateEndpointConnections

# Check encryption settings
$service.Encryption

# Check managed identity
$service.Identity

# Get policy compliance for specific service
Get-AzPolicyState -ResourceId $service.Id

# Check diagnostic settings
Get-AzDiagnosticSetting -ResourceId $service.Id
```

### Performance and Cost Considerations

- **Private Endpoints**: Additional cost per endpoint (~$5/month)
- **Customer-Managed Keys**: Key Vault operations may add latency
- **Diagnostic Logging**: Monitor log volume to control costs
- **High-Tier SKUs**: Significant cost impact requiring approval
- **Data Residency**: May limit service availability in some regions

### Support Resources

- **Cognitive Services Documentation**: https://docs.microsoft.com/azure/cognitive-services/
- **Responsible AI Guidelines**: https://docs.microsoft.com/azure/cognitive-services/responsible-use-of-ai-overview
- **Azure Policy Troubleshooting**: https://docs.microsoft.com/azure/governance/policy/troubleshoot/
- **Data Residency Documentation**: https://docs.microsoft.com/azure/cognitive-services/cognitive-services-data-residency
- **Azure Support**: Create support ticket for complex policy or service issues

---

## Best Practices

### Security Recommendations

1. **Use System-Assigned Managed Identity** for most services unless integration requires user-assigned
2. **Enable Private Endpoints** for all production Cognitive Services
3. **Implement Customer-Managed Keys** for services processing sensitive data
4. **Monitor High-Risk Services** (Face, Personalizer) with enhanced logging
5. **Configure Network Restrictions** to prevent unauthorized access

### Cost Optimization

1. **Start with F0 (Free) Tier** for development and proof-of-concept
2. **Monitor API Usage** to optimize SKU selection
3. **Implement Budget Alerts** for high-tier services
4. **Review Diagnostic Log Retention** to balance compliance and costs
5. **Use Regional Pricing** differences for non-data-processing services

### Operational Excellence

1. **Automate Policy Deployment** using infrastructure as code
2. **Implement Approval Workflows** for restricted services
3. **Regular Compliance Reviews** to identify and address violations
4. **Document Service Decisions** for audit and compliance purposes
5. **Test Policy Changes** in non-production environments

### AI Governance

1. **Service Risk Classification**: Classify services by AI risk level
2. **Data Classification**: Apply appropriate controls based on data sensitivity
3. **Regular AI Ethics Reviews**: Review service usage for ethical implications
4. **User Training**: Ensure teams understand responsible AI practices
5. **Incident Response**: Define procedures for AI-related security incidents

## Contributing

When adding new policies or modifying existing ones:

1. Follow SFI-W1 naming conventions: `SFI-W1-Def-CogSvc-[PolicyName]`
2. Include comprehensive parameter validation and service kind filtering
3. Add detailed compliance framework mappings and AI ethics considerations
4. Update documentation with service-specific guidance
5. Test thoroughly across different Cognitive Services types
6. Consider regional availability and data residency requirements

## License

This project is licensed under the MIT License - see the LICENSE file for details.
