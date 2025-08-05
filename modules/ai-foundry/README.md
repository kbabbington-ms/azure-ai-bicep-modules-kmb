# AI Foundry Module

Comprehensive Azure AI Foundry (Azure AI Studio) workspace module for enterprise generative AI scenarios with advanced security and governance features.

## Features

- **🤖 Generative AI Hub**: Complete AI Foundry workspace for model deployment and management
- **🔒 Enterprise Security**: Private endpoints, customer-managed encryption, and network isolation
- **🎨 Model Management**: Support for GPT-4o, DALL-E, and custom model deployments
- **📊 Governance**: Content filtering, usage tracking, and compliance monitoring
- **🛡️ Zero-Trust Architecture**: Deny-by-default security with explicit allow rules
- **🔐 Identity Integration**: Azure AD authentication with managed identities

## Usage

```bicep
module aiFoundry 'modules/ai-foundry/main.bicep' = {
  name: 'enterprise-ai-foundry'
  params: {
    aiFoundryWorkspaceName: 'mycompany-ai-foundry-prod'
    location: 'eastus'
    environment: 'prod'
    
    // Security configuration
    enablePrivateEndpoint: true
    privateEndpointSubnetId: '/subscriptions/.../subnets/ai-subnet'
    enableCustomerManagedEncryption: true
    keyVaultUri: 'https://mykv.vault.azure.net/'
    
    // Network isolation
    publicNetworkAccess: 'Disabled'
    allowedIPRanges: []
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Security: 'High'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `aiFoundryWorkspaceName` | string | *Required* | Name of the AI Foundry workspace |
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `enablePrivateEndpoint` | bool | `true` | Enable private endpoint connectivity |
| `publicNetworkAccess` | string | `'Disabled'` | Public network access setting |
| `enableCustomerManagedEncryption` | bool | `true` | Enable customer-managed encryption |
| `keyVaultUri` | string | `''` | Key Vault URI for encryption keys |

## Security Features

- **🔒 Private Endpoints**: Secure connectivity without public internet exposure
- **🔐 Customer-Managed Keys**: Full control over encryption with Key Vault integration
- **🌐 Network Isolation**: VNet integration with configurable IP restrictions
- **👤 Identity-Based Access**: Azure AD integration with RBAC
- **📝 Audit Logging**: Comprehensive diagnostic settings and monitoring
- **🛡️ Content Safety**: Integrated content filtering and abuse monitoring

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `aiFoundryWorkspaceId` | string | Resource ID of the AI Foundry workspace |
| `aiFoundryWorkspaceName` | string | Name of the AI Foundry workspace |
| `aiFoundryWorkspaceEndpoint` | string | Workspace endpoint URL |
| `privateEndpointId` | string | Private endpoint resource ID (if enabled) |

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Audit logging and access controls
- **ISO 27001**: Encryption and network security
- **GDPR**: Data residency and privacy controls
- **HIPAA**: Healthcare data protection (when properly configured)
