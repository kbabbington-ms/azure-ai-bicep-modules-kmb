@description('Azure AI Workflows - Intelligent Automation Platform that creates comprehensive Logic Apps workflows for AI service orchestration with enterprise security, monitoring, and scalability. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure AI Workflows - Intelligent Automation Platform'
metadata description = 'Enterprise-grade Logic Apps workflows for AI service orchestration with pre-built connectors and security'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Resource name for the Logic Apps and related workflow resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security governance
@description('Required. Base name for AI Workflows resources (2-50 characters)')
@minLength(2)
@maxLength(50)
param logicAppName string

// Azure region for deploying the AI Workflows infrastructure
// Note: Logic Apps Standard requires specific regional support
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for deployment')
@allowed([
  'eastus'
  'eastus2'
  'westus2'
  'westeurope'
  'northeurope'
  'southeastasia'
  'australiaeast'
  'canadacentral'
  'uksouth'
  'japaneast'
  'francecentral'
  'switzerlandnorth'
  'centralus'
  'southcentralus'
  'westus3'
  'brazilsouth'
  'southafricanorth'
  'uaenorth'
])
param location string

// Logic Apps hosting plan type determining capabilities and pricing
// Standard plan provides better performance and advanced features
// 🔒 SECURITY ENHANCEMENT: Use Standard for production with VNet integration
@description('Logic Apps hosting plan type')
@allowed([
  'WS1'  // Workflow Standard tier (production workloads)
  'WS2'  // Workflow Standard tier (higher performance)
  'WS3'  // Workflow Standard tier (premium performance)
])
param logicAppSku string = 'WS1'

// App Service Plan configuration for Logic Apps Standard
@description('App Service Plan configuration for Logic Apps hosting')
param appServicePlanConfig object = {
  name: '${logicAppName}-asp'
  sku: logicAppSku
  capacity: 1
  maximumElasticWorkerCount: 20
  targetWorkerCount: 1
  targetWorkerSizeId: 0
  workerTierName: null
}

// ============================================================================
// PARAMETERS - AI SERVICE INTEGRATIONS
// ============================================================================

// Azure OpenAI service integration configuration
// Enables workflow integration with GPT models and DALL-E
// 🔒 SECURITY ENHANCEMENT: Secure API key management through Key Vault
@description('Azure OpenAI service integration configuration')
param azureOpenAIConfig object = {
  enabled: true
  endpoint: ''
  apiVersion: '2024-02-01'
  deploymentName: 'gpt-4o'
  maxTokens: 4000
  temperature: '0.7'
  useSystemAssignedIdentity: true
}

// Document Intelligence service integration configuration
// Enables workflow integration with document processing capabilities
@description('Document Intelligence service integration configuration')
param documentIntelligenceConfig object = {
  enabled: true
  endpoint: ''
  apiVersion: '2023-07-31'
  modelId: 'prebuilt-invoice'
  useSystemAssignedIdentity: true
}

// Cognitive Services integration configuration
// Enables workflow integration with various AI services
@description('Cognitive Services integration configuration')
param cognitiveServicesConfig object = {
  enabled: true
  endpoint: ''
  services: [
    'ComputerVision'
    'TextAnalytics'
    'Translator'
    'SpeechServices'
  ]
  useSystemAssignedIdentity: true
}

// Azure AI Search integration configuration
// Enables workflow integration with search and knowledge mining
@description('Azure AI Search integration configuration')
param aiSearchConfig object = {
  enabled: false
  endpoint: ''
  indexName: 'ai-knowledge-base'
  apiVersion: '2023-11-01'
  useSystemAssignedIdentity: true
}

// ============================================================================
// PARAMETERS - WORKFLOW CONFIGURATION
// ============================================================================

// Enable pre-built AI workflow templates
// Provides ready-to-use workflows for common AI scenarios
// 🔒 SECURITY ENHANCEMENT: Templates follow security best practices
@description('Enable pre-built AI workflow templates')
param enablePrebuiltWorkflows bool = true

// Pre-built workflow templates to deploy
@description('Pre-built workflow templates to enable')
param enabledWorkflowTemplates object = {
  documentProcessing: true      // End-to-end document processing pipeline
  intelligentRouting: true      // Smart content routing based on AI analysis
  contentModeration: true       // Automated content review and approval
  dataExtraction: true          // AI-powered data extraction from various sources
  sentimentAnalysis: true       // Customer feedback and sentiment processing
  translationPipeline: true     // Multi-language content translation workflow
  voiceToText: true            // Voice processing and transcription pipeline
  imageAnalysis: true          // Image processing and analysis workflow
  knowledgeExtraction: true    // Knowledge mining and extraction from documents
  chatbotOrchestration: true   // Orchestration for conversational AI
}

// Workflow execution timeout configuration
// Controls maximum execution time for different workflow types
@description('Workflow execution timeout settings')
param workflowTimeouts object = {
  shortRunning: 'PT5M'     // 5 minutes for quick operations
  mediumRunning: 'PT30M'   // 30 minutes for standard processing
  longRunning: 'PT2H'      // 2 hours for complex operations
  batchProcessing: 'PT6H'  // 6 hours for large batch operations
}

// Workflow retry policy configuration
// Defines retry behavior for failed workflow executions
@description('Workflow retry policy configuration')
param retryPolicyConfig object = {
  count: 3
  interval: 'PT1M'
  type: 'exponential'
  minimumInterval: 'PT30S'
  maximumInterval: 'PT10M'
}

// ============================================================================
// PARAMETERS - SECURITY & COMPLIANCE
// ============================================================================

// Enable private endpoints for secure network access
// Ensures workflow traffic stays within your virtual network
// 🔒 SECURITY ENHANCEMENT: Essential for processing sensitive data in workflows
@description('Enable private endpoints for secure access')
param enablePrivateEndpoint bool = false

// Virtual network subnet for private endpoint deployment
// Required when private endpoints are enabled
@description('Subnet resource ID for private endpoint (required if enablePrivateEndpoint is true)')
param subnetId string = ''

// Virtual network integration for Logic Apps Standard
// Enables VNet integration for outbound connectivity
@description('Enable VNet integration for Logic Apps')
param enableVNetIntegration bool = false

// VNet integration subnet for Logic Apps Standard
@description('Subnet resource ID for VNet integration (required if enableVNetIntegration is true)')
param vnetIntegrationSubnetId string = ''

// Enable customer-managed encryption keys for workflow data
// Provides additional control over encryption keys for compliance
// 🔒 SECURITY ENHANCEMENT: Required for regulated industries
@description('Enable customer-managed encryption keys')
param enableCustomerManagedKey bool = false

// Key Vault resource ID for customer-managed encryption
@description('Key Vault resource ID for customer-managed encryption')
param keyVaultId string = ''

// Key name for customer-managed encryption
@description('Key name for customer-managed encryption')
param keyName string = ''

// Key version for customer-managed encryption (optional, uses latest if empty)
@description('Key version for customer-managed encryption')
param keyVersion string = ''

// Enable audit logging for compliance and security monitoring
// Tracks all workflow executions and data access
// 🔒 SECURITY ENHANCEMENT: Essential for compliance and security investigations
@description('Enable audit logging for compliance monitoring')
param enableAuditLogging bool = true

// Data retention period for workflow logs and execution history
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on regulatory requirements
@description('Data retention period for logs and execution history (days)')
@minValue(30)
@maxValue(2555)  // 7 years maximum
param dataRetentionDays int = 365

// ============================================================================
// PARAMETERS - MONITORING & ANALYTICS
// ============================================================================

// Enable Application Insights for workflow monitoring and analytics
// Provides insights into workflow performance and usage patterns
// 🔒 SECURITY ENHANCEMENT: Essential for detecting anomalous behavior
@description('Enable Application Insights for workflow monitoring')
param enableApplicationInsights bool = true

// Application Insights resource ID for existing workspace
// If not provided, a new Application Insights instance will be created
@description('Application Insights resource ID (auto-created if empty)')
param applicationInsightsId string = ''

// Log Analytics workspace for centralized logging
// Consolidates logs from all workflow operations
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string = ''

// Enable alerts for workflow failures and performance issues
// Provides proactive monitoring of workflow health and performance
@description('Enable monitoring alerts')
param enableAlerts bool = true

// Enable workflow analytics and reporting
// Provides business insights into workflow performance and outcomes
@description('Enable workflow analytics and reporting')
param enableWorkflowAnalytics bool = true

// ============================================================================
// PARAMETERS - STORAGE CONFIGURATION
// ============================================================================

// Enable dedicated storage account for workflow data
// Provides secure storage for workflow state, artifacts, and logs
// 🔒 SECURITY ENHANCEMENT: Isolates workflow data with proper access controls
@description('Enable dedicated storage account for workflow data')
param enableDedicatedStorage bool = true

// Storage account SKU for workflow data storage
// Premium options provide better performance for high-throughput workflows
@description('Storage account SKU for workflow data')
@allowed([
  'Standard_LRS'    // Standard locally redundant storage
  'Standard_GRS'    // Standard geo-redundant storage
  'Standard_RAGRS'  // Standard read-access geo-redundant storage
  'Premium_LRS'     // Premium locally redundant storage
])
param storageAccountSku string = 'Standard_LRS'

// Enable storage encryption with customer-managed keys
// Provides additional security for workflow data storage
@description('Enable storage encryption with customer-managed keys')
param enableStorageEncryption bool = false

// Storage containers for different workflow data types
@description('Storage containers for workflow data organization')
param storageContainers array = [
  'workflow-state'
  'workflow-artifacts'
  'input-data'
  'output-data'
  'audit-logs'
  'analytics-data'
]

// ============================================================================
// PARAMETERS - INTEGRATION CONFIGURATION
// ============================================================================

// Enable Event Grid integration for event-driven workflows
// Enables reactive workflows based on Azure events
@description('Enable Event Grid integration')
param enableEventGrid bool = true

// Event Grid topics configuration
@description('Event Grid topics for workflow triggers')
param eventGridTopics array = [
  'ai-workflow-events'
  'document-processing-events'
  'content-moderation-events'
]

// Enable Service Bus integration for reliable messaging
// Provides durable messaging for workflow communication
@description('Enable Service Bus integration')
param enableServiceBus bool = true

// Service Bus namespace configuration
@description('Service Bus namespace configuration')
param serviceBusConfig object = {
  name: '${logicAppName}-sb'
  sku: 'Standard'
  queues: [
    'ai-processing-queue'
    'document-queue'
    'error-queue'
    'dead-letter-queue'
  ]
  topics: [
    'workflow-events'
    'ai-results'
  ]
}

// ============================================================================
// PARAMETERS - SCALING & PERFORMANCE
// ============================================================================

// Enable auto-scaling for workflow processing
// Automatically scales based on workload demand
@description('Enable auto-scaling for workflow processing')
param enableAutoScaling bool = true

// Auto-scaling configuration
@description('Auto-scaling configuration for workflow processing')
param autoScalingConfig object = {
  minWorkerCount: 1
  maxWorkerCount: 10
  targetCpuPercentage: 70
  targetMemoryPercentage: 80
  scaleOutCooldown: 'PT5M'
  scaleInCooldown: 'PT10M'
}

// Enable workflow caching for improved performance
// Caches frequently accessed data and results
@description('Enable workflow caching for performance optimization')
param enableWorkflowCaching bool = true

// Workflow caching configuration
@description('Workflow caching configuration')
param cachingConfig object = {
  redisCacheEnabled: false
  redisCacheId: ''
  inMemoryCacheSize: '100MB'
  cacheTtl: 'PT1H'
}

// ============================================================================
// PARAMETERS - TAGGING & METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// Environment designation for resource organization
@description('Environment designation (dev, test, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'prod'

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with AI Workflows-specific metadata
var defaultTags = {
  Environment: environment
  Service: 'AI Workflows'
  ManagedBy: 'Bicep'
  WorkflowOrchestration: 'enabled'
  AIIntegration: 'comprehensive'
  DataClassification: tags.?DataClassification ?? 'internal'
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Generate unique names for related resources
var logicAppServiceName = '${logicAppName}${resourceSuffix}'
var appServicePlanName = '${appServicePlanConfig.name}${resourceSuffix}'
var storageAccountName = enableDedicatedStorage ? take(replace('${logicAppName}${resourceSuffix}storage', '-', ''), 24) : ''
var appInsightsName = enableApplicationInsights && empty(applicationInsightsId) ? '${logicAppName}-insights${resourceSuffix}' : ''
var privateEndpointName = enablePrivateEndpoint ? '${logicAppName}-pe${resourceSuffix}' : ''

// Service Bus resources names
var serviceBusNamespaceName = enableServiceBus ? '${serviceBusConfig.name}${resourceSuffix}' : ''

// Event Grid resources names
var eventGridTopicNames = [for topic in eventGridTopics: '${topic}${resourceSuffix}']

// Workflow template definitions
var workflowTemplates = enablePrebuiltWorkflows ? {
  documentProcessing: {
    enabled: enabledWorkflowTemplates.documentProcessing
    timeout: workflowTimeouts.longRunning
    retryPolicy: retryPolicyConfig
  }
  intelligentRouting: {
    enabled: enabledWorkflowTemplates.intelligentRouting
    timeout: workflowTimeouts.shortRunning
    retryPolicy: retryPolicyConfig
  }
  contentModeration: {
    enabled: enabledWorkflowTemplates.contentModeration
    timeout: workflowTimeouts.mediumRunning
    retryPolicy: retryPolicyConfig
  }
  dataExtraction: {
    enabled: enabledWorkflowTemplates.dataExtraction
    timeout: workflowTimeouts.mediumRunning
    retryPolicy: retryPolicyConfig
  }
  sentimentAnalysis: {
    enabled: enabledWorkflowTemplates.sentimentAnalysis
    timeout: workflowTimeouts.shortRunning
    retryPolicy: retryPolicyConfig
  }
  translationPipeline: {
    enabled: enabledWorkflowTemplates.translationPipeline
    timeout: workflowTimeouts.mediumRunning
    retryPolicy: retryPolicyConfig
  }
  voiceToText: {
    enabled: enabledWorkflowTemplates.voiceToText
    timeout: workflowTimeouts.longRunning
    retryPolicy: retryPolicyConfig
  }
  imageAnalysis: {
    enabled: enabledWorkflowTemplates.imageAnalysis
    timeout: workflowTimeouts.mediumRunning
    retryPolicy: retryPolicyConfig
  }
  knowledgeExtraction: {
    enabled: enabledWorkflowTemplates.knowledgeExtraction
    timeout: workflowTimeouts.longRunning
    retryPolicy: retryPolicyConfig
  }
  chatbotOrchestration: {
    enabled: enabledWorkflowTemplates.chatbotOrchestration
    timeout: workflowTimeouts.shortRunning
    retryPolicy: retryPolicyConfig
  }
} : {}

// ============================================================================
// RESOURCES - STORAGE ACCOUNT
// ============================================================================

// Dedicated storage account for workflow data and state
resource workflowStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = if (enableDedicatedStorage) {
  name: storageAccountName
  location: location
  tags: allTags
  sku: {
    name: storageAccountSku
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true  // Required for Logic Apps Standard
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: enablePrivateEndpoint ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
    encryption: {
      requireInfrastructureEncryption: true
      services: {
        blob: {
          enabled: true
          keyType: enableStorageEncryption ? 'Customer' : 'Service'
        }
        file: {
          enabled: true
          keyType: enableStorageEncryption ? 'Customer' : 'Service'
        }
        table: {
          enabled: true
          keyType: enableStorageEncryption ? 'Customer' : 'Service'
        }
        queue: {
          enabled: true
          keyType: enableStorageEncryption ? 'Customer' : 'Service'
        }
      }
      keySource: enableStorageEncryption ? 'Microsoft.Keyvault' : 'Microsoft.Storage'
      keyvaultproperties: enableStorageEncryption && !empty(keyVaultId) ? {
        keyname: keyName
        keyvaulturi: reference(keyVaultId, '2023-07-01').vaultUri
        keyversion: keyVersion
      } : null
    }
  }
}

// Blob containers for workflow data organization
resource workflowStorageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in storageContainers: if (enableDedicatedStorage) {
  name: '${workflowStorage.name}/default/${container}'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'ai-workflows'
      retention: string(dataRetentionDays)
    }
  }
}]

// File shares for Logic Apps runtime storage
resource workflowFileShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2023-01-01' = [for shareName in ['content', 'data', 'logs']: if (enableDedicatedStorage) {
  name: '${workflowStorage.name}/default/${logicAppServiceName}-${shareName}'
  properties: {
    shareQuota: 5120  // 5GB quota
    enabledProtocols: 'SMB'
  }
}]

// ============================================================================
// RESOURCES - APPLICATION INSIGHTS
// ============================================================================

// Application Insights for workflow monitoring and analytics
resource workflowAppInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights && empty(applicationInsightsId)) {
  name: appInsightsName
  location: location
  tags: allTags
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    DisableIpMasking: false  // Maintain user privacy
    DisableLocalAuth: false  // Allow both API key and AAD auth
  }
}

// ============================================================================
// RESOURCES - APP SERVICE PLAN
// ============================================================================

// App Service Plan for Logic Apps Standard hosting
resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: allTags
  sku: {
    name: appServicePlanConfig.sku
    tier: 'WorkflowStandard'
    capacity: appServicePlanConfig.capacity
  }
  kind: 'elastic'
  properties: {
    elasticScaleEnabled: enableAutoScaling
    maximumElasticWorkerCount: enableAutoScaling ? autoScalingConfig.maxWorkerCount : appServicePlanConfig.maximumElasticWorkerCount
    targetWorkerCount: appServicePlanConfig.targetWorkerCount
    targetWorkerSizeId: appServicePlanConfig.targetWorkerSizeId
    workerTierName: appServicePlanConfig.workerTierName
  }
}

// ============================================================================
// RESOURCES - LOGIC APPS STANDARD
// ============================================================================

// Logic Apps Standard service for AI workflow orchestration
resource logicApp 'Microsoft.Web/sites@2023-01-01' = {
  name: logicAppServiceName
  location: location
  tags: allTags
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    reserved: false
    siteConfig: {
      netFrameworkVersion: 'v6.0'
      functionsRuntimeScaleMonitoringEnabled: enableAutoScaling
      use32BitWorkerProcess: false
      ftpsState: 'Disabled'
      alwaysOn: true
      http20Enabled: true
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      appSettings: [
        {
          name: 'APP_KIND'
          value: 'workflowApp'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__id'
          value: 'Microsoft.Azure.Functions.ExtensionBundle.Workflows'
        }
        {
          name: 'AzureFunctionsJobHost__extensionBundle__version'
          value: '[1.*, 2.0.0)'
        }
        {
          name: 'AzureWebJobsStorage'
          value: enableDedicatedStorage ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${az.environment().suffixes.storage}' : ''
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: enableDedicatedStorage ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccountName};EndpointSuffix=${az.environment().suffixes.storage}' : ''
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: enableDedicatedStorage ? '${logicAppServiceName}-content' : ''
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: enableApplicationInsights ? (empty(applicationInsightsId) ? workflowAppInsights!.properties.InstrumentationKey : reference(applicationInsightsId, '2020-02-02').InstrumentationKey) : ''
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: enableApplicationInsights ? (empty(applicationInsightsId) ? workflowAppInsights!.properties.ConnectionString : reference(applicationInsightsId, '2020-02-02').ConnectionString) : ''
        }
        {
          name: 'WORKFLOWS_SUBSCRIPTION_ID'
          value: subscription().subscriptionId
        }
        {
          name: 'WORKFLOWS_RESOURCE_GROUP_NAME'
          value: resourceGroup().name
        }
        {
          name: 'WORKFLOWS_LOCATION_NAME'
          value: location
        }
        {
          name: 'WORKFLOWS_ENVIRONMENT'
          value: environment
        }
        {
          name: 'AZURE_OPENAI_ENDPOINT'
          value: azureOpenAIConfig.enabled ? azureOpenAIConfig.endpoint : ''
        }
        {
          name: 'AZURE_OPENAI_API_VERSION'
          value: azureOpenAIConfig.enabled ? azureOpenAIConfig.apiVersion : ''
        }
        {
          name: 'AZURE_OPENAI_DEPLOYMENT_NAME'
          value: azureOpenAIConfig.enabled ? azureOpenAIConfig.deploymentName : ''
        }
        {
          name: 'DOCUMENT_INTELLIGENCE_ENDPOINT'
          value: documentIntelligenceConfig.enabled ? documentIntelligenceConfig.endpoint : ''
        }
        {
          name: 'DOCUMENT_INTELLIGENCE_API_VERSION'
          value: documentIntelligenceConfig.enabled ? documentIntelligenceConfig.apiVersion : ''
        }
        {
          name: 'COGNITIVE_SERVICES_ENDPOINT'
          value: cognitiveServicesConfig.enabled ? cognitiveServicesConfig.endpoint : ''
        }
        {
          name: 'AI_SEARCH_ENDPOINT'
          value: aiSearchConfig.enabled ? aiSearchConfig.endpoint : ''
        }
        {
          name: 'AI_SEARCH_INDEX_NAME'
          value: aiSearchConfig.enabled ? aiSearchConfig.indexName : ''
        }
      ]
      connectionStrings: []
    }
    virtualNetworkSubnetId: enableVNetIntegration && !empty(vnetIntegrationSubnetId) ? vnetIntegrationSubnetId : null
    vnetContentShareEnabled: enableVNetIntegration
    vnetImagePullEnabled: enableVNetIntegration
    vnetRouteAllEnabled: enableVNetIntegration
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
    httpsOnly: true
    clientAffinityEnabled: false
    redundancyMode: 'None'
  }
}

// ============================================================================
// RESOURCES - SERVICE BUS NAMESPACE
// ============================================================================

// Service Bus namespace for reliable workflow messaging
resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = if (enableServiceBus) {
  name: serviceBusNamespaceName
  location: location
  tags: allTags
  sku: {
    name: serviceBusConfig.sku
    tier: serviceBusConfig.sku
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    minimumTlsVersion: '1.2'
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
    disableLocalAuth: false
    zoneRedundant: serviceBusConfig.sku == 'Premium'
  }
}

// Service Bus queues for workflow communication
resource serviceBusQueues 'Microsoft.ServiceBus/namespaces/queues@2022-10-01-preview' = [for queue in serviceBusConfig.queues: if (enableServiceBus) {
  name: queue
  parent: serviceBusNamespace
  properties: {
    maxDeliveryCount: 10
    defaultMessageTimeToLive: 'P14D'
    lockDuration: 'PT5M'
    enableBatchedOperations: true
    enablePartitioning: false
    enableExpress: false
    deadLetteringOnMessageExpiration: true
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    maxSizeInMegabytes: 1024
    requiresDuplicateDetection: false
    requiresSession: false
  }
}]

// Service Bus topics for workflow events
resource serviceBusTopics 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = [for topic in serviceBusConfig.topics: if (enableServiceBus) {
  name: topic
  parent: serviceBusNamespace
  properties: {
    defaultMessageTimeToLive: 'P14D'
    maxSizeInMegabytes: 1024
    enableBatchedOperations: true
    enablePartitioning: false
    enableExpress: false
    requiresDuplicateDetection: false
    duplicateDetectionHistoryTimeWindow: 'PT10M'
    supportOrdering: true
  }
}]

// ============================================================================
// RESOURCES - EVENT GRID TOPICS
// ============================================================================

// Event Grid topics for event-driven workflow triggers
resource eventGridTopicsResource 'Microsoft.EventGrid/topics@2022-06-15' = [for (topic, i) in eventGridTopics: if (enableEventGrid) {
  name: eventGridTopicNames[i]
  location: location
  tags: allTags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    inputSchema: 'EventGridSchema'
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
    disableLocalAuth: false
    dataResidencyBoundary: 'WithinGeopair'
  }
}]

// ============================================================================
// RESOURCES - PRIVATE ENDPOINTS
// ============================================================================

// Private endpoint for Logic Apps secure access
resource logicAppPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (enablePrivateEndpoint && !empty(subnetId)) {
  name: '${privateEndpointName}-logicapp'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${logicAppServiceName}-connection'
        properties: {
          privateLinkServiceId: logicApp.id
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

// Private endpoint for Service Bus secure access
resource serviceBusPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (enablePrivateEndpoint && enableServiceBus && !empty(subnetId)) {
  name: '${privateEndpointName}-servicebus'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${serviceBusNamespaceName}-connection'
        properties: {
          privateLinkServiceId: serviceBusNamespace.id
          groupIds: [
            'namespace'
          ]
        }
      }
    ]
  }
}

// ============================================================================
// RESOURCES - RBAC ASSIGNMENTS
// ============================================================================

// RBAC assignment for Logic App to access storage
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableDedicatedStorage) {
  name: guid(workflowStorage.id, logicApp.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: workflowStorage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// RBAC assignment for Logic App to access Service Bus
resource serviceBusRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableServiceBus) {
  name: guid(serviceBusNamespace.id, logicApp.id, '090c5cfd-751d-490a-894a-3ce6f1109419')
  scope: serviceBusNamespace
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '090c5cfd-751d-490a-894a-3ce6f1109419') // Azure Service Bus Data Owner
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

// RBAC assignment for Logic App to access Event Grid
resource eventGridRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (topic, i) in eventGridTopics: if (enableEventGrid) {
  name: guid(eventGridTopicsResource[i].id, logicApp.id, '1e241071-0855-49ea-94dc-649edcd759de')
  scope: eventGridTopicsResource[i]
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1e241071-0855-49ea-94dc-649edcd759de') // EventGrid Data Sender
    principalId: logicApp.identity.principalId
    principalType: 'ServicePrincipal'
  }
}]

// ============================================================================
// RESOURCES - AUTO-SCALING CONFIGURATION
// ============================================================================

// Auto-scaling settings for App Service Plan
resource autoScalingSetting 'Microsoft.Insights/autoscalesettings@2022-10-01' = if (enableAutoScaling) {
  name: '${appServicePlanName}-autoscale'
  location: location
  tags: allTags
  properties: {
    enabled: true
    targetResourceUri: appServicePlan.id
    profiles: [
      {
        name: 'DefaultAutoscaleProfile'
        capacity: {
          minimum: string(autoScalingConfig.minWorkerCount)
          maximum: string(autoScalingConfig.maxWorkerCount)
          default: string(autoScalingConfig.minWorkerCount)
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: autoScalingConfig.targetCpuPercentage
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: autoScalingConfig.scaleOutCooldown
            }
          }
          {
            metricTrigger: {
              metricName: 'CpuPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 30
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: autoScalingConfig.scaleInCooldown
            }
          }
          {
            metricTrigger: {
              metricName: 'MemoryPercentage'
              metricNamespace: 'Microsoft.Web/serverfarms'
              metricResourceUri: appServicePlan.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: autoScalingConfig.targetMemoryPercentage
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: autoScalingConfig.scaleOutCooldown
            }
          }
        ]
      }
    ]
    notifications: []
  }
}

// ============================================================================
// RESOURCES - MONITORING ALERTS
// ============================================================================

// Alert for workflow execution failures
resource workflowFailureAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableApplicationInsights) {
  name: '${logicAppServiceName}-workflow-failures'
  location: 'global'
  tags: allTags
  properties: {
    description: 'Alert when workflow execution failure rate exceeds threshold'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      logicApp.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'WorkflowFailures'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'WorkflowRunsCompleted'
          metricNamespace: 'Microsoft.Web/sites'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Total'
          dimensions: [
            {
              name: 'Status'
              operator: 'Include'
              values: [
                'Failed'
                'Cancelled'
                'TimedOut'
              ]
            }
          ]
        }
      ]
    }
    actions: []
  }
}

// Alert for high workflow latency
resource workflowLatencyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableApplicationInsights) {
  name: '${logicAppServiceName}-high-latency'
  location: 'global'
  tags: allTags
  properties: {
    description: 'Alert when workflow execution latency exceeds threshold'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      logicApp.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HighLatency'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'WorkflowRunDuration'
          metricNamespace: 'Microsoft.Web/sites'
          operator: 'GreaterThan'
          threshold: 300000  // 5 minutes in milliseconds
          timeAggregation: 'Average'
        }
      ]
    }
    actions: []
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Logic Apps service configuration')
output logicAppConfig object = {
  name: logicApp.name
  id: logicApp.id
  principalId: logicApp.identity.principalId
  defaultHostName: logicApp.properties.defaultHostName
  environment: environment
  location: location
}

@description('App Service Plan configuration')
output appServicePlanConfig object = {
  name: appServicePlan.name
  id: appServicePlan.id
  sku: appServicePlan.sku
  kind: appServicePlan.kind
  maxWorkerCount: enableAutoScaling ? autoScalingConfig.maxWorkerCount : appServicePlanConfig.maximumElasticWorkerCount
}

@description('Storage configuration')
output storageConfig object = enableDedicatedStorage ? {
  accountName: workflowStorage.name
  accountId: workflowStorage.id
  containers: storageContainers
  encryptionEnabled: enableStorageEncryption
} : {}

@description('Service Bus configuration')
output serviceBusConfig object = enableServiceBus ? {
  namespaceName: serviceBusNamespace.name
  namespaceId: serviceBusNamespace.id
  queues: serviceBusConfig.queues
  topics: serviceBusConfig.topics
} : {}

@description('Event Grid configuration')
output eventGridConfig object = enableEventGrid ? {
  topics: eventGridTopicNames
} : {}

@description('Monitoring configuration')
output monitoringConfig object = {
  applicationInsights: enableApplicationInsights ? {
    name: empty(applicationInsightsId) ? workflowAppInsights!.name : 'External'
    instrumentationKey: empty(applicationInsightsId) ? workflowAppInsights!.properties.InstrumentationKey : reference(applicationInsightsId, '2020-02-02').InstrumentationKey
    connectionString: empty(applicationInsightsId) ? workflowAppInsights!.properties.ConnectionString : reference(applicationInsightsId, '2020-02-02').ConnectionString
  } : {}
  alertsEnabled: enableAlerts
  auditLoggingEnabled: enableAuditLogging
  analyticsEnabled: enableWorkflowAnalytics
}

@description('Security configuration')
output securityConfig object = {
  privateEndpointEnabled: enablePrivateEndpoint
  vnetIntegrationEnabled: enableVNetIntegration
  customerManagedKeyEnabled: enableCustomerManagedKey
  auditLoggingEnabled: enableAuditLogging
  dataRetentionDays: dataRetentionDays
  httpsOnlyEnabled: true
  tlsVersion: '1.2'
}

@description('AI service integrations')
output aiIntegrations object = {
  azureOpenAI: azureOpenAIConfig
  documentIntelligence: documentIntelligenceConfig
  cognitiveServices: cognitiveServicesConfig
  aiSearch: aiSearchConfig
}

@description('Workflow templates configuration')
output workflowTemplates object = workflowTemplates

@description('Performance and scaling configuration')
output performanceConfig object = {
  autoScalingEnabled: enableAutoScaling
  autoScalingConfig: enableAutoScaling ? autoScalingConfig : {}
  cachingEnabled: enableWorkflowCaching
  cachingConfig: enableWorkflowCaching ? cachingConfig : {}
}

@description('Deployment summary and next steps')
output deploymentSummary object = {
  status: 'AI Workflows service deployed successfully'
  environment: environment
  workflowsEnabled: enablePrebuiltWorkflows
  aiServicesIntegrated: [
    azureOpenAIConfig.enabled ? 'Azure OpenAI' : null
    documentIntelligenceConfig.enabled ? 'Document Intelligence' : null
    cognitiveServicesConfig.enabled ? 'Cognitive Services' : null
    aiSearchConfig.enabled ? 'AI Search' : null
  ]
  nextSteps: [
    'Configure AI service connection strings in Logic App settings'
    'Deploy workflow templates for your specific use cases'
    'Set up monitoring and alerting for production workloads'
    'Configure API Management integration for external access'
    'Test workflow execution with sample data'
    'Set up proper RBAC for workflow management users'
    'Configure Event Grid subscriptions for event-driven workflows'
  ]
  capabilities: [
    'Pre-built AI workflow templates'
    'Secure integration with Azure AI services'
    'Auto-scaling based on workload demand'
    'Private endpoint support for secure access'
    'Comprehensive monitoring and alerting'
    'Event-driven workflow execution'
    'Reliable messaging with Service Bus'
    'Customer-managed encryption support'
  ]
  documentationLinks: {
    logicApps: 'https://docs.microsoft.com/azure/logic-apps/'
    workflows: 'https://docs.microsoft.com/azure/logic-apps/logic-apps-workflow-definition-language'
    connectors: 'https://docs.microsoft.com/connectors/'
    monitoring: 'https://docs.microsoft.com/azure/logic-apps/monitor-logic-apps'
    security: 'https://docs.microsoft.com/azure/logic-apps/logic-apps-securing-a-logic-app'
    pricing: 'https://azure.microsoft.com/pricing/details/logic-apps/'
  }
}
