# Azure Cognitive Services Bicep Module

## Overview

This comprehensive Bicep module creates a highly secure Azure Cognitive Services account following Microsoft security best practices and enterprise requirements. The module supports all Cognitive Services types including Azure OpenAI, Speech Services, Computer Vision, Face API, Text Analytics, Form Recognizer, and more.

## 🔐 Security Features

- **Zero-Trust Network Architecture**: Private endpoints with network ACLs
- **Customer-Managed Encryption**: Azure Key Vault integration for enhanced security
- **Identity & Access Management**: Azure AD authentication with RBAC
- **Audit & Compliance**: Comprehensive diagnostic logging and monitoring
- **Network Isolation**: VNet integration and IP-based restrictions
- **Data Residency**: User-owned storage support for compliance requirements

## 🚀 Supported Services

| Service Type | Kind Value | Description |
|--------------|------------|-------------|
| **Azure OpenAI** | `OpenAI` | GPT, ChatGPT, and DALL-E models |
| **Speech Services** | `SpeechServices` | Speech-to-Text, Text-to-Speech, Translation |
| **Computer Vision** | `ComputerVision` | Image analysis, OCR, spatial analysis |
| **Face API** | `Face` | Face detection, recognition, verification |
| **Text Analytics** | `TextAnalytics` | Sentiment analysis, key phrase extraction |
| **Form Recognizer** | `FormRecognizer` | Document intelligence and data extraction |
| **Multi-Service** | `CognitiveServices` | Access to multiple services with single key |
| **Custom Vision** | `CustomVision.Training` | Custom image classification training |
| **LUIS** | `Luis` | Language understanding and intent recognition |
| **QnA Maker** | `QnAMaker` | Question and answer knowledge base |
| **Translator** | `TextTranslation` | Text translation across languages |

## 📋 Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cognitiveServiceName` | string | Name of the Cognitive Services account (2-64 characters) |
| `location` | string | Azure region for deployment |
| `kind` | string | Type of Cognitive Services (OpenAI, CognitiveServices, etc.) |

### Security Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `disableLocalAuth` | bool | `true` | Disable API key authentication (Azure AD only) |
| `publicNetworkAccess` | string | `Disabled` | Public network access control |
| `restrictOutboundNetworkAccess` | bool | `true` | Restrict outbound network calls |
| `networkAclsDefaultAction` | string | `Deny` | Default network access rule |
| `encryptionKeySource` | string | `Microsoft.CognitiveServices` | Encryption key management |
| `managedIdentityType` | string | `SystemAssigned` | Managed identity configuration |

### Network Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowedIpAddresses` | array | `[]` | IP addresses/CIDR ranges allowed access |
| `allowedSubnetIds` | array | `[]` | VNet subnet IDs for access |
| `enablePrivateEndpoint` | bool | `true` | Enable private endpoint |
| `privateEndpointSubnetId` | string | `''` | Subnet for private endpoint |
| `customSubDomainName` | string | `''` | Custom subdomain for authentication |

### Monitoring & Compliance

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDiagnosticSettings` | bool | `true` | Enable audit logging |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace for logs |
| `diagnosticLogsRetentionDays` | int | `90` | Log retention period |
| `enableAlerts` | bool | `true` | Enable monitoring alerts |

## 🎯 Usage Examples

### 1. Azure OpenAI with Maximum Security

```bicep
module openAI 'modules/cognitive-services/cognitive-services.bicep' = {
  name: 'secure-openai-deployment'
  params: {
    cognitiveServiceName: 'mycompany-openai-prod'
    location: 'eastus'
    kind: 'OpenAI'
    skuName: 'S0'
    
    // Security configuration
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    restrictOutboundNetworkAccess: true
    customSubDomainName: 'mycompany-openai-prod'
    
    // Network security
    networkAclsDefaultAction: 'Deny'
    enablePrivateEndpoint: true
    privateEndpointSubnetId: '/subscriptions/{sub}/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/ai-vnet/subnets/pe-subnet'
    
    // Customer-managed encryption
    encryptionKeySource: 'Microsoft.KeyVault'
    keyVaultUri: 'https://mycompany-kv.vault.azure.net/'
    keyVaultKeyName: 'openai-encryption-key'
    
    // Identity and monitoring
    managedIdentityType: 'SystemAssigned'
    enableDiagnosticSettings: true
    logAnalyticsWorkspaceId: '/subscriptions/{sub}/resourceGroups/monitoring-rg/providers/Microsoft.OperationalInsights/workspaces/ai-logs'
    
    tags: {
      Environment: 'Production'
      Compliance: 'SOC2-TypeII'
      DataClassification: 'Confidential'
    }
  }
}
```

### 2. Multi-Service Account for Development

```bicep
module cognitiveServices 'modules/cognitive-services/cognitive-services.bicep' = {
  name: 'dev-cognitive-services'
  params: {
    cognitiveServiceName: 'mycompany-ai-dev'
    location: 'westus2'
    kind: 'CognitiveServices'
    skuName: 'F0'  // Free tier for development
    
    // Relaxed security for development
    disableLocalAuth: false
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Allow'
    
    // Basic monitoring
    enableDiagnosticSettings: true
    enableAlerts: false
    
    tags: {
      Environment: 'Development'
      Purpose: 'AI Experimentation'
    }
  }
}
```

### 3. Speech Services with VNet Integration

```bicep
module speechServices 'modules/cognitive-services/cognitive-services.bicep' = {
  name: 'speech-services-deployment'
  params: {
    cognitiveServiceName: 'mycompany-speech-prod'
    location: 'eastus2'
    kind: 'SpeechServices'
    skuName: 'S0'
    
    // Network configuration
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Deny'
    allowedSubnetIds: [
      '/subscriptions/{sub}/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/app-vnet/subnets/app-subnet'
    ]
    allowedIpAddresses: [
      '203.0.113.0/24'  // Corporate IP range
    ]
    
    // Custom subdomain required for token auth
    customSubDomainName: 'mycompany-speech-prod'
    managedIdentityType: 'SystemAssigned'
    
    // RBAC assignments
    roleAssignments: [
      {
        principalId: '{app-service-identity}'
        roleDefinitionId: 'Cognitive Services User'
        principalType: 'ServicePrincipal'
        description: 'App Service access to Speech Services'
      }
    ]
  }
}
```

### 4. Form Recognizer with User-Owned Storage

```bicep
module formRecognizer 'modules/cognitive-services/cognitive-services.bicep' = {
  name: 'form-recognizer-deployment'
  params: {
    cognitiveServiceName: 'mycompany-formrec-compliance'
    location: 'centralus'
    kind: 'FormRecognizer'
    skuName: 'S0'
    
    // Compliance configuration
    enableUserOwnedStorage: true
    userOwnedStorageAccounts: [
      {
        storageAccountResourceId: '/subscriptions/{sub}/resourceGroups/storage-rg/providers/Microsoft.Storage/storageAccounts/formrecstorage'
        identityClientId: '{user-assigned-identity-client-id}'
      }
    ]
    
    // Security settings
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    enablePrivateEndpoint: true
    customSubDomainName: 'mycompany-formrec-compliance'
    
    // Data residency and compliance
    restrictOutboundNetworkAccess: true
    allowedFqdnList: [
      'api.cognitive.microsoft.com'
    ]
    
    tags: {
      Environment: 'Production'
      Compliance: 'HIPAA,SOC2'
      DataResidency: 'US-Only'
    }
  }
}
```

## 🔑 Outputs

The module provides comprehensive outputs for integration with other resources:

```bicep
// Primary outputs
output cognitiveServiceId string        // Resource ID
output cognitiveServiceName string      // Resource name
output endpoint string                  // Service endpoint URL
output customSubDomainName string       // Custom subdomain

// Identity outputs
output systemAssignedIdentityPrincipalId string  // System identity principal ID
output userAssignedIdentities object             // User-assigned identities

// Network outputs
output privateEndpointId string         // Private endpoint resource ID

// Configuration summaries
output cognitiveServiceConfig object     // Service configuration
output securityConfig object            // Security settings
output networkConfig object             // Network configuration
```

## 🏗️ Deployment

### Using Azure CLI

```bash
# Basic deployment
az deployment group create \
  --resource-group myai-rg \
  --template-file cognitive-services.bicep \
  --parameters @cognitive-services.parameters.json

# With custom parameters
az deployment group create \
  --resource-group myai-rg \
  --template-file cognitive-services.bicep \
  --parameters cognitiveServiceName=myai-openai kind=OpenAI skuName=S0
```

### Using PowerShell

```powershell
# Basic deployment
New-AzResourceGroupDeployment `
  -ResourceGroupName "myai-rg" `
  -TemplateFile "cognitive-services.bicep" `
  -TemplateParameterFile "cognitive-services.parameters.json"

# With inline parameters
New-AzResourceGroupDeployment `
  -ResourceGroupName "myai-rg" `
  -TemplateFile "cognitive-services.bicep" `
  -cognitiveServiceName "myai-openai" `
  -kind "OpenAI" `
  -skuName "S0"
```

### Using Deployment Scripts

The module includes comprehensive deployment scripts with validation and error handling:

```bash
# Bash script with full validation
./deploy.sh -g myai-rg

# PowerShell script with dry-run
.\deploy.ps1 -ResourceGroupName "myai-rg" -DryRun
```

## 🔒 Security Best Practices

### 1. Authentication & Authorization
- **Disable local authentication** (`disableLocalAuth: true`)
- **Use Azure AD authentication** with custom subdomains
- **Implement RBAC** with principle of least privilege
- **Use managed identities** for service-to-service authentication

### 2. Network Security
- **Deploy private endpoints** for all production workloads
- **Configure network ACLs** with default deny
- **Restrict outbound access** with FQDN allowlists
- **Use VNet integration** for application connectivity

### 3. Data Protection
- **Enable customer-managed encryption** for sensitive data
- **Use user-owned storage** for data residency requirements
- **Configure diagnostic logging** for security monitoring
- **Implement data classification** with appropriate tags

### 4. Monitoring & Compliance
- **Enable comprehensive logging** to Log Analytics
- **Configure security alerts** for anomalous activity
- **Set up automated backup** for configuration
- **Regular security assessments** and compliance audits

## 🧪 Testing

The module includes comprehensive test scenarios covering:

- **Security configurations**: Maximum security, compliance scenarios
- **Network topologies**: Private endpoints, VNet integration, IP restrictions
- **Service types**: All supported Cognitive Services kinds
- **RBAC scenarios**: Different user types and permissions
- **Multi-region deployments**: Global availability patterns

See [test-scenarios.md](./test-scenarios.md) for detailed test cases.

## 📊 Monitoring & Alerting

### Default Metrics and Alerts

The module automatically configures monitoring for:

- **Request metrics**: Total calls, errors, latency
- **Token usage**: For Azure OpenAI services
- **Throttling events**: Rate limiting occurrences
- **Security events**: Authentication failures, access violations

### Log Analytics Queries

```kql
// Failed authentication attempts
CognitiveServicesAuditLogs
| where TimeGenerated > ago(24h)
| where ResultType == "Failure"
| where OperationName contains "Authentication"
| summarize count() by CallerIpAddress, bin(TimeGenerated, 1h)

// High error rate detection
CognitiveServicesRequestResponse
| where TimeGenerated > ago(1h)
| where ResponseCode >= 400
| summarize ErrorRate = (count() * 100.0) / countif(ResponseCode < 400) by bin(TimeGenerated, 5m)
| where ErrorRate > 10
```

## 🔄 Maintenance

### Regular Tasks
- **Monitor costs** and optimize SKU sizes
- **Review access logs** for security compliance
- **Update encryption keys** according to rotation policy
- **Validate backup procedures** for disaster recovery

### Scaling Considerations
- **Monitor throttling** and adjust capacity units
- **Consider multi-region** for global applications
- **Implement caching** to reduce API calls
- **Use dedicated endpoints** for high-volume scenarios

## 📚 Additional Resources

- [Azure Cognitive Services Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/)
- [Azure OpenAI Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Private Endpoints for Cognitive Services](https://docs.microsoft.com/en-us/azure/cognitive-services/cognitive-services-virtual-networks)
- [Customer-Managed Keys](https://docs.microsoft.com/en-us/azure/cognitive-services/encryption/cognitive-services-encryption-keys-portal)

## 🤝 Contributing

Please refer to the main repository's contributing guidelines for information on how to contribute to this module.
