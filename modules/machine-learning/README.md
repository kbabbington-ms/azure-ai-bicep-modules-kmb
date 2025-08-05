# Machine Learning Module

Enterprise Azure Machine Learning workspace with advanced security, governance, and MLOps capabilities for production AI/ML workloads.

## Features

- **🏢 HBI Workspace**: High Business Impact classification for sensitive data
- **🔒 Managed Network**: Zero-trust outbound rules with private endpoints
- **🔐 Customer Encryption**: Full encryption with customer-managed keys
- **🖥️ Serverless Compute**: Auto-scaling compute with custom subnet support
- **📊 Feature Store**: Enterprise feature management and lineage tracking
- **👥 RBAC Integration**: Data scientist and MLOps engineer role assignments
- **🛡️ Network Isolation**: Private workspace with no public access

## Usage

```bicep
module mlWorkspace 'modules/machine-learning/main.bicep' = {
  name: 'enterprise-ml-workspace'
  params: {
    workspaceName: 'mycompany-ml-prod'
    location: 'eastus'
    environment: 'prod'
    
    // Security configuration
    hbiWorkspace: true
    enablePrivateEndpoint: true
    privateEndpointSubnetId: '/subscriptions/.../subnets/ml-subnet'
    enableCustomerManagedEncryption: true
    keyVaultId: '/subscriptions/.../providers/Microsoft.KeyVault/vaults/mykv'
    
    // Network isolation
    publicNetworkAccess: 'Disabled'
    managedNetworkSettings: {
      isolationMode: 'AllowOnlyApprovedOutbound'
      outboundRules: {
        allowInternet: false
        allowAzureServices: true
      }
    }
    
    tags: {
      Environment: 'Production'
      Classification: 'HBI'
      Application: 'ML Platform'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `workspaceName` | string | *Required* | Name of the ML workspace |
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `hbiWorkspace` | bool | `true` | High Business Impact workspace classification |
| `enablePrivateEndpoint` | bool | `true` | Enable private endpoint connectivity |
| `publicNetworkAccess` | string | `'Disabled'` | Public network access setting |
| `enableCustomerManagedEncryption` | bool | `true` | Enable customer-managed encryption |
| `keyVaultId` | string | `''` | Key Vault resource ID for encryption |

## Security Features

- **🏢 HBI Classification**: High Business Impact workspace for sensitive data
- **🔒 Private Connectivity**: Private endpoints for secure access
- **🔐 Customer-Managed Keys**: Full encryption control with Key Vault
- **🌐 Managed Network**: Zero-trust outbound connectivity rules
- **👤 Identity-Based Access**: Azure AD integration with ML-specific RBAC
- **📝 Comprehensive Logging**: Diagnostic settings for all ML activities
- **🛡️ Network Isolation**: No public internet access by default

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `mlWorkspaceId` | string | Resource ID of the ML workspace |
| `mlWorkspaceName` | string | Name of the ML workspace |
| `mlWorkspaceEndpoint` | string | Workspace endpoint URL |
| `discoveryUrl` | string | Workspace discovery URL |
| `privateEndpointId` | string | Private endpoint resource ID (if enabled) |

## MLOps Integration

This module includes support for:
- **🔄 CI/CD Pipelines**: GitHub Actions and Azure DevOps integration
- **📊 Model Registry**: Centralized model versioning and governance
- **🖥️ Compute Management**: Auto-scaling compute clusters and instances
- **📈 Experiment Tracking**: MLflow integration for experiment management
- **🔍 Model Monitoring**: Performance and drift detection capabilities

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Audit logging and access controls
- **ISO 27001**: Encryption and network security
- **GDPR**: Data residency and privacy controls
- **HIPAA**: Healthcare ML workloads (when properly configured)
- **FedRAMP**: Government ML workloads (with additional configuration)
