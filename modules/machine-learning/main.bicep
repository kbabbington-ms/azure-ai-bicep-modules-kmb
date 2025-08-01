// ============================================================================
// Azure Machine Learning Workspace - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// ============================================================================

// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// Unique name for the Azure Machine Learning workspace resource
// Used to identify the workspace in Azure and as the primary resource identifier
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@description('Name of the Machine Learning workspace')
@minLength(3)
@maxLength(33)
param workspaceName string

// Azure region where all ML resources will be deployed
// Critical for data residency, compliance, and model training performance
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and ML workflows
// 🔒 SECURITY ENHANCEMENT: Use different encryption keys and access policies per environment
@description('Environment name (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

// Resource tags for governance, cost management, and ML lifecycle tracking
// Essential for enterprise resource management and model governance
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// WORKSPACE CONFIGURATION
// ============================================================================

// Human-readable display name for the workspace in the Azure ML Studio portal
// Helps users identify the workspace purpose and scope in the UI
@description('Friendly name for the workspace')
param friendlyName string = ''

// Detailed description of the workspace's intended use and ML objectives
// Important for governance and helping users understand workspace scope
@description('Description of the workspace')
param workspaceDescription string = ''

// High Business Impact (HBI) classification for enhanced data protection
// Reduces diagnostic data collection and enables additional security controls
// 🔒 SECURITY ENHANCEMENT: Always enable for production workloads with sensitive data
@description('Enable High Business Impact (HBI) workspace for reduced diagnostic data collection')
param hbiWorkspace bool = true

// Controls public access when workspace is connected to a virtual network
// Critical security setting that should be disabled for enterprise deployments
// 🔒 SECURITY ENHANCEMENT: Always set to false for zero-trust network architecture
@description('Allow public access when behind VNet')
param allowPublicAccessWhenBehindVnet bool = false

// Global public network access control for the ML workspace
// Primary network security control that determines internet accessibility
// 🔒 SECURITY ENHANCEMENT: Set to 'Disabled' for enterprise security and use private endpoints
@description('Public network access setting')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Disabled'

// Legacy v1 workspace mode compatibility (may limit v2 API functionality)
// Should remain false for modern ML workspace capabilities
// 🔒 SECURITY ENHANCEMENT: Keep disabled to use latest security features and APIs
@description('Enable v1 legacy mode (may prevent v2 API features)')
param v1LegacyMode bool = false

// Enhanced data isolation controls for multi-tenant ML environments
// Provides additional data separation and access controls for ML workloads
// 🔒 SECURITY ENHANCEMENT: Enable for enhanced data protection and compliance
@description('Enable data isolation')
param enableDataIsolation bool = true

// ============================================================================
// DEPENDENT RESOURCES CONFIGURATION
// ============================================================================

@description('Resource ID of the Application Insights instance')
param applicationInsightsId string

@description('Resource ID of the Container Registry')
param containerRegistryId string = ''

@description('Resource ID of the Key Vault')
param keyVaultId string

@description('Resource ID of the Storage Account')
param storageAccountId string

@description('List of additional workspace storage accounts')
param additionalWorkspaceStorageAccounts array = []

// ============================================================================
// IDENTITY CONFIGURATION
// ============================================================================

@description('Type of managed identity')
@allowed(['None', 'SystemAssigned', 'UserAssigned', 'SystemAssigned,UserAssigned'])
param managedIdentityType string = 'SystemAssigned,UserAssigned'

@description('Resource IDs of user-assigned managed identities')
param userAssignedIdentities array = []

@description('Primary user-assigned identity resource ID')
param primaryUserAssignedIdentity string = ''

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

@description('Key Vault key identifier for encryption')
param encryptionKeyIdentifier string = ''

@description('User-assigned identity for accessing encryption key')
param encryptionIdentityId string = ''

@description('Encryption status')
@allowed(['Enabled', 'Disabled'])
param encryptionStatus string = 'Enabled'

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

@description('Enable managed network')
param enableManagedNetwork bool = true

@description('Managed network isolation mode')
@allowed(['Disabled', 'AllowInternetOutbound', 'AllowOnlyApprovedOutbound'])
param managedNetworkIsolationMode string = 'AllowOnlyApprovedOutbound'

@description('Firewall SKU for FQDN rules')
@allowed(['Standard', 'Basic'])
param firewallSku string = 'Standard'

@description('Outbound rules for managed network')
param outboundRules object = {}

// ============================================================================
// PRIVATE ENDPOINT CONFIGURATION
// ============================================================================

@description('Enable private endpoints')
param enablePrivateEndpoints bool = true

@description('Virtual Network resource ID for private endpoints')
param vnetId string = ''

@description('Subnet resource ID for private endpoints')
param privateEndpointSubnetId string = ''

@description('Private DNS zone resource IDs')
param privateDnsZoneIds object = {
  api: ''
  notebooks: ''
}

@description('Custom private endpoint name suffix')
param privateEndpointNameSuffix string = ''

// ============================================================================
// COMPUTE CONFIGURATION
// ============================================================================

@description('Compute instance for image builds')
param imageBuildCompute string = ''

@description('Enable serverless compute')
param enableServerlessCompute bool = true

@description('Custom subnet for serverless compute')
param serverlessComputeCustomSubnet string = ''

@description('Disable public IP for serverless compute nodes')
param serverlessComputeNoPublicIP bool = true

// ============================================================================
// FEATURE STORE CONFIGURATION
// ============================================================================

@description('Enable feature store settings')
param enableFeatureStore bool = false

@description('Offline store connection name')
param offlineStoreConnectionName string = ''

@description('Online store connection name')
param onlineStoreConnectionName string = ''

@description('Spark runtime version for feature store')
param sparkRuntimeVersion string = ''

// ============================================================================
// SERVICE MANAGED RESOURCES
// ============================================================================

@description('Enable custom CosmosDB settings')
param enableCustomCosmosDbSettings bool = false

@description('CosmosDB collections throughput')
param cosmosDbCollectionsThroughput int = 400

// ============================================================================
// WORKSPACE HUB CONFIGURATION
// ============================================================================

@description('Enable workspace hub configuration')
param enableWorkspaceHub bool = false

@description('Default workspace resource group for hub')
param defaultWorkspaceResourceGroup string = ''

@description('Associated workspaces for hub')
param associatedWorkspaces array = []

@description('Hub resource ID')
param hubResourceId string = ''

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

@description('Enable diagnostic settings')
param enableDiagnostics bool = true

@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

@description('Storage account resource ID for diagnostics')
param diagnosticsStorageAccountId string = ''

@description('Event Hub authorization rule ID for diagnostics')
param eventHubAuthorizationRuleId string = ''

@description('Event Hub name for diagnostics')
param eventHubName string = ''

@description('Diagnostic logs categories to enable')
param diagnosticLogsCategories array = [
  'AmlComputeClusterEvent'
  'AmlComputeClusterNodeEvent'
  'AmlComputeJobEvent'
  'AmlComputeCpuGpuUtilization'
  'AmlRunStatusChangedEvent'
  'ModelsChangeEvent'
  'ModelsReadEvent'
  'ModelsActionEvent'
  'DeploymentReadEvent'
  'DeploymentEventACI'
  'DeploymentEventAKS'
  'InferencingOperationAKS'
  'InferencingOperationACI'
]

@description('Diagnostic metrics categories to enable')
param diagnosticMetricsCategories array = [
  'AllMetrics'
]

@description('Diagnostic logs retention in days')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 90

// ============================================================================
// RBAC CONFIGURATION
// ============================================================================

@description('Enable RBAC role assignments')
param enableRbacAssignments bool = true

@description('Machine Learning workspace administrators')
param workspaceAdministrators array = []

@description('Machine Learning workspace contributors')
param workspaceContributors array = []

@description('Machine Learning workspace readers')
param workspaceReaders array = []

@description('Data scientists with compute access')
param dataScientists array = []

@description('MLOps engineers with deployment access')
param mlOpsEngineers array = []

// ============================================================================
// SHARED PRIVATE LINK RESOURCES
// ============================================================================

@description('Shared private link resources configuration')
param sharedPrivateLinkResources array = []

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '-${environment}-${substring(uniqueString(resourceGroup().id), 0, 6)}'

var defaultTags = {
  Environment: environment
  Service: 'Machine Learning'
  ManagedBy: 'Bicep'
}

var allTags = union(defaultTags, tags)

// Identity configuration
var identityConfig = managedIdentityType == 'None' ? null : {
  type: managedIdentityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? reduce(userAssignedIdentities, {}, (acc, identityId) => union(acc, {
    '${identityId}': {}
  })) : null
}

// Encryption configuration
var encryptionConfig = enableCustomerManagedEncryption && !empty(encryptionKeyIdentifier) ? {
  status: encryptionStatus
  keyVaultProperties: {
    keyVaultArmId: keyVaultId
    keyIdentifier: encryptionKeyIdentifier
  }
  identity: !empty(encryptionIdentityId) ? {
    userAssignedIdentity: encryptionIdentityId
  } : null
} : null

// Managed network configuration
var managedNetworkConfig = enableManagedNetwork ? {
  isolationMode: managedNetworkIsolationMode
  firewallSku: firewallSku
  outboundRules: outboundRules
} : null

// Serverless compute configuration
var serverlessComputeConfig = enableServerlessCompute ? {
  serverlessComputeCustomSubnet: !empty(serverlessComputeCustomSubnet) ? serverlessComputeCustomSubnet : null
  serverlessComputeNoPublicIP: serverlessComputeNoPublicIP
} : null

// Feature store configuration
var featureStoreConfig = enableFeatureStore ? {
  offlineStoreConnectionName: !empty(offlineStoreConnectionName) ? offlineStoreConnectionName : null
  onlineStoreConnectionName: !empty(onlineStoreConnectionName) ? onlineStoreConnectionName : null
  computeRuntime: !empty(sparkRuntimeVersion) ? {
    sparkRuntimeVersion: sparkRuntimeVersion
  } : null
} : null

// Service managed resources configuration
var serviceManagedResourcesConfig = enableCustomCosmosDbSettings ? {
  cosmosDb: {
    collectionsThroughput: cosmosDbCollectionsThroughput
  }
} : null

// Workspace hub configuration
var workspaceHubConfig = enableWorkspaceHub ? {
  defaultWorkspaceResourceGroup: !empty(defaultWorkspaceResourceGroup) ? defaultWorkspaceResourceGroup : null
  additionalWorkspaceStorageAccounts: additionalWorkspaceStorageAccounts
} : null

// Built-in role definitions
var roleDefinitions = {
  owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  azureMLDataScientist: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
  azureMLComputeOperator: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e503ece1-11d0-4e8e-8e2c-7a6c3bf38815')
  azureMLWorkspaceConnection: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '3500b8e0-6d3a-4e2d-b6a8-4b4e7de1e4fe')
}

// ============================================================================
// RESOURCES
// ============================================================================

// Machine Learning workspace
resource mlWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: workspaceName
  location: location
  tags: allTags
  kind: enableFeatureStore ? 'FeatureStore' : 'Default'
  identity: identityConfig
  properties: {
    friendlyName: !empty(friendlyName) ? friendlyName : workspaceName
    description: workspaceDescription
    hbiWorkspace: hbiWorkspace
    allowPublicAccessWhenBehindVnet: allowPublicAccessWhenBehindVnet
    publicNetworkAccess: publicNetworkAccess
    v1LegacyMode: v1LegacyMode
    enableDataIsolation: enableDataIsolation
    applicationInsights: applicationInsightsId
    containerRegistry: !empty(containerRegistryId) ? containerRegistryId : null
    keyVault: keyVaultId
    storageAccount: storageAccountId
    primaryUserAssignedIdentity: !empty(primaryUserAssignedIdentity) ? primaryUserAssignedIdentity : null
    encryption: encryptionConfig
    managedNetwork: managedNetworkConfig
    imageBuildCompute: !empty(imageBuildCompute) ? imageBuildCompute : null
    serverlessComputeSettings: serverlessComputeConfig
    featureStoreSettings: featureStoreConfig
    serviceManagedResourcesSettings: serviceManagedResourcesConfig
    workspaceHubConfig: workspaceHubConfig
    hubResourceId: !empty(hubResourceId) ? hubResourceId : null
    associatedWorkspaces: associatedWorkspaces
    sharedPrivateLinkResources: sharedPrivateLinkResources
  }
}

// Private endpoints for ML workspace
resource mlWorkspacePrivateEndpointApi 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${workspaceName}-api${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${workspaceName}-api'
        properties: {
          privateLinkServiceId: mlWorkspace.id
          groupIds: ['amlworkspace']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for ML workspace API'
          }
        }
      }
    ]
  }
}

resource mlWorkspacePrivateEndpointNotebooks 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${workspaceName}-notebooks${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${workspaceName}-notebooks'
        properties: {
          privateLinkServiceId: mlWorkspace.id
          groupIds: ['notebook']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for ML workspace notebooks'
          }
        }
      }
    ]
  }
}

// Private DNS zone groups
resource mlWorkspacePrivateDnsZoneGroupApi 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneIds.api)) {
  parent: mlWorkspacePrivateEndpointApi
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.api
        }
      }
    ]
  }
}

resource mlWorkspacePrivateDnsZoneGroupNotebooks 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneIds.notebooks)) {
  parent: mlWorkspacePrivateEndpointNotebooks
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.notebooks
        }
      }
    ]
  }
}

// Diagnostic settings
resource mlWorkspaceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticsStorageAccountId) || !empty(eventHubAuthorizationRuleId))) {
  scope: mlWorkspace
  name: 'diag-${workspaceName}'
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    storageAccountId: !empty(diagnosticsStorageAccountId) ? diagnosticsStorageAccountId : null
    eventHubAuthorizationRuleId: !empty(eventHubAuthorizationRuleId) ? eventHubAuthorizationRuleId : null
    eventHubName: !empty(eventHubName) ? eventHubName : null
    logs: [for category in diagnosticLogsCategories: {
      category: category
      enabled: true
      retentionPolicy: {
        enabled: diagnosticLogsRetentionInDays > 0
        days: diagnosticLogsRetentionInDays
      }
    }]
    metrics: [for category in diagnosticMetricsCategories: {
      category: category
      enabled: true
      retentionPolicy: {
        enabled: diagnosticLogsRetentionInDays > 0
        days: diagnosticLogsRetentionInDays
      }
    }]
  }
}

// RBAC role assignments
resource workspaceAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (admin, i) in workspaceAdministrators: if (enableRbacAssignments) {
  scope: mlWorkspace
  name: guid(mlWorkspace.id, admin.principalId, 'Owner')
  properties: {
    roleDefinitionId: roleDefinitions.owner
    principalId: admin.principalId
    principalType: admin.principalType
    description: 'Machine Learning workspace administrator access'
  }
}]

resource workspaceContributorRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (contributor, i) in workspaceContributors: if (enableRbacAssignments) {
  scope: mlWorkspace
  name: guid(mlWorkspace.id, contributor.principalId, 'Contributor')
  properties: {
    roleDefinitionId: roleDefinitions.contributor
    principalId: contributor.principalId
    principalType: contributor.principalType
    description: 'Machine Learning workspace contributor access'
  }
}]

resource workspaceReaderRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (reader, i) in workspaceReaders: if (enableRbacAssignments) {
  scope: mlWorkspace
  name: guid(mlWorkspace.id, reader.principalId, 'Reader')
  properties: {
    roleDefinitionId: roleDefinitions.reader
    principalId: reader.principalId
    principalType: reader.principalType
    description: 'Machine Learning workspace reader access'
  }
}]

resource dataScientistRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (scientist, i) in dataScientists: if (enableRbacAssignments) {
  scope: mlWorkspace
  name: guid(mlWorkspace.id, scientist.principalId, 'AzureMLDataScientist')
  properties: {
    roleDefinitionId: roleDefinitions.azureMLDataScientist
    principalId: scientist.principalId
    principalType: scientist.principalType
    description: 'Azure ML Data Scientist access'
  }
}]

resource mlOpsEngineerRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (engineer, i) in mlOpsEngineers: if (enableRbacAssignments) {
  scope: mlWorkspace
  name: guid(mlWorkspace.id, engineer.principalId, 'AzureMLComputeOperator')
  properties: {
    roleDefinitionId: roleDefinitions.azureMLComputeOperator
    principalId: engineer.principalId
    principalType: engineer.principalType
    description: 'Azure ML Compute Operator access for MLOps'
  }
}]

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Machine Learning workspace resource ID')
output workspaceId string = mlWorkspace.id

@description('Machine Learning workspace name')
output workspaceName string = mlWorkspace.name

@description('Machine Learning workspace location')
output workspaceLocation string = mlWorkspace.location

@description('Machine Learning workspace discovery URL')
output discoveryUrl string = mlWorkspace.properties.discoveryUrl

@description('Machine Learning workspace MLFlow tracking URI')
output mlFlowTrackingUri string = mlWorkspace.properties.mlFlowTrackingUri

@description('Machine Learning workspace ID (immutable)')
output workspaceGuid string = mlWorkspace.properties.workspaceId

@description('Machine Learning workspace principal ID (system-assigned identity)')
output workspacePrincipalId string = mlWorkspace.identity.?principalId ?? ''

@description('Machine Learning workspace tenant ID')
output workspaceTenantId string = mlWorkspace.identity.?tenantId ?? ''

@description('Private endpoint resource IDs')
output privateEndpointIds object = enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId) ? {
  api: mlWorkspacePrivateEndpointApi.id
  notebooks: mlWorkspacePrivateEndpointNotebooks.id
} : {}

@description('Private endpoint IP addresses')
output privateEndpointIpAddresses object = {}

@description('Managed network status')
output managedNetworkStatus object = enableManagedNetwork ? {
  isolationMode: mlWorkspace.properties.managedNetwork.isolationMode
  status: mlWorkspace.properties.managedNetwork.status
  networkId: mlWorkspace.properties.managedNetwork.networkId
} : {}

@description('Service managed resource group name')
output serviceManagedResourceGroup string = mlWorkspace.properties.serviceProvisionedResourceGroup

@description('Storage account HNS enabled status')
output storageHnsEnabled bool = mlWorkspace.properties.storageHnsEnabled

@description('Notebook resource information')
output notebookInfo object = {
  resourceId: mlWorkspace.properties.notebookInfo.resourceId
  fqdn: mlWorkspace.properties.notebookInfo.fqdn
}

@description('Associated dependent resources')
output dependentResources object = {
  applicationInsights: mlWorkspace.properties.applicationInsights
  containerRegistry: mlWorkspace.properties.containerRegistry
  keyVault: mlWorkspace.properties.keyVault
  storageAccount: mlWorkspace.properties.storageAccount
}

@description('All applied tags')
output appliedTags object = allTags
