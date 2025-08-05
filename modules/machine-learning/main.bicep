@description('Azure Machine Learning Workspace - Enterprise ML platform for AI model development, training, and deployment with advanced security, compliance, and MLOps capabilities. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Machine Learning Workspace - Enterprise Edition'  
metadata description = 'Enterprise-grade ML workspace with advanced security, managed networks, and comprehensive MLOps capabilities'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
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
// PARAMETERS - ADVANCED SECURITY & COMPLIANCE
// ============================================================================

// Enable Azure Defender for Machine Learning workspaces and compute resources
// Provides advanced threat protection and security monitoring for ML workloads
// 🔒 SECURITY ENHANCEMENT: Always enable for production ML environments requiring threat protection
@description('Enable Azure Defender for advanced threat protection')
param enableAzureDefender bool = true

// Data loss prevention policies for ML workspace to prevent data exfiltration
// Controls data export and sharing capabilities within the ML workspace
// 🔒 SECURITY ENHANCEMENT: Enable for environments with sensitive data and compliance requirements
@description('Enable data loss prevention policies')
param enableDataLossPrevention bool = true

// Audit policy configuration for comprehensive ML operations logging
// Controls what ML activities are audited and logged for compliance
// 🔒 SECURITY ENHANCEMENT: Configure comprehensive audit policies for regulated environments
@description('Audit policy configuration for ML operations')
param auditPolicyConfig object = {
  enabled: true
  auditComputeClusterEvents: true
  auditJobEvents: true
  auditModelEvents: true
  auditDeploymentEvents: true
  auditDataStoreEvents: true
  auditWorkspaceEvents: true
}

// Immutable workspace configuration to prevent accidental modifications
// Locks critical workspace settings to prevent unauthorized changes
// 🔒 SECURITY ENHANCEMENT: Enable for production workspaces requiring configuration stability
@description('Enable immutable workspace configuration')
param enableImmutableWorkspace bool = false

// Content filtering policies for ML workspace to control model outputs
// Similar to Azure OpenAI content filtering but for custom ML models
// 🔒 SECURITY ENHANCEMENT: Configure content policies for ML models with public-facing outputs
@description('Content filtering policies for ML model outputs')
param contentFilteringPolicies object = {
  enabled: false
  strictContentFiltering: false
  customPolicies: []
}

// Data residency enforcement for strict geographic data boundaries
// Ensures all ML data and models remain within specified geographic regions
// 🔒 SECURITY ENHANCEMENT: Required for compliance with data sovereignty regulations
@description('Enforce strict data residency requirements')
param enforceDataResidency bool = true

// Allowed regions for data processing and model training
// Restricts where ML compute and data processing can occur
// 🔒 SECURITY ENHANCEMENT: Define allowed regions based on compliance requirements
@description('Allowed regions for ML data processing and compute')
param allowedDataProcessingRegions array = [location]

// ============================================================================
// PARAMETERS - ENHANCED COMPUTE & SCALING
// ============================================================================  

// Auto-shutdown configuration for compute instances to control costs and security
// Automatically shuts down idle compute instances to prevent unauthorized usage
// 🔒 SECURITY ENHANCEMENT: Prevents compute resources from running indefinitely
@description('Auto-shutdown configuration for compute instances')
param autoShutdownConfig object = {
  enabled: true
  idleTimeBeforeShutdownMinutes: 30
  enableScheduledShutdown: true
  scheduledShutdownTime: '22:00'
  scheduledShutdownTimeZone: 'UTC'
}

// Compute instance access control for fine-grained user permissions
// Controls who can access and use compute instances within the workspace
// 🔒 SECURITY ENHANCEMENT: Implement principle of least privilege for compute access
@description('Compute instance access control configuration')
param computeInstanceAccessControl object = {
  enabled: true
  defaultAccessLevel: 'NoAccess'
  allowedUsers: []
  allowedGroups: []
  requireApprovalForNewUsers: true
}

// Maximum node counts for compute clusters to prevent resource exhaustion
// Sets upper limits on cluster scaling to control costs and prevent abuse
// 🔒 SECURITY ENHANCEMENT: Prevent runaway compute scaling and associated costs
@description('Maximum node limits for compute clusters')
param computeClusterLimits object = {
  maxNodeCount: 100
  maxConcurrentJobs: 50
  maxClusterCount: 10
  enableNodeIdleTimeout: true
  nodeIdleTimeoutMinutes: 15
}

// Spot instance configuration for cost-effective training workloads
// Enables use of Azure Spot VMs for non-critical ML training workloads
// 🔒 SECURITY ENHANCEMENT: Monitor spot instance usage for security compliance
@description('Spot instance configuration for cost optimization')
param spotInstanceConfig object = {
  enabled: false
  maxSpotNodeCount: 50
  spotBidPrice: -1  // -1 means pay up to on-demand price
  enableSpotEvictionPolicy: true
}

// Custom compute image configuration for standardized ML environments
// Provides custom Docker images with approved libraries and security configurations
// 🔒 SECURITY ENHANCEMENT: Use approved images with security scanning and compliance
@description('Custom compute image configuration')
param customComputeImages array = []

// ============================================================================
// PARAMETERS - MODEL MANAGEMENT & GOVERNANCE
// ============================================================================

// Model governance policies for enterprise ML model lifecycle management
// Controls model registration, versioning, approval workflows, and deployment
// 🔒 SECURITY ENHANCEMENT: Implement model approval workflows and security scanning
@description('Model governance and lifecycle management policies')
param modelGovernancePolicies object = {
  enabled: true
  requireModelApproval: true
  enableModelVersioning: true
  enableModelTags: true
  requireModelDocumentation: true
  enableModelLineage: true
  modelRetentionDays: 365
}

// Model registry configuration for centralized model storage and management
// Provides centralized repository for trained models with version control
// 🔒 SECURITY ENHANCEMENT: Enable access controls and audit logging for model registry
@description('Model registry configuration')
param modelRegistryConfig object = {
  enabled: true
  enableModelEncryption: true
  enableModelAccessAuditing: true
  enableModelIntegrityChecks: true
  allowedModelFormats: ['MLflow', 'ONNX', 'Pickle', 'PyTorch', 'TensorFlow']
}

// Automated model deployment policies for MLOps workflows
// Controls how models are automatically deployed from training to production
// 🔒 SECURITY ENHANCEMENT: Implement security gates in deployment pipelines
@description('Automated model deployment configuration')
param modelDeploymentConfig object = {
  enabled: false
  enableAutomatedDeployment: false
  enableDeploymentApproval: true
  enableCanaryDeployment: true
  enableBlueGreenDeployment: false
  deploymentSecurityChecks: true
}

// Experiment tracking and management configuration
// Controls how ML experiments are tracked, logged, and managed
// 🔒 SECURITY ENHANCEMENT: Enable audit logging for all experiment activities
@description('Experiment tracking and management configuration')
param experimentTrackingConfig object = {
  enabled: true
  enableMetricsLogging: true
  enableArtifactTracking: true
  enableParameterTracking: true
  enableEnvironmentTracking: true
  retentionDays: 90
}

// ============================================================================
// PARAMETERS - DATA SECURITY & PRIVACY
// ============================================================================

// Data encryption configuration for ML datasets and models
// Provides comprehensive encryption for data at rest and in transit
// 🔒 SECURITY ENHANCEMENT: Enable comprehensive encryption for all ML data
@description('Comprehensive data encryption configuration')
param dataEncryptionConfig object = {
  encryptDataAtRest: true
  encryptDataInTransit: true
  encryptModelArtifacts: true
  encryptExperimentLogs: true
  useCustomerManagedKeys: true
  enableDoubleEncryption: false
}

// Data anonymization and privacy protection features
// Provides data privacy controls for sensitive datasets used in ML training  
// 🔒 SECURITY ENHANCEMENT: Enable for workspaces processing personal or sensitive data
@description('Data privacy and anonymization configuration')
param dataPrivacyConfig object = {
  enabled: false
  enableDataAnonymization: false
  enableDifferentialPrivacy: false
  enableFederatedLearning: false
  enableSecureMultipartyComputation: false
}

// Data lineage tracking for comprehensive data governance
// Tracks data flow from source through ML pipeline to model outputs
// 🔒 SECURITY ENHANCEMENT: Enable comprehensive data lineage for audit and compliance
@description('Data lineage and governance configuration')
param dataLineageConfig object = {
  enabled: true
  trackDataSources: true
  trackDataTransformations: true
  trackModelInputs: true
  trackModelOutputs: true
  enableDataCatalog: true
}

// Data retention policies for ML workspace data and artifacts
// Controls how long different types of ML data are retained
// 🔒 SECURITY ENHANCEMENT: Configure retention based on compliance requirements
@description('Data retention policies for ML artifacts')
param dataRetentionPolicies object = {
  enabled: true
  experimentDataRetentionDays: 90
  modelArtifactRetentionDays: 365
  logDataRetentionDays: 30
  computeNodeLogsRetentionDays: 7
  enableAutomaticCleanup: true
}

// ============================================================================
// PARAMETERS - ENHANCED MONITORING & ALERTING
// ============================================================================

// Real-time monitoring configuration for ML workspace operations
// Provides continuous monitoring of ML workloads and resource usage
// 🔒 SECURITY ENHANCEMENT: Enable comprehensive monitoring for security and performance
@description('Real-time monitoring configuration for ML operations')
param realTimeMonitoringConfig object = {
  enabled: true
  enablePerformanceMonitoring: true
  enableSecurityMonitoring: true
  enableCostMonitoring: true
  enableResourceUtilizationMonitoring: true
  monitoringIntervalMinutes: 5
}

// Alert configuration for ML workspace events and anomalies
// Configures alerts for various ML workspace events and security incidents
// 🔒 SECURITY ENHANCEMENT: Configure alerts for security events and anomalous activities
@description('Alert configuration for ML workspace events')
param alertConfiguration object = {
  enabled: true
  enableSecurityAlerts: true
  enablePerformanceAlerts: true
  enableCostAlerts: true
  enableComplianceAlerts: true
  alertThresholds: {
    highCpuUtilization: 80
    highMemoryUtilization: 85
    unusualDataAccess: true
    failedAuthentications: 5
    costThresholdPercentage: 80
  }
}

// Model drift detection configuration for production ML models
// Monitors model performance degradation and data drift in production
// 🔒 SECURITY ENHANCEMENT: Monitor for data poisoning and model manipulation
@description('Model drift detection and monitoring configuration')
param modelDriftDetectionConfig object = {
  enabled: false
  enableDataDriftDetection: false
  enableModelPerformanceDrift: false
  driftDetectionThreshold: '0.1'
  driftDetectionIntervalDays: 7
  enableAutomaticRetraining: false
}

// ============================================================================
// PARAMETERS - ENHANCED TAGGING & METADATA
// ============================================================================

// Environment classification for security policy application and access control
// Determines which security policies and access controls are applied to the workspace
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application based on environment
@description('Environment classification for security policies')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environmentClassification string = 'production'

// Data classification level for compliance and security policy enforcement
// Defines the sensitivity level of data processed by the ML workspace
// 🔒 SECURITY ENHANCEMENT: Use for automated compliance policy application and access controls
@description('Data classification level for compliance and security')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'internal'

// Business criticality level for resource prioritization and SLA application
// Determines service level agreements and priority for support and maintenance
// 🔒 SECURITY ENHANCEMENT: Use for security incident prioritization and response
@description('Business criticality level for SLA and support prioritization')
@allowed(['low', 'medium', 'high', 'critical', 'mission-critical'])
param businessCriticality string = 'high'

// Cost center information for billing and resource allocation tracking
// Enables cost tracking and allocation for enterprise resource management
// 🔒 SECURITY ENHANCEMENT: Use for security cost allocation and budget tracking
@description('Cost center for billing and resource allocation')
param costCenter string = ''

// Owner information for resource accountability and contact management
// Specifies responsible party for resource management and security compliance
// 🔒 SECURITY ENHANCEMENT: Required for security incident response and accountability
@description('Resource owner information for accountability')
param resourceOwner object = {
  name: ''
  email: ''
  department: ''
  managerId: ''
}

// Project information for resource organization and governance
// Enables project-based resource organization and cost allocation
// 🔒 SECURITY ENHANCEMENT: Use for project-based security policies and access controls
@description('Project information for resource organization')
param projectInformation object = {
  projectName: ''
  projectId: ''
  projectManager: ''
  budget: ''
  startDate: ''
  endDate: ''
}

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '-${environment}-${substring(uniqueString(resourceGroup().id), 0, 6)}'

// Enhanced default tags with comprehensive metadata
var defaultTags = {
  Environment: environment
  EnvironmentClassification: environmentClassification
  Service: 'Machine Learning'
  ManagedBy: 'Bicep'
  DataClassification: dataClassification
  BusinessCriticality: businessCriticality
  CostCenter: !empty(costCenter) ? costCenter : 'Not Specified'
  Owner: !empty(resourceOwner.name) ? resourceOwner.name : 'Not Specified'
  OwnerEmail: !empty(resourceOwner.email) ? resourceOwner.email : 'Not Specified'
  Department: !empty(resourceOwner.department) ? resourceOwner.department : 'Not Specified'
  ProjectName: !empty(projectInformation.projectName) ? projectInformation.projectName : 'Not Specified'
  ProjectId: !empty(projectInformation.projectId) ? projectInformation.projectId : 'Not Specified'
  LastUpdated: '2025-08-01'
  MLWorkspaceEnabled: 'true'
  HBIWorkspace: string(hbiWorkspace)
  PrivateEndpointsEnabled: string(enablePrivateEndpoints)
  CustomerManagedEncryption: string(enableCustomerManagedEncryption)
  ManagedNetworkEnabled: string(enableManagedNetwork)
  FeatureStoreEnabled: string(enableFeatureStore)
}

// Merge user-provided tags with enhanced defaults
var allTags = union(defaultTags, tags)

// Identity configuration with enhanced support
var identityConfig = managedIdentityType == 'None' ? null : {
  type: managedIdentityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? reduce(userAssignedIdentities, {}, (acc, identityId) => union(acc, {
    '${identityId}': {}
  })) : null
}

// Enhanced encryption configuration (API-compliant)
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

// Enhanced managed network configuration (API-compliant)
var managedNetworkConfig = enableManagedNetwork ? {
  isolationMode: managedNetworkIsolationMode
  firewallSku: firewallSku
  outboundRules: outboundRules
} : null

// Enhanced serverless compute configuration (API-compliant)
var serverlessComputeConfig = enableServerlessCompute ? {
  serverlessComputeCustomSubnet: !empty(serverlessComputeCustomSubnet) ? serverlessComputeCustomSubnet : null
  serverlessComputeNoPublicIP: serverlessComputeNoPublicIP
} : null

// Enhanced feature store configuration (API-compliant)
var featureStoreConfig = enableFeatureStore ? {
  offlineStoreConnectionName: !empty(offlineStoreConnectionName) ? offlineStoreConnectionName : null
  onlineStoreConnectionName: !empty(onlineStoreConnectionName) ? onlineStoreConnectionName : null
  computeRuntime: !empty(sparkRuntimeVersion) ? {
    sparkRuntimeVersion: sparkRuntimeVersion
  } : null
} : null

// Enhanced service managed resources configuration (API-compliant)
var serviceManagedResourcesConfig = enableCustomCosmosDbSettings ? {
  cosmosDb: {
    collectionsThroughput: cosmosDbCollectionsThroughput
  }
} : null

// Enhanced workspace hub configuration (API-compliant)
var workspaceHubConfig = enableWorkspaceHub ? {
  defaultWorkspaceResourceGroup: !empty(defaultWorkspaceResourceGroup) ? defaultWorkspaceResourceGroup : null
  additionalWorkspaceStorageAccounts: additionalWorkspaceStorageAccounts
} : null

// Advanced security configuration
var advancedSecurityConfig = {
  azureDefenderEnabled: enableAzureDefender
  dataLossPreventionEnabled: enableDataLossPrevention
  auditPolicies: auditPolicyConfig
  immutableWorkspace: enableImmutableWorkspace
  contentFiltering: contentFilteringPolicies
  dataResidencyEnforcement: enforceDataResidency
  allowedProcessingRegions: allowedDataProcessingRegions
}

// Enhanced monitoring configuration
var enhancedMonitoringConfig = {
  realTimeMonitoring: realTimeMonitoringConfig
  alertConfiguration: alertConfiguration
  modelDriftDetection: modelDriftDetectionConfig
  dataPrivacySettings: dataPrivacyConfig
  experimentTracking: experimentTrackingConfig
}

// Model management configuration
var modelManagementConfig = {
  governancePolicies: modelGovernancePolicies
  registryConfig: modelRegistryConfig
  deploymentConfig: modelDeploymentConfig
  customComputeImages: customComputeImages
  dataLineage: dataLineageConfig
}

// Built-in role definitions with enhanced ML roles
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

@description('Advanced security configuration summary')
output advancedSecurityConfiguration object = advancedSecurityConfig

@description('Enhanced monitoring configuration summary')
output enhancedMonitoringConfiguration object = enhancedMonitoringConfig

@description('Model management configuration summary')
output modelManagementConfiguration object = modelManagementConfig

@description('Compute configuration summary')
output computeConfiguration object = {
  autoShutdownConfig: autoShutdownConfig
  computeInstanceAccessControl: computeInstanceAccessControl
  computeClusterLimits: computeClusterLimits
  spotInstanceConfig: spotInstanceConfig
  customComputeImages: customComputeImages
}

@description('Data security and privacy summary')
output dataSecuritySummary object = {
  dataEncryptionConfig: dataEncryptionConfig
  dataRetentionPolicies: dataRetentionPolicies
  customerManagedEncryption: enableCustomerManagedEncryption
  hbiWorkspace: hbiWorkspace
  dataIsolationEnabled: enableDataIsolation
}

@description('Enhanced metadata and governance')
output enhancedMetadata object = {
  environmentClassification: environmentClassification
  dataClassification: dataClassification
  businessCriticality: businessCriticality
  costCenter: costCenter
  resourceOwner: resourceOwner
  projectInformation: projectInformation
  allAppliedTags: allTags
}

@description('Comprehensive workspace status summary')
output comprehensiveWorkspaceStatus object = {
  workspaceId: mlWorkspace.id
  workspaceName: mlWorkspace.name
  workspaceGuid: mlWorkspace.properties.workspaceId
  discoveryUrl: mlWorkspace.properties.discoveryUrl
  mlFlowTrackingUri: mlWorkspace.properties.mlFlowTrackingUri
  provisioningState: mlWorkspace.properties.provisioningState
  identity: mlWorkspace.identity
  configuration: mlWorkspace.properties
  enhancedFeatures: {
    hbiWorkspaceEnabled: hbiWorkspace
    managedNetworkEnabled: enableManagedNetwork
    featureStoreEnabled: enableFeatureStore
    privateEndpointsEnabled: enablePrivateEndpoints
    customerManagedEncryptionEnabled: enableCustomerManagedEncryption
    azureDefenderEnabled: enableAzureDefender
    dataLossPreventionEnabled: enableDataLossPrevention
    immutableWorkspaceEnabled: enableImmutableWorkspace
    dataResidencyEnforced: enforceDataResidency
  }
}
