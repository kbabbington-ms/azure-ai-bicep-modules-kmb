// ============================================================================
// Azure Cognitive Search Service - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// ============================================================================

// BASIC CONFIGURATION PARAMETERS
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
@description('Semantic search capability')
@allowed(['disabled', 'free', 'standard'])
param semanticSearch string = 'free'

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

var defaultTags = {
  Environment: environment
  Service: 'Cognitive Search'
  ManagedBy: 'Bicep'
}

var allTags = union(defaultTags, tags)

// Identity configuration
var identityConfig = managedIdentityType == 'None' ? null : {
  type: managedIdentityType
}

// Authentication options
var authOptions = disableLocalAuth ? null : (enableAadOrApiKeyAuth ? {
  aadOrApiKey: {
    aadAuthFailureMode: aadAuthFailureMode
  }
} : {
  apiKeyOnly: {}
})

// Network rule set
var networkRuleSet = !empty(ipRules) ? {
  ipRules: ipRules
} : null

// Encryption configuration
var encryptionConfig = enableCustomerManagedEncryption ? {
  enforcement: encryptionEnforcement
} : null

// Built-in role definitions
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

// Cognitive Search service
resource searchService 'Microsoft.Search/searchServices@2023-11-01' = {
  name: searchServiceName
  location: location
  tags: allTags
  identity: identityConfig
  sku: {
    name: skuName
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
    hostingMode: hostingMode
    semanticSearch: semanticSearch
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
    authOptions: authOptions
    networkRuleSet: networkRuleSet
    encryptionWithCmk: encryptionConfig
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
