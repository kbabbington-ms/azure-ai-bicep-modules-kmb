// ============================================================================
// Azure Storage Account - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-04
// Description: Comprehensive Azure Storage with enterprise security, encryption,
//              private endpoints, zero-trust networking, and Data Lake capabilities
// ============================================================================

metadata name = 'Azure Storage Account - Enterprise Edition'
metadata description = 'Enterprise storage account with advanced security, encryption, and Data Lake Gen2 support'
metadata author = 'Azure AI Platform Team'
metadata version = '1.0.0'

targetScope = 'resourceGroup'

// ============================================================================
// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// Azure region where all resources will be deployed
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
// Used in resource naming conventions and cost allocation
@description('Project name for resource naming and tagging')
@minLength(2)
@maxLength(10)
param projectName string = 'ai-enclave'

// Resource tags for governance, cost management, and compliance tracking
// Essential for enterprise resource management and security auditing
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// STORAGE CONFIGURATION
// ============================================================================

// Custom name for the storage account resource
// Must be globally unique and follow Azure naming conventions (3-24 lowercase alphanumeric characters)
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@description('Storage account name (leave empty for auto-generation)')
@minLength(0)
@maxLength(24)
param storageAccountName string = ''

// Storage account performance and replication tier
// Determines data durability, availability, and performance characteristics
// 🔒 SECURITY ENHANCEMENT: Use geo-redundant options (GRS/RAGRS) for critical data protection
@description('Storage account SKU determining performance and replication')
@allowed([
  'Standard_LRS'    // Locally redundant storage
  'Standard_GRS'    // Geo-redundant storage
  'Standard_RAGRS'  // Read-access geo-redundant storage
  'Standard_ZRS'    // Zone-redundant storage
  'Premium_LRS'     // Premium locally redundant storage
  'Premium_ZRS'     // Premium zone-redundant storage
])
param storageAccountSku string = 'Standard_ZRS'

// Storage account type determining available services and capabilities
// StorageV2 provides all modern features including blob versioning and lifecycle management
// 🔒 SECURITY ENHANCEMENT: Use StorageV2 for maximum security features and compliance capabilities
@description('Storage account kind determining available services')
@allowed([
  'Storage'           // Legacy general-purpose v1
  'StorageV2'         // General-purpose v2 (recommended)
  'BlobStorage'       // Blob storage only
  'FileStorage'       // Premium file storage
  'BlockBlobStorage'  // Premium block blob storage
])
param storageAccountKind string = 'StorageV2'

// Default access tier for blob data storage optimization
// Controls automatic tiering and cost optimization for blob storage
// 🔒 SECURITY ENHANCEMENT: Use Hot tier for frequently accessed security logs and audit data
@description('Storage account access tier for cost optimization')
@allowed(['Hot', 'Cool'])
param accessTier string = 'Hot'

// Enable hierarchical namespace for Azure Data Lake Storage Gen2 functionality
// Provides file system semantics and improved performance for big data analytics
// 🔒 SECURITY ENHANCEMENT: Enable for structured data access with ACL-based security
@description('Enable hierarchical namespace for Data Lake Storage Gen2')
param enableHierarchicalNamespace bool = true

// Enable Network File System 3.0 protocol support for Linux workloads
// Allows mounting storage as file system from Linux and Unix systems
// 🔒 SECURITY ENHANCEMENT: Only enable if required by specific workloads
@description('Enable Network File System 3.0 protocol')
param enableNfsV3 bool = false

// Enable SSH File Transfer Protocol support for secure file transfers
// Provides secure command-line file transfer capabilities
// 🔒 SECURITY ENHANCEMENT: Only enable if SFTP access is specifically required
@description('Enable SFTP protocol')
param enableSftp bool = false

// ============================================================================
// SECURITY CONFIGURATION
// ============================================================================

// Allow anonymous public read access to blob containers and data
// Critical security setting that should be disabled for enterprise deployments
// 🔒 SECURITY ENHANCEMENT: Always set to false to prevent data leakage and unauthorized access
@description('Allow blob public access')
param allowBlobPublicAccess bool = false

// Allow authentication using storage account access keys
// Controls whether legacy key-based authentication is permitted
// 🔒 SECURITY ENHANCEMENT: Set to false to enforce Azure AD authentication only
@description('Allow shared key access')
param allowSharedKeyAccess bool = false

// Require HTTPS for all storage account operations
// Ensures all data transfers are encrypted in transit using TLS
// 🔒 SECURITY ENHANCEMENT: Always enable to prevent man-in-the-middle attacks
@description('Require secure transfer (HTTPS only)')
param supportsHttpsTrafficOnly bool = true

// Minimum Transport Layer Security version for secure connections
// Controls the oldest TLS version accepted by the storage account
// 🔒 SECURITY ENHANCEMENT: Use TLS1_2 minimum to prevent downgrade attacks
@description('Minimum TLS version required')
@allowed(['TLS1_0', 'TLS1_1', 'TLS1_2'])
param minimumTlsVersion string = 'TLS1_2'

// Network access control rules for IP and virtual network restrictions
// Provides fine-grained control over which networks can access storage
// 🔒 SECURITY ENHANCEMENT: Use 'Deny' default action with explicit allow rules for known networks
@description('Network access rules configuration')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
}

// ============================================================================
// PRIVATE ENDPOINT CONFIGURATION
// ============================================================================

// Enable private endpoints for Azure Blob Storage service
// Provides secure, private connectivity eliminating internet exposure
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring network isolation
@description('Enable private endpoint for blob service')
param enableBlobPrivateEndpoint bool = true

// Enable private endpoints for Azure File Storage service
// Provides secure access to file shares from private networks
// 🔒 SECURITY ENHANCEMENT: Enable for file storage requiring private network access
@description('Enable private endpoint for file service')
param enableFilePrivateEndpoint bool = true

// Enable private endpoints for Azure Queue Storage service
// Provides secure access to message queues from private networks
// 🔒 SECURITY ENHANCEMENT: Enable if using queues for secure message processing
@description('Enable private endpoint for queue service')
param enableQueuePrivateEndpoint bool = false

// Enable private endpoints for Azure Table Storage service
// Provides secure access to NoSQL tables from private networks
// 🔒 SECURITY ENHANCEMENT: Enable if using tables for structured data storage
@description('Enable private endpoint for table service')
param enableTablePrivateEndpoint bool = false

// Subnet resource ID where private endpoint network interfaces will be created
// Must be a subnet with adequate address space and appropriate security controls
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet with NSG rules restricting access
@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

// Private DNS zone resource IDs for resolving storage service private endpoint FQDNs
// Essential for proper name resolution within the virtual network
// 🔒 SECURITY ENHANCEMENT: Use private DNS to prevent DNS leakage to public resolvers
@description('Private DNS zone IDs for storage services')
param privateDnsZoneIds object = {
  blob: ''
  file: ''
  queue: ''
  table: ''
}

// Custom suffix for private endpoint resource names
// Helps with resource organization and governance in large deployments
@description('Custom private endpoint name suffix')
param privateEndpointNameSuffix string = ''

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

// Enable customer-managed encryption keys (CMK) for data protection at rest
// Provides customer control over encryption keys and enhanced compliance
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring key control
@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

// Azure Key Vault URI containing customer-managed encryption keys
// Must be accessible by the assigned managed identity for encryption operations
// 🔒 SECURITY ENHANCEMENT: Use Key Vault with access policies and network restrictions
@description('Key Vault URI for customer-managed encryption key')
param keyVaultUri string = ''

// Name of the encryption key stored in Azure Key Vault
// Key must support encrypt/decrypt operations and be accessible by managed identity
// 🔒 SECURITY ENHANCEMENT: Use RSA keys with HSM protection for maximum security
@description('Customer-managed encryption key name')
@minLength(0)
@maxLength(127)
param encryptionKeyName string = 'storage-encryption-key'

// User-assigned managed identity resource ID with Key Vault access
// Identity must have 'Key Vault Crypto Service Encryption User' role on the key
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal required permissions
@description('User-assigned managed identity ID for Key Vault access')
param userAssignedIdentityId string = ''

// ============================================================================
// CONTAINER AND STORAGE CONFIGURATION
// ============================================================================

// List of blob containers to create with specific access and configuration settings
// Defines the container structure for organized data storage
// 🔒 SECURITY ENHANCEMENT: Set all containers to 'None' public access for enterprise security
@description('Containers to create in blob storage')
param blobContainers array = [
  {
    name: 'ai-models'
    publicAccess: 'None'
    metadata: {}
  }
  {
    name: 'training-data'
    publicAccess: 'None'
    metadata: {}
  }
  {
    name: 'inference-results'
    publicAccess: 'None'
    metadata: {}
  }
]

@description('File shares to create')
param fileShares array = [
  {
    name: 'ai-shared-storage'
    quota: 100
    enabledProtocols: 'SMB'
    rootSquash: 'NoRootSquash'
    accessTier: 'TransactionOptimized'
  }
]

@description('Queues to create')
param queues array = []

@description('Tables to create')
param tables array = []

@description('Enable diagnostic settings')
param enableDiagnostics bool = true

@description('Log Analytics workspace ID for diagnostic settings')
param logAnalyticsWorkspaceId string = ''

@description('Storage account ID for diagnostic logs')
param diagnosticStorageAccountId string = ''

@description('Lifecycle management rules')
param lifecycleRules array = [
  {
    enabled: true
    name: 'ai-data-lifecycle'
    type: 'Lifecycle'
    definition: {
      filters: {
        blobTypes: ['blockBlob']
        prefixMatch: ['training-data/', 'inference-results/']
      }
      actions: {
        baseBlob: {
          tierToCool: {
            daysAfterModificationGreaterThan: 30
          }
          tierToArchive: {
            daysAfterModificationGreaterThan: 90
          }
          delete: {
            daysAfterModificationGreaterThan: 365
          }
        }
        snapshot: {
          delete: {
            daysAfterCreationGreaterThan: 30
          }
        }
        version: {
          delete: {
            daysAfterCreationGreaterThan: 30
          }
        }
      }
    }
  }
]

// ============================================================================
// VARIABLES
// ============================================================================

var storageAccountNameGenerated = !empty(storageAccountName) ? storageAccountName : take('st${projectName}${environment}${substring(uniqueString(resourceGroup().id), 0, 6)}', 24)
var blobPrivateEndpointName = '${storageAccountNameGenerated}-blob-pe${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : ''}'
var filePrivateEndpointName = '${storageAccountNameGenerated}-file-pe${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : ''}'
var queuePrivateEndpointName = '${storageAccountNameGenerated}-queue-pe${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : ''}'
var tablePrivateEndpointName = '${storageAccountNameGenerated}-table-pe${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : ''}'

var defaultTags = {
  Environment: environment
  Project: projectName
  Service: 'Storage'
  ManagedBy: 'Bicep'
}

var allTags = union(defaultTags, tags)

// ============================================================================
// RESOURCES
// ============================================================================

// Storage Account with comprehensive security configuration
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountNameGenerated
  location: location
  tags: allTags
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  identity: !empty(userAssignedIdentityId) ? {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${userAssignedIdentityId}': {}
    }
  } : null
  properties: {
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    minimumTlsVersion: minimumTlsVersion
    isHnsEnabled: enableHierarchicalNamespace
    isNfsV3Enabled: enableNfsV3
    isSftpEnabled: enableSftp
    networkAcls: networkAcls
    publicNetworkAccess: (enableBlobPrivateEndpoint || enableFilePrivateEndpoint) ? 'Disabled' : 'Enabled'
    encryption: enableCustomerManagedEncryption && !empty(keyVaultUri) && !empty(userAssignedIdentityId) ? {
      identity: {
        userAssignedIdentity: userAssignedIdentityId
      }
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
      keySource: 'Microsoft.Keyvault'
      keyvaultproperties: {
        keyname: encryptionKeyName
        keyvaulturi: keyVaultUri
      }
    } : {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
        queue: {
          enabled: true
          keyType: 'Service'
        }
        table: {
          enabled: true
          keyType: 'Service'
        }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

// Blob Service Configuration
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    changeFeed: {
      enabled: true
      retentionInDays: 30
    }
    restorePolicy: {
      enabled: true
      days: 29
    }
    isVersioningEnabled: true
    lastAccessTimeTrackingPolicy: {
      enable: true
      name: 'AccessTimeTracking'
      trackingGranularityInDays: 1
      blobType: ['blockBlob']
    }
    cors: {
      corsRules: []
    }
  }
}

// File Service Configuration
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 30
    }
    cors: {
      corsRules: []
    }
  }
}

// Queue Service Configuration
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Table Service Configuration
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-01-01' = {
  name: 'default'
  parent: storageAccount
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Blob Containers
resource blobContainerResources 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in blobContainers: {
  name: container.name
  parent: blobService
  properties: {
    publicAccess: container.publicAccess
    metadata: container.metadata
  }
}]

// File Shares
resource fileShareResources 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for share in fileShares: {
  name: share.name
  parent: fileService
  properties: {
    shareQuota: share.quota
    enabledProtocols: share.enabledProtocols
    rootSquash: share.rootSquash
    accessTier: share.accessTier
  }
}]

// Queues
resource queueResources 'Microsoft.Storage/storageAccounts/queueServices/queues@2023-01-01' = [for queue in queues: {
  name: queue.name
  parent: queueService
  properties: {
    metadata: queue.metadata
  }
}]

// Tables
resource tableResources 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-01-01' = [for table in tables: {
  name: table.name
  parent: tableService
  properties: {}
}]

// Lifecycle Management
resource lifecycleManagement 'Microsoft.Storage/storageAccounts/managementPolicies@2023-01-01' = if (!empty(lifecycleRules)) {
  name: 'default'
  parent: storageAccount
  properties: {
    policy: {
      rules: lifecycleRules
    }
  }
}

// Private Endpoint for Blob Service
resource blobPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enableBlobPrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: blobPrivateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for blob storage'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${blobPrivateEndpointName}-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['blob']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for blob storage'
          }
        }
      }
    ]
  }
}

// Private Endpoint for File Service
resource filePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enableFilePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: filePrivateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for file storage'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${filePrivateEndpointName}-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['file']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for file storage'
          }
        }
      }
    ]
  }
}

// Private Endpoint for Queue Service
resource queuePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enableQueuePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: queuePrivateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for queue storage'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${queuePrivateEndpointName}-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['queue']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for queue storage'
          }
        }
      }
    ]
  }
}

// Private Endpoint for Table Service
resource tablePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enableTablePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: tablePrivateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for table storage'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${tablePrivateEndpointName}-connection'
        properties: {
          privateLinkServiceId: storageAccount.id
          groupIds: ['table']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for table storage'
          }
        }
      }
    ]
  }
}

// Private DNS Zone Groups
resource blobDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enableBlobPrivateEndpoint && !empty(privateDnsZoneIds.blob)) {
  name: 'default'
  parent: blobPrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'blob-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.blob
        }
      }
    ]
  }
}

resource fileDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enableFilePrivateEndpoint && !empty(privateDnsZoneIds.file)) {
  name: 'default'
  parent: filePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'file-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.file
        }
      }
    ]
  }
}

resource queueDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enableQueuePrivateEndpoint && !empty(privateDnsZoneIds.queue)) {
  name: 'default'
  parent: queuePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'queue-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.queue
        }
      }
    ]
  }
}

resource tableDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enableTablePrivateEndpoint && !empty(privateDnsZoneIds.table)) {
  name: 'default'
  parent: tablePrivateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'table-config'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.table
        }
      }
    ]
  }
}

// Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticStorageAccountId))) {
  name: '${storageAccountNameGenerated}-diagnostics'
  scope: storageAccount
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    metrics: [
      {
        category: 'Transaction'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
      {
        category: 'Capacity'
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
@description('Storage account resource ID')
output storageAccountId string = storageAccount.id

@description('Storage account name')
output storageAccountName string = storageAccount.name

@description('Primary endpoints for storage services')
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

@description('Private endpoint information')
output privateEndpoints object = {
  blob: enableBlobPrivateEndpoint ? {
    id: blobPrivateEndpoint.id
    name: blobPrivateEndpoint.name
    fqdn: '${storageAccountNameGenerated}.blob.${az.environment().suffixes.storage}'
  } : {}
  file: enableFilePrivateEndpoint ? {
    id: filePrivateEndpoint.id
    name: filePrivateEndpoint.name
    fqdn: '${storageAccountNameGenerated}.file.${az.environment().suffixes.storage}'
  } : {}
  queue: enableQueuePrivateEndpoint ? {
    id: queuePrivateEndpoint.id
    name: queuePrivateEndpoint.name
    fqdn: '${storageAccountNameGenerated}.queue.${az.environment().suffixes.storage}'
  } : {}
  table: enableTablePrivateEndpoint ? {
    id: tablePrivateEndpoint.id
    name: tablePrivateEndpoint.name
    fqdn: '${storageAccountNameGenerated}.table.${az.environment().suffixes.storage}'
  } : {}
}

@description('Created blob containers')
output blobContainers array = [for (container, index) in blobContainers: {
  name: container.name
  id: blobContainerResources[index].id
  url: '${storageAccount.properties.primaryEndpoints.blob}${container.name}'
}]

@description('Created file shares')
output fileShares array = [for (share, index) in fileShares: {
  name: share.name
  id: fileShareResources[index].id
  url: '${storageAccount.properties.primaryEndpoints.file}${share.name}'
}]

@description('Security configuration summary')
output securityConfig object = {
  customerManagedEncryption: enableCustomerManagedEncryption
  httpsOnly: supportsHttpsTrafficOnly
  minimumTlsVersion: minimumTlsVersion
  blobPublicAccess: allowBlobPublicAccess
  sharedKeyAccess: allowSharedKeyAccess
  privateEndpoints: {
    blob: enableBlobPrivateEndpoint
    file: enableFilePrivateEndpoint
    queue: enableQueuePrivateEndpoint
    table: enableTablePrivateEndpoint
  }
}
