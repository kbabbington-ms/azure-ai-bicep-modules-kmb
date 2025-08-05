// ============================================================================
// Azure Key Vault - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-04
// Description: Comprehensive Azure Key Vault with enterprise security,
//              RBAC, private endpoints, customer-managed keys, and HSM support
// ============================================================================

metadata name = 'Azure Key Vault - Enterprise Security Edition'
metadata description = 'Enterprise Key Vault with advanced security, encryption, and compliance features'
metadata author = 'Azure AI Platform Team'
metadata version = '1.0.0'

targetScope = 'resourceGroup'

// ============================================================================
// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// Azure region where Key Vault will be deployed
// Critical for data residency and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and access controls
// 🔒 SECURITY ENHANCEMENT: Use different encryption keys and access policies per environment
@description('Environment name for resource naming and tagging')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'

// Project identifier for resource naming and organizational purposes
// Used in resource naming conventions and cost management
@description('Project name for resource naming and tagging')
@minLength(2)
@maxLength(10)
param projectName string = 'ai-enclave'

// Resource tags for governance, cost management, and compliance tracking
// Essential for enterprise resource management and security auditing
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// Key Vault name override (auto-generated if empty)
// Must be globally unique across Azure
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security scanning and governance
@description('Key Vault name (leave empty for auto-generation based on project and environment)')
@maxLength(24)
param keyVaultName string = ''

// ============================================================================
// IDENTITY AND ACCESS CONTROL
// ============================================================================

// Azure AD tenant ID for the subscription
// Required for proper identity integration and access control
// 🔒 SECURITY ENHANCEMENT: Verify tenant ID matches your organization's Azure AD
@description('Azure AD tenant ID for the subscription')
param tenantId string = subscription().tenantId

// Enable Azure RBAC for Key Vault access control
// Modern approach to access management replacing legacy access policies
// 🔒 SECURITY ENHANCEMENT: Always enable RBAC for granular and auditable access control
@description('Enable Azure RBAC for Key Vault access (recommended over access policies)')
param enableRbacAuthorization bool = true

// User-assigned managed identity resource IDs with access permissions
// Allows for shared identities across multiple resources
// 🔒 SECURITY ENHANCEMENT: Use dedicated identities for different access patterns
@description('User-assigned managed identity resource IDs with access permissions')
param managedIdentityIds array = []

// Azure AD object IDs with Key Vault Administrator access
// Users or service principals with full Key Vault management permissions
// 🔒 SECURITY ENHANCEMENT: Limit to essential administrators only
@description('Azure AD object IDs with Key Vault Administrator access')
param administratorObjectIds array = []

// Azure AD object IDs with Key Vault Secrets User access
// Users or applications that can read secrets but not manage the vault
// 🔒 SECURITY ENHANCEMENT: Use least privilege principle for secret access
@description('Azure AD object IDs with Key Vault Secrets User access')
param secretsUserObjectIds array = []

// Azure AD object IDs with Key Vault Certificates User access
// Users or applications that can read certificates
// 🔒 SECURITY ENHANCEMENT: Separate certificate access from secret access
@description('Azure AD object IDs with Key Vault Certificates User access')
param certificatesUserObjectIds array = []

// Azure AD object IDs with Key Vault Crypto User access
// Users or applications that can perform cryptographic operations
// 🔒 SECURITY ENHANCEMENT: Limit cryptographic operations to authorized services only
@description('Azure AD object IDs with Key Vault Crypto User access')
param cryptoUserObjectIds array = []

// ============================================================================
// DATA PROTECTION CONFIGURATION
// ============================================================================

// Enable soft delete protection to prevent accidental deletion
// Provides recovery capability for deleted keys, secrets, and certificates
// 🔒 SECURITY ENHANCEMENT: Always enable for production environments
@description('Enable soft delete protection')
param enableSoftDelete bool = true

// Soft delete retention period in days
// Duration for which deleted items can be recovered
// 🔒 SECURITY ENHANCEMENT: Use maximum retention (90 days) for critical environments
@description('Soft delete retention period in days (7-90)')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

// Enable purge protection to prevent permanent deletion
// Once enabled, cannot be disabled - provides ultimate data protection
// 🔒 SECURITY ENHANCEMENT: Always enable for production environments containing critical keys
@description('Enable purge protection (cannot be disabled once enabled)')
param enablePurgeProtection bool = true

// Key Vault SKU determining performance and features
// Controls availability, throughput, and HSM integration
// 🔒 SECURITY ENHANCEMENT: Use Premium SKU for HSM-backed keys and enhanced security
@description('Key Vault SKU')
@allowed([
  'Standard'  // Software-based keys, standard performance
  'Premium'   // HSM-backed keys, enhanced security
])
param keyVaultSku string = 'Premium'

// ============================================================================
// NETWORK SECURITY CONFIGURATION
// ============================================================================

// Public network access control for Key Vault
// Determines whether the vault can be accessed from public internet
// 🔒 SECURITY ENHANCEMENT: Set to 'Disabled' with private endpoints for maximum security
@description('Public network access control')
@allowed([
  'Enabled'   // Allow public access (with network rules)
  'Disabled'  // Private endpoints only (recommended)
])
param publicNetworkAccess string = 'Disabled'

// Network access control list configuration
// Defines IP addresses and VNets allowed to access Key Vault
// 🔒 SECURITY ENHANCEMENT: Use 'Deny' default with explicit allow rules for zero-trust
@description('Network access rules configuration')
param networkAcls object = {
  bypass: 'AzureServices'         // Allow trusted Azure services
  defaultAction: 'Deny'           // Deny by default
  ipRules: []                     // Allowed IP addresses/CIDR ranges
  virtualNetworkRules: []         // Allowed VNet subnet IDs
}

// Enable private endpoint for Key Vault
// Provides private network connectivity without internet exposure
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise environments
@description('Enable private endpoint for Key Vault')
param enablePrivateEndpoint bool = true

// Private endpoint subnet resource ID
// Subnet where the private endpoint will be created
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet for private endpoints
@description('Private endpoint subnet resource ID')
param privateEndpointSubnetId string = ''

// Private DNS zone resource ID for Key Vault
// Enables DNS resolution for private endpoint
// 🔒 SECURITY ENHANCEMENT: Use private DNS zones for proper name resolution
@description('Private DNS zone resource ID for Key Vault')
param privateDnsZoneId string = ''

// ============================================================================
// CUSTOMER-MANAGED ENCRYPTION
// ============================================================================

// Create customer-managed keys for encryption services
// Provides customer control over encryption keys
// 🔒 SECURITY ENHANCEMENT: Enable for services requiring customer key management
@description('Create customer-managed keys for encryption')
param createCustomerManagedKeys bool = true

// Specifications for customer-managed keys
// Defines key properties for various encryption scenarios
// 🔒 SECURITY ENHANCEMENT: Use RSA-2048 minimum, RSA-4096 for high security
@description('Key specifications for customer-managed keys')
param customerManagedKeys array = [
  {
    name: 'storage-encryption-key'
    keyType: 'RSA'
    keySize: 2048
    keyOps: ['encrypt', 'decrypt', 'wrapKey', 'unwrapKey']
  }
  {
    name: 'ai-services-encryption-key'
    keyType: 'RSA'
    keySize: 2048
    keyOps: ['encrypt', 'decrypt', 'wrapKey', 'unwrapKey']
  }
  {
    name: 'database-encryption-key'
    keyType: 'RSA'
    keySize: 2048
    keyOps: ['encrypt', 'decrypt', 'wrapKey', 'unwrapKey']
  }
]

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

// Enable comprehensive diagnostic logging and monitoring
// Critical for security auditing, compliance, and operational insights
// 🔒 SECURITY ENHANCEMENT: Always enable for security monitoring and compliance
@description('Enable diagnostic settings')
param enableDiagnostics bool = true

// Log Analytics workspace resource ID for diagnostic data
// Centralized logging for security analytics and monitoring
// 🔒 SECURITY ENHANCEMENT: Required for security monitoring and SIEM integration
@description('Log Analytics workspace resource ID for diagnostic settings')
param logAnalyticsWorkspaceId string = ''

// Storage account resource ID for diagnostic log archival
// Long-term retention of audit logs for compliance
// 🔒 SECURITY ENHANCEMENT: Use immutable storage for audit log retention
@description('Storage account resource ID for diagnostic logs')
param diagnosticStorageAccountId string = ''

// ============================================================================
// SECRETS MANAGEMENT
// ============================================================================

// Initial secrets to create in the Key Vault
// Bootstrap secrets for application configuration
// 🔒 SECURITY ENHANCEMENT: Use secure string parameters and managed identities for secret access
@description('Secrets to create in Key Vault')
param secretsToCreate array = []

// ============================================================================
// RESOURCE IMPLEMENTATION
// ============================================================================

// Variables
var keyVaultNameGenerated = !empty(keyVaultName) ? keyVaultName : 'kv-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var privateEndpointName = '${keyVaultNameGenerated}-pe'
var networkInterfaceName = '${privateEndpointName}-nic'

// Key Vault with comprehensive security configuration
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultNameGenerated
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Secure key and secret management for AI Enclave'
    'Security-Level': 'High'
  })
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: keyVaultSku == 'Premium' ? 'premium' : 'standard'
    }
    enabledForDeployment: false
    enabledForDiskEncryption: true
    enabledForTemplateDeployment: true
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    createMode: 'default'
  }
}

// RBAC assignments for Key Vault (when RBAC is enabled)
resource keyVaultAdministratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (objectId, index) in administratorObjectIds: if (enableRbacAuthorization && !empty(administratorObjectIds)) {
  name: guid(keyVault.id, objectId, 'Key Vault Administrator')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483') // Key Vault Administrator
    principalId: objectId
    principalType: 'User'
    description: 'Key Vault Administrator access for AI Enclave'
  }
}]

resource keyVaultSecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (objectId, index) in secretsUserObjectIds: if (enableRbacAuthorization && !empty(secretsUserObjectIds)) {
  name: guid(keyVault.id, objectId, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: objectId
    principalType: 'User'
    description: 'Key Vault Secrets User access for AI Enclave'
  }
}]

// RBAC assignments for Certificate Users
resource keyVaultCertificatesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (objectId, index) in certificatesUserObjectIds: if (enableRbacAuthorization && !empty(certificatesUserObjectIds)) {
  name: guid(keyVault.id, objectId, 'Key Vault Certificates User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'db79e9a7-68ee-4b58-9aeb-b90e7c24fcba') // Key Vault Certificates User
    principalId: objectId
    principalType: 'User'
    description: 'Key Vault Certificates User access for AI Enclave'
  }
}]

// RBAC assignments for Crypto Users
resource keyVaultCryptoUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (objectId, index) in cryptoUserObjectIds: if (enableRbacAuthorization && !empty(cryptoUserObjectIds)) {
  name: guid(keyVault.id, objectId, 'Key Vault Crypto User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424') // Key Vault Crypto User
    principalId: objectId
    principalType: 'User'
    description: 'Key Vault Crypto User access for AI Enclave'
  }
}]

// Managed Identity RBAC assignments
resource managedIdentitySecretsUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (identityId, index) in managedIdentityIds: if (enableRbacAuthorization && !empty(managedIdentityIds)) {
  name: guid(keyVault.id, identityId, 'Key Vault Secrets User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: identityId
    principalType: 'ServicePrincipal'
    description: 'Managed Identity Key Vault Secrets access'
  }
}]

resource managedIdentityCryptoUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (identityId, index) in managedIdentityIds: if (enableRbacAuthorization && !empty(managedIdentityIds)) {
  name: guid(keyVault.id, identityId, 'Key Vault Crypto User')
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '12338af0-0e69-4776-bea7-57ae8d297424') // Key Vault Crypto User
    principalId: identityId
    principalType: 'ServicePrincipal'
    description: 'Managed Identity Key Vault Crypto access'
  }
}]

// Customer-managed encryption keys
resource customerManagedKey 'Microsoft.KeyVault/vaults/keys@2023-07-01' = [for key in customerManagedKeys: if (createCustomerManagedKeys) {
  name: key.name
  parent: keyVault
  properties: {
    kty: key.keyType
    keySize: key.?keySize
    keyOps: key.keyOps
    attributes: {
      enabled: true
      exportable: false
    }
  }
}]

// Secrets creation
resource secretsCreation 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for secret in secretsToCreate: {
  name: secret.name
  parent: keyVault
  properties: {
    value: secret.value
    contentType: secret.?contentType ?? 'text/plain'
    attributes: {
      enabled: true
    }
  }
}]

// Private Endpoint for Key Vault
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enablePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: privateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for Key Vault'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for Key Vault'
          }
        }
      }
    ]
    customNetworkInterfaceName: networkInterfaceName
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enablePrivateEndpoint && !empty(privateDnsZoneId)) {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'vault-config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticStorageAccountId))) {
  name: '${keyVaultNameGenerated}-diagnostics'
  scope: keyVault
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Outputs
@description('Key Vault resource ID')
output keyVaultId string = keyVault.id

@description('Key Vault name')
output keyVaultName string = keyVault.name

@description('Key Vault URI')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Key Vault tenant ID')
output tenantId string = keyVault.properties.tenantId

@description('Private endpoint information')
output privateEndpoint object = enablePrivateEndpoint && !empty(privateEndpointSubnetId) ? {
  id: privateEndpoint.id
  name: privateEndpoint.name
  fqdn: '${keyVaultNameGenerated}.${az.environment().suffixes.keyvaultDns}'
} : {}

@description('Customer-managed key information')
output customerManagedKeysInfo array = [for (key, index) in customerManagedKeys: createCustomerManagedKeys ? {
  name: key.name
  id: customerManagedKey[index].id
  uri: customerManagedKey[index]!.properties.keyUri
  version: customerManagedKey[index]!.properties.keyUriWithVersion
} : {}]

@description('Created secrets information')
output secretsCreated array = [for (secret, index) in secretsToCreate: {
  name: secret.name
  id: secretsCreation[index].id
  uri: secretsCreation[index].properties.secretUri
}]

@description('Key Vault DNS configuration for application settings')
output keyVaultDnsConfig object = {
  keyVaultUri: keyVault.properties.vaultUri
  keyVaultName: keyVault.name
  privateEndpointFqdn: enablePrivateEndpoint ? '${keyVaultNameGenerated}.${az.environment().suffixes.keyvaultDns}' : ''
}

@description('Security configuration summary')
output securityConfig object = {
  rbacEnabled: enableRbacAuthorization
  softDeleteEnabled: enableSoftDelete
  purgeProtectionEnabled: enablePurgeProtection
  privateEndpointEnabled: enablePrivateEndpoint
  diagnosticsEnabled: enableDiagnostics
}
