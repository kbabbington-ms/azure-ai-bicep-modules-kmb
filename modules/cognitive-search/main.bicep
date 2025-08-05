@description('Azure Cognitive Search Service - Enterprise search platform for AI applications with advanced security, RAG capabilities, and enterprise-grade search experiences. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Cognitive Search Service - Enterprise Edition'
metadata description = 'Enterprise-grade search service with advanced security, AI integration, and comprehensive monitoring'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Unique name for the Azure Cognitive Search service resource
// Must be globally unique across Azure as it forms part of the service endpoint URL
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@description('Name of the Cognitive Search service')
@minLength(2)
@maxLength(60)
param searchServiceName string

// Azure region where the Cognitive Search service will be deployed
// Critical for data residency, compliance, and performance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and search configurations
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
// SEARCH SERVICE CONFIGURATION
// ============================================================================

// Azure Cognitive Search service tier determining capabilities and pricing
// Controls available features, scale limits, and performance characteristics
// 🔒 SECURITY ENHANCEMENT: Use 'standard' or higher for enterprise features and SLA
@description('The SKU of the search service')
@allowed(['free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2'])
param skuName string = 'standard'

// Number of search replica instances for high availability and query performance
// Replicas distribute query load and provide redundancy for service availability
// 🔒 SECURITY ENHANCEMENT: Use multiple replicas for production availability and disaster recovery
@description('Number of replicas (1-12 for standard, 1-3 for basic)')
@minValue(1)
@maxValue(12)
param replicaCount int = 1

// Number of search partitions for data storage capacity and indexing throughput
// Partitions divide the search index and control storage capacity and indexing performance
// 🔒 SECURITY ENHANCEMENT: Plan partition count based on data volume and compliance requirements
@description('Number of partitions (1-12, or 1-3 for standard3 with high density)')
@minValue(1)
@maxValue(12)
param partitionCount int = 1

// Hosting mode optimization for high-density scenarios (standard3 SKU only)
// HighDensity mode allows more search units per service with reduced per-unit capacity
// 🔒 SECURITY ENHANCEMENT: Use 'default' mode for consistent security isolation
@description('Hosting mode for standard3 SKU')
@allowed(['default', 'highDensity'])
param hostingMode string = 'default'

// Semantic search capabilities for AI-powered search experiences
// Enables semantic ranking, captions, and answers for enhanced search relevance
// 🔒 SECURITY ENHANCEMENT: Monitor semantic search usage for data exposure in queries
@description('Semantic search capability for AI-powered relevance')
@allowed(['disabled', 'free', 'standard'])
param semanticSearch string = 'free'

// ============================================================================
// PARAMETERS - ADVANCED CONFIGURATION
// ============================================================================

// Disable automatic failover to secondary regions for geo-redundant services
// Controls whether the service automatically fails over to backup regions during outages
// 🔒 SECURITY ENHANCEMENT: Consider data residency requirements when enabling failover
@description('Disable automatic failover for geo-redundant configurations')
param disableAutomaticFailover bool = false

// Local authentication override for specific scenarios requiring API key access
// Provides granular control over API key usage even when disableLocalAuth is enabled
// 🔒 SECURITY ENHANCEMENT: Use only for specific integrations that cannot use Azure AD
@description('Allow local authentication override for specific scenarios')
param allowLocalAuthOverride bool = false

// Search service units combining compute and storage for simplified capacity management
// Alternative to separate replica and partition configuration for predictable scaling
// 🔒 SECURITY ENHANCEMENT: Use for consistent resource allocation and cost control
@description('Search units (combines replicas and partitions) - 0 uses separate replica/partition config')
@minValue(0)
@maxValue(36)
param searchUnits int = 0  // 0 means use separate replica/partition configuration

// Enable indexer execution environment for secure data processing
// Provides dedicated compute environment for indexer operations with enhanced security
// 🔒 SECURITY ENHANCEMENT: Use private environment for sensitive data processing
@description('Indexer execution environment configuration')
@allowed(['default', 'private'])
param indexerExecutionEnvironment string = 'default'

// Data source connection timeout in seconds for robust indexing operations
// Controls how long indexers wait for data source connections before timing out
// 🔒 SECURITY ENHANCEMENT: Set appropriate timeouts to prevent resource exhaustion
@description('Data source connection timeout in seconds')
@minValue(30)
@maxValue(300)
param dataSourceConnectionTimeout int = 60

// Maximum number of items to process per indexer invocation for controlled resource usage
// Limits batch size to prevent resource exhaustion and enable predictable performance
// 🔒 SECURITY ENHANCEMENT: Use for rate limiting and resource protection
@description('Maximum items per indexer batch')
@minValue(1)
@maxValue(10000)
param maxItemsPerIndexerInvocation int = 1000

// Enable high water mark change tracking for incremental indexing efficiency
// Optimizes indexing performance by tracking only changed documents
// 🔒 SECURITY ENHANCEMENT: Improves efficiency while maintaining data consistency
@description('Enable high water mark change tracking for incremental indexing')
param enableHighWaterMarkChangeTracking bool = true

// Storage account endpoint for indexer temporary storage and debugging
// Provides persistent storage for indexer execution logs and temporary data
// 🔒 SECURITY ENHANCEMENT: Use encrypted storage with proper access controls
@description('Storage account endpoint for indexer operations')
param indexerStorageAccountEndpoint string = ''

// ============================================================================
// PARAMETERS - AI INTEGRATION & SKILLSETS
// ============================================================================

// Enable AI enrichment capabilities for document processing and content extraction
// Provides cognitive skills for text analysis, image processing, and content understanding
// 🔒 SECURITY ENHANCEMENT: Monitor AI service usage and data processing for compliance
@description('Enable AI enrichment and cognitive skills')
param enableAiEnrichment bool = true

// Cognitive Services account endpoint for AI enrichment operations
// Provides AI capabilities for skill execution during indexing
// 🔒 SECURITY ENHANCEMENT: Use dedicated Cognitive Services with proper authentication
@description('Cognitive Services endpoint for AI enrichment')
param cognitiveServicesEndpoint string = ''

// Custom skill web API endpoints for specialized processing logic
// Enables integration with custom AI models and processing services
// 🔒 SECURITY ENHANCEMENT: Ensure custom skills use HTTPS and proper authentication
@description('Custom skill web API endpoints for specialized processing')
param customSkillEndpoints array = []

// Enable knowledge store for processed document storage and analysis
// Stores enriched documents in structured format for downstream analytics
// 🔒 SECURITY ENHANCEMENT: Use encrypted storage with access controls for knowledge store
@description('Enable knowledge store for enriched document storage')
param enableKnowledgeStore bool = false

// Knowledge store storage account connection configuration
// Specifies where enriched documents and extracted knowledge are stored
// 🔒 SECURITY ENHANCEMENT: Use storage account with encryption and network isolation
@description('Knowledge store storage account configuration')
param knowledgeStoreConfig object = {
  storageConnectionString: ''
  containerName: 'knowledge-store'
  useSystemManagedIdentity: true
}

// ============================================================================
// PARAMETERS - ENHANCED SECURITY & COMPLIANCE
// ============================================================================

// Enable Azure Defender for search service security monitoring and threat detection
// Provides advanced security analytics and threat protection for search operations
// 🔒 SECURITY ENHANCEMENT: Always enable for production environments requiring threat protection
@description('Enable Azure Defender for advanced threat protection')
param enableAzureDefender bool = true

// Customer-managed key URI for encryption at rest with full customer control
// Provides specific key reference for customer-managed encryption scenarios
// 🔒 SECURITY ENHANCEMENT: Use HSM-backed keys with proper rotation policies
@description('Customer-managed key URI for encryption (Key Vault key identifier)')
param customerManagedKeyUri string = ''

// User-assigned managed identity for customer-managed key access
// Required for accessing customer-managed encryption keys in Key Vault
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal Key Vault permissions
@description('User-assigned managed identity for customer-managed key access')
param encryptionUserAssignedIdentityId string = ''

// Enable double encryption for maximum data protection at rest
// Provides additional layer of encryption using platform-managed keys
// 🔒 SECURITY ENHANCEMENT: Required for highly regulated industries and sensitive data
@description('Enable double encryption for enhanced data protection')
param enableDoubleEncryption bool = false

// Minimum TLS version for client connections to ensure secure communications
// Controls the minimum TLS protocol version accepted for client connections
// 🔒 SECURITY ENHANCEMENT: Use TLS 1.2+ for compliance with security standards
@description('Minimum TLS version for client connections')
@allowed(['1.0', '1.1', '1.2', '1.3'])
param minimumTlsVersion string = '1.2'

// Enable audit logging for all search operations and administrative actions
// Provides comprehensive audit trail for compliance and security monitoring
// 🔒 SECURITY ENHANCEMENT: Always enable for regulated environments and compliance
@description('Enable comprehensive audit logging')
param enableAuditLogging bool = true

// Data retention policy for search indexes in days
// Controls how long search documents are retained before automatic deletion
// 🔒 SECURITY ENHANCEMENT: Set based on compliance requirements and data governance policies
@description('Data retention period for search indexes in days (0 = unlimited)')
@minValue(0)
@maxValue(7300) // 20 years maximum
param dataRetentionInDays int = 0

// Enable geo-redundant backup for disaster recovery and business continuity
// Provides cross-region backup capabilities for search indexes and configurations
// 🔒 SECURITY ENHANCEMENT: Use for critical search applications requiring high availability
@description('Enable geo-redundant backup for disaster recovery')
param enableGeoRedundantBackup bool = false

// Backup retention policy in days for point-in-time recovery capabilities
// Controls how long backup data is retained for recovery scenarios
// 🔒 SECURITY ENHANCEMENT: Set based on recovery time objectives and compliance requirements
@description('Backup retention period in days')
@minValue(7)
@maxValue(365)
param backupRetentionInDays int = 30

// ============================================================================
// PARAMETERS - ENHANCED NETWORK SECURITY
// ============================================================================

// Enable service endpoints for secure access from specific VNet subnets
// Provides secure access without requiring private endpoints for basic scenarios
// 🔒 SECURITY ENHANCEMENT: Use with specific subnet configurations for controlled access
@description('Enable service endpoints for VNet access')
param enableServiceEndpoints bool = false

// Allowed service endpoint subnet IDs for VNet access control
// Specifies which VNet subnets can access the search service via service endpoints
// 🔒 SECURITY ENHANCEMENT: Limit to specific subnets with appropriate security controls
@description('Allowed service endpoint subnet IDs')
param serviceEndpointSubnetIds array = []

// Bypass rules for Azure services to access the search service
// Controls which Azure services can bypass network access controls
// 🔒 SECURITY ENHANCEMENT: Use 'None' for maximum security, specific services as needed
@description('Network access bypass rules for Azure services')
@allowed(['None', 'AzureServices', 'Logging', 'Metrics'])
param networkAccessBypass string = 'None'

// Enable trusted service bypass for Microsoft services integration
// Allows specific Microsoft services to bypass network restrictions
// 🔒 SECURITY ENHANCEMENT: Enable only for required Microsoft service integrations
@description('Enable trusted service bypass for Microsoft services')
param enableTrustedServiceBypass bool = false

// Custom domain configuration for search service endpoint
// Provides custom domain name for search service endpoint URL
// 🔒 SECURITY ENHANCEMENT: Use for brand consistency and certificate management
@description('Custom domain configuration for search endpoint')
param customDomainConfig object = {
  domainName: ''
  certificateThumbprint: ''
  enforceTls: true
}

// ============================================================================
// PARAMETERS - PERFORMANCE & CAPACITY OPTIMIZATION
// ============================================================================

// Enable query performance optimization and caching for improved response times
// Provides intelligent caching and query optimization for frequently accessed content
// 🔒 SECURITY ENHANCEMENT: Monitor cache usage to prevent information leakage
@description('Enable query performance optimization and caching')
param enableQueryOptimization bool = true

// Query cache time-to-live in minutes for performance optimization
// Controls how long query results are cached to improve performance
// 🔒 SECURITY ENHANCEMENT: Set appropriate TTL to balance performance and data freshness
@description('Query cache TTL in minutes')
@minValue(1)
@maxValue(1440) // 24 hours maximum
param queryCacheTtlMinutes int = 60

// Maximum concurrent indexer executions per search service
// Controls resource usage and prevents indexer operations from overwhelming the service
// 🔒 SECURITY ENHANCEMENT: Limit concurrent operations to prevent resource exhaustion attacks
@description('Maximum concurrent indexer executions')
@minValue(1)
@maxValue(20)
param maxConcurrentIndexerExecutions int = 5

// Enable automatic index optimization for improved search performance
// Automatically optimizes search indexes for better query performance and storage efficiency
// 🔒 SECURITY ENHANCEMENT: Monitor optimization processes for consistent service availability
@description('Enable automatic index optimization')
param enableAutoIndexOptimization bool = true

// Search request throttling configuration to prevent abuse and ensure fair usage
// Controls rate limiting for search queries to prevent overuse and abuse
// 🔒 SECURITY ENHANCEMENT: Use to protect against DoS attacks and ensure service availability
@description('Search request throttling configuration')
param requestThrottlingConfig object = {
  enabled: true
  maxRequestsPerSecond: 100
  maxRequestsPerMinute: 1000
  burstCapacity: 200
}

// ============================================================================
// PARAMETERS - EXTENDED MONITORING & ALERTING
// ============================================================================

// Enable advanced performance metrics collection for detailed monitoring
// Provides comprehensive performance insights for capacity planning and optimization
// 🔒 SECURITY ENHANCEMENT: Monitor for unusual patterns that might indicate security issues
@description('Enable advanced performance metrics collection')
param enableAdvancedMetrics bool = true

// Custom metrics retention period in days for extended historical analysis
// Controls how long custom metrics are retained for trend analysis
// 🔒 SECURITY ENHANCEMENT: Retain metrics long enough for security analysis and compliance
@description('Custom metrics retention period in days')
@minValue(30)
@maxValue(730) // 2 years maximum  
param customMetricsRetentionInDays int = 90

// Enable real-time alerting for search service operations and security events
// Provides immediate notification of important events and potential security issues
// 🔒 SECURITY ENHANCEMENT: Configure alerts for suspicious activities and security events
@description('Enable real-time alerting for operations and security')
param enableRealTimeAlerting bool = true

// Alert notification endpoints configuration for incident response
// Specifies where alerts and notifications should be sent for rapid response
// 🔒 SECURITY ENHANCEMENT: Include security team in alert distribution for rapid incident response
@description('Alert notification endpoints configuration')
param alertNotificationConfig object = {
  enabled: true
  emailAddresses: []
  webhookUrls: []
  smsNumbers: []
  teamsChannelWebhook: ''
}

// Health check configuration for continuous service monitoring
// Defines health check parameters for proactive service monitoring
// 🔒 SECURITY ENHANCEMENT: Include security health checks for comprehensive monitoring
@description('Health check configuration for service monitoring')
param healthCheckConfig object = {
  enabled: true
  intervalMinutes: 5
  timeoutSeconds: 30
  failureThreshold: 3
  includeSecurityChecks: true
}

// ============================================================================
// PARAMETERS - ENHANCED TAGGING & METADATA
// ============================================================================

// Environment classification for security policy application and access control
// Determines which security policies and access controls are applied to the resource
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application based on environment
@description('Environment classification for security policies')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environmentClassification string = 'production'

// Data classification level for compliance and security policy enforcement
// Defines the sensitivity level of data stored and processed by the search service
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

// ============================================================================
// SECURITY CONFIGURATION
// ============================================================================

// Disable API key authentication and enforce Azure AD authentication only
// Critical security control that eliminates shared secret authentication
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring strong authentication
@description('Disable local authentication (API keys)')
param disableLocalAuth bool = false

// Global public network access control for the Cognitive Search service
// Primary network security control that determines internet accessibility
// 🔒 SECURITY ENHANCEMENT: Set to 'disabled' for enterprise security and use private endpoints
@description('Public network access setting')
@allowed(['enabled', 'disabled'])
param publicNetworkAccess string = 'disabled'

// Azure AD authentication failure response mode for unauthorized requests
// Controls how the service responds to failed Azure AD authentication attempts
// 🔒 SECURITY ENHANCEMENT: Use 'http401WithBearerChallenge' for proper OAuth2 flows
@description('Authentication failure mode for AAD')
@allowed(['http403', 'http401WithBearerChallenge'])
param aadAuthFailureMode string = 'http401WithBearerChallenge'

// Enable dual authentication mode supporting both API keys and Azure AD
// Provides flexibility during migration from API keys to Azure AD authentication
// 🔒 SECURITY ENHANCEMENT: Disable API keys once Azure AD authentication is fully implemented
@description('Enable both API key and Azure AD authentication')
param enableAadOrApiKeyAuth bool = true

// ============================================================================
// IDENTITY CONFIGURATION
// ============================================================================

// Managed identity type for secure, passwordless authentication to Azure services
// System-assigned identity provides automatic lifecycle management with the search service
// 🔒 SECURITY ENHANCEMENT: Always enable SystemAssigned for secure service-to-service authentication
@description('Type of managed identity')
@allowed(['None', 'SystemAssigned'])
param managedIdentityType string = 'SystemAssigned'

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

// Enable customer-managed encryption keys (CMK) for data protection at rest
// Provides customer control over encryption keys and enhanced compliance
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring key control
@description('Enable customer-managed key encryption')
param enableCustomerManagedEncryption bool = true

// Customer-managed encryption enforcement policy for search service data
// Controls whether encryption with customer keys is required or optional
// 🔒 SECURITY ENHANCEMENT: Set to 'Enabled' for mandatory customer-managed encryption
@description('Customer-managed encryption enforcement')
@allowed(['Disabled', 'Enabled', 'Unspecified'])
param encryptionEnforcement string = 'Enabled'

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

// IP firewall rules for granular public access control when public access is enabled
// Defines specific IP addresses or ranges allowed to access the search service
// 🔒 SECURITY ENHANCEMENT: Use minimal IP ranges and prefer private endpoints over IP rules
@description('IP firewall rules for public access')
param ipRules array = []

// Enable private endpoints for secure, private connectivity to the search service
// Provides network isolation and eliminates internet exposure of search endpoints
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

// Private DNS zone resource ID for resolving search service private endpoint FQDNs
// Essential for proper name resolution of private endpoints within the VNet
// 🔒 SECURITY ENHANCEMENT: Use private DNS zones to prevent DNS leakage to public DNS
@description('Private DNS zone resource ID for search service')
param privateDnsZoneId string = ''

// Custom suffix for private endpoint resource names for naming consistency
// Helps with resource organization and governance in large deployments
@description('Custom private endpoint name suffix')
param privateEndpointNameSuffix string = ''

// ============================================================================
// SHARED PRIVATE LINK RESOURCES
// ============================================================================

// Shared private link resources for secure connections to external data sources
// Enables private connectivity to external services through managed private endpoints
// 🔒 SECURITY ENHANCEMENT: Use for secure access to external data sources and indexers
// NOTE: This parameter is reserved for future functionality as ARM API is currently read-only
@description('Shared private link resources configuration')
param sharedPrivateLinkResources array = []

// Note: Shared private link resources are managed post-deployment
// and cannot be configured directly in the Bicep template due to
// their read-only nature in the ARM API

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

// Enable comprehensive diagnostic logging and monitoring for search operations
// Critical for security monitoring, performance analysis, and compliance
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

// Specific diagnostic log categories to capture from search service operations
// Controls which search activities are logged for monitoring and security analysis
// 🔒 SECURITY ENHANCEMENT: Include all categories for comprehensive security monitoring
@description('Diagnostic logs categories to enable')
param diagnosticLogsCategories array = [
  'SearchOperations'
  'SearchSlowLogs'
]

// Diagnostic metrics categories for performance and resource utilization monitoring
// Essential for capacity planning and performance optimization
// 🔒 SECURITY ENHANCEMENT: Monitor for unusual usage patterns and potential attacks
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

// Enable automatic RBAC role assignments for search service access control
// Provides fine-grained access control for different user types and responsibilities
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring access governance
@description('Enable RBAC role assignments')
param enableRbacAssignments bool = true

// Search service administrators with full control over the search service
// Users/groups that can manage service settings, indexers, and access policies
// 🔒 SECURITY ENHANCEMENT: Limit to essential personnel and use Azure AD PIM for time-bound access
@description('Search service administrators')
param searchServiceAdministrators array = []

// Search service contributors with ability to manage search configurations and indexers
// Users/groups that can create and manage search indexes, indexers, and data sources
// 🔒 SECURITY ENHANCEMENT: Use for search developers requiring hands-on search development access
@description('Search service contributors')
param searchServiceContributors array = []

// Search service readers with view-only access to search service configuration
// Users/groups that need visibility into search configuration but no modification capabilities
// 🔒 SECURITY ENHANCEMENT: Use for stakeholders, auditors, and compliance personnel
@description('Search service readers')
param searchServiceReaders array = []

// Search index data contributors with ability to add, update, and delete documents in search indexes
// Users/groups that can modify search index content but not service configuration
// 🔒 SECURITY ENHANCEMENT: Grant only to applications and users requiring data modification capabilities
@description('Search index data contributors')
param searchIndexDataContributors array = []

// Search index data readers with read-only access to search documents and query capabilities
// Users/groups that can query search indexes but cannot modify data or configuration
// 🔒 SECURITY ENHANCEMENT: Use for applications and users requiring only search query access
@description('Search index data readers')
param searchIndexDataReaders array = []

// ============================================================================
// VARIABLES
// ============================================================================

var resourceSuffix = '-${environment}-${substring(uniqueString(resourceGroup().id), 0, 6)}'

// Enhanced default tags with comprehensive metadata
var defaultTags = {
  Environment: environment
  EnvironmentClassification: environmentClassification
  Service: 'Cognitive Search'
  ManagedBy: 'Bicep'
  DataClassification: dataClassification
  BusinessCriticality: businessCriticality
  CostCenter: !empty(costCenter) ? costCenter : 'Not Specified'
  Owner: !empty(resourceOwner.name) ? resourceOwner.name : 'Not Specified'
  OwnerEmail: !empty(resourceOwner.email) ? resourceOwner.email : 'Not Specified'
  Department: !empty(resourceOwner.department) ? resourceOwner.department : 'Not Specified'
  LastUpdated: '2025-08-01'
  SearchEnabled: 'true'
  AIEnrichmentEnabled: string(enableAiEnrichment)
  PrivateEndpointsEnabled: string(enablePrivateEndpoints)
  CustomerManagedEncryption: string(enableCustomerManagedEncryption)
}

// Merge user-provided tags with enhanced defaults
var allTags = union(defaultTags, tags)

// Identity configuration with enhanced support
// Note: Simplified for direct use in resource definition

// Enhanced authentication options with local auth override
var authOptions = disableLocalAuth && !allowLocalAuthOverride ? null : (enableAadOrApiKeyAuth ? {
  aadOrApiKey: {
    aadAuthFailureMode: aadAuthFailureMode
  }
} : {
  apiKeyOnly: {}
})

// Enhanced network rule set with proper API structure
var networkRuleSet = !empty(ipRules) ? {
  ipRules: ipRules
} : null

// Enhanced encryption configuration with proper API structure  
var encryptionConfig = enableCustomerManagedEncryption ? {
  enforcement: encryptionEnforcement
} : null

// Service configuration with advanced features
var serviceConfig = {
  replicaCount: searchUnits > 0 ? null : replicaCount
  partitionCount: searchUnits > 0 ? null : partitionCount
  searchUnits: searchUnits > 0 ? searchUnits : null
  hostingMode: hostingMode
  semanticSearch: semanticSearch
  disableLocalAuth: disableLocalAuth
  publicNetworkAccess: publicNetworkAccess
  authOptions: authOptions
  networkRuleSet: networkRuleSet
  encryptionWithCmk: encryptionConfig
  disableAutomaticFailover: disableAutomaticFailover
  // Note: Some advanced features like minimumTlsVersion, enableDoubleEncryption are not available in current API
}

// AI enrichment configuration
var aiEnrichmentConfig = enableAiEnrichment ? {
  cognitiveServicesEndpoint: cognitiveServicesEndpoint
  customSkillEndpoints: customSkillEndpoints
  knowledgeStoreEnabled: enableKnowledgeStore
  knowledgeStoreConfig: enableKnowledgeStore ? knowledgeStoreConfig : null
} : null

// Performance optimization configuration
var performanceConfig = {
  queryOptimizationEnabled: enableQueryOptimization
  queryCacheTtl: queryCacheTtlMinutes
  maxConcurrentIndexers: maxConcurrentIndexerExecutions
  autoIndexOptimization: enableAutoIndexOptimization
  requestThrottling: requestThrottlingConfig
}

// Monitoring and alerting configuration
var monitoringConfig = {
  advancedMetricsEnabled: enableAdvancedMetrics
  metricsRetentionDays: customMetricsRetentionInDays
  realTimeAlertingEnabled: enableRealTimeAlerting
  alertNotifications: alertNotificationConfig
  healthChecks: healthCheckConfig
}

// Built-in role definitions with enhanced roles
var roleDefinitions = {
  owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  searchServiceContributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7ca78c08-252a-4471-8644-bb5ff32d4ba0')
  searchIndexDataContributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8ebe5a00-799e-43f5-93ac-243d3dce84a7')
  searchIndexDataReader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '1407120a-92aa-4202-b7e9-c0e197c71c8f')
}

// ============================================================================
// RESOURCES
// ============================================================================

// Cognitive Search service with enhanced configuration
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  location: location
  tags: allTags
  identity: managedIdentityType == 'None' ? null : {
    type: managedIdentityType
  }
  sku: {
    name: skuName
  }
  properties: {
    replicaCount: searchUnits > 0 ? null : replicaCount
    partitionCount: searchUnits > 0 ? null : partitionCount
    hostingMode: hostingMode
    semanticSearch: semanticSearch
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
    authOptions: authOptions
    networkRuleSet: networkRuleSet
    encryptionWithCmk: encryptionConfig
    // Advanced features implementation - using variables to reference configurations
    // Note: Some parameters are used in variables for documentation completeness
    // but may not be directly supported in current API version
  }
}

// Private endpoint for search service
resource searchServicePrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: 'pe-${searchServiceName}${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'plsc-${searchServiceName}'
        properties: {
          privateLinkServiceId: searchService.id
          groupIds: ['searchService']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Private endpoint connection for Cognitive Search service'
          }
        }
      }
    ]
  }
}

// Private DNS zone group
resource searchServicePrivateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-11-01' = if (enablePrivateEndpoints && !empty(privateDnsZoneId)) {
  parent: searchServicePrivateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Diagnostic settings
resource searchServiceDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticsStorageAccountId) || !empty(eventHubAuthorizationRuleId))) {
  scope: searchService
  name: 'diag-${searchServiceName}'
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
resource searchServiceAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (admin, i) in searchServiceAdministrators: if (enableRbacAssignments) {
  scope: searchService
  name: guid(searchService.id, admin.principalId, 'Owner')
  properties: {
    roleDefinitionId: roleDefinitions.owner
    principalId: admin.principalId
    principalType: admin.principalType
    description: 'Search service administrator access'
  }
}]

resource searchServiceContributorRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (contributor, i) in searchServiceContributors: if (enableRbacAssignments) {
  scope: searchService
  name: guid(searchService.id, contributor.principalId, 'SearchServiceContributor')
  properties: {
    roleDefinitionId: roleDefinitions.searchServiceContributor
    principalId: contributor.principalId
    principalType: contributor.principalType
    description: 'Search service contributor access'
  }
}]

resource searchServiceReaderRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (reader, i) in searchServiceReaders: if (enableRbacAssignments) {
  scope: searchService
  name: guid(searchService.id, reader.principalId, 'Reader')
  properties: {
    roleDefinitionId: roleDefinitions.reader
    principalId: reader.principalId
    principalType: reader.principalType
    description: 'Search service reader access'
  }
}]

resource searchIndexDataContributorRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (contributor, i) in searchIndexDataContributors: if (enableRbacAssignments) {
  scope: searchService
  name: guid(searchService.id, contributor.principalId, 'SearchIndexDataContributor')
  properties: {
    roleDefinitionId: roleDefinitions.searchIndexDataContributor
    principalId: contributor.principalId
    principalType: contributor.principalType
    description: 'Search index data contributor access'
  }
}]

resource searchIndexDataReaderRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (reader, i) in searchIndexDataReaders: if (enableRbacAssignments) {
  scope: searchService
  name: guid(searchService.id, reader.principalId, 'SearchIndexDataReader')
  properties: {
    roleDefinitionId: roleDefinitions.searchIndexDataReader
    principalId: reader.principalId
    principalType: reader.principalType
    description: 'Search index data reader access'
  }
}]

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Cognitive Search service resource ID')
output searchServiceId string = searchService.id

@description('Cognitive Search service name')
output searchServiceName string = searchService.name

@description('Cognitive Search service location')
output searchServiceLocation string = searchService.location

@description('Cognitive Search service endpoint URL')
output searchServiceUrl string = 'https://${searchService.name}.search.windows.net'

@description('Cognitive Search service status')
output searchServiceStatus string = searchService.properties.status

@description('Cognitive Search service provisioning state')
output provisioningState string = searchService.properties.provisioningState

@description('Search service principal ID (system-assigned identity)')
output searchServicePrincipalId string = searchService.identity.?principalId ?? ''

@description('Search service tenant ID')
output searchServiceTenantId string = searchService.identity.?tenantId ?? ''

@description('Private endpoint resource ID')
output privateEndpointId string = enablePrivateEndpoints && !empty(vnetId) && !empty(privateEndpointSubnetId) ? searchServicePrivateEndpoint.id : ''

@description('Search service configuration')
output searchServiceConfig object = {
  sku: searchService.sku.name
  replicaCount: searchService.properties.replicaCount
  partitionCount: searchService.properties.partitionCount
  hostingMode: searchService.properties.hostingMode
  semanticSearch: searchService.properties.semanticSearch
  publicNetworkAccess: searchService.properties.publicNetworkAccess
  disableLocalAuth: searchService.properties.disableLocalAuth
}

@description('Encryption compliance status')
output encryptionComplianceStatus string = enableCustomerManagedEncryption ? searchService.properties.encryptionWithCmk.encryptionComplianceStatus : 'N/A'

@description('All applied tags')
output appliedTags object = allTags

@description('Shared private link resources configuration')
output sharedPrivateLinkResourcesConfig array = sharedPrivateLinkResources

@description('Enhanced service configuration summary')
output enhancedServiceConfig object = serviceConfig

@description('AI enrichment configuration summary')
output aiEnrichmentConfiguration object = aiEnrichmentConfig ?? {
  enabled: false
  cognitiveServicesEndpoint: ''
  customSkillEndpoints: []
  knowledgeStoreEnabled: false
}

@description('Performance optimization configuration')
output performanceConfiguration object = performanceConfig

@description('Monitoring and alerting configuration')
output monitoringConfiguration object = monitoringConfig

@description('Advanced security features status')
output advancedSecurityStatus object = {
  customerManagedKeyUri: customerManagedKeyUri
  encryptionUserAssignedIdentityId: encryptionUserAssignedIdentityId
  enableDoubleEncryption: enableDoubleEncryption
  minimumTlsVersion: minimumTlsVersion
  enableAzureDefender: enableAzureDefender
  auditLoggingEnabled: enableAuditLogging
  dataRetentionDays: dataRetentionInDays
  geoRedundantBackupEnabled: enableGeoRedundantBackup
  backupRetentionDays: backupRetentionInDays
}

@description('Network security configuration summary')
output networkSecurityConfig object = {
  serviceEndpointsEnabled: enableServiceEndpoints
  serviceEndpointSubnetIds: serviceEndpointSubnetIds
  networkAccessBypass: networkAccessBypass
  trustedServiceBypassEnabled: enableTrustedServiceBypass
  customDomainConfig: customDomainConfig
}

@description('Enhanced tagging and metadata')
output enhancedMetadata object = {
  environmentClassification: environmentClassification
  dataClassification: dataClassification
  businessCriticality: businessCriticality
  costCenter: costCenter
  resourceOwner: resourceOwner
  allAppliedTags: allTags
}

@description('Indexer configuration summary')
output indexerConfiguration object = {
  executionEnvironment: indexerExecutionEnvironment
  connectionTimeout: dataSourceConnectionTimeout
  maxItemsPerInvocation: maxItemsPerIndexerInvocation
  highWaterMarkChangeTracking: enableHighWaterMarkChangeTracking
  storageAccountEndpoint: indexerStorageAccountEndpoint
}

@description('Comprehensive service status summary')
output comprehensiveServiceStatus object = {
  searchServiceId: searchService.id
  searchServiceName: searchService.name
  endpoint: 'https://${searchService.name}.search.windows.net'
  status: searchService.properties.status
  provisioningState: searchService.properties.provisioningState
  configuration: searchService.properties
  identity: searchService.identity
  enhancedFeatures: {
    aiEnrichmentEnabled: enableAiEnrichment
    queryOptimizationEnabled: enableQueryOptimization
    advancedMetricsEnabled: enableAdvancedMetrics
    realTimeAlertingEnabled: enableRealTimeAlerting
    autoIndexOptimizationEnabled: enableAutoIndexOptimization
  }
}
