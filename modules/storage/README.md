# Azure Storage Account Bicep Module

## Overview

This module creates a highly secure Azure Storage Account following Microsoft and security best practices. It includes comprehensive configuration options covering all aspects of storage account management, security, and compliance.

## Features

### 🔒 Security Features
- **HTTPS-only access** with configurable minimum TLS version
- **Disabled public blob access** by default
- **Azure AD authentication preferred** over shared keys
- **Network access controls** with IP allowlists and virtual network rules
- **Customer-managed encryption keys** support with Key Vault integration
- **Infrastructure encryption** (double encryption) support
- **SAS policy management** with expiration controls
- **Cross-tenant replication controls**

### 🌐 Network Security
- **Network ACLs** with deny-by-default configuration
- **Private endpoint** ready configuration
- **Virtual network service endpoints** support
- **Public network access controls**
- **Routing preference** configuration

### 🔑 Identity & Access Management
- **Managed identity** support (System-assigned and User-assigned)
- **Azure Files identity-based authentication** (Azure AD DS, AD DS, Kerberos)
- **RBAC integration** ready
- **Key rotation policies**

### 📁 Advanced Storage Features
- **Azure Data Lake Storage Gen2** (Hierarchical Namespace)
- **NFSv3 protocol** support
- **SFTP protocol** support with local user management
- **Large file shares** (up to 100 TiB)
- **Immutable storage** with WORM policies
- **Point-in-time restore** capabilities
- **Custom domains** support

### 🛡️ Compliance & Governance
- **Immutability policies** for compliance requirements
- **Data residency** controls
- **Audit logging** ready
- **Tagging** for governance and cost management

## Usage

### Basic Deployment

```bicep
module storageAccount './modules/storage/storage-account.bicep' = {
  name: 'storageAccountDeployment'
  params: {
    storageAccountName: 'mystgaccount001'
    location: 'East US 2'
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
  }
}
```

### Secure Enterprise Deployment

```bicep
module storageAccount './modules/storage/storage-account.bicep' = {
  name: 'secureStorageDeployment'
  params: {
    storageAccountName: 'entpstgaccount001'
    location: 'East US 2'
    skuName: 'Standard_GZRS'
    kind: 'StorageV2'
    
    // Security settings
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
    allowBlobPublicAccess: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    allowedCopyScope: 'AAD'
    
    // Network security
    networkAclsDefaultAction: 'Deny'
    networkAclsBypass: 'AzureServices'
    allowedSubnetIds: [
      '/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}'
    ]
    
    // Encryption
    encryptionKeySource: 'Microsoft.Keyvault'
    requireInfrastructureEncryption: true
    keyVaultUri: 'https://myvault.vault.azure.net/'
    keyVaultKeyName: 'storage-encryption-key'
    encryptionUserAssignedIdentityId: '/subscriptions/{subscription-id}/resourceGroups/{rg}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identity}'
    
    // Identity
    managedIdentityType: 'SystemAssigned'
    
    // Policies
    sasExpirationPeriod: '01.00:00:00'
    sasExpirationAction: 'Block'
    keyExpirationPeriodInDays: 90
    
    // Immutable storage
    immutableStorageEnabled: true
    immutabilityPeriodSinceCreationInDays: 2555 // 7 years
    immutabilityPolicyState: 'Locked'
    
    tags: {
      Environment: 'Production'
      DataClassification: 'Confidential'
      Compliance: 'SOX'
    }
  }
}
```

### Data Lake Storage Gen2 Deployment

```bicep
module dataLakeStorage './modules/storage/storage-account.bicep' = {
  name: 'dataLakeDeployment'
  params: {
    storageAccountName: 'datalakestg001'
    location: 'East US 2'
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
    
    // Enable Data Lake features
    isHnsEnabled: true
    accessTier: 'Hot'
    
    // Security
    publicNetworkAccess: 'Disabled'
    networkAclsDefaultAction: 'Deny'
    
    tags: {
      Purpose: 'DataLake'
      Environment: 'Analytics'
    }
  }
}
```

## Parameters

### Required Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `storageAccountName` | string | Storage account name (3-24 chars, lowercase alphanumeric) |
| `location` | string | Azure region for deployment |
| `skuName` | string | Storage redundancy (Standard_LRS, Standard_ZRS, etc.) |
| `kind` | string | Storage account type (StorageV2 recommended) |

### Security Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `supportsHttpsTrafficOnly` | bool | `true` | **SECURITY**: Require HTTPS traffic only |
| `minimumTlsVersion` | string | `TLS1_2` | **SECURITY**: Minimum TLS version (TLS1_2/TLS1_3 recommended) |
| `allowSharedKeyAccess` | bool | `false` | **SECURITY**: Allow shared key access (false = AD auth only) |
| `allowBlobPublicAccess` | bool | `false` | **SECURITY**: Allow public blob access |
| `allowCrossTenantReplication` | bool | `false` | **SECURITY**: Allow cross-tenant replication |
| `defaultToOAuthAuthentication` | bool | `true` | **SECURITY**: Prefer OAuth over access keys |
| `publicNetworkAccess` | string | `Disabled` | **SECURITY**: Public network access control |
| `allowedCopyScope` | string | `AAD` | **SECURITY**: Copy operation scope restriction |

### Network Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `networkAclsDefaultAction` | string | `Deny` | **SECURITY**: Default network access rule |
| `networkAclsBypass` | string | `AzureServices` | **SECURITY**: Network ACL bypass rules |
| `allowedIpAddresses` | array | `[]` | **SECURITY**: Allowed IP addresses/CIDR ranges |
| `allowedSubnetIds` | array | `[]` | **SECURITY**: Allowed virtual network subnets |
| `resourceAccessRules` | array | `[]` | **SECURITY**: Cross-tenant resource access rules |

### Encryption Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `encryptionKeySource` | string | `Microsoft.Storage` | **SECURITY**: Encryption key source |
| `requireInfrastructureEncryption` | bool | `true` | **SECURITY**: Require double encryption |
| `keyVaultUri` | string | `''` | **SECURITY**: Key Vault URI for CMK |
| `keyVaultKeyName` | string | `''` | **SECURITY**: Key Vault key name |
| `blobEncryptionKeyType` | string | `Account` | **SECURITY**: Blob encryption key scope |
| `fileEncryptionKeyType` | string | `Account` | **SECURITY**: File encryption key scope |

### Feature Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `isHnsEnabled` | bool | `false` | Enable Azure Data Lake Storage Gen2 |
| `isNfsV3Enabled` | bool | `false` | Enable NFSv3 protocol support |
| `isSftpEnabled` | bool | `false` | Enable SFTP protocol support |
| `largeFileSharesState` | string | `Disabled` | Enable large file shares (up to 100 TiB) |
| `immutableStorageEnabled` | bool | `false` | **SECURITY**: Enable immutable storage |

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `storageAccountId` | string | Storage account resource ID |
| `storageAccountName` | string | Storage account name |
| `primaryEndpoints` | object | Primary service endpoints |
| `systemAssignedIdentityPrincipalId` | string | System-assigned identity principal ID |
| `networkAclsConfig` | object | Applied network ACL configuration |
| `encryptionConfig` | object | Applied encryption configuration |

## Security Best Practices

### 🔒 Authentication & Authorization
1. **Disable shared key access** (`allowSharedKeyAccess: false`)
2. **Use managed identities** for service authentication
3. **Enable Azure AD authentication** (`defaultToOAuthAuthentication: true`)
4. **Implement RBAC** for fine-grained access control

### 🌐 Network Security
1. **Deny public access by default** (`publicNetworkAccess: 'Disabled'`)
2. **Use private endpoints** for secure connectivity
3. **Implement network ACLs** with specific IP/subnet allowlists
4. **Enable firewall rules** (`networkAclsDefaultAction: 'Deny'`)

### 🔐 Encryption
1. **Use customer-managed keys** for enhanced control
2. **Enable infrastructure encryption** for double encryption
3. **Implement key rotation policies**
4. **Use account-level encryption keys** for broader scope

### 📋 Compliance
1. **Enable immutable storage** for WORM compliance
2. **Configure SAS policies** with short expiration periods
3. **Implement proper tagging** for governance
4. **Enable audit logging** (configure separately)

### 🔄 Operational
1. **Use zone-redundant storage** (ZRS/GZRS) for high availability
2. **Implement monitoring and alerting** (configure separately)
3. **Regular access reviews** for permissions
4. **Backup and disaster recovery** planning

## Compliance Standards

This module helps achieve compliance with:
- **SOC 2 Type II**
- **ISO 27001**
- **PCI DSS**
- **HIPAA** (with proper configuration)
- **GDPR** (with appropriate settings)
- **FedRAMP** (with enhanced security settings)

## Prerequisites

1. **Azure subscription** with appropriate permissions
2. **Resource group** for deployment
3. **User-assigned managed identity** (if using customer-managed keys)
4. **Key Vault** (if using customer-managed encryption)
5. **Virtual network and subnets** (if using network restrictions)

## Deployment

### Azure CLI

```bash
az deployment group create \
  --resource-group myResourceGroup \
  --template-file modules/storage/storage-account.bicep \
  --parameters modules/storage/storage-account.parameters.json
```

### Azure PowerShell

```powershell
New-AzResourceGroupDeployment `
  -ResourceGroupName "myResourceGroup" `
  -TemplateFile "modules/storage/storage-account.bicep" `
  -TemplateParameterFile "modules/storage/storage-account.parameters.json"
```

### Azure DevOps Pipeline

```yaml
- task: AzureResourceManagerTemplateDeployment@3
  inputs:
    deploymentScope: 'Resource Group'
    azureResourceManagerConnection: 'AzureServiceConnection'
    subscriptionId: '$(subscriptionId)'
    action: 'Create Or Update Resource Group'
    resourceGroupName: '$(resourceGroupName)'
    location: '$(location)'
    templateLocation: 'Linked artifact'
    csmFile: 'modules/storage/storage-account.bicep'
    csmParametersFile: 'modules/storage/storage-account.parameters.json'
```

## Troubleshooting

### Common Issues

1. **Storage account name conflicts**
   - Storage account names must be globally unique
   - Use naming conventions with random suffixes

2. **Network access denied**
   - Verify IP allowlists include your deployment source
   - Check virtual network service endpoints

3. **Customer-managed key issues**
   - Ensure managed identity has Key Vault access
   - Verify key permissions (Get, Wrap Key, Unwrap Key)

4. **Feature compatibility**
   - Some features require specific SKUs (Premium for NFSv3)
   - Check regional availability for advanced features

### Validation

```bash
# Test storage account connectivity
az storage account show \
  --name mystorageaccount \
  --resource-group myResourceGroup

# Check network ACL configuration
az storage account show \
  --name mystorageaccount \
  --resource-group myResourceGroup \
  --query "networkRuleSet"
```

## Contributing

When contributing to this module:
1. Follow security-first principles
2. Update documentation for new parameters
3. Include security implications in descriptions
4. Test with various configurations
5. Validate against compliance requirements

## License

This module follows Microsoft's licensing terms for Azure Bicep templates.

## Support

For issues and questions:
1. Check Azure documentation
2. Review troubleshooting section
3. Validate parameters against schema
4. Test in development environment first

---

**⚠️ Security Notice**: This module implements security best practices by default. Review all parameters before production deployment and ensure they meet your organization's security requirements.
