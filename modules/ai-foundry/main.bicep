// ============================================================================
// Azure AI Foundry (Azure AI Studio) - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// Description: Comprehensive AI Foundry workspace with enterprise security
// ============================================================================

// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// The unique name for the AI Foundry workspace resource
// Used to identify the workspace in Azure and as the primary resource identifier
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@description('Name of the AI Foundry workspace')
@minLength(3)
@maxLength(33)
param aiFoundryWorkspaceName string

// Azure region where all resources will be deployed
// Critical for data residency and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and access controls
// 🔒 SECURITY ENHANCEMENT: Use different encryption keys and access policies per environment
@description('Environment name (dev, test, prod)')
@allowed(['dev', 'test', 'prod'])
param environment string = 'dev'

// Resource tags for governance, cost management, and compliance tracking
// Essential for enterprise resource management and security auditing
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// AI FOUNDRY WORKSPACE CONFIGURATION
// ============================================================================

// Human-readable display name for the workspace in the Azure AI Foundry portal
// Helps users identify the workspace purpose and scope in the UI
@description('Friendly name for the AI Foundry workspace')
param friendlyName string = ''

// Detailed description of the workspace's intended use and purpose
// Important for governance and helping users understand workspace scope
@description('Description of the AI Foundry workspace')
param workspaceDescription string = ''

// High Business Impact (HBI) classification for enhanced data protection
// Enables additional security controls for sensitive data and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Always enable for production workloads with sensitive data
@description('Enable High Business Impact (HBI) workspace for enhanced security')
param hbiWorkspace bool = true

// Controls public access when workspace is connected to a virtual network
// Critical security setting that should be disabled for enterprise deployments
// 🔒 SECURITY ENHANCEMENT: Always set to false for zero-trust network architecture
@description('Allow public access when behind VNet')
param allowPublicAccessWhenBehindVnet bool = false

// Global public network access control for the AI Foundry workspace
// Primary network security control that determines internet accessibility
// 🔒 SECURITY ENHANCEMENT: Set to 'Disabled' for enterprise security and use private endpoints
@description('Public network access setting')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Disabled'

// Legacy v1 workspace mode compatibility (deprecated for AI Foundry)
// Should remain false for modern AI Foundry Hub functionality
// 🔒 SECURITY ENHANCEMENT: Keep disabled to use latest security features
@description('Enable v1 legacy mode (not recommended for AI Foundry)')
param v1LegacyMode bool = false

// Enhanced data isolation controls for multi-tenant environments
// Provides additional data separation and access controls
// 🔒 SECURITY ENHANCEMENT: Enable for enhanced data protection and compliance
@description('Enable data isolation for enhanced security')
param enableDataIsolation bool = true

// ============================================================================
// AI FOUNDRY HUB CONFIGURATION
// ============================================================================

// Enables AI Foundry Hub mode for multi-project management and resource sharing
// Hub workspaces provide centralized governance and resource management for AI projects
// 🔒 SECURITY ENHANCEMENT: Use Hub mode for centralized security policies and compliance
@description('Enable AI Foundry Hub configuration')
param enableAIFoundryHub bool = true

// List of child AI Foundry project workspaces associated with this Hub
// Allows for hierarchical organization and shared resource management
// 🔒 SECURITY ENHANCEMENT: Control project access through Hub-level RBAC policies
@description('Associated AI Foundry projects/workspaces')
param associatedWorkspaces array = []

// Default resource group for new projects created under this Hub
// Provides consistent resource organization and governance
@description('Default workspace resource group for hub')
param defaultWorkspaceResourceGroup string = ''

// Additional storage accounts that can be shared across Hub projects
// Enables centralized data management and cost optimization
// 🔒 SECURITY ENHANCEMENT: Use shared storage with proper RBAC and encryption
@description('Additional workspace storage accounts for projects')
param additionalWorkspaceStorageAccounts array = []

// ============================================================================
// DEPENDENT RESOURCES CONFIGURATION
// ============================================================================

// Application Insights resource for comprehensive AI workload monitoring and diagnostics
// Critical for performance monitoring, debugging, and security auditing
// 🔒 SECURITY ENHANCEMENT: Configure with private endpoints and restricted access
@description('Resource ID of the Application Insights instance')
param applicationInsightsId string

// Azure Container Registry for storing and managing AI model container images
// Essential for secure model deployment and version management
// 🔒 SECURITY ENHANCEMENT: Use private registry with vulnerability scanning enabled
@description('Resource ID of the Container Registry for AI models')
param containerRegistryId string = ''

// Azure Key Vault for centralized secrets, keys, and certificate management
// Core security component for protecting sensitive AI workload credentials
// 🔒 SECURITY ENHANCEMENT: Use customer-managed keys and hardware security modules (HSM)
@description('Resource ID of the Key Vault for secrets management')
param keyVaultId string

// Primary storage account for AI workspace artifacts, models, and datasets
// Must support advanced security features for data protection
// 🔒 SECURITY ENHANCEMENT: Enable encryption at rest, private endpoints, and access controls
@description('Resource ID of the Storage Account for AI assets')
param storageAccountId string

// Azure OpenAI service for generative AI capabilities and large language models
// Provides access to GPT, DALL-E, and other OpenAI models
// 🔒 SECURITY ENHANCEMENT: Configure with private endpoints and content filtering
@description('Resource ID of the Azure OpenAI service')
param openAIServiceId string = ''

// Multi-service Cognitive Services account for traditional AI capabilities
// Provides speech, vision, language, and decision AI services
// 🔒 SECURITY ENHANCEMENT: Use customer-managed keys and VNet integration
@description('Resource ID of the Cognitive Services multi-service account')
param cognitiveServicesId string = ''

// Azure Cognitive Search service for intelligent search and knowledge mining
// Enables semantic search, vector search, and AI-powered content discovery
// 🔒 SECURITY ENHANCEMENT: Configure with private endpoints and query key management
@description('Resource ID of the Cognitive Search service')
param cognitiveSearchId string = ''

// ============================================================================
// IDENTITY CONFIGURATION
// ============================================================================

// Managed identity type for secure, passwordless authentication to Azure services
// Controls how the AI Foundry workspace authenticates to dependent services
// 🔒 SECURITY ENHANCEMENT: Use 'SystemAssigned,UserAssigned' for maximum flexibility and security
@description('Type of managed identity')
@allowed(['None', 'SystemAssigned', 'UserAssigned', 'SystemAssigned,UserAssigned'])
param managedIdentityType string = 'SystemAssigned,UserAssigned'

// List of user-assigned managed identities for fine-grained access control
// Enables shared identities across multiple resources and precise RBAC management
// 🔒 SECURITY ENHANCEMENT: Use separate identities for different service connections
@description('Resource IDs of user-assigned managed identities')
param userAssignedIdentities array = []

// Primary user-assigned identity for workspace operations and service connections
// Used as the default identity for AI Foundry operations when multiple identities exist
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal required permissions
@description('Primary user-assigned identity resource ID')
param primaryUserAssignedIdentity string = ''

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

// Enable customer-managed encryption keys (CMK) for data protection at rest
// Provides customer control over encryption keys and enhanced compliance
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring key control
@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

// Azure Key Vault key identifier (URL) for customer-managed encryption
// Must be a versioned key URL from an accessible Key Vault
// 🔒 SECURITY ENHANCEMENT: Use HSM-backed keys and implement key rotation policies
@description('Key Vault key identifier for encryption')
param encryptionKeyIdentifier string = ''

// User-assigned managed identity with Key Vault access for encryption operations
// Must have 'Key Vault Crypto Service Encryption User' role on the encryption key
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal Key Vault permissions
@description('User-assigned identity for accessing encryption key')
param encryptionIdentityId string = ''

// Customer-managed encryption status control for the workspace
// Determines whether encryption with customer keys is active
// 🔒 SECURITY ENHANCEMENT: Keep enabled for maximum data protection
@description('Encryption status')
@allowed(['Enabled', 'Disabled'])
param encryptionStatus string = 'Enabled'

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

// Enable Azure AI Foundry managed network for enhanced network security
// Provides automatic network isolation and outbound traffic control
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring network control
@description('Enable managed network for AI Foundry')
param enableManagedNetwork bool = true

// Network isolation mode controlling outbound internet access from the workspace
// Determines the level of network restriction for AI workloads
// 🔒 SECURITY ENHANCEMENT: Use 'AllowOnlyApprovedOutbound' for zero-trust network architecture
@description('Managed network isolation mode')
@allowed(['Disabled', 'AllowInternetOutbound', 'AllowOnlyApprovedOutbound'])
param managedNetworkIsolationMode string = 'AllowOnlyApprovedOutbound'

// Azure Firewall SKU for FQDN-based outbound rules and advanced threat protection
// Controls the firewall capabilities for managed network rules
// 🔒 SECURITY ENHANCEMENT: Use 'Standard' SKU for advanced security features
@description('Firewall SKU for FQDN rules')
@allowed(['Standard', 'Basic'])
param firewallSku string = 'Standard'

// Custom outbound network rules for controlling AI service access
// Defines which external services the workspace can communicate with
// 🔒 SECURITY ENHANCEMENT: Define minimal required rules for AI services and dependencies
@description('Outbound rules for managed network')
param outboundRules object = {
  'Azure-OpenAI-Rule': {
    type: 'ServiceTag'
    category: 'Required'
    destination: {
      serviceTag: 'CognitiveServicesManagement'
      protocol: 'TCP'
      portRanges: '443'
      action: 'Allow'
    }
  }
  'Azure-AI-Services-Rule': {
    type: 'ServiceTag'
    category: 'Required'
    destination: {
      serviceTag: 'AzureActiveDirectory'
      protocol: 'TCP'
      portRanges: '443'
      action: 'Allow'
    }
  }
}

// ============================================================================
// PRIVATE ENDPOINT CONFIGURATION
// ============================================================================

// Enable private endpoints for secure, private connectivity to AI Foundry services
// Provides network isolation and eliminates internet exposure of AI endpoints
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring network isolation
@description('Enable private endpoints')
param enablePrivateEndpoints bool = true

// Virtual Network resource ID where private endpoints will be created
// Must be a VNet with sufficient address space and appropriate subnets
// 🔒 SECURITY ENHANCEMENT: Use dedicated VNet with network security groups and restricted access
@description('Virtual Network resource ID for private endpoints')
param vnetId string = ''

// Subnet resource ID specifically designated for private endpoint network interfaces
// Should be a dedicated subnet with appropriate security controls
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet with NSG rules blocking unnecessary traffic
@description('Subnet resource ID for private endpoints')
param privateEndpointSubnetId string = ''

// Private DNS zone resource IDs for resolving AI Foundry private endpoint FQDNs
// Essential for proper name resolution of private endpoints within the VNet
// 🔒 SECURITY ENHANCEMENT: Use private DNS zones to prevent DNS leakage to public DNS
@description('Private DNS zone resource IDs for AI Foundry')
param privateDnsZoneIds object = {
  api: ''
  notebooks: ''
  inference: ''
}

// Custom suffix for private endpoint resource names for naming consistency
// Helps with resource organization and governance in large deployments
@description('Custom private endpoint name suffix')
param privateEndpointNameSuffix string = ''

// ============================================================================
// AI FOUNDRY FEATURES CONFIGURATION
// ============================================================================

// Enable AI Foundry compute resources for model training and experimentation
// Provides managed compute infrastructure for AI development workflows
// 🔒 SECURITY ENHANCEMENT: Use private compute with VNet integration and no public IP
@description('Enable AI Foundry compute for model training')
param enableAIFoundryCompute bool = true

// Specific compute instance name for AI model container image builds
// Used for custom environment and model containerization processes
@description('Compute instance for AI model builds')
param imageBuildCompute string = ''

// Enable serverless compute for scalable AI model training and inference
// Provides auto-scaling compute without infrastructure management overhead
// 🔒 SECURITY ENHANCEMENT: Use with private networking and VNet integration
@description('Enable serverless compute for AI workloads')
param enableServerlessCompute bool = true

// Custom subnet resource ID for serverless compute network integration
// Allows serverless compute to run within your private network infrastructure
// 🔒 SECURITY ENHANCEMENT: Use private subnet with controlled outbound access
@description('Custom subnet for serverless compute')
param serverlessComputeCustomSubnet string = ''

// Disable public IP addresses for serverless compute nodes for enhanced security
// Ensures compute nodes are not directly accessible from the internet
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise security and compliance
@description('Disable public IP for serverless compute nodes')
param serverlessComputeNoPublicIP bool = true

// Note: enableAIFoundryCompute is used to determine compute availability
// and influences the serverless compute configuration

// ============================================================================
// AI MODEL AND DATA CONFIGURATION
// ============================================================================

// Enable AI Foundry feature store for centralized ML feature management
// Provides versioned, governed feature storage for consistent model training
// 🔒 SECURITY ENHANCEMENT: Use with private endpoints and access controls
@description('Enable feature store for AI model features')
param enableFeatureStore bool = false

// Connection name for offline feature store (typically Azure Storage or Data Lake)
// Used for batch feature computation and historical feature retrieval
@description('Offline store connection name for feature store')
param offlineStoreConnectionName string = ''

// Connection name for online feature store (typically Redis or Cosmos DB)
// Used for real-time feature serving during model inference
@description('Online store connection name for feature store')
param onlineStoreConnectionName string = ''

// Apache Spark runtime version for feature store compute operations
// Determines the Spark version used for feature engineering workloads
@description('Spark runtime version for feature store')
param sparkRuntimeVersion string = '3.4'

// ============================================================================
// AI CONNECTIONS CONFIGURATION
// ============================================================================

// Custom AI service connections for the workspace (e.g., external APIs, databases)
// Enables integration with external AI services and data sources
// 🔒 SECURITY ENHANCEMENT: Use managed identity authentication and private connectivity
@description('AI Foundry workspace connections')
param workspaceConnections array = []

// Shared private link resources for secure connections to AI services
// Enables private connectivity to external services through managed private endpoints
// 🔒 SECURITY ENHANCEMENT: Use for secure access to external AI services and data stores
@description('Shared private link resources for AI services')
param sharedPrivateLinkResources array = []

// Note: workspaceConnections are managed post-deployment through the AI Foundry portal
// This parameter is reserved for future connection automation capabilities

// ============================================================================
// SERVICE MANAGED RESOURCES
// ============================================================================

// Enable custom configuration for CosmosDB used by AI Foundry for metadata storage
// Controls the underlying CosmosDB instance used for workspace metadata
// 🔒 SECURITY ENHANCEMENT: Use for compliance requirements needing custom DB settings
@description('Enable custom CosmosDB settings for AI metadata')
param enableCustomCosmosDbSettings bool = false

// Request Units (RU) throughput for CosmosDB collections storing AI metadata
// Controls the performance and cost of metadata operations
@description('CosmosDB collections throughput for AI metadata')
param cosmosDbCollectionsThroughput int = 400

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

// Enable comprehensive diagnostic logging and monitoring for AI Foundry operations
// Critical for security monitoring, compliance, and operational insights
// 🔒 SECURITY ENHANCEMENT: Always enable for security auditing and compliance
@description('Enable diagnostic settings')
param enableDiagnostics bool = true

// Log Analytics workspace resource ID for centralized log storage and analysis
// Required for security monitoring, alerting, and compliance reporting
// 🔒 SECURITY ENHANCEMENT: Use dedicated workspace with appropriate retention policies
@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

// Storage account resource ID for long-term diagnostic log archival
// Used for compliance requirements and cost-effective log retention
// 🔒 SECURITY ENHANCEMENT: Use storage with encryption, access controls, and immutability
@description('Storage account resource ID for diagnostics')
param diagnosticsStorageAccountId string = ''

// Event Hub authorization rule ID for real-time log streaming
// Enables real-time security monitoring and integration with SIEM systems
// 🔒 SECURITY ENHANCEMENT: Use for real-time threat detection and incident response
@description('Event Hub authorization rule ID for diagnostics')
param eventHubAuthorizationRuleId string = ''

// Event Hub name for streaming diagnostic logs and security events
// Target Event Hub for real-time log processing and analysis
@description('Event Hub name for diagnostics')
param eventHubName string = ''

// Specific diagnostic log categories to capture from AI Foundry operations
// Controls which AI activities are logged for monitoring and security analysis
// 🔒 SECURITY ENHANCEMENT: Include all categories for comprehensive security monitoring
@description('Diagnostic logs categories to enable for AI Foundry')
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

// Diagnostic metrics categories for performance and resource utilization monitoring
// Essential for capacity planning and performance optimization
// 🔒 SECURITY ENHANCEMENT: Monitor for unusual resource usage patterns
@description('Diagnostic metrics categories to enable')
param diagnosticMetricsCategories array = [
  'AllMetrics'
]

// Retention period in days for diagnostic logs in Log Analytics workspace
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on compliance and security investigation requirements
@description('Diagnostic logs retention in days')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 90

// ============================================================================
// RBAC CONFIGURATION
// ============================================================================

// Enable automatic RBAC role assignments for AI Foundry workspace access control
// Provides fine-grained access control for different user types and responsibilities
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring access governance
@description('Enable RBAC role assignments')
param enableRbacAssignments bool = true

// Workspace administrators with full control over the AI Foundry workspace
// Users/groups that can manage workspace settings, compute, and access policies
// 🔒 SECURITY ENHANCEMENT: Limit to essential personnel and use Azure AD PIM for time-bound access
@description('AI Foundry workspace administrators')
param workspaceAdministrators array = []

// Workspace contributors with ability to create and manage AI experiments and models
// Users/groups that can develop AI solutions but cannot change workspace configuration
// 🔒 SECURITY ENHANCEMENT: Use for development teams requiring hands-on AI development access
@description('AI Foundry workspace contributors')
param workspaceContributors array = []

// Workspace readers with view-only access to AI models, experiments, and results
// Users/groups that need visibility into AI development but no modification capabilities
// 🔒 SECURITY ENHANCEMENT: Use for stakeholders, auditors, and compliance personnel
@description('AI Foundry workspace readers')
param workspaceReaders array = []

// AI developers with specialized access to generative AI and model development features
// Users/groups focused on AI model development, prompt engineering, and fine-tuning
// 🔒 SECURITY ENHANCEMENT: Grant only to users requiring access to AI model development features
@description('AI developers with model development access')
param aiDevelopers array = []

// AI engineers with access to model deployment, MLOps, and production AI systems
// Users/groups responsible for deploying and maintaining AI models in production
// 🔒 SECURITY ENHANCEMENT: Restrict to DevOps personnel with AI system responsibilities
@description('AI engineers with deployment access')
param aiEngineers array = []

// Data scientists with access to data analysis, ML pipelines, and feature engineering
// Users/groups focused on data preparation, feature engineering, and ML experimentation
// 🔒 SECURITY ENHANCEMENT: Grant access based on data classification and need-to-know principles
@description('Data scientists with ML pipeline access')
param dataScientists array = []

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '-${environment}-${substring(uniqueString(resourceGroup().id), 0, 6)}'

var defaultTags = {
  Environment: environment
  Service: 'AI Foundry'
  ManagedBy: 'Bicep'
  AIFoundryEnabled: 'true'
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

// Managed network configuration for AI Foundry
var managedNetworkConfig = enableManagedNetwork ? {
  isolationMode: managedNetworkIsolationMode
  firewallSku: firewallSku
  outboundRules: outboundRules
} : null

// Serverless compute configuration
var serverlessComputeConfig = enableServerlessCompute && enableAIFoundryCompute ? {
  serverlessComputeCustomSubnet: !empty(serverlessComputeCustomSubnet) ? serverlessComputeCustomSubnet : null
  serverlessComputeNoPublicIP: serverlessComputeNoPublicIP
} : null

// Feature store configuration for AI models
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

// AI Foundry Hub configuration
var workspaceHubConfig = enableAIFoundryHub ? {
  defaultWorkspaceResourceGroup: !empty(defaultWorkspaceResourceGroup) ? defaultWorkspaceResourceGroup : null
  additionalWorkspaceStorageAccounts: additionalWorkspaceStorageAccounts
} : null

// Built-in role definitions for AI Foundry
var roleDefinitions = {
  owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  azureMLDataScientist: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'f6c7c914-8db3-469d-8ca1-694a8f32e121')
  azureMLComputeOperator: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'e503ece1-11d0-4e8e-8e2c-7a6c3bf38815')
  cognitiveServicesUser: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')
  cognitiveServicesOpenAIUser: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  cognitiveServicesOpenAIContributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a001fd3d-188f-4b5d-821b-7da978bf7442')
}

// ============================================================================
// RESOURCES
// ============================================================================

// AI Foundry workspace (using ML workspace with AI Foundry configuration)
resource aiFoundryWorkspace 'Microsoft.MachineLearningServices/workspaces@2024-10-01' = {
  name: aiFoundryWorkspaceName
  location: location
  tags: allTags
  kind: 'Hub'  // AI Foundry hub workspace type
  identity: identityConfig
  properties: {
    friendlyName: !empty(friendlyName) ? friendlyName : '${aiFoundryWorkspaceName} AI Foundry'
    description: !empty(workspaceDescription) ? workspaceDescription : 'Enterprise AI Foundry workspace for generative AI development'
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
    associatedWorkspaces: associatedWorkspaces
    sharedPrivateLinkResources: sharedPrivateLinkResources
  }
}

// Private endpoints for AI Foundry workspace
resource aiFoundryPrivateEndpointApi 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${aiFoundryWorkspaceName}-api${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${aiFoundryWorkspaceName}-api'
        properties: {
          privateLinkServiceId: aiFoundryWorkspace.id
          groupIds: ['amlworkspace']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for AI Foundry workspace API'
          }
        }
      }
    ]
  }
}

resource aiFoundryPrivateEndpointNotebooks 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${aiFoundryWorkspaceName}-notebooks${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${aiFoundryWorkspaceName}-notebooks'
        properties: {
          privateLinkServiceId: aiFoundryWorkspace.id
          groupIds: ['notebook']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for AI Foundry notebooks'
          }
        }
      }
    ]
  }
}

resource aiFoundryPrivateEndpointInference 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${aiFoundryWorkspaceName}-inference${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${aiFoundryWorkspaceName}-inference'
        properties: {
          privateLinkServiceId: aiFoundryWorkspace.id
          groupIds: ['inference']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for AI Foundry inference endpoints'
          }
        }
      }
    ]
  }
}

// Private DNS zone groups
resource aiFoundryPrivateDnsZoneGroupApi 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneIds.api)) {
  parent: aiFoundryPrivateEndpointApi
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

resource aiFoundryPrivateDnsZoneGroupNotebooks 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneIds.notebooks)) {
  parent: aiFoundryPrivateEndpointNotebooks
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

resource aiFoundryPrivateDnsZoneGroupInference 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneIds.inference)) {
  parent: aiFoundryPrivateEndpointInference
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneIds.inference
        }
      }
    ]
  }
}

// Diagnostic settings for AI Foundry
resource aiFoundryDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticsStorageAccountId) || !empty(eventHubAuthorizationRuleId))) {
  scope: aiFoundryWorkspace
  name: 'diag-${aiFoundryWorkspaceName}'
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

// RBAC role assignments for AI Foundry
resource workspaceAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (admin, i) in workspaceAdministrators: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, admin.principalId, 'Owner')
  properties: {
    roleDefinitionId: roleDefinitions.owner
    principalId: admin.principalId
    principalType: admin.principalType
    description: 'AI Foundry workspace administrator access'
  }
}]

resource workspaceContributorRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (contributor, i) in workspaceContributors: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, contributor.principalId, 'Contributor')
  properties: {
    roleDefinitionId: roleDefinitions.contributor
    principalId: contributor.principalId
    principalType: contributor.principalType
    description: 'AI Foundry workspace contributor access'
  }
}]

resource workspaceReaderRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (reader, i) in workspaceReaders: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, reader.principalId, 'Reader')
  properties: {
    roleDefinitionId: roleDefinitions.reader
    principalId: reader.principalId
    principalType: reader.principalType
    description: 'AI Foundry workspace reader access'
  }
}]

resource aiDeveloperRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (developer, i) in aiDevelopers: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, developer.principalId, 'CognitiveServicesOpenAIUser')
  properties: {
    roleDefinitionId: roleDefinitions.cognitiveServicesOpenAIUser
    principalId: developer.principalId
    principalType: developer.principalType
    description: 'AI developer access for generative AI development'
  }
}]

resource aiEngineerRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (engineer, i) in aiEngineers: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, engineer.principalId, 'CognitiveServicesOpenAIContributor')
  properties: {
    roleDefinitionId: roleDefinitions.cognitiveServicesOpenAIContributor
    principalId: engineer.principalId
    principalType: engineer.principalType
    description: 'AI engineer access for model deployment and management'
  }
}]

resource dataScientistRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (scientist, i) in dataScientists: if (enableRbacAssignments) {
  scope: aiFoundryWorkspace
  name: guid(aiFoundryWorkspace.id, scientist.principalId, 'AzureMLDataScientist')
  properties: {
    roleDefinitionId: roleDefinitions.azureMLDataScientist
    principalId: scientist.principalId
    principalType: scientist.principalType
    description: 'Data scientist access for ML pipeline development'
  }
}]

// ============================================================================
// OUTPUTS
// ============================================================================

@description('AI Foundry workspace resource ID')
output workspaceId string = aiFoundryWorkspace.id

@description('AI Foundry workspace name')
output workspaceName string = aiFoundryWorkspace.name

@description('AI Foundry workspace location')
output workspaceLocation string = aiFoundryWorkspace.location

@description('AI Foundry workspace discovery URL')
output discoveryUrl string = aiFoundryWorkspace.properties.discoveryUrl

@description('AI Foundry workspace MLFlow tracking URI')
output mlFlowTrackingUri string = aiFoundryWorkspace.properties.mlFlowTrackingUri

@description('AI Foundry workspace ID (immutable)')
output workspaceGuid string = aiFoundryWorkspace.properties.workspaceId

@description('AI Foundry workspace principal ID (system-assigned identity)')
output workspacePrincipalId string = aiFoundryWorkspace.identity.?principalId ?? ''

@description('AI Foundry workspace tenant ID')
output workspaceTenantId string = aiFoundryWorkspace.identity.?tenantId ?? ''

@description('Private endpoint resource IDs')
output privateEndpointIds object = enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId) ? {
  api: aiFoundryPrivateEndpointApi.id
  notebooks: aiFoundryPrivateEndpointNotebooks.id
  inference: aiFoundryPrivateEndpointInference.id
} : {}

@description('Managed network status')
output managedNetworkStatus object = enableManagedNetwork ? {
  isolationMode: aiFoundryWorkspace.properties.managedNetwork.isolationMode
  status: aiFoundryWorkspace.properties.managedNetwork.status
  networkId: aiFoundryWorkspace.properties.managedNetwork.networkId
} : {}

@description('Service managed resource group name')
output serviceManagedResourceGroup string = aiFoundryWorkspace.properties.serviceProvisionedResourceGroup

@description('Storage account HNS enabled status')
output storageHnsEnabled bool = aiFoundryWorkspace.properties.storageHnsEnabled

@description('Notebook resource information')
output notebookInfo object = {
  resourceId: aiFoundryWorkspace.properties.notebookInfo.resourceId
  fqdn: aiFoundryWorkspace.properties.notebookInfo.fqdn
}

@description('Associated dependent resources for AI Foundry')
output dependentResources object = {
  applicationInsights: aiFoundryWorkspace.properties.applicationInsights
  containerRegistry: aiFoundryWorkspace.properties.containerRegistry
  keyVault: aiFoundryWorkspace.properties.keyVault
  storageAccount: aiFoundryWorkspace.properties.storageAccount
  openAIService: openAIServiceId
  cognitiveServices: cognitiveServicesId
  cognitiveSearch: cognitiveSearchId
}

@description('AI Foundry Hub configuration')
output hubConfiguration object = enableAIFoundryHub ? {
  workspaceType: 'Hub'
  associatedWorkspaces: aiFoundryWorkspace.properties.associatedWorkspaces
  defaultWorkspaceResourceGroup: aiFoundryWorkspace.properties.workspaceHubConfig.defaultWorkspaceResourceGroup
  additionalStorageAccounts: aiFoundryWorkspace.properties.workspaceHubConfig.additionalWorkspaceStorageAccounts
} : {}

@description('AI Foundry workspace endpoints')
output workspaceEndpoints object = {
  apiEndpoint: 'https://${aiFoundryWorkspaceName}.workspace.${location}.api.azureml.ms'
  studioEndpoint: 'https://ml.azure.com/workspaces/${aiFoundryWorkspace.properties.workspaceId}'
  notebooksEndpoint: aiFoundryWorkspace.properties.notebookInfo.fqdn
  mlFlowEndpoint: aiFoundryWorkspace.properties.mlFlowTrackingUri
}

@description('AI Foundry workspace connections and services configuration')
output workspaceConnectionsInfo object = {
  configuredConnections: length(workspaceConnections)
  sharedPrivateLinkResources: length(sharedPrivateLinkResources)
  computeEnabled: enableAIFoundryCompute
  supportedConnectionTypes: [
    'AzureOpenAI'
    'CognitiveServices'
    'CognitiveSearch'
    'AzureBlob'
    'CosmosDb'
    'AzureSqlDb'
  ]
}

@description('All applied tags')
output appliedTags object = allTags
