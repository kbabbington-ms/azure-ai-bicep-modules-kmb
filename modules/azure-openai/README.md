# Azure OpenAI Service - Dedicated Module

## Overview

This comprehensive Bicep module creates a production-ready Azure OpenAI service with advanced enterprise features including multiple model deployments, content filtering policies, customer-managed encryption, private endpoints, and comprehensive monitoring. This module is specifically designed for organizations requiring maximum security, compliance, and governance for their generative AI workloads.

## 🔐 Security Features

- **🔒 Zero-Trust Architecture**: Private endpoints with network isolation by default
- **🛡️ Content Safety**: Advanced content filtering with custom RAI policies
- **🔑 Customer-Managed Encryption**: Azure Key Vault integration for enhanced security
- **🎭 Identity & Access Management**: Azure AD authentication with RBAC roles
- **📊 Comprehensive Monitoring**: Audit logging, diagnostics, and security analytics
- **🌐 Network Security**: IP restrictions, VNet integration, and private connectivity
- **🔐 API Security**: Disabled local authentication, token-based access only

## 🚀 Supported Models & Deployments

### **Generative Models**
| Model | Purpose | Recommended Capacity | Use Cases |
|-------|---------|---------------------|-----------|
| **GPT-4o** | Latest multimodal reasoning | 10-50 TPM | Complex reasoning, analysis, code generation |
| **GPT-4o-mini** | Fast, cost-effective | 50-200 TPM | Chat, content generation, quick responses |
| **GPT-3.5-Turbo** | Balanced performance | 100-500 TPM | General purpose, high-volume applications |

### **Embedding Models**
| Model | Purpose | Recommended Capacity | Use Cases |
|-------|---------|---------------------|-----------|
| **text-embedding-3-small** | High performance, compact | 120-1000 TPM | Search, clustering, similarity |
| **text-embedding-3-large** | Maximum accuracy | 120-500 TPM | Advanced semantic understanding |

### **Image Generation**
| Model | Purpose | Recommended Capacity | Use Cases |
|-------|---------|---------------------|-----------|
| **DALL-E 3** | High-quality image generation | 2-10 TPM | Creative content, marketing materials |

### **Speech & Audio**
| Model | Purpose | Recommended Capacity | Use Cases |
|-------|---------|---------------------|-----------|
| **Whisper** | Speech-to-text transcription | Variable | Meeting transcription, voice interfaces |

## 📋 Parameters

### **Required Parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `openAIAccountName` | string | Globally unique name for the OpenAI service |
| `location` | string | Azure region for deployment |
| `customSubDomainName` | string | Custom subdomain for Azure AD authentication |

### **Model Deployment Configuration**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `modelDeployments` | array | GPT-4o + embeddings | Array of model deployments to create |
| `skuName` | string | `S0` | Service tier (F0=Free, S0=Standard) |

### **Security Parameters**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `publicNetworkAccess` | string | `Disabled` | Public network access control |
| `disableLocalAuth` | bool | `true` | Disable API key authentication |
| `networkAclsDefaultAction` | string | `Deny` | Default network access rule |
| `allowedIpAddresses` | array | `[]` | IP addresses/CIDR ranges allowed |
| `allowedSubnetIds` | array | `[]` | VNet subnet IDs for access |
| `enableAdvancedContentFiltering` | bool | `true` | Enable custom content filtering |

### **Private Endpoint Configuration**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enablePrivateEndpoint` | bool | `true` | Enable private endpoint |
| `vnetId` | string | `''` | Virtual Network ID |
| `privateEndpointSubnetId` | string | `''` | Subnet for private endpoint |
| `privateEndpointName` | string | `''` | Custom private endpoint name |

### **Identity & RBAC**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `managedIdentityType` | string | `SystemAssigned` | Managed identity configuration |
| `userAssignedIdentities` | array | `[]` | User-assigned identity IDs |
| `enableRbacAssignments` | bool | `true` | Enable automatic role assignments |
| `openAIAdministrators` | array | `[]` | Service administrators |
| `openAIDevelopers` | array | `[]` | AI developers and data scientists |
| `openAIUsers` | array | `[]` | Application users |

### **Customer-Managed Encryption**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableCustomerManagedEncryption` | bool | `false` | Enable customer-managed encryption |
| `keyVaultId` | string | `''` | Key Vault resource ID |
| `keyVaultKeyIdentifier` | string | `''` | Key Vault key identifier |
| `encryptionIdentityId` | string | `''` | Identity for Key Vault access |

### **Monitoring & Diagnostics**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `enableDiagnostics` | bool | `true` | Enable diagnostic settings |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace ID |
| `diagnosticsStorageAccountId` | string | `''` | Storage account for log archive |
| `eventHubAuthorizationRuleId` | string | `''` | Event Hub for SIEM integration |
| `diagnosticLogsRetentionInDays` | int | `90` | Log retention period |

## 🎯 Usage Examples

### 1. **Enterprise Production Deployment**

```bicep
module openAI 'modules/azure-openai/main.bicep' = {
  name: 'enterprise-openai'
  params: {
    openAIAccountName: 'mycompany-openai-prod'
    location: 'eastus'
    customSubDomainName: 'mycompany-openai-prod'
    
    // Model deployments
    modelDeployments: [
      {
        name: 'gpt-4o'
        model: {
          format: 'OpenAI'
          name: 'gpt-4o'
          version: '2024-08-06'
        }
        capacity: 50
        raiPolicyName: 'strict-enterprise-policy'
      }
      {
        name: 'text-embedding-3-small'
        model: {
          format: 'OpenAI'
          name: 'text-embedding-3-small'
          version: '1'
        }
        capacity: 500
        raiPolicyName: ''
      }
    ]
    
    // Maximum security
    publicNetworkAccess: 'Disabled'
    disableLocalAuth: true
    enablePrivateEndpoint: true
    vnetId: '/subscriptions/{sub}/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/ai-vnet'
    privateEndpointSubnetId: '/subscriptions/{sub}/resourceGroups/network/providers/Microsoft.Network/virtualNetworks/ai-vnet/subnets/openai'
    
    // Customer-managed encryption
    enableCustomerManagedEncryption: true
    keyVaultId: '/subscriptions/{sub}/resourceGroups/security/providers/Microsoft.KeyVault/vaults/enterprise-kv'
    keyVaultKeyIdentifier: 'https://enterprise-kv.vault.azure.net/keys/openai-key/latest'
    
    // Monitoring
    enableDiagnostics: true
    logAnalyticsWorkspaceId: '/subscriptions/{sub}/resourceGroups/monitoring/providers/Microsoft.OperationalInsights/workspaces/ai-logs'
    
    tags: {
      Environment: 'Production'
      Compliance: 'SOC2,HIPAA,GDPR'
      DataClassification: 'Confidential'
    }
  }
}
```

### 2. **Development Environment**

```bicep
module openAIDev 'modules/azure-openai/main.bicep' = {
  name: 'dev-openai'
  params: {
    openAIAccountName: 'mycompany-openai-dev'
    location: 'eastus'
    customSubDomainName: 'mycompany-openai-dev'
    skuName: 'S0'  // Use S0 even for dev for consistent experience
    
    // Limited model deployments
    modelDeployments: [
      {
        name: 'gpt-4o-mini'
        model: {
          format: 'OpenAI'
          name: 'gpt-4o-mini'
          version: '2024-07-18'
        }
        capacity: 10
        raiPolicyName: ''
      }
    ]
    
    // Relaxed security for development
    publicNetworkAccess: 'Enabled'
    networkAclsDefaultAction: 'Allow'
    enablePrivateEndpoint: false
    enableCustomerManagedEncryption: false
    
    // Basic monitoring
    enableDiagnostics: true
    
    tags: {
      Environment: 'Development'
      Purpose: 'AI Experimentation'
    }
  }
}
```

### 3. **Multi-Model AI Platform**

```bicep
module openAIComplete 'modules/azure-openai/main.bicep' = {
  name: 'complete-ai-platform'
  params: {
    openAIAccountName: 'mycompany-ai-platform'
    location: 'eastus'
    customSubDomainName: 'mycompany-ai-platform'
    
    // Comprehensive model suite
    modelDeployments: [
      // Text generation
      {
        name: 'gpt-4o'
        model: { format: 'OpenAI', name: 'gpt-4o', version: '2024-08-06' }
        capacity: 100
        raiPolicyName: 'enterprise-policy'
      }
      {
        name: 'gpt-4o-mini'
        model: { format: 'OpenAI', name: 'gpt-4o-mini', version: '2024-07-18' }
        capacity: 200
        raiPolicyName: 'enterprise-policy'
      }
      // Embeddings
      {
        name: 'text-embedding-3-small'
        model: { format: 'OpenAI', name: 'text-embedding-3-small', version: '1' }
        capacity: 1000
        raiPolicyName: ''
      }
      {
        name: 'text-embedding-3-large'
        model: { format: 'OpenAI', name: 'text-embedding-3-large', version: '1' }
        capacity: 500
        raiPolicyName: ''
      }
      // Image generation
      {
        name: 'dall-e-3'
        model: { format: 'OpenAI', name: 'dall-e-3', version: '3.0' }
        capacity: 5
        raiPolicyName: 'strict-image-policy'
      }
    ]
    
    // Enterprise RBAC
    openAIAdministrators: [
      {
        principalId: 'admin-group-id'
        principalType: 'Group'
        displayName: 'AI Platform Admins'
      }
    ]
    
    openAIDevelopers: [
      {
        principalId: 'dev-group-id'
        principalType: 'Group'
        displayName: 'AI Developers'
      }
    ]
  }
}
```

## 🔑 Outputs

The module provides comprehensive outputs for integration:

```bicep
// Primary outputs
output openAIId string              // Resource ID
output openAIName string            // Resource name
output openAIEndpoint string        // Service endpoint URL
output customSubDomain string       // Custom subdomain

// Identity outputs
output systemAssignedIdentityPrincipalId string  // System identity principal ID
output userAssignedIdentities object             // User-assigned identities

// Network outputs
output privateEndpointId string     // Private endpoint resource ID

// Configuration summaries
output openAIConfig object          // Service configuration
output securityConfig object        // Security settings
output networkConfig object         // Network configuration
output modelDeployments array       // Deployed models status
```

## 🏗️ Deployment

### **Using Azure CLI**

```bash
# Basic deployment
az deployment group create \
  --resource-group ai-services-rg \
  --template-file main.bicep \
  --parameters @main.parameters.json

# With custom parameters
az deployment group create \
  --resource-group ai-services-rg \
  --template-file main.bicep \
  --parameters openAIAccountName=mycompany-openai customSubDomainName=mycompany-openai
```

### **Using PowerShell**

```powershell
# Basic deployment
New-AzResourceGroupDeployment `
  -ResourceGroupName "ai-services-rg" `
  -TemplateFile "main.bicep" `
  -TemplateParameterFile "main.parameters.json"

# With inline parameters
New-AzResourceGroupDeployment `
  -ResourceGroupName "ai-services-rg" `
  -TemplateFile "main.bicep" `
  -openAIAccountName "mycompany-openai" `
  -customSubDomainName "mycompany-openai"
```

### **Using Deployment Scripts**

```bash
# Deploy with validation
./deploy.sh -g ai-services-rg -l eastus --validate

# Deploy with monitoring
./deploy.sh -g ai-services-rg -l eastus --monitor
```

## 🔒 Security Best Practices

### **1. Network Security**
- **✅ Always use private endpoints** for production deployments
- **✅ Disable public network access** unless specifically required
- **✅ Implement IP allowlists** for any public access scenarios
- **✅ Use dedicated subnets** for AI service private endpoints

### **2. Authentication & Authorization**
- **✅ Disable local authentication** (API keys) in favor of Azure AD
- **✅ Use managed identities** for service-to-service authentication
- **✅ Implement Azure AD groups** for user access management
- **✅ Apply principle of least privilege** with specific role assignments

### **3. Data Protection**
- **✅ Enable customer-managed encryption** for sensitive workloads
- **✅ Use HSM-backed keys** for maximum security
- **✅ Implement key rotation policies** according to compliance requirements
- **✅ Monitor data access patterns** through audit logs

### **4. Content Safety & Governance**
- **✅ Enable advanced content filtering** with custom policies
- **✅ Create industry-specific RAI policies** for compliance
- **✅ Monitor content filtering events** for policy effectiveness
- **✅ Regularly review and update** content filtering rules

### **5. Monitoring & Compliance**
- **✅ Enable comprehensive logging** to Log Analytics
- **✅ Set up security alerts** for anomalous usage patterns
- **✅ Implement log retention policies** per compliance requirements
- **✅ Regular security reviews** and access audits

## 📊 Monitoring & Alerting

### **Key Metrics to Monitor**

- **🔢 Token Usage**: Track consumption against capacity limits
- **⚡ Response Times**: Monitor model inference performance
- **🚫 Content Filtering**: Track blocked content attempts
- **🔐 Authentication Events**: Monitor access patterns and failures
- **💰 Cost Optimization**: Track usage for budget management

### **Recommended Alerts**

```kql
// High error rate detection
CognitiveServicesAuditLogs
| where TimeGenerated > ago(5m)
| where ResultType startswith "4" or ResultType startswith "5"
| summarize ErrorCount = count() by bin(TimeGenerated, 1m)
| where ErrorCount > 10

// Suspicious authentication patterns
CognitiveServicesAuditLogs
| where TimeGenerated > ago(1h)
| where OperationName contains "Authentication"
| where ResultType == "Failure"
| summarize FailureCount = count() by CallerIpAddress
| where FailureCount > 20

// Content filtering violations
CognitiveServicesAuditLogs
| where TimeGenerated > ago(1h)
| where OperationName contains "ContentFilter"
| where Properties contains "blocked"
| summarize BlockedCount = count() by bin(TimeGenerated, 5m)
```

## 🧪 Testing

### **Validation Tests**
- ✅ Template syntax and parameter validation
- ✅ Model deployment configuration verification
- ✅ Network security configuration testing
- ✅ RBAC permission validation

### **Security Tests**
- ✅ Private endpoint connectivity verification
- ✅ API key authentication disabled confirmation
- ✅ Content filtering policy effectiveness
- ✅ Encryption at rest validation

### **Performance Tests**
- ✅ Model inference latency testing
- ✅ Concurrent request handling
- ✅ Capacity limit validation
- ✅ Auto-scaling behavior verification

## 🔄 Maintenance

### **Regular Tasks**
- **🔍 Monitor token usage** and adjust capacity as needed
- **📊 Review audit logs** for security compliance
- **🔄 Update model versions** according to Azure OpenAI roadmap
- **🔐 Rotate encryption keys** per security policies

### **Scaling Considerations**
- **📈 Monitor capacity utilization** and scale deployments
- **🌍 Consider multi-region deployment** for global applications
- **⚖️ Implement load balancing** across multiple OpenAI accounts
- **💾 Use caching strategies** to optimize API calls

## 📚 Additional Resources

- [Azure OpenAI Service Documentation](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/)
- [Content Filtering and Safety](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/concepts/content-filter)
- [Private Endpoints for OpenAI](https://docs.microsoft.com/en-us/azure/cognitive-services/cognitive-services-virtual-networks)
- [Customer-Managed Keys](https://docs.microsoft.com/en-us/azure/cognitive-services/encryption/cognitive-services-encryption-keys-portal)
- [Azure OpenAI RBAC](https://docs.microsoft.com/en-us/azure/cognitive-services/openai/how-to/role-based-access-control)

## 🤝 Contributing

Please refer to the main repository's contributing guidelines for information on how to contribute to this module.

---

**⚠️ Security Notice**: This module implements enterprise-grade security by default. Always review configurations before production deployment and ensure they meet your organization's specific security requirements. Pay special attention to content filtering policies and data residency requirements.
