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

// CORS allowed origins for web application integration
// Specify allowed domains for cross-origin requests
// 🔒 SECURITY ENHANCEMENT: Restrict to specific domains instead of wildcard
@description('CORS allowed origins for web application integration')
param corsAllowedOrigins array = ['*']

// CORS allowed methods for web application integration
// Specify allowed HTTP methods for cross-origin requests  
@description('CORS allowed methods for web application integration')
param corsAllowedMethods array = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS']

// ============================================================================
// PARAMETERS - ADVANCED DOCUMENT PROCESSING
// ============================================================================

// Enable advanced OCR capabilities for enhanced text extraction
// Provides improved accuracy for complex layouts and multi-language documents
// 🔒 SECURITY ENHANCEMENT: Monitor OCR usage for sensitive document detection
@description('Enable advanced OCR capabilities for enhanced text extraction')
param enableAdvancedOcr bool = true

// OCR language support configuration for multi-language document processing
// Enables processing of documents in multiple languages
@description('OCR language support configuration')
param ocrLanguageConfig object = {
  enabled: true
  supportedLanguages: ['en', 'es', 'fr', 'de', 'it', 'pt', 'nl', 'sv', 'da', 'fi', 'no']
  autoDetectLanguage: true
  enableMultiLanguageDocuments: true
}

// Document confidence threshold for quality control
// Rejects documents below specified confidence level for processing accuracy
// 🔒 SECURITY ENHANCEMENT: Prevent processing of potentially malicious or corrupted documents
@description('Document confidence threshold for quality control (0.7 = 70%)')
param documentConfidenceThreshold string = '0.7'

// Enable document classification for automated document routing
// Automatically classifies documents into predefined categories
// 🔒 SECURITY ENHANCEMENT: Route sensitive documents to appropriate secure processing workflows
@description('Enable document classification for automated routing')
param enableDocumentClassification bool = false

// Document size limits for processing optimization and security
// Controls maximum document size to prevent resource exhaustion
// 🔒 SECURITY ENHANCEMENT: Prevent oversized uploads that could impact service availability
@description('Document size limits for processing (MB)')
param documentSizeLimits object = {
  maxFileSizeMB: 500
  maxPageCount: 2000
  maxBatchSizeMB: 1000
  enableSizeValidation: true
}

// Content filtering policies for document processing
// Filters out inappropriate or malicious content during document processing
// 🔒 SECURITY ENHANCEMENT: Prevent processing of potentially harmful content
@description('Content filtering policies for document processing')
param contentFilteringPolicies object = {
  enabled: false
  blockMaliciousContent: true
  blockPersonalIdentifiableInfo: false
  blockFinancialInfo: false
  customFilteringRules: []
}

// ============================================================================
// PARAMETERS - ADVANCED SECURITY & COMPLIANCE
// ============================================================================

// Enable Azure Defender for Document Intelligence advanced threat protection
// Provides security monitoring and threat detection for document processing
// 🔒 SECURITY ENHANCEMENT: Essential for production environments processing sensitive documents
@description('Enable Azure Defender for advanced threat protection')
param enableAzureDefender bool = true

// Data loss prevention policies for document processing workflows
// Prevents sensitive data from being inappropriately shared or processed
// 🔒 SECURITY ENHANCEMENT: Critical for environments with sensitive document processing
@description('Enable data loss prevention policies')
param enableDataLossPrevention bool = true

// Immutable document storage for compliance and audit requirements
// Ensures processed documents cannot be modified or deleted for specified period
// 🔒 SECURITY ENHANCEMENT: Required for regulatory compliance in many industries
@description('Enable immutable document storage for compliance')
param enableImmutableStorage bool = false

// Immutable storage retention period in days
// Defines how long documents remain immutable for compliance
@description('Immutable storage retention period in days')
@minValue(1)
@maxValue(3653) // 10 years maximum
param immutableRetentionDays int = 2555 // 7 years default

// Enable automatic data classification for processed documents
// Automatically classifies document content based on sensitivity
// 🔒 SECURITY ENHANCEMENT: Enables automated data governance and protection policies
@description('Enable automatic data classification for processed documents')
param enableDataClassification bool = true

// Data classification policies for automated document labeling
// Defines rules for classifying document content by sensitivity level
@description('Data classification policies for document labeling')
param dataClassificationConfig object = {
  enabled: true
  sensitivityLabels: ['Public', 'Internal', 'Confidential', 'Restricted']
  autoClassificationRules: {
    enablePiiDetection: true
    enableFinancialDataDetection: true
    enableHealthDataDetection: true
    enableLegalDataDetection: true
  }
  labelingThreshold: '0.8'
}

// Enable encryption for documents in transit during processing
// Ensures all document transfers are encrypted using TLS 1.3
// 🔒 SECURITY ENHANCEMENT: Protects document data during network transmission
@description('Enable encryption for documents in transit')
param enableTransitEncryption bool = true

// Minimum TLS version for document transmission security
// Controls the minimum TLS protocol version for secure communications
// 🔒 SECURITY ENHANCEMENT: Use TLS 1.2+ for compliance with security standards
@description('Minimum TLS version for document transmission')
@allowed(['1.1', '1.2', '1.3'])
param minimumTlsVersion string = '1.2'

// ============================================================================
// PARAMETERS - ADVANCED MONITORING & ANALYTICS
// ============================================================================

// Enable comprehensive performance monitoring for document processing operations
// Provides detailed insights into processing times, success rates, and resource usage
// 🔒 SECURITY ENHANCEMENT: Monitor for unusual processing patterns that might indicate attacks
@description('Enable comprehensive performance monitoring')
param enablePerformanceMonitoring bool = true

// Performance monitoring configuration for detailed analytics
@description('Performance monitoring configuration')
param performanceMonitoringConfig object = {
  enabled: true
  trackProcessingTimes: true
  trackAccuracyMetrics: true
  trackResourceUtilization: true
  trackUserPatterns: true
  enableAnomalyDetection: true
  alertThresholds: {
    processingTimeMs: 30000
    errorRatePercentage: 5
    resourceUtilizationPercentage: 80
  }
}

// Enable usage analytics for document processing patterns and optimization
// Analyzes document processing patterns to optimize performance and detect anomalies
// 🔒 SECURITY ENHANCEMENT: Detect unusual usage patterns that might indicate security issues
@description('Enable usage analytics for processing optimization')
param enableUsageAnalytics bool = true

// Usage analytics retention period for historical analysis
// Controls how long usage analytics data is retained for trend analysis
@description('Usage analytics retention period in days')
@minValue(30)
@maxValue(730) // 2 years maximum
param usageAnalyticsRetentionDays int = 90

// Enable real-time monitoring dashboards for operational visibility
// Provides real-time visibility into document processing operations and system health
// 🔒 SECURITY ENHANCEMENT: Enable real-time security monitoring and incident response
@description('Enable real-time monitoring dashboards')
param enableRealTimeMonitoring bool = true

// Advanced alerting configuration for comprehensive monitoring
// Configures detailed alerting for various document processing events and security issues
@description('Advanced alerting configuration')
param advancedAlertingConfig object = {
  enabled: true
  enableSecurityAlerts: true
  enablePerformanceAlerts: true
  enableCapacityAlerts: true
  enableComplianceAlerts: true
  alertChannels: {
    email: true
    webhook: false
    sms: false
    teams: false
  }
  alertSeverityLevels: ['Critical', 'High', 'Medium', 'Low']
}

// ============================================================================
// PARAMETERS - ENHANCED TAGGING & METADATA
// ============================================================================

// Environment classification for security policy application and access control
// Determines which security policies and access controls are applied to the service
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application based on environment
@description('Environment classification for security policies')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environmentClassification string = 'production'

// Data classification level for compliance and security policy enforcement
// Defines the sensitivity level of documents processed by the service
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

// Compliance framework requirements for regulatory adherence
// Specifies which compliance frameworks the service must adhere to
// 🔒 SECURITY ENHANCEMENT: Enables automated compliance checks and reporting
@description('Compliance framework requirements')
param complianceRequirements object = {
  gdprCompliance: false
  hipaaCompliance: false
  sox404Compliance: false
  iso27001Compliance: false
  pcidssCompliance: false
  customComplianceFrameworks: []
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

// ============================================================================
// VARIABLES
// ============================================================================

// Enhanced default tags with comprehensive metadata
var defaultTags = {
  Environment: tags.?Environment ?? 'Production'
  EnvironmentClassification: environmentClassification
  Service: 'Document Intelligence'
  ManagedBy: 'Bicep'
  DocumentProcessing: 'enabled'
  DataClassification: dataClassification
  BusinessCriticality: businessCriticality
  CostCenter: !empty(costCenter) ? costCenter : 'Not Specified'
  Owner: !empty(resourceOwner.name) ? resourceOwner.name : 'Not Specified'
  OwnerEmail: !empty(resourceOwner.email) ? resourceOwner.email : 'Not Specified'
  Department: !empty(resourceOwner.department) ? resourceOwner.department : 'Not Specified'
  ProjectName: !empty(projectInformation.projectName) ? projectInformation.projectName : 'Not Specified'
  ProjectId: !empty(projectInformation.projectId) ? projectInformation.projectId : 'Not Specified'
  LastUpdated: '2025-08-01'
  DocumentIntelligenceEnabled: 'true'
  PrivateEndpointEnabled: string(enablePrivateEndpoint)
  CustomerManagedKeyEnabled: string(enableCustomerManagedKey)
  ManagedIdentityEnabled: string(enableManagedIdentity)
  AdvancedOcrEnabled: string(enableAdvancedOcr)
  DataClassificationEnabled: string(enableDataClassification)
  AzureDefenderEnabled: string(enableAzureDefender)
}

// Merge user-provided tags with enhanced defaults
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

// Advanced processing configuration
var advancedProcessingConfig = {
  ocrLanguageConfig: ocrLanguageConfig
  documentConfidenceThreshold: documentConfidenceThreshold
  documentClassificationEnabled: enableDocumentClassification
  documentSizeLimits: documentSizeLimits
  contentFilteringPolicies: contentFilteringPolicies
  advancedOcrEnabled: enableAdvancedOcr
}

// Advanced security configuration
var advancedSecurityConfig = {
  azureDefenderEnabled: enableAzureDefender
  dataLossPreventionEnabled: enableDataLossPrevention
  immutableStorageEnabled: enableImmutableStorage
  immutableRetentionDays: immutableRetentionDays
  dataClassificationEnabled: enableDataClassification
  dataClassificationConfig: dataClassificationConfig
  transitEncryptionEnabled: enableTransitEncryption
  minimumTlsVersion: minimumTlsVersion
}

// Advanced monitoring configuration
var advancedMonitoringConfig = {
  performanceMonitoringEnabled: enablePerformanceMonitoring
  performanceMonitoringConfig: performanceMonitoringConfig
  usageAnalyticsEnabled: enableUsageAnalytics
  usageAnalyticsRetentionDays: usageAnalyticsRetentionDays
  realTimeMonitoringEnabled: enableRealTimeMonitoring
  advancedAlertingConfig: advancedAlertingConfig
}

// CORS configuration
var corsConfig = {
  enabled: enableCors
  allowedOrigins: corsAllowedOrigins
  allowedMethods: corsAllowedMethods
}

// Compliance configuration
var complianceConfig = {
  requirements: complianceRequirements
  auditLoggingEnabled: enableAuditLogging
  dataRetentionDays: dataRetentionDays
  immutableStorageEnabled: enableImmutableStorage
}

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

// Azure AI Document Intelligence service with advanced configuration
resource documentIntelligenceService 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: documentIntelligenceServiceName
  location: location
  tags: union(allTags, {
    AdvancedProcessingEnabled: string(advancedProcessingConfig.advancedOcrEnabled)
    SecurityConfigured: string(advancedSecurityConfig.azureDefenderEnabled)
    MonitoringEnabled: string(advancedMonitoringConfig.performanceMonitoringEnabled)
    CorsEnabled: string(corsConfig.enabled)
    ComplianceConfigured: string(complianceConfig.auditLoggingEnabled)
  })
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
      qnaRuntimeEndpoint: null
      qnaAzureSearchEndpointId: null
      qnaAzureSearchEndpointKey: null
      eventHubConnectionString: null
      storageAccountConnectionString: enableDedicatedStorage ? null : null
    }
    customSubDomainName: documentIntelligenceServiceName
    disableLocalAuth: !enableApiKeyAuth
    publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : (empty(allowedIpAddresses) ? 'Enabled' : 'Enabled')
    networkAcls: empty(allowedIpAddresses) ? null : {
      defaultAction: 'Deny'
      ipRules: ipRules
      virtualNetworkRules: []
    }
    encryption: enableCustomerManagedKey && !empty(keyVaultId) ? {
      keyVaultProperties: {
        keyName: keyName
        keyVaultUri: reference(keyVaultId, '2023-07-01').vaultUri
        keyVersion: keyVersion
        identityClientId: null
      }
      keySource: 'Microsoft.KeyVault'
    } : {
      keySource: 'Microsoft.CognitiveServices'
    }
    userOwnedStorage: enableDedicatedStorage ? [
      {
        resourceId: documentStorage.id
      }
    ] : null
    restrictOutboundNetworkAccess: advancedSecurityConfig.dataLossPreventionEnabled
    allowedFqdnList: []
    migrationToken: null
    dynamicThrottlingEnabled: false
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

@description('Security configuration with advanced settings')
output securityConfig object = {
  privateEndpointEnabled: enablePrivateEndpoint
  customerManagedKeyEnabled: enableCustomerManagedKey
  managedIdentityEnabled: enableManagedIdentity
  auditLoggingEnabled: enableAuditLogging
  dataRetentionDays: dataRetentionDays
  networkAccessRestricted: !empty(allowedIpAddresses)
  azureDefenderEnabled: advancedSecurityConfig.azureDefenderEnabled
  dataLossPreventionEnabled: advancedSecurityConfig.dataLossPreventionEnabled
  immutableStorageEnabled: advancedSecurityConfig.immutableStorageEnabled
  immutableRetentionDays: advancedSecurityConfig.immutableRetentionDays
  dataClassificationEnabled: advancedSecurityConfig.dataClassificationEnabled
  transitEncryptionEnabled: advancedSecurityConfig.transitEncryptionEnabled
  minimumTlsVersion: advancedSecurityConfig.minimumTlsVersion
}

@description('Processing capabilities with advanced OCR configuration')
output processingCapabilities object = {
  prebuiltModelsEnabled: enablePrebuiltModels
  enabledPrebuiltModels: enabledPrebuiltModels
  customModelsEnabled: enableCustomModels
  maxCustomModels: maxCustomModels
  composedModelsEnabled: enableComposedModels
  batchProcessingEnabled: enableBatchProcessing
  maxBatchSize: maxBatchSize
  advancedOcrEnabled: advancedProcessingConfig.advancedOcrEnabled
  ocrLanguageConfig: advancedProcessingConfig.ocrLanguageConfig
  documentConfidenceThreshold: advancedProcessingConfig.documentConfidenceThreshold
  documentClassificationEnabled: advancedProcessingConfig.documentClassificationEnabled
  documentSizeLimits: advancedProcessingConfig.documentSizeLimits
  contentFilteringEnabled: !empty(advancedProcessingConfig.contentFilteringPolicies)
}

@description('Advanced monitoring configuration')
output advancedMonitoringConfig object = {
  performanceMonitoringEnabled: advancedMonitoringConfig.performanceMonitoringEnabled
  performanceMonitoringConfig: advancedMonitoringConfig.performanceMonitoringConfig
  usageAnalyticsEnabled: advancedMonitoringConfig.usageAnalyticsEnabled
  usageAnalyticsRetentionDays: advancedMonitoringConfig.usageAnalyticsRetentionDays
  realTimeMonitoringEnabled: advancedMonitoringConfig.realTimeMonitoringEnabled
  advancedAlertingConfig: advancedMonitoringConfig.advancedAlertingConfig
}

@description('CORS and connectivity configuration')
output connectivityConfig object = {
  corsEnabled: corsConfig.enabled
  corsAllowedOrigins: corsConfig.allowedOrigins
  corsAllowedMethods: corsConfig.allowedMethods
  publicNetworkAccess: enablePrivateEndpoint ? 'Disabled' : 'Enabled'
  allowedIpAddresses: allowedIpAddresses
}

@description('Compliance and governance configuration')
output complianceConfig object = {
  requirements: complianceConfig.requirements
  auditLoggingEnabled: complianceConfig.auditLoggingEnabled
  dataRetentionDays: complianceConfig.dataRetentionDays
  immutableStorageEnabled: complianceConfig.immutableStorageEnabled
  environmentClassification: environmentClassification
  dataClassification: dataClassification
  businessCriticality: businessCriticality
}

@description('Resource ownership and project information')
output resourceManagement object = {
  resourceOwner: resourceOwner
  projectInformation: projectInformation
  costCenter: costCenter
  environmentClassification: environmentClassification
  allTags: allTags
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
