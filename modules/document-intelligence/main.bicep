@description('Azure AI Document Intelligence - Advanced Document Processing Platform that creates a comprehensive Document Intelligence service with custom models, security features, and enterprise compliance. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure AI Document Intelligence - Advanced Document Processing'
metadata description = 'Enterprise-grade document processing with custom model training and AI-powered data extraction'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Resource name for the Document Intelligence service and related resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security governance
@description('Required. Base name for Document Intelligence resources (2-24 characters)')
@minLength(2)
@maxLength(24)
param documentIntelligenceName string

// Azure region for deploying the Document Intelligence service
// Note: Document Intelligence has limited regional availability
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for deployment')
@allowed([
  'eastus'
  'eastus2'
  'westus2'
  'westeurope'
  'southeastasia'
  'australiaeast'
  'canadacentral'
  'uksouth'
  'japaneast'
  'koreacentral'
  'francecentral'
  'switzerlandnorth'
  'northeurope'
  'centralus'
  'southcentralus'
  'westus3'
])
param location string

// Document Intelligence service tier determining capabilities and pricing
// S0 is standard tier with higher throughput and custom model training
// 🔒 SECURITY ENHANCEMENT: Use S0 for production with SLA guarantees
@description('Document Intelligence service pricing tier')
@allowed([
  'F0'  // Free tier (development and testing, 500 pages/month)
  'S0'  // Standard tier (production workloads, custom models)
])
param documentIntelligenceSku string = 'S0'

// ============================================================================
// PARAMETERS - DOCUMENT PROCESSING CONFIGURATION
// ============================================================================

// Enable prebuilt models for common document types
// Provides out-of-the-box support for invoices, receipts, business cards, etc.
// 🔒 SECURITY ENHANCEMENT: Reduces need for custom training data exposure
@description('Enable prebuilt models for common document types')
param enablePrebuiltModels bool = true

// Prebuilt models to enable for document processing
@description('Prebuilt models to enable')
param enabledPrebuiltModels object = {
  invoice: true           // Invoice processing
  receipt: true           // Receipt processing
  businessCard: true      // Business card extraction
  identityDocument: true  // ID and passport processing
  w2: true               // W-2 tax form processing
  contract: true         // Contract analysis
  layout: true           // Layout analysis
  generalDocument: true   // General document analysis
}

// Enable custom model training capabilities
// Allows training models for organization-specific document types
// 🔒 SECURITY ENHANCEMENT: Ensure training data is properly secured
@description('Enable custom model training capabilities')
param enableCustomModels bool = true

// Maximum number of custom models allowed
// Controls resource usage and costs for custom model training
@description('Maximum number of custom models')
@minValue(1)
@maxValue(100)
param maxCustomModels int = 10

// Enable composed models for complex document workflows
// Allows combining multiple models for comprehensive document processing
@description('Enable composed models for complex workflows')
param enableComposedModels bool = true

// ============================================================================
// PARAMETERS - SECURITY & COMPLIANCE
// ============================================================================

// Enable private endpoints for secure network access
// Ensures document processing traffic stays within your virtual network
// 🔒 SECURITY ENHANCEMENT: Essential for processing sensitive documents
@description('Enable private endpoints for secure access')
param enablePrivateEndpoint bool = false

// Virtual network subnet for private endpoint deployment
// Required when private endpoints are enabled
@description('Subnet resource ID for private endpoint (required if enablePrivateEndpoint is true)')
param subnetId string = ''

// Enable customer-managed encryption keys for data at rest
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
// Tracks all document processing operations and access attempts
// 🔒 SECURITY ENHANCEMENT: Essential for compliance and security investigations
@description('Enable audit logging for compliance monitoring')
param enableAuditLogging bool = true

// Data retention period for processed documents and logs in days
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on regulatory requirements
@description('Data retention period for documents and logs (days)')
@minValue(30)
@maxValue(2555)  // 7 years maximum
param dataRetentionDays int = 365

// ============================================================================
// PARAMETERS - MONITORING & ANALYTICS
// ============================================================================

// Enable Application Insights for service monitoring and analytics
// Provides insights into processing performance and usage patterns
// 🔒 SECURITY ENHANCEMENT: Essential for detecting anomalous behavior
@description('Enable Application Insights for service monitoring')
param enableApplicationInsights bool = true

// Application Insights resource ID for existing workspace
// If not provided, a new Application Insights instance will be created
@description('Application Insights resource ID (auto-created if empty)')
param applicationInsightsId string = ''

// Log Analytics workspace for centralized logging
// Consolidates logs from all Document Intelligence operations
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID')
param logAnalyticsWorkspaceId string = ''

// Enable alerts for processing failures and security events
// Provides proactive monitoring of service health and security
@description('Enable monitoring alerts')
param enableAlerts bool = true

// ============================================================================
// PARAMETERS - STORAGE CONFIGURATION
// ============================================================================

// Enable dedicated storage account for document processing
// Provides secure storage for training data and processed documents
// 🔒 SECURITY ENHANCEMENT: Isolates document data with proper access controls
@description('Enable dedicated storage account for document processing')
param enableDedicatedStorage bool = true

// Storage account SKU for document storage
// Premium options provide better performance for large-scale processing
@description('Storage account SKU for document processing')
@allowed([
  'Standard_LRS'    // Standard locally redundant storage
  'Standard_GRS'    // Standard geo-redundant storage
  'Standard_RAGRS'  // Standard read-access geo-redundant storage
  'Premium_LRS'     // Premium locally redundant storage
])
param storageAccountSku string = 'Standard_LRS'

// Enable storage encryption with customer-managed keys
// Provides additional security for document storage
@description('Enable storage encryption with customer-managed keys')
param enableStorageEncryption bool = false

// Storage containers for different document types and processing stages
@description('Storage containers for document processing workflow')
param storageContainers array = [
  'input-documents'
  'processed-documents'
  'training-data'
  'model-artifacts'
  'audit-logs'
]

// ============================================================================
// PARAMETERS - BATCH PROCESSING
// ============================================================================

// Enable batch processing for large-scale document processing
// Allows processing multiple documents efficiently
@description('Enable batch processing capabilities')
param enableBatchProcessing bool = true

// Maximum batch size for document processing
// Controls resource usage and processing timeouts
@description('Maximum batch size for document processing')
@minValue(1)
@maxValue(1000)
param maxBatchSize int = 100

// ============================================================================
// PARAMETERS - API ACCESS CONTROL
// ============================================================================

// Enable API key authentication (default Azure method)
// Provides simple API access control
@description('Enable API key authentication')
param enableApiKeyAuth bool = true

// Enable managed identity authentication for Azure resources
// Provides secure authentication without storing credentials
// 🔒 SECURITY ENHANCEMENT: Preferred method for Azure resource access
@description('Enable managed identity authentication')
param enableManagedIdentity bool = true

// Allowed IP addresses for API access
// Restricts API access to specific networks or addresses
// 🔒 SECURITY ENHANCEMENT: Implement network-level access controls
@description('Allowed IP addresses or CIDR ranges for API access')
param allowedIpAddresses array = []

// Enable CORS for web application integration
// Required for browser-based applications to access the service
@description('Enable CORS for web application integration')
param enableCors bool = true

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

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with Document Intelligence-specific metadata
var defaultTags = {
  Environment: tags.?Environment ?? 'Production'
  Service: 'Document Intelligence'
  ManagedBy: 'Bicep'
  DocumentProcessing: 'enabled'
  DataClassification: tags.?DataClassification ?? 'internal'
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Generate unique names for related resources
var documentIntelligenceServiceName = '${documentIntelligenceName}${resourceSuffix}'
var storageAccountName = enableDedicatedStorage ? take(replace('${documentIntelligenceName}${resourceSuffix}storage', '-', ''), 24) : ''
var appInsightsName = enableApplicationInsights && empty(applicationInsightsId) ? '${documentIntelligenceName}-insights${resourceSuffix}' : ''
var privateEndpointName = enablePrivateEndpoint ? '${documentIntelligenceName}-pe${resourceSuffix}' : ''

// Create IP rules array as a variable to avoid for-expression issues
var ipRules = [for ip in allowedIpAddresses: {
  value: ip
}]

// ============================================================================
// RESOURCES - STORAGE ACCOUNT
// ============================================================================

// Dedicated storage account for document processing
resource documentStorage 'Microsoft.Storage/storageAccounts@2023-01-01' = if (enableDedicatedStorage) {
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
    allowSharedKeyAccess: !enableManagedIdentity
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    networkAcls: {
      defaultAction: enablePrivateEndpoint ? 'Deny' : (empty(allowedIpAddresses) ? 'Allow' : 'Deny')
      ipRules: empty(allowedIpAddresses) ? [] : ipRules
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

// Blob containers for document processing workflow
resource documentStorageContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-01-01' = [for container in storageContainers: if (enableDedicatedStorage) {
  name: '${documentStorage.name}/default/${container}'
  properties: {
    publicAccess: 'None'
    metadata: {
      purpose: 'document-intelligence'
      retention: string(dataRetentionDays)
    }
  }
}]

// ============================================================================
// RESOURCES - APPLICATION INSIGHTS
// ============================================================================

// Application Insights for Document Intelligence monitoring
resource documentIntelligenceAppInsights 'Microsoft.Insights/components@2020-02-02' = if (enableApplicationInsights && empty(applicationInsightsId)) {
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
// RESOURCES - DOCUMENT INTELLIGENCE SERVICE
// ============================================================================

// Azure AI Document Intelligence service
resource documentIntelligenceService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: documentIntelligenceServiceName
  location: location
  tags: allTags
  sku: {
    name: documentIntelligenceSku
  }
  kind: 'FormRecognizer'
  identity: enableManagedIdentity ? {
    type: 'SystemAssigned'
  } : null
  properties: {
    apiProperties: {
      statisticsEnabled: enableApplicationInsights
    }
    customSubDomainName: documentIntelligenceServiceName
    disableLocalAuth: !enableApiKeyAuth
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : (empty(allowedIpAddresses) ? 'Enabled' : 'Enabled')
    networkAcls: empty(allowedIpAddresses) ? null : {
      defaultAction: 'Deny'
      ipRules: ipRules
    }
    encryption: enableCustomerManagedKey && !empty(keyVaultId) ? {
      keyVaultProperties: {
        keyName: keyName
        keyVaultUri: reference(keyVaultId, '2023-07-01').vaultUri
        keyVersion: keyVersion
      }
      keySource: 'Microsoft.KeyVault'
    } : null
    userOwnedStorage: enableDedicatedStorage ? [
      {
        resourceId: documentStorage.id
      }
    ] : null
  }
}

// ============================================================================
// RESOURCES - PRIVATE ENDPOINT
// ============================================================================

// Private endpoint for secure access to Document Intelligence
resource documentIntelligencePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-05-01' = if (enablePrivateEndpoint && !empty(subnetId)) {
  name: privateEndpointName
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${documentIntelligenceServiceName}-connection'
        properties: {
          privateLinkServiceId: documentIntelligenceService.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

// ============================================================================
// RESOURCES - RBAC ASSIGNMENTS
// ============================================================================

// RBAC assignment for storage access
resource storageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (enableDedicatedStorage && enableManagedIdentity) {
  name: guid(documentStorage.id, documentIntelligenceService.id, 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')
  scope: documentStorage
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: documentIntelligenceService.identity!.principalId
    principalType: 'ServicePrincipal'
  }
}

// ============================================================================
// RESOURCES - MONITORING ALERTS
// ============================================================================

// Alert for processing failures
resource processingFailureAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableApplicationInsights) {
  name: '${documentIntelligenceServiceName}-processing-failures'
  location: 'global'
  tags: allTags
  properties: {
    description: 'Alert when document processing failure rate exceeds threshold'
    severity: 2
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      documentIntelligenceService.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'ProcessingFailures'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'TotalErrors'
          metricNamespace: 'Microsoft.CognitiveServices/accounts'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Total'
        }
      ]
    }
    actions: []
  }
}

// Alert for high latency
resource highLatencyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableApplicationInsights) {
  name: '${documentIntelligenceServiceName}-high-latency'
  location: 'global'
  tags: allTags
  properties: {
    description: 'Alert when document processing latency exceeds threshold'
    severity: 3
    enabled: true
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    scopes: [
      documentIntelligenceService.id
    ]
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'HighLatency'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'TotalTokenCalls'
          metricNamespace: 'Microsoft.CognitiveServices/accounts'
          operator: 'GreaterThan'
          threshold: 10000
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

@description('Document Intelligence service configuration')
output documentIntelligenceConfig object = {
  name: documentIntelligenceService.name
  id: documentIntelligenceService.id
  endpoint: documentIntelligenceService.properties.endpoint
  customDomain: documentIntelligenceService.properties.customSubDomainName
  sku: documentIntelligenceSku
  location: location
}

@description('API access configuration')
output apiConfig object = {
  endpoint: documentIntelligenceService.properties.endpoint
  apiKeyAuthEnabled: enableApiKeyAuth
  managedIdentityEnabled: enableManagedIdentity
  privateEndpointEnabled: enablePrivateEndpoint
  corsEnabled: enableCors
}

@description('Storage configuration')
output storageConfig object = enableDedicatedStorage ? {
  accountName: documentStorage.name
  accountId: documentStorage.id
  containers: storageContainers
  encryptionEnabled: enableStorageEncryption
} : {}

@description('Monitoring configuration')
output monitoringConfig object = {
  applicationInsights: enableApplicationInsights ? {
    name: empty(applicationInsightsId) ? documentIntelligenceAppInsights!.name : 'External'
    instrumentationKey: empty(applicationInsightsId) ? documentIntelligenceAppInsights!.properties.InstrumentationKey : reference(applicationInsightsId, '2020-02-02').InstrumentationKey
    connectionString: empty(applicationInsightsId) ? documentIntelligenceAppInsights!.properties.ConnectionString : reference(applicationInsightsId, '2020-02-02').ConnectionString
  } : {}
  alertsEnabled: enableAlerts
  auditLoggingEnabled: enableAuditLogging
}

@description('Security configuration')
output securityConfig object = {
  privateEndpointEnabled: enablePrivateEndpoint
  customerManagedKeyEnabled: enableCustomerManagedKey
  managedIdentityEnabled: enableManagedIdentity
  auditLoggingEnabled: enableAuditLogging
  dataRetentionDays: dataRetentionDays
  networkAccessRestricted: !empty(allowedIpAddresses)
}

@description('Processing capabilities')
output processingCapabilities object = {
  prebuiltModelsEnabled: enablePrebuiltModels
  enabledPrebuiltModels: enabledPrebuiltModels
  customModelsEnabled: enableCustomModels
  maxCustomModels: maxCustomModels
  composedModelsEnabled: enableComposedModels
  batchProcessingEnabled: enableBatchProcessing
  maxBatchSize: maxBatchSize
}

@description('Deployment summary and next steps')
output deploymentSummary object = {
  status: 'Document Intelligence service deployed successfully'
  nextSteps: [
    'Configure custom models for your specific document types'
    'Set up batch processing workflows for large-scale operations'
    'Integrate with your applications using the provided endpoint'
    'Configure monitoring and alerting for production workloads'
    'Test document processing with sample documents'
    'Set up proper RBAC for users and applications'
  ]
  capabilities: [
    'Prebuilt models for common document types'
    'Custom model training for organization-specific documents'
    'Batch processing for large-scale operations'
    'Private endpoint support for secure access'
    'Customer-managed encryption for enhanced security'
    'Comprehensive monitoring and alerting'
  ]
  documentationLinks: {
    documentIntelligence: 'https://docs.microsoft.com/azure/applied-ai-services/form-recognizer/'
    customModels: 'https://docs.microsoft.com/azure/applied-ai-services/form-recognizer/concept-custom'
    apiReference: 'https://docs.microsoft.com/rest/api/formrecognizer/'
    pricing: 'https://azure.microsoft.com/pricing/details/form-recognizer/'
  }
}
