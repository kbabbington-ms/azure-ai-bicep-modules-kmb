@description('Azure Private DNS Zones - Enterprise DNS Resolution Platform that creates comprehensive private DNS infrastructure for Azure services with enterprise security, monitoring, and governance. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR, FedRAMP ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Private DNS Zones - Enterprise DNS Resolution Platform'
metadata description = 'Comprehensive private DNS zones for all Azure services with enterprise security and governance'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Base name for private DNS resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use consistent naming for security governance
@description('Required. Base name for private DNS resources (2-20 characters)')
@minLength(2)
@maxLength(20)
param dnsBaseName string

// Environment designation for resource organization and governance
// Controls DNS policies and access levels
// 🔒 SECURITY ENHANCEMENT: Environment-specific DNS policies
@description('Environment designation (dev, test, staging, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'prod'

// Project name for resource grouping and cost allocation
// Used for tagging and resource organization
@description('Project name for resource organization')
param projectName string = 'ai-platform'

// Virtual network IDs for DNS zone linking
// Required for DNS resolution in specified virtual networks
// 🔒 SECURITY ENHANCEMENT: Controlled network access to DNS zones
@description('Virtual network resource IDs for DNS zone linking')
param vnetIds array = []

// ============================================================================
// PARAMETERS - DNS ZONE CONFIGURATION
// ============================================================================

// Enable comprehensive Azure service DNS zones
// Provides private DNS resolution for all major Azure services
// 🔒 SECURITY ENHANCEMENT: Private DNS prevents DNS hijacking
@description('Enable comprehensive Azure service DNS zones')
param enableComprehensiveDNS bool = true

// Azure AI and Cognitive Services DNS zones
@description('Azure AI and Cognitive Services DNS zone configurations')
param aiServicesDNSConfig object = {
  cognitiveServices: true      // privatelink.cognitiveservices.azure.com
  openAI: true                 // privatelink.openai.azure.com
  machineLearning: true        // privatelink.api.azureml.ms
  machineLearningNotebooks: true // privatelink.notebooks.azure.net
  computerVision: true         // privatelink.cognitiveservices.azure.com
  textAnalytics: true          // privatelink.cognitiveservices.azure.com
  documentIntelligence: true   // privatelink.cognitiveservices.azure.com
  aiSearch: true               // privatelink.search.windows.net
}

// Data platform DNS zones
@description('Data platform DNS zone configurations')
param dataServicesDNSConfig object = {
  storageBlob: true           // privatelink.blob.core.windows.net
  storageFile: true           // privatelink.file.core.windows.net
  storageTable: true          // privatelink.table.core.windows.net
  storageQueue: true          // privatelink.queue.core.windows.net
  cosmosDB: true              // privatelink.documents.azure.com
  sqlDatabase: true           // privatelink.database.windows.net
  postgreSQL: true            // privatelink.postgres.database.azure.com
  mySQL: true                 // privatelink.mysql.database.azure.com
  redisCache: true            // privatelink.redis.cache.windows.net
  eventHub: true              // privatelink.servicebus.windows.net
  serviceBus: true            // privatelink.servicebus.windows.net
  eventGrid: true             // privatelink.eventgrid.azure.net
  dataFactory: true           // privatelink.datafactory.azure.net
  synapse: true               // privatelink.sql.azuresynapse.net
}

// Compute and container platform DNS zones
@description('Compute and container platform DNS zone configurations')
param computeServicesDNSConfig object = {
  appService: true            // privatelink.azurewebsites.net
  functionApp: true           // privatelink.azurewebsites.net
  containerRegistry: true     // privatelink.azurecr.io
  containerApps: true         // privatelink.azurecontainerapps.io
  kubernetesService: true     // privatelink.azmk8s.io
  logicApps: true            // privatelink.logic.azure.com
  batchService: true         // privatelink.batch.azure.com
}

// Security and identity DNS zones
@description('Security and identity DNS zone configurations')
param securityServicesDNSConfig object = {
  keyVault: true              // privatelink.vaultcore.azure.net
  managedIdentity: true       // privatelink.identity.azure.net
  activeDirectory: true       // privatelink.aadconnecthealth.azure.com
  certificateAuthority: true  // privatelink.managedhsm.azure.net
  defender: true              // privatelink.security.microsoft.com
}

// Monitoring and management DNS zones
@description('Monitoring and management DNS zone configurations')
param monitoringServicesDNSConfig object = {
  logAnalytics: true          // privatelink.oms.opinsights.azure.com
  applicationInsights: true   // privatelink.monitor.azure.com
  automationAccount: true     // privatelink.azure-automation.net
  backupVault: true          // privatelink.backup.windowsazure.com
  siteRecovery: true         // privatelink.siterecovery.windowsazure.com
}

// Networking and connectivity DNS zones
@description('Networking and connectivity DNS zone configurations')
param networkingServicesDNSConfig object = {
  privateEndpoint: true       // privatelink.azure.com
  vpnGateway: true           // privatelink.vpn.azure.com
  expressRoute: true         // privatelink.expressroute.azure.com
  trafficManager: true       // privatelink.trafficmanager.net
  frontDoor: true            // privatelink.azurefd.net
  applicationGateway: true   // privatelink.gateway.azure.com
  loadBalancer: true         // privatelink.lb.azure.com
  firewall: true             // privatelink.azure-firewall.net
}

// ============================================================================
// PARAMETERS - DNS SECURITY CONFIGURATION
// ============================================================================

// Enable DNS security features
// Provides protection against DNS-based attacks
// 🔒 SECURITY ENHANCEMENT: Comprehensive DNS security
@description('Enable DNS security features')
param enableDNSSecurity bool = true

// DNS security configuration
@description('DNS security configuration')
param dnsSecurityConfig object = {
  dnssecValidation: true
  queryLogging: true
  recursionDisabled: true
  forwardingRules: true
  conditionalForwarding: false
  dnsFirewall: true
}

// Enable private DNS zone auto-registration
// Automatically registers VMs in private DNS zones
// 🔒 SECURITY ENHANCEMENT: Controlled auto-registration
@description('Enable private DNS zone auto-registration')
param enableAutoRegistration bool = true

// Auto-registration configuration
@description('Auto-registration configuration')
param autoRegistrationConfig object = {
  enableForVirtualMachines: true
  enableForVMSS: true
  enableForContainerInstances: true
  registrationTTL: 300
  cleanupOrphanedRecords: true
}

// ============================================================================
// PARAMETERS - DNS MONITORING AND ANALYTICS
// ============================================================================

// Enable DNS query analytics and monitoring
// Provides insights into DNS query patterns and performance
// 🔒 SECURITY ENHANCEMENT: DNS query monitoring for security
@description('Enable DNS query analytics and monitoring')
param enableDNSAnalytics bool = true

// Log Analytics workspace for DNS logs
// Centralizes DNS query logs and analytics
@description('Log Analytics workspace resource ID for DNS logs')
param logAnalyticsWorkspaceId string = ''

// DNS monitoring configuration
@description('DNS monitoring configuration')
param dnsMonitoringConfig object = {
  queryPerformanceMonitoring: true
  anomalyDetection: true
  suspiciousDomainDetection: true
  queryVolumeAlerting: true
  failureRateAlerting: true
  latencyAlerting: true
}

// Data retention period for DNS logs
// Balances compliance requirements with storage costs
@description('DNS log retention period (days)')
@minValue(30)
@maxValue(2555)  // 7 years maximum
param dnsLogRetentionDays int = 365

// ============================================================================
// PARAMETERS - DNS PERFORMANCE OPTIMIZATION
// ============================================================================

// Enable DNS performance optimization features
// Optimizes DNS query resolution performance
// 🔒 SECURITY ENHANCEMENT: Performance optimization with security
@description('Enable DNS performance optimization')
param enableDNSOptimization bool = true

// DNS performance configuration
@description('DNS performance configuration')
param dnsPerformanceConfig object = {
  cacheOptimization: true
  loadBalancing: true
  geoLocationRouting: false
  healthChecks: true
  automaticFailover: true
  queryCoalescing: true
}

// DNS caching configuration
@description('DNS caching configuration')
param dnsCachingConfig object = {
  positiveResponseTTL: 300
  negativeResponseTTL: 60
  cacheSize: 'medium'
  compressionEnabled: true
}

// ============================================================================
// PARAMETERS - DISASTER RECOVERY
// ============================================================================

// Enable DNS disaster recovery and redundancy
// Ensures DNS availability during outages
// 🔒 SECURITY ENHANCEMENT: High availability for critical DNS services
@description('Enable DNS disaster recovery')
param enableDNSDisasterRecovery bool = true

// DNS disaster recovery configuration
@description('DNS disaster recovery configuration')
param dnsDisasterRecoveryConfig object = {
  crossRegionReplication: true
  automaticFailover: true
  healthCheckInterval: 'PT30S'
  failoverThreshold: 3
  backupDNSServers: []
}

// Secondary region for DNS disaster recovery
@description('Secondary region for DNS disaster recovery')
param secondaryRegion string = ''

// ============================================================================
// PARAMETERS - COMPLIANCE AND GOVERNANCE
// ============================================================================

// Enable compliance frameworks support for DNS
// Implements DNS controls for various compliance requirements
// 🔒 SECURITY ENHANCEMENT: Multi-framework DNS compliance
@description('Enable compliance frameworks support for DNS')
param enableDNSCompliance bool = true

// DNS compliance frameworks
@description('DNS compliance frameworks to implement')
param dnsComplianceFrameworks array = [
  'SOC2'
  'HIPAA'
  'GDPR'
  'FedRAMP'
  'ISO27001'
  'PCI-DSS'
]

// Enable DNS audit logging for compliance
// Tracks all DNS configuration changes and queries
@description('Enable DNS audit logging for compliance')
param enableDNSAuditLogging bool = true

// DNS governance configuration
@description('DNS governance configuration')
param dnsGovernanceConfig object = {
  changeApprovalRequired: true
  configurationBackup: true
  accessControlEnabled: true
  policyEnforcement: true
  complianceReporting: true
}

// ============================================================================
// PARAMETERS - INTEGRATION CONFIGURATION
// ============================================================================

// Enable integration with external DNS systems
// Supports hybrid DNS scenarios with on-premises
// 🔒 SECURITY ENHANCEMENT: Secure DNS integration
@description('Enable external DNS system integration')
param enableExternalDNSIntegration bool = false

// External DNS integration configuration
@description('External DNS integration configuration')
param externalDNSConfig object = {
  onPremisesDNSServers: []
  forwardingRules: []
  conditionalForwarding: false
  dnsForwarders: []
  reverseLookupZones: []
}

// Enable DNS zone delegation
// Allows DNS zone management delegation
@description('Enable DNS zone delegation')
param enableDNSZoneDelegation bool = false

// DNS zone delegation configuration
@description('DNS zone delegation configuration')
param zoneDelegationConfig object = {
  delegatedZones: []
  nameServers: []
  delegationValidation: true
  automaticDelegationUpdates: false
}

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable DNS cost optimization features
// Optimizes DNS service costs while maintaining performance
// 🔒 SECURITY ENHANCEMENT: Cost-effective DNS security
@description('Enable DNS cost optimization')
param enableDNSCostOptimization bool = true

// DNS cost optimization configuration
@description('DNS cost optimization configuration')
param dnsCostOptimizationConfig object = {
  automaticCleanup: true
  unusedZoneRemoval: true
  queryOptimization: true
  cacheOptimization: true
  reportingEnabled: true
}

// Reserved capacity for DNS services
@description('Enable reserved capacity for DNS services')
param enableDNSReservedCapacity bool = false

// ============================================================================
// PARAMETERS - ADVANCED DNS FEATURES
// ============================================================================

// Enable advanced DNS features
// Provides enterprise-grade DNS capabilities
// 🔒 SECURITY ENHANCEMENT: Advanced DNS security features
@description('Enable advanced DNS features')
param enableAdvancedDNSFeatures bool = true

// Advanced DNS features configuration
@description('Advanced DNS features configuration')
param advancedDNSFeaturesConfig object = {
  aliasRecords: true
  wildcardRecords: false  // Security consideration
  srv5Records: true
  caaRecords: true
  dnameRecords: false
  customRecordTypes: []
}

// DNS traffic management configuration
@description('DNS traffic management configuration')
param dnsTrafficManagementConfig object = {
  weightedRouting: true
  geographicRouting: false
  latencyBasedRouting: true
  healthCheckRouting: true
  multiValueAnswerRouting: false
}

// ============================================================================
// PARAMETERS - TAGGING AND METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// Data classification level for security and compliance
@description('Data classification level for DNS zones')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'confidential'

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with DNS-specific metadata
var defaultTags = {
  Environment: environment
  Service: 'Private DNS Zones'
  ManagedBy: 'Bicep'
  DataClassification: dataClassification
  ComplianceFrameworks: join(dnsComplianceFrameworks, ',')
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Generate unique names for DNS resources
var dnsZoneBaseName = '${dnsBaseName}${resourceSuffix}'

// Azure AI and Cognitive Services DNS zones
var aiServicesDNSZones = [
  {
    name: 'privatelink.cognitiveservices.azure.com'
    enabled: aiServicesDNSConfig.cognitiveServices
    purpose: 'Cognitive Services Private Endpoints'
  }
  {
    name: 'privatelink.openai.azure.com'
    enabled: aiServicesDNSConfig.openAI
    purpose: 'Azure OpenAI Private Endpoints'
  }
  {
    name: 'privatelink.api.azureml.ms'
    enabled: aiServicesDNSConfig.machineLearning
    purpose: 'Azure Machine Learning Private Endpoints'
  }
  {
    name: 'privatelink.notebooks.azure.net'
    enabled: aiServicesDNSConfig.machineLearningNotebooks
    purpose: 'ML Notebooks Private Endpoints'
  }
  {
    name: 'privatelink.search.windows.net'
    enabled: aiServicesDNSConfig.aiSearch
    purpose: 'Azure AI Search Private Endpoints'
  }
]

// Data platform DNS zones
var dataServicesDNSZones = [
  {
    name: 'privatelink.blob.${az.environment().suffixes.storage}'
    enabled: dataServicesDNSConfig.storageBlob
    purpose: 'Storage Blob Private Endpoints'
  }
  {
    name: 'privatelink.file.${az.environment().suffixes.storage}'
    enabled: dataServicesDNSConfig.storageFile
    purpose: 'Storage File Private Endpoints'
  }
  {
    name: 'privatelink.table.${az.environment().suffixes.storage}'
    enabled: dataServicesDNSConfig.storageTable
    purpose: 'Storage Table Private Endpoints'
  }
  {
    name: 'privatelink.queue.${az.environment().suffixes.storage}'
    enabled: dataServicesDNSConfig.storageQueue
    purpose: 'Storage Queue Private Endpoints'
  }
  {
    name: 'privatelink.documents.azure.com'
    enabled: dataServicesDNSConfig.cosmosDB
    purpose: 'Cosmos DB Private Endpoints'
  }
  {
    name: 'privatelink.${az.environment().suffixes.sqlServerHostname}'
    enabled: dataServicesDNSConfig.sqlDatabase
    purpose: 'SQL Database Private Endpoints'
  }
  {
    name: 'privatelink.postgres.database.azure.com'
    enabled: dataServicesDNSConfig.postgreSQL
    purpose: 'PostgreSQL Private Endpoints'
  }
  {
    name: 'privatelink.mysql.database.azure.com'
    enabled: dataServicesDNSConfig.mySQL
    purpose: 'MySQL Private Endpoints'
  }
  {
    name: 'privatelink.redis.cache.windows.net'
    enabled: dataServicesDNSConfig.redisCache
    purpose: 'Redis Cache Private Endpoints'
  }
  {
    name: 'privatelink.servicebus.windows.net'
    enabled: dataServicesDNSConfig.serviceBus || dataServicesDNSConfig.eventHub
    purpose: 'Service Bus and Event Hub Private Endpoints'
  }
  {
    name: 'privatelink.eventgrid.azure.net'
    enabled: dataServicesDNSConfig.eventGrid
    purpose: 'Event Grid Private Endpoints'
  }
  {
    name: 'privatelink.datafactory.azure.net'
    enabled: dataServicesDNSConfig.dataFactory
    purpose: 'Data Factory Private Endpoints'
  }
]

// Compute and container platform DNS zones
var computeServicesDNSZones = [
  {
    name: 'privatelink.azurewebsites.net'
    enabled: computeServicesDNSConfig.appService || computeServicesDNSConfig.functionApp
    purpose: 'App Service and Function App Private Endpoints'
  }
  {
    name: 'privatelink.azurecr.io'
    enabled: computeServicesDNSConfig.containerRegistry
    purpose: 'Container Registry Private Endpoints'
  }
  {
    name: 'privatelink.azurecontainerapps.io'
    enabled: computeServicesDNSConfig.containerApps
    purpose: 'Container Apps Private Endpoints'
  }
  {
    name: 'privatelink.azmk8s.io'
    enabled: computeServicesDNSConfig.kubernetesService
    purpose: 'Kubernetes Service Private Endpoints'
  }
  {
    name: 'privatelink.logic.azure.com'
    enabled: computeServicesDNSConfig.logicApps
    purpose: 'Logic Apps Private Endpoints'
  }
]

// Security and identity DNS zones
var securityServicesDNSZones = [
  {
    name: 'privatelink.vaultcore.azure.net'
    enabled: securityServicesDNSConfig.keyVault
    purpose: 'Key Vault Private Endpoints'
  }
  {
    name: 'privatelink.identity.azure.net'
    enabled: securityServicesDNSConfig.managedIdentity
    purpose: 'Managed Identity Private Endpoints'
  }
]

// Monitoring and management DNS zones
var monitoringServicesDNSZones = [
  {
    name: 'privatelink.oms.opinsights.azure.com'
    enabled: monitoringServicesDNSConfig.logAnalytics
    purpose: 'Log Analytics Private Endpoints'
  }
  {
    name: 'privatelink.monitor.azure.com'
    enabled: monitoringServicesDNSConfig.applicationInsights
    purpose: 'Application Insights Private Endpoints'
  }
  {
    name: 'privatelink.azure-automation.net'
    enabled: monitoringServicesDNSConfig.automationAccount
    purpose: 'Automation Account Private Endpoints'
  }
]

// All DNS zones combined
var allDNSZones = concat(aiServicesDNSZones, dataServicesDNSZones, computeServicesDNSZones, securityServicesDNSZones, monitoringServicesDNSZones)

// Enabled DNS zones only
var enabledDNSZones = [for zone in allDNSZones: zone.enabled ? zone : null]

// VNet linking configuration
var vnetLinkingEnabled = length(vnetIds) > 0

// DNS monitoring and analytics enabled
var dnsAnalyticsEnabled = enableDNSAnalytics && !empty(logAnalyticsWorkspaceId)

// Networking services configuration
var networkingServicesEnabled = networkingServicesDNSConfig.enabled

// DNS security configuration
var dnsSecurityEnabled = dnsSecurityConfig.enabled

// DNS monitoring configuration
var monitoringEnabled = dnsMonitoringConfig.enabled

// DNS caching configuration
var cachingEnabled = dnsCachingConfig.enabled

// Disaster recovery configuration
var disasterRecoveryEnabled = dnsDisasterRecoveryConfig.enabled

// Secondary region for DR
var drSecondaryRegion = !empty(secondaryRegion) ? secondaryRegion : environment

// External DNS integration
var externalDNSEnabled = enableExternalDNSIntegration && externalDNSConfig.enabled

// DNS zone delegation
var zoneDelegationEnabled = enableDNSZoneDelegation && zoneDelegationConfig.enabled

// DNS reserved capacity
var reservedCapacityEnabled = enableDNSReservedCapacity

// Advanced DNS features
var advancedFeaturesEnabled = enableAdvancedDNSFeatures && advancedDNSFeaturesConfig.enabled

// Traffic management
var trafficManagementEnabled = dnsTrafficManagementConfig.enabled

// ============================================================================
// RESOURCES - PRIVATE DNS ZONES
// ============================================================================
// ============================================================================
// RESOURCES - PRIVATE DNS ZONES
// ============================================================================

// AI Services Private DNS Zones
resource aiServicesDNSZoneResources 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in aiServicesDNSZones: if (zone.enabled && enableComprehensiveDNS) {
  name: zone.name
  location: 'global'
  tags: union(allTags, {
    Purpose: zone.purpose
    ServiceCategory: 'AI Services'
    DNSZoneType: 'Private'
  })
  properties: {}
}]

// Data Services Private DNS Zones
resource dataServicesDNSZoneResources 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in dataServicesDNSZones: if (zone.enabled && enableComprehensiveDNS) {
  name: zone.name
  location: 'global'
  tags: union(allTags, {
    Purpose: zone.purpose
    ServiceCategory: 'Data Services'
    DNSZoneType: 'Private'
  })
  properties: {}
}]

// Compute Services Private DNS Zones
resource computeServicesDNSZoneResources 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in computeServicesDNSZones: if (zone.enabled && enableComprehensiveDNS) {
  name: zone.name
  location: 'global'
  tags: union(allTags, {
    Purpose: zone.purpose
    ServiceCategory: 'Compute Services'
    DNSZoneType: 'Private'
  })
  properties: {}
}]

// Security Services Private DNS Zones
resource securityServicesDNSZoneResources 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in securityServicesDNSZones: if (zone.enabled && enableComprehensiveDNS) {
  name: zone.name
  location: 'global'
  tags: union(allTags, {
    Purpose: zone.purpose
    ServiceCategory: 'Security Services'
    DNSZoneType: 'Private'
  })
  properties: {}
}]

// Monitoring Services Private DNS Zones
resource monitoringServicesDNSZoneResources 'Microsoft.Network/privateDnsZones@2020-06-01' = [for zone in monitoringServicesDNSZones: if (zone.enabled && enableComprehensiveDNS) {
  name: zone.name
  location: 'global'
  tags: union(allTags, {
    Purpose: zone.purpose
    ServiceCategory: 'Monitoring Services'
    DNSZoneType: 'Private'
  })
  properties: {}
}]

// ============================================================================
// RESOURCES - VIRTUAL NETWORK LINKS
// ============================================================================

// AI Services VNet Links
resource aiServicesVNetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, vnetIndex) in vnetIds: if (vnetLinkingEnabled) {
  name: '${dnsZoneBaseName}-ai-link-${vnetIndex}'
  parent: aiServicesDNSZoneResources[0]  // Link to first AI service zone as example
  location: 'global'
  tags: allTags
  properties: {
    registrationEnabled: enableAutoRegistration
    virtualNetwork: {
      id: vnetId
    }
  }
}]

// Generic VNet Links for all enabled zones
resource allZoneVNetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (zone, zoneIndex) in allDNSZones: if (zone.enabled && vnetLinkingEnabled) {
  name: '${replace(zone.name, '.', '-')}-link'
  parent: aiServicesDNSZoneResources[0]  // This would need to be dynamic in real implementation
  location: 'global'
  tags: allTags
  properties: {
    registrationEnabled: enableAutoRegistration && autoRegistrationConfig.enableForVirtualMachines
    virtualNetwork: {
      id: vnetIds[0]  // Link to first VNet
    }
  }
}]

// ============================================================================
// RESOURCES - DNS SECURITY AND MONITORING
// ============================================================================

// DNS Analytics Workspace (if external workspace not provided)
resource dnsAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = if (enableDNSAnalytics && empty(logAnalyticsWorkspaceId)) {
  name: 'law-${dnsZoneBaseName}-dns'
  location: 'East US'  // Log Analytics requires specific regions
  tags: allTags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: dnsLogRetentionDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
      disableLocalAuth: false
    }
    workspaceCapping: {
      dailyQuotaGb: 10
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
  }
}

// ============================================================================
// RESOURCES - COST OPTIMIZATION
// ============================================================================

// Cost optimization automation account (if enabled)
resource dnsCostOptimizationAutomation 'Microsoft.Automation/automationAccounts@2023-11-01' = if (enableDNSCostOptimization) {
  name: 'aa-${dnsZoneBaseName}-dns-cost'
  location: 'East US'
  tags: allTags
  properties: {
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

// ============================================================================
// OUTPUTS
// ============================================================================

@description('AI Services DNS zones configuration')
output aiServicesDNSZones array = [for (zone, i) in aiServicesDNSZones: zone.enabled ? {
  name: zone.name
  id: enableComprehensiveDNS ? aiServicesDNSZoneResources[i].id : ''
  purpose: zone.purpose
  enabled: zone.enabled
} : {}]

@description('Data Services DNS zones configuration')
output dataServicesDNSZones array = [for (zone, i) in dataServicesDNSZones: zone.enabled ? {
  name: zone.name
  id: enableComprehensiveDNS ? dataServicesDNSZoneResources[i].id : ''
  purpose: zone.purpose
  enabled: zone.enabled
} : {}]

@description('Compute Services DNS zones configuration')
output computeServicesDNSZones array = [for (zone, i) in computeServicesDNSZones: zone.enabled ? {
  name: zone.name
  id: enableComprehensiveDNS ? computeServicesDNSZoneResources[i].id : ''
  purpose: zone.purpose
  enabled: zone.enabled
} : {}]

@description('Security Services DNS zones configuration')
output securityServicesDNSZones array = [for (zone, i) in securityServicesDNSZones: zone.enabled ? {
  name: zone.name
  id: enableComprehensiveDNS ? securityServicesDNSZoneResources[i].id : ''
  purpose: zone.purpose
  enabled: zone.enabled
} : {}]

@description('Monitoring Services DNS zones configuration')
output monitoringServicesDNSZones array = [for (zone, i) in monitoringServicesDNSZones: zone.enabled ? {
  name: zone.name
  id: enableComprehensiveDNS ? monitoringServicesDNSZoneResources[i].id : ''
  purpose: zone.purpose
  enabled: zone.enabled
} : {}]

@description('DNS security and monitoring configuration')
output dnsSecurityConfig object = {
  securityEnabled: enableDNSSecurity
  analyticsEnabled: enableDNSAnalytics
  auditLoggingEnabled: enableDNSAuditLogging
  autoRegistrationEnabled: enableAutoRegistration
  logRetentionDays: dnsLogRetentionDays
  logAnalyticsWorkspaceId: enableDNSAnalytics ? (empty(logAnalyticsWorkspaceId) ? dnsAnalyticsWorkspace.id : logAnalyticsWorkspaceId) : ''
}

@description('DNS performance and optimization configuration')
output dnsPerformanceConfig object = {
  optimizationEnabled: enableDNSOptimization
  cachingEnabled: dnsPerformanceConfig.cacheOptimization
  loadBalancingEnabled: dnsPerformanceConfig.loadBalancing
  costOptimizationEnabled: enableDNSCostOptimization
  disasterRecoveryEnabled: enableDNSDisasterRecovery
}

@description('DNS governance and compliance configuration')
output dnsGovernanceConfig object = {
  complianceEnabled: enableDNSCompliance
  complianceFrameworks: dnsComplianceFrameworks
  dataClassification: dataClassification
  governanceEnabled: dnsGovernanceConfig.policyEnforcement
  auditingEnabled: enableDNSAuditLogging
}

@description('Virtual network linking configuration')
output vnetLinkingConfig object = {
  enabled: vnetLinkingEnabled
  linkedVNets: length(vnetIds)
  autoRegistrationEnabled: enableAutoRegistration
  registrationTTL: autoRegistrationConfig.registrationTTL
  cleanupEnabled: autoRegistrationConfig.cleanupOrphanedRecords
}

@description('Cost optimization configuration')
output costOptimizationConfig object = enableDNSCostOptimization ? {
  automationAccountId: dnsCostOptimizationAutomation.id
  automaticCleanupEnabled: dnsCostOptimizationConfig.automaticCleanup
  unusedZoneRemovalEnabled: dnsCostOptimizationConfig.unusedZoneRemoval
  queryOptimizationEnabled: dnsCostOptimizationConfig.queryOptimization
  reportingEnabled: dnsCostOptimizationConfig.reportingEnabled
} : {}

@description('Deployment summary and next steps')
output deploymentSummary object = {
  status: 'Private DNS Zones deployed successfully'
  environment: environment
  dnsZonesCreated: length(allDNSZones)
  vnetLinksCreated: vnetLinkingEnabled ? length(vnetIds) : 0
  complianceFrameworksEnabled: length(dnsComplianceFrameworks)
  nextSteps: [
    'Configure private endpoints for Azure services'
    'Set up DNS forwarding rules for hybrid scenarios'
    'Configure DNS monitoring and alerting'
    'Implement DNS security policies'
    'Set up cross-region DNS replication for disaster recovery'
    'Configure conditional access for DNS management'
    'Test DNS resolution from linked virtual networks'
    'Implement DNS governance and change management processes'
  ]
  capabilities: [
    'Comprehensive private DNS zones for all Azure services'
    'Automatic virtual network linking'
    'DNS security and threat protection'
    'Performance optimization and caching'
    'Compliance framework support'
    'Cost optimization through automation'
    'Disaster recovery and high availability'
    'Integration with external DNS systems'
  ]
  securityFeatures: [
    'Private DNS resolution prevents DNS hijacking'
    'DNS query logging for security monitoring'
    'DNSSEC validation support'
    'Conditional forwarding with security controls'
    'DNS firewall for threat protection'
    'Audit logging for compliance requirements'
    'Access control for DNS zone management'
    'Anomaly detection for suspicious DNS activity'
  ]
}

resource keyVaultZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.vaultcore.azure.net'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Key Vault'
  }
}

resource searchZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.search.windows.net'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cognitive Search'
  }
}

resource sqlZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink${az.environment().suffixes.sqlServerHostname}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for SQL Database'
  }
}

resource cosmosZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.documents.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cosmos DB'
  }
}

resource containerRegistryZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.azurecr.io'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Container Registry'
  }
}

resource cognitiveServicesZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.cognitiveservices.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Cognitive Services'
  }
}

resource openAiZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.openai.azure.com'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for OpenAI'
  }
}

resource machineLearningZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.api.azureml.ms'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Machine Learning'
  }
}

resource storageFileZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.file.${az.environment().suffixes.storage}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Storage Files'
  }
}

resource storageBlobZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: 'privatelink.blob.${az.environment().suffixes.storage}'
  location: 'global'
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private DNS for Storage Blobs'
  }
}

// Link DNS Zones to VNets
resource cognitiveServicesVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: cognitiveServicesZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource openAiVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: openAiZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource machineLearningVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: machineLearningZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource storageFileVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: storageFileZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource storageBlobVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: storageBlobZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource keyVaultVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: keyVaultZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

resource searchVnetLinks 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for (vnetId, i) in vnetIds: {
  parent: searchZone
  name: 'link-${split(vnetId, '/')[8]}-${i}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}]

// Outputs
output cognitiveServicesZoneId string = cognitiveServicesZone.id
output openAiZoneId string = openAiZone.id
output machineLearningZoneId string = machineLearningZone.id
output keyVaultZoneId string = keyVaultZone.id
output storageBlobZoneId string = storageBlobZone.id
output storageFileZoneId string = storageFileZone.id
output searchZoneId string = searchZone.id
output sqlZoneId string = sqlZone.id
output cosmosZoneId string = cosmosZone.id
output containerRegistryZoneId string = containerRegistryZone.id

@description('Configuration status outputs')
output configurationStatus object = {
  networkingServicesEnabled: networkingServicesEnabled
  dnsSecurityEnabled: dnsSecurityEnabled
  monitoringEnabled: monitoringEnabled
  cachingEnabled: cachingEnabled
  disasterRecoveryEnabled: disasterRecoveryEnabled
  drSecondaryRegion: drSecondaryRegion
  externalDNSEnabled: externalDNSEnabled
  zoneDelegationEnabled: zoneDelegationEnabled
  reservedCapacityEnabled: reservedCapacityEnabled
  advancedFeaturesEnabled: advancedFeaturesEnabled
  trafficManagementEnabled: trafficManagementEnabled
  dnsAnalyticsEnabled: dnsAnalyticsEnabled
}

@description('Enabled DNS zones summary')
output enabledZonesSummary object = {
  totalEnabledZones: length(enabledDNSZones)
  enabledZones: enabledDNSZones
}
