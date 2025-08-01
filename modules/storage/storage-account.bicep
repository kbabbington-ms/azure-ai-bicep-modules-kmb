// =============================================================================
// Azure Storage Account - Enterprise Security Configuration
// =============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// Description: Highly secure Azure Storage Account following Microsoft security best practices
// =============================================================================

targetScope = 'resourceGroup'

// BASIC CONFIGURATION PARAMETERS
// =============================================================================

// Unique name for the Azure Storage Account resource
// Must be globally unique across Azure as it forms part of storage endpoint URLs
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@minLength(3)
@maxLength(24)
@description('Required. Name of the storage account. Must be globally unique, 3-24 characters, lowercase letters and numbers only.')
param storageAccountName string

// Azure region where the storage account will be deployed
// Critical for data residency, compliance, and performance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Required. Azure region where the storage account will be deployed. This affects performance, compliance, and data residency.')
param location string = resourceGroup().location

// Storage account redundancy and replication strategy
// Controls data durability, availability, and disaster recovery capabilities
// 🔒 SECURITY ENHANCEMENT: Use GRS or GZRS for critical data requiring geo-redundancy
@allowed([
  'Standard_LRS'  // Locally redundant storage
  'Standard_GRS'  // Geo-redundant storage
  'Standard_RAGRS' // Read-access geo-redundant storage
  'Standard_ZRS'  // Zone-redundant storage
  'Premium_LRS'   // Premium locally redundant storage
  'Premium_ZRS'   // Premium zone-redundant storage
  'Standard_GZRS' // Geo-zone-redundant storage
  'Standard_RAGZRS' // Read-access geo-zone-redundant storage
])
@description('Required. Storage account SKU. Determines redundancy, performance, and pricing. ZRS/GZRS recommended for high availability.')
param skuName string

@allowed([
  'Storage'           // General-purpose v1 (legacy, not recommended)
  'StorageV2'         // General-purpose v2 (recommended)
  'BlobStorage'       // Blob-only storage account
  'FileStorage'       // Premium file shares only
  'BlockBlobStorage'  // Premium block blobs only
])
@description('Required. Storage account kind. StorageV2 recommended for most scenarios as it supports all features.')
param kind string = 'StorageV2'

// =============================================================================
// ACCESS TIER & PERFORMANCE
// =============================================================================

@allowed([
  'Hot'     // Frequently accessed data
  'Cool'    // Infrequently accessed data (30+ days)
  'Premium' // High-performance tier
  'Cold'    // Rarely accessed data (90+ days)
])
@description('Optional. Default access tier for blob storage. Hot = frequent access, Cool = infrequent access (lower storage cost, higher access cost).')
param accessTier string = 'Hot'

// =============================================================================
// SECURITY PARAMETERS
// =============================================================================

@description('SECURITY: Require HTTPS traffic only. Should always be true for security compliance.')
param supportsHttpsTrafficOnly bool = true

@allowed([
  'TLS1_0' // Legacy, not recommended
  'TLS1_1' // Legacy, not recommended
  'TLS1_2' // Recommended minimum
  'TLS1_3' // Most secure
])
@description('SECURITY: Minimum TLS version for requests. TLS1_2 or TLS1_3 recommended for security compliance.')
param minimumTlsVersion string = 'TLS1_2'

@description('SECURITY: Allow shared key access. Set to false to force Azure AD authentication only (recommended for enhanced security).')
param allowSharedKeyAccess bool = false

@description('SECURITY: Allow public blob access. Set to false to prevent anonymous access to blobs (recommended for security).')
param allowBlobPublicAccess bool = false

@description('SECURITY: Allow cross-tenant replication. Set to false unless specifically needed (recommended for security).')
param allowCrossTenantReplication bool = false

@description('SECURITY: Default to OAuth authentication. Set to true to prefer Azure AD over access keys (recommended for security).')
param defaultToOAuthAuthentication bool = true

@allowed([
  'Enabled'           // Public access allowed
  'Disabled'          // Public access blocked
  'SecuredByPerimeter' // Controlled by Network Security Perimeter
])
@description('SECURITY: Public network access setting. Use Disabled for maximum security, Enabled only if needed.')
param publicNetworkAccess string = 'Disabled'

@allowed([
  'PrivateLink' // Copy operations limited to private endpoints
  'AAD'        // Copy operations limited to same AAD tenant
])
@description('SECURITY: Restrict copy operations scope. PrivateLink most secure, AAD for tenant isolation.')
param allowedCopyScope string = 'AAD'

// =============================================================================
// ADVANCED STORAGE FEATURES
// =============================================================================

@description('Enable hierarchical namespace (Azure Data Lake Storage Gen2). Required for big data analytics.')
param isHnsEnabled bool = false

@description('Enable NFSv3 protocol support. Requires premium performance tier and specific network configuration.')
param isNfsV3Enabled bool = false

@description('Enable SFTP protocol support. Useful for secure file transfers.')
param isSftpEnabled bool = false

@description('Enable local users for SFTP. Required if SFTP is enabled.')
param isLocalUserEnabled bool = false

@description('Enable extended group support for local users. Provides additional group management capabilities.')
param enableExtendedGroups bool = false

@allowed([
  'Disabled' // Large file shares not supported
  'Enabled'  // Large file shares supported (up to 100 TiB)
])
@description('Large file shares state. Once enabled, cannot be disabled. Allows file shares up to 100 TiB.')
param largeFileSharesState string = 'Disabled'

@allowed([
  'Standard'     // Standard DNS endpoint
  'AzureDnsZone' // DNS Zone endpoint for large-scale deployments
])
@description('DNS endpoint type. AzureDnsZone recommended for creating many accounts in single subscription.')
param dnsEndpointType string = 'Standard'

// =============================================================================
// NETWORK ACCESS CONTROL
// =============================================================================

@allowed([
  'Allow' // Allow access by default
  'Deny'  // Deny access by default (recommended for security)
])
@description('SECURITY: Default network access rule. Deny recommended for zero-trust security model.')
param networkAclsDefaultAction string = 'Deny'

@allowed([
  'None'           // No bypass rules
  'Logging'        // Allow Azure logging services
  'Metrics'        // Allow Azure metrics services
  'AzureServices'  // Allow trusted Azure services
])
@description('SECURITY: Network ACL bypass rules. AzureServices commonly needed for Azure platform services.')
param networkAclsBypass string = 'AzureServices'

@description('SECURITY: Array of IP addresses or CIDR ranges allowed to access the storage account. Use for specific trusted networks.')
param allowedIpAddresses array = []

@description('SECURITY: Array of virtual network subnet resource IDs allowed to access the storage account.')
param allowedSubnetIds array = []

@description('SECURITY: Array of resource access rules for cross-tenant scenarios. Use sparingly for security.')
param resourceAccessRules array = []

// =============================================================================
// ENCRYPTION SETTINGS
// =============================================================================

@allowed([
  'Microsoft.Storage'   // Platform-managed keys (default)
  'Microsoft.Keyvault' // Customer-managed keys (enhanced security)
])
@description('SECURITY: Encryption key source. Microsoft.Keyvault recommended for customer-managed encryption keys.')
param encryptionKeySource string = 'Microsoft.Storage'

@description('SECURITY: Require infrastructure encryption (double encryption). Provides additional layer of encryption.')
param requireInfrastructureEncryption bool = true

@description('SECURITY: Key Vault URI for customer-managed keys. Required if encryptionKeySource is Microsoft.Keyvault.')
param keyVaultUri string = ''

@description('SECURITY: Key Vault key name for customer-managed keys. Required if encryptionKeySource is Microsoft.Keyvault.')
param keyVaultKeyName string = ''

@description('SECURITY: Key Vault key version for customer-managed keys. Leave empty for latest version.')
param keyVaultKeyVersion string = ''

@description('SECURITY: User-assigned managed identity resource ID for Key Vault access. Required for customer-managed keys.')
param encryptionUserAssignedIdentityId string = ''

@description('SECURITY: Multi-tenant application client ID for cross-tenant customer-managed keys.')
param federatedIdentityClientId string = ''

// Encryption key types for different services
@allowed([
  'Service' // Service-level encryption key
  'Account' // Account-level encryption key
])
@description('SECURITY: Blob service encryption key type. Account-level keys provide broader scope.')
param blobEncryptionKeyType string = 'Account'

@allowed([
  'Service' // Service-level encryption key
  'Account' // Account-level encryption key
])
@description('SECURITY: File service encryption key type. Account-level keys provide broader scope.')
param fileEncryptionKeyType string = 'Account'

@allowed([
  'Service' // Service-level encryption key
  'Account' // Account-level encryption key
])
@description('SECURITY: Table service encryption key type. Account-level keys provide broader scope.')
param tableEncryptionKeyType string = 'Account'

@allowed([
  'Service' // Service-level encryption key
  'Account' // Account-level encryption key
])
@description('SECURITY: Queue service encryption key type. Account-level keys provide broader scope.')
param queueEncryptionKeyType string = 'Account'

// =============================================================================
// MANAGED IDENTITY
// =============================================================================

@allowed([
  'None'                        // No managed identity
  'SystemAssigned'             // System-assigned managed identity
  'UserAssigned'               // User-assigned managed identity
  'SystemAssigned,UserAssigned' // Both types
])
@description('SECURITY: Managed identity type. SystemAssigned recommended for most scenarios.')
param managedIdentityType string = 'SystemAssigned'

@description('SECURITY: User-assigned managed identity resource IDs. Required if managedIdentityType includes UserAssigned.')
param userAssignedIdentityIds object = {}

// =============================================================================
// AZURE FILES IDENTITY-BASED AUTHENTICATION
// =============================================================================

@allowed([
  'None'     // No identity-based authentication
  'AADDS'    // Azure AD Domain Services
  'AD'       // Active Directory Domain Services
  'AADKERB'  // Azure AD Kerberos
])
@description('SECURITY: Azure Files identity-based authentication method. AADDS or AADKERB recommended for enterprise scenarios.')
param azureFilesIdentityBasedAuthentication string = 'None'

@allowed([
  'None'                                      // No default permissions
  'StorageFileDataSmbShareReader'            // Read access
  'StorageFileDataSmbShareContributor'       // Read/write access
  'StorageFileDataSmbShareElevatedContributor' // Full access
])
@description('SECURITY: Default share permission for Azure Files Kerberos authentication.')
param defaultSharePermission string = 'None'

// Active Directory properties (required if using AD authentication)
@description('Active Directory domain name. Required if using AD authentication.')
param adDomainName string = ''

@description('Active Directory domain GUID. Required if using AD authentication.')
param adDomainGuid string = ''

@description('Active Directory domain SID. Required if using AD authentication.')
param adDomainSid string = ''

@description('Active Directory forest name. Required if using AD authentication.')
param adForestName string = ''

@description('Active Directory NetBIOS domain name. Required if using AD authentication.')
param adNetBiosDomainName string = ''

@description('Active Directory SAM account name for Azure Storage.')
param adSamAccountName string = ''

@description('Active Directory Azure Storage SID.')
param adAzureStorageSid string = ''

@allowed([
  'User'     // User account type
  'Computer' // Computer account type
])
@description('Active Directory account type for Azure Storage.')
param adAccountType string = 'User'

// =============================================================================
// SAS POLICY
// =============================================================================

@description('SECURITY: SAS expiration period in DD.HH:MM:SS format. Shorter periods are more secure.')
param sasExpirationPeriod string = '01.00:00:00'

@allowed([
  'Log'   // Log violations for audit
  'Block' // Block violations
])
@description('SECURITY: Action when SAS policy is violated. Block recommended for strict security.')
param sasExpirationAction string = 'Block'

// =============================================================================
// KEY ROTATION POLICY
// =============================================================================

@minValue(1)
@maxValue(365)
@description('SECURITY: Key expiration period in days. Shorter periods increase security but require more management.')
param keyExpirationPeriodInDays int = 90

// =============================================================================
// CUSTOM DOMAIN
// =============================================================================

@description('Custom domain name (CNAME source). Leave empty if not using custom domain.')
param customDomainName string = ''

@description('Use subdomain name for custom domain. Set to true for indirect CNAME validation.')
param customDomainUseSubDomain bool = false

// =============================================================================
// ROUTING PREFERENCE
// =============================================================================

@allowed([
  'MicrosoftRouting' // Route via Microsoft network (default)
  'InternetRouting'  // Route via internet (may have lower latency)
])
@description('Network routing choice. MicrosoftRouting recommended for reliability.')
param routingChoice string = 'MicrosoftRouting'

@description('Publish internet routing endpoints. Set to false if using MicrosoftRouting only.')
param publishInternetEndpoints bool = false

@description('Publish Microsoft routing endpoints. Set to false if using InternetRouting only.')
param publishMicrosoftEndpoints bool = true

// =============================================================================
// IMMUTABLE STORAGE
// =============================================================================

@description('SECURITY: Enable account-level immutability. Provides write-once-read-many (WORM) protection.')
param immutableStorageEnabled bool = false

@minValue(1)
@maxValue(146000)
@description('SECURITY: Immutability period in days for default policy. Provides compliance and data protection.')
param immutabilityPeriodSinceCreationInDays int = 30

@allowed([
  'Unlocked' // Policy can be modified
  'Locked'   // Policy cannot be modified
  'Disabled' // Policy is disabled
])
@description('SECURITY: Immutability policy state. Locked provides strongest protection.')
param immutabilityPolicyState string = 'Unlocked'

@description('SECURITY: Allow protected append writes for immutable storage. Permits adding data while maintaining immutability.')
param allowProtectedAppendWrites bool = false

// =============================================================================
// BLOB RESTORE (Note: Blob restore is configured post-deployment)
// =============================================================================
// Point-in-time restore is enabled through separate configuration
// after the storage account is created, not during initial deployment

// =============================================================================
// TAGGING
// =============================================================================

@description('Resource tags for organization, cost management, and governance.')
param tags object = {}

// =============================================================================
// EXTENDED LOCATION (EDGE ZONES)
// =============================================================================

@description('Extended location name for edge zones. Leave empty for standard regions.')
param extendedLocationName string = ''

@allowed([
  'EdgeZone' // Azure Edge Zone
])
@description('Extended location type. Only EdgeZone is currently supported.')
param extendedLocationType string = 'EdgeZone'

// =============================================================================
// VARIABLES
// =============================================================================

// Build network ACLs object
var ipRules = [for ip in allowedIpAddresses: {
  action: 'Allow'
  value: ip
}]

var virtualNetworkRules = [for subnetId in allowedSubnetIds: {
  action: 'Allow'
  id: subnetId
  state: 'Succeeded'
}]

var networkAcls = {
  defaultAction: networkAclsDefaultAction
  bypass: networkAclsBypass
  ipRules: ipRules
  virtualNetworkRules: virtualNetworkRules
  resourceAccessRules: resourceAccessRules
}

// Build encryption object
var encryption = {
  keySource: encryptionKeySource
  requireInfrastructureEncryption: requireInfrastructureEncryption
  services: {
    blob: {
      enabled: true
      keyType: blobEncryptionKeyType
    }
    file: {
      enabled: true
      keyType: fileEncryptionKeyType
    }
    table: {
      enabled: true
      keyType: tableEncryptionKeyType
    }
    queue: {
      enabled: true
      keyType: queueEncryptionKeyType
    }
  }
  // Include Key Vault properties only if using customer-managed keys
  keyvaultproperties: encryptionKeySource == 'Microsoft.Keyvault' ? {
    keyvaulturi: keyVaultUri
    keyname: keyVaultKeyName
    keyversion: !empty(keyVaultKeyVersion) ? keyVaultKeyVersion : null
  } : null
  // Include identity for customer-managed keys
  identity: (encryptionKeySource == 'Microsoft.Keyvault' && !empty(encryptionUserAssignedIdentityId)) ? {
    userAssignedIdentity: encryptionUserAssignedIdentityId
    federatedIdentityClientId: !empty(federatedIdentityClientId) ? federatedIdentityClientId : null
  } : null
}

// Build managed identity object
var identity = managedIdentityType != 'None' ? {
  type: managedIdentityType
  userAssignedIdentities: contains(managedIdentityType, 'UserAssigned') ? userAssignedIdentityIds : null
} : null

// Build Azure Files identity-based authentication
var azureFilesIdentityBasedAuth = azureFilesIdentityBasedAuthentication != 'None' ? {
  directoryServiceOptions: azureFilesIdentityBasedAuthentication
  defaultSharePermission: defaultSharePermission
  activeDirectoryProperties: azureFilesIdentityBasedAuthentication == 'AD' ? {
    domainName: adDomainName
    domainGuid: adDomainGuid
    domainSid: adDomainSid
    forestName: adForestName
    netBiosDomainName: adNetBiosDomainName
    samAccountName: adSamAccountName
    azureStorageSid: adAzureStorageSid
    accountType: adAccountType
  } : null
} : null

// Build custom domain object
var customDomain = !empty(customDomainName) ? {
  name: customDomainName
  useSubDomainName: customDomainUseSubDomain
} : null

// Build routing preference
var routingPreference = {
  routingChoice: routingChoice
  publishInternetEndpoints: publishInternetEndpoints
  publishMicrosoftEndpoints: publishMicrosoftEndpoints
}

// Build SAS policy
var sasPolicy = {
  sasExpirationPeriod: sasExpirationPeriod
  expirationAction: sasExpirationAction
}

// Build key policy
var keyPolicy = {
  keyExpirationPeriodInDays: keyExpirationPeriodInDays
}

// Build immutable storage configuration
var immutableStorageWithVersioning = immutableStorageEnabled ? {
  enabled: true
  immutabilityPolicy: {
    immutabilityPeriodSinceCreationInDays: immutabilityPeriodSinceCreationInDays
    state: immutabilityPolicyState
    allowProtectedAppendWrites: allowProtectedAppendWrites
  }
} : null

// Build extended location
var extendedLocation = !empty(extendedLocationName) ? {
  name: extendedLocationName
  type: extendedLocationType
} : null

// =============================================================================
// STORAGE ACCOUNT RESOURCE
// =============================================================================

@description('Azure Storage Account with comprehensive security and configuration options')
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  extendedLocation: extendedLocation
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  identity: identity
  properties: {
    // Access and security settings
    accessTier: (kind == 'BlobStorage' || kind == 'StorageV2') ? accessTier : null
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: minimumTlsVersion
    allowSharedKeyAccess: allowSharedKeyAccess
    allowBlobPublicAccess: allowBlobPublicAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    defaultToOAuthAuthentication: defaultToOAuthAuthentication
    publicNetworkAccess: publicNetworkAccess
    allowedCopyScope: allowedCopyScope
    
    // Network access control
    networkAcls: networkAcls
    
    // Advanced features
    isHnsEnabled: isHnsEnabled
    isNfsV3Enabled: isNfsV3Enabled
    isSftpEnabled: isSftpEnabled
    isLocalUserEnabled: isLocalUserEnabled
    enableExtendedGroups: enableExtendedGroups
    largeFileSharesState: largeFileSharesState
    dnsEndpointType: dnsEndpointType
    
    // Encryption
    encryption: encryption
    
    // Azure Files authentication
    azureFilesIdentityBasedAuthentication: azureFilesIdentityBasedAuth
    
    // Custom domain
    customDomain: customDomain
    
    // Routing
    routingPreference: routingPreference
    
    // Policies
    sasPolicy: sasPolicy
    keyPolicy: keyPolicy
    
    // Immutable storage
    immutableStorageWithVersioning: immutableStorageWithVersioning
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Storage account resource ID')
output storageAccountId string = storageAccount.id

@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Storage account location')
output location string = storageAccount.location

@description('Storage account primary endpoints')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('Storage account secondary endpoints (if applicable)')
output secondaryEndpoints object = storageAccount.properties.secondaryEndpoints

@description('Storage account system-assigned managed identity principal ID')
output systemAssignedIdentityPrincipalId string = (managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned,UserAssigned') ? storageAccount.identity.principalId : ''

@description('Storage account system-assigned managed identity tenant ID')
output systemAssignedIdentityTenantId string = (managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned,UserAssigned') ? storageAccount.identity.tenantId : ''

@description('Storage account user-assigned managed identities')
output userAssignedIdentities object = contains(managedIdentityType, 'UserAssigned') ? storageAccount.identity.userAssignedIdentities : {}

@description('Storage account provisioning state')
output provisioningState string = storageAccount.properties.provisioningState

@description('Storage account creation time')
output creationTime string = storageAccount.properties.creationTime

@description('Storage account primary location')
output primaryLocation string = storageAccount.properties.primaryLocation

@description('Storage account secondary location (if applicable)')
output secondaryLocation string = storageAccount.properties.secondaryLocation

@description('Storage account status of primary')
output statusOfPrimary string = storageAccount.properties.statusOfPrimary

@description('Storage account status of secondary (if applicable)')
output statusOfSecondary string = storageAccount.properties.statusOfSecondary

@description('Storage account network ACLs configuration')
output networkAclsConfig object = storageAccount.properties.networkAcls

@description('Storage account encryption configuration')
output encryptionConfig object = storageAccount.properties.encryption
