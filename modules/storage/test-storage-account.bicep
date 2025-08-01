// =============================================================================
// Storage Account Module Test File
// =============================================================================
// This file tests the storage account module with various configurations
// to ensure all parameters work correctly and security settings are applied.
// =============================================================================

targetScope = 'resourceGroup'

// =============================================================================
// TEST PARAMETERS
// =============================================================================

@description('Test environment identifier')
param testEnvironment string = 'test'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Unique suffix for resource names')
param uniqueSuffix string = uniqueString(resourceGroup().id, deployment().name)

// =============================================================================
// TEST SCENARIOS
// =============================================================================

// Test 1: Basic Storage Account
module basicStorageAccount './storage-account.bicep' = {
  name: 'test-basic-storage'
  params: {
    storageAccountName: 'stgbasic${uniqueSuffix}'
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    tags: {
      TestType: 'Basic'
      Environment: testEnvironment
      Purpose: 'Unit Testing'
    }
  }
}

// Test 2: Secure Storage Account with all security features
module secureStorageAccount './storage-account.bicep' = {
  name: 'test-secure-storage'
  params: {
    storageAccountName: 'stgsecure${uniqueSuffix}'
    location: location
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    
    // Security settings
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
    allowBlobPublicAccess: false
    allowCrossTenantReplication: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    allowedCopyScope: 'AAD'
    
    // Network security
    networkAclsDefaultAction: 'Deny'
    networkAclsBypass: 'AzureServices'
    allowedIpAddresses: ['192.168.1.0/24']
    
    // Encryption
    encryptionKeySource: 'Microsoft.Storage'
    requireInfrastructureEncryption: true
    blobEncryptionKeyType: 'Account'
    fileEncryptionKeyType: 'Account'
    tableEncryptionKeyType: 'Account'
    queueEncryptionKeyType: 'Account'
    
    // Identity
    managedIdentityType: 'SystemAssigned'
    
    // Policies
    sasExpirationPeriod: '01.00:00:00'
    sasExpirationAction: 'Block'
    keyExpirationPeriodInDays: 90
    
    // Immutable storage
    immutableStorageEnabled: true
    immutabilityPeriodSinceCreationInDays: 30
    immutabilityPolicyState: 'Unlocked'
    allowProtectedAppendWrites: false
    
    tags: {
      TestType: 'Secure'
      Environment: testEnvironment
      Purpose: 'Security Testing'
      DataClassification: 'Confidential'
    }
  }
}

// Test 3: Data Lake Storage Gen2
module dataLakeStorageAccount './storage-account.bicep' = {
  name: 'test-datalake-storage'
  params: {
    storageAccountName: 'stgdatalake${uniqueSuffix}'
    location: location
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    
    // Data Lake features
    isHnsEnabled: true
    
    // Security
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
    allowBlobPublicAccess: false
    defaultToOAuthAuthentication: true
    publicNetworkAccess: 'Disabled'
    networkAclsDefaultAction: 'Deny'
    networkAclsBypass: 'AzureServices'
    
    // Identity
    managedIdentityType: 'SystemAssigned'
    
    tags: {
      TestType: 'DataLake'
      Environment: testEnvironment
      Purpose: 'Analytics Testing'
      DataProcessing: 'BigData'
    }
  }
}

// Test 4: Premium Storage Account
module premiumStorageAccount './storage-account.bicep' = {
  name: 'test-premium-storage'
  params: {
    storageAccountName: 'stgpremium${uniqueSuffix}'
    location: location
    skuName: 'Premium_ZRS'
    kind: 'StorageV2'
    accessTier: 'Premium'
    
    // Security
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    
    // Identity
    managedIdentityType: 'SystemAssigned'
    
    tags: {
      TestType: 'Premium'
      Environment: testEnvironment
      Purpose: 'Performance Testing'
    }
  }
}

// Test 5: Storage Account with Custom Routing
module routingStorageAccount './storage-account.bicep' = {
  name: 'test-routing-storage'
  params: {
    storageAccountName: 'stgrouting${uniqueSuffix}'
    location: location
    skuName: 'Standard_GRS'
    kind: 'StorageV2'
    
    // Routing preferences
    routingChoice: 'InternetRouting'
    publishInternetEndpoints: true
    publishMicrosoftEndpoints: false
    
    // Security
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    managedIdentityType: 'SystemAssigned'
    
    tags: {
      TestType: 'Routing'
      Environment: testEnvironment
      Purpose: 'Network Testing'
    }
  }
}

// Test 6: SFTP Enabled Storage Account
module sftpStorageAccount './storage-account.bicep' = {
  name: 'test-sftp-storage'
  params: {
    storageAccountName: 'stgsftp${uniqueSuffix}'
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    
    // SFTP features
    isSftpEnabled: true
    isLocalUserEnabled: true
    enableExtendedGroups: true
    isHnsEnabled: true // Required for SFTP
    
    // Security
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    managedIdentityType: 'SystemAssigned'
    
    tags: {
      TestType: 'SFTP'
      Environment: testEnvironment
      Purpose: 'Protocol Testing'
    }
  }
}

// =============================================================================
// TEST OUTPUTS
// =============================================================================

// Basic Storage Account Outputs
output basicStorageAccountId string = basicStorageAccount.outputs.storageAccountId
output basicStorageAccountName string = basicStorageAccount.outputs.storageAccountName
output basicStorageAccountEndpoints object = basicStorageAccount.outputs.primaryEndpoints

// Secure Storage Account Outputs
output secureStorageAccountId string = secureStorageAccount.outputs.storageAccountId
output secureStorageAccountName string = secureStorageAccount.outputs.storageAccountName
output secureStorageAccountIdentity string = secureStorageAccount.outputs.systemAssignedIdentityPrincipalId
output secureStorageAccountNetworkConfig object = secureStorageAccount.outputs.networkAclsConfig
output secureStorageAccountEncryption object = secureStorageAccount.outputs.encryptionConfig

// Data Lake Storage Outputs
output dataLakeStorageAccountId string = dataLakeStorageAccount.outputs.storageAccountId
output dataLakeStorageAccountName string = dataLakeStorageAccount.outputs.storageAccountName
output dataLakeStorageAccountEndpoints object = dataLakeStorageAccount.outputs.primaryEndpoints

// Premium Storage Outputs
output premiumStorageAccountId string = premiumStorageAccount.outputs.storageAccountId
output premiumStorageAccountName string = premiumStorageAccount.outputs.storageAccountName

// Routing Storage Outputs
output routingStorageAccountId string = routingStorageAccount.outputs.storageAccountId
output routingStorageAccountName string = routingStorageAccount.outputs.storageAccountName

// SFTP Storage Outputs
output sftpStorageAccountId string = sftpStorageAccount.outputs.storageAccountId
output sftpStorageAccountName string = sftpStorageAccount.outputs.storageAccountName

// =============================================================================
// TEST VALIDATION OUTPUTS
// =============================================================================

output testResults object = {
  basicStorage: {
    deployed: true
    accountId: basicStorageAccount.outputs.storageAccountId
    location: basicStorageAccount.outputs.location
    provisioningState: basicStorageAccount.outputs.provisioningState
  }
  secureStorage: {
    deployed: true
    accountId: secureStorageAccount.outputs.storageAccountId
    location: secureStorageAccount.outputs.location
    provisioningState: secureStorageAccount.outputs.provisioningState
    hasSystemIdentity: !empty(secureStorageAccount.outputs.systemAssignedIdentityPrincipalId)
    networkDenyByDefault: secureStorageAccount.outputs.networkAclsConfig.defaultAction == 'Deny'
    encryptionEnabled: secureStorageAccount.outputs.encryptionConfig.keySource == 'Microsoft.Storage'
  }
  dataLakeStorage: {
    deployed: true
    accountId: dataLakeStorageAccount.outputs.storageAccountId
    location: dataLakeStorageAccount.outputs.location
    provisioningState: dataLakeStorageAccount.outputs.provisioningState
    hasDfsEndpoint: contains(dataLakeStorageAccount.outputs.primaryEndpoints, 'dfs')
  }
  premiumStorage: {
    deployed: true
    accountId: premiumStorageAccount.outputs.storageAccountId
    location: premiumStorageAccount.outputs.location
    provisioningState: premiumStorageAccount.outputs.provisioningState
  }
  routingStorage: {
    deployed: true
    accountId: routingStorageAccount.outputs.storageAccountId
    location: routingStorageAccount.outputs.location
    provisioningState: routingStorageAccount.outputs.provisioningState
  }
  sftpStorage: {
    deployed: true
    accountId: sftpStorageAccount.outputs.storageAccountId
    location: sftpStorageAccount.outputs.location
    provisioningState: sftpStorageAccount.outputs.provisioningState
    hasDfsEndpoint: contains(sftpStorageAccount.outputs.primaryEndpoints, 'dfs')
  }
}

output deploymentSummary object = {
  totalDeployments: 6
  testEnvironment: testEnvironment
  resourceGroup: resourceGroup().name
  uniqueSuffix: uniqueSuffix
  allSuccessful: true
}
