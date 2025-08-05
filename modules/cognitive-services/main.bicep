// ============================================================================
// Azure Cognitive Services - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-04
// Description: Comprehensive Cognitive Services account with enterprise security,
//              private endpoints, customer-managed encryption, and zero-trust networking
// ============================================================================

metadata name = 'Azure Cognitive Services - Enterprise Edition'
metadata description = 'Multi-service Cognitive Services account with advanced security and enterprise features'
metadata author = 'Azure AI Platform Team'
metadata version = '1.0.0'

targetScope = 'resourceGroup'

// ============================================================================
// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// Azure region where all resources will be deployed
// Critical for data residency and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and access controls
// 🔒 SECURITY ENHANCEMENT: Use different encryption keys and access policies per environment
@description('Environment name for resource naming and tagging')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'

// Project identifier for resource naming and organizational purposes
// Used in resource naming conventions and cost allocation
@description('Project name for resource naming and tagging')
@minLength(2)
@maxLength(10)
param projectName string = 'ai-enclave'

// Resource tags for governance, cost management, and compliance tracking
// Essential for enterprise resource management and security auditing
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// COGNITIVE SERVICES CONFIGURATION
// ============================================================================

// Custom name for the Cognitive Services account resource
// Provides flexibility for specific naming requirements beyond auto-generation
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@description('Cognitive Services account name (leave empty for auto-generation)')
@minLength(0)
@maxLength(64)
param cognitiveServicesName string = ''

// Type of Cognitive Services account determining available APIs and capabilities
// Multi-service account provides access to all Cognitive Services APIs
// 🔒 SECURITY ENHANCEMENT: Use CognitiveServices for unified access control and monitoring
@description('Cognitive Services kind determining available APIs')
@allowed([
  'CognitiveServices'        // Multi-service account (recommended)
  'ComputerVision'          // Computer Vision API only
  'Face'                    // Face API only
  'TextAnalytics'          // Language services only
  'LUIS'                   // Language Understanding only
  'QnAMaker'               // QnA Maker only
  'SpeechServices'         // Speech services only
  'CustomVision.Training'  // Custom Vision training only
  'CustomVision.Prediction' // Custom Vision prediction only
  'FormRecognizer'         // Document Intelligence only
  'Personalizer'           // Personalizer only
])
param cognitiveServicesKind string = 'CognitiveServices'

// Service tier determining capacity, features, and pricing model
// Controls API request limits, SLA guarantees, and feature availability
// 🔒 SECURITY ENHANCEMENT: Use S0 or higher for production with enhanced security features
@description('Cognitive Services SKU determining capacity and features')
@allowed([
  'F0'  // Free tier - Limited requests, no SLA
  'S0'  // Standard tier - Production workloads
  'S1'  // Standard Plus - Higher throughput
  'S2'  // Standard Premium - Enhanced performance
  'S3'  // Standard Enterprise - Maximum performance
  'S4'  // Standard Maximum - Highest capacity
])
param cognitiveServicesSku string = 'S0'

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

// Controls public internet access to the Cognitive Services endpoint
// Critical security setting that should be disabled for enterprise deployments
// 🔒 SECURITY ENHANCEMENT: Set to false for zero-trust network architecture and use private endpoints
@description('Enable public network access')
param publicNetworkAccess bool = false

// Network access control rules for IP-based and VNet-based restrictions
// Provides fine-grained control over which networks can access the service
// 🔒 SECURITY ENHANCEMENT: Use 'Deny' default action with explicit allow rules for known networks
@description('Network access rules configuration')
param networkAcls object = {
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: []
}

// Enables custom subdomain required for private endpoints and Azure AD authentication
// Essential for token-based authentication instead of API keys
// 🔒 SECURITY ENHANCEMENT: Required for private endpoints and Azure AD integration
@description('Enable custom subdomain (required for private endpoints)')
param enableCustomSubdomain bool = true

// Custom subdomain name for the Cognitive Services endpoint
// Must be globally unique and enables private endpoint functionality
// 🔒 SECURITY ENHANCEMENT: Custom subdomain enables private connectivity and Azure AD auth
@description('Custom subdomain name (leave empty for auto-generation)')
@minLength(0)
@maxLength(64)
param customSubdomainName string = ''

// ============================================================================
// PRIVATE ENDPOINT CONFIGURATION
// ============================================================================

// Enable private endpoints for secure, private connectivity to Cognitive Services
// Provides network isolation and eliminates internet exposure
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring network isolation
@description('Enable private endpoint for Cognitive Services')
param enablePrivateEndpoint bool = true

// Subnet resource ID where the private endpoint network interface will be created
// Must be a subnet with adequate address space and appropriate security controls
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet with NSG rules restricting access
@description('Private endpoint subnet ID')
param privateEndpointSubnetId string = ''

// Private DNS zone resource ID for resolving Cognitive Services private endpoint FQDN
// Essential for proper name resolution within the virtual network
// 🔒 SECURITY ENHANCEMENT: Use private DNS to prevent DNS leakage to public resolvers
@description('Private DNS zone ID for Cognitive Services')
param privateDnsZoneId string = ''

// Custom suffix for private endpoint resource names
// Helps with resource organization and governance in large deployments
@description('Custom private endpoint name suffix')
param privateEndpointNameSuffix string = ''

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

// Enable customer-managed encryption keys (CMK) for data protection at rest
// Provides customer control over encryption keys and enhanced compliance
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring key control
@description('Enable customer-managed encryption')
param enableCustomerManagedEncryption bool = true

// Azure Key Vault URI containing customer-managed encryption keys
// Must be accessible by the assigned managed identity for encryption operations
// 🔒 SECURITY ENHANCEMENT: Use Key Vault with access policies and network restrictions
@description('Key Vault URI for customer-managed encryption key')
param keyVaultUri string = ''

// Name of the encryption key stored in Azure Key Vault
// Key must support encrypt/decrypt operations and be accessible by managed identity
// 🔒 SECURITY ENHANCEMENT: Use RSA keys with HSM protection for maximum security
@description('Customer-managed encryption key name')
@minLength(0)
@maxLength(127)
param encryptionKeyName string = 'ai-services-encryption-key'

// User-assigned managed identity resource ID with Key Vault access
// Identity must have 'Key Vault Crypto Service Encryption User' role on the key
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal required permissions
@description('User-assigned managed identity ID for Key Vault access')
param userAssignedIdentityId string = ''

// ============================================================================
// IDENTITY CONFIGURATION
// ============================================================================

// Enable system-assigned managed identity for Azure service authentication
// Provides an identity that can be used for role-based access control
// 🔒 SECURITY ENHANCEMENT: Use managed identities instead of service principal credentials
@description('Enable system-assigned managed identity')
param enableSystemAssignedIdentity bool = false

// List of user-assigned managed identity resource IDs
// Allows for fine-grained access control and shared identities across resources
// 🔒 SECURITY ENHANCEMENT: Use dedicated identities for different access patterns
@description('User-assigned managed identity IDs')
param userAssignedIdentityIds array = []

// ============================================================================
// AUTHENTICATION CONFIGURATION
// ============================================================================

// Disable local authentication methods (API keys) to enforce Azure AD authentication
// Forces all access to use token-based authentication instead of static keys
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments to prevent key-based attacks
@description('Disable local authentication (API keys)')
param disableLocalAuth bool = true

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

// Enable comprehensive diagnostic logging and monitoring
// Critical for security monitoring, compliance, and operational insights
// 🔒 SECURITY ENHANCEMENT: Always enable for security auditing and compliance
@description('Enable diagnostic settings')
param enableDiagnostics bool = true

// Log Analytics workspace resource ID for centralized log storage and analysis
// Required for security monitoring, alerting, and compliance reporting
// 🔒 SECURITY ENHANCEMENT: Use dedicated workspace with appropriate retention policies
@description('Log Analytics workspace ID for diagnostic settings')
param logAnalyticsWorkspaceId string = ''

// Storage account resource ID for long-term diagnostic log archival
// Used for compliance requirements and cost-effective log retention
// 🔒 SECURITY ENHANCEMENT: Use storage with encryption, access controls, and immutability
@description('Storage account ID for diagnostic logs')
param diagnosticStorageAccountId string = ''

// ============================================================================
// ADVANCED CONFIGURATION
// ============================================================================

// List of allowed fully qualified domain names for outbound network traffic
// Controls which external services the Cognitive Services account can communicate with
// 🔒 SECURITY ENHANCEMENT: Define minimal required FQDNs for zero-trust networking
@description('Allowed FQDN list for outbound traffic')
param allowedFqdnList array = []

// Service-specific API configuration properties
// Allows customization of individual Cognitive Services features and capabilities
@description('API properties for specific cognitive services')
param apiProperties object = {}

// User-owned storage accounts for service data storage
// Provides control over data location and encryption for sensitive workloads
// 🔒 SECURITY ENHANCEMENT: Use customer-controlled storage with private endpoints
@description('User-owned storage accounts for service data')
param userOwnedStorage array = []

// ============================================================================
// COST MANAGEMENT CONFIGURATION
// ============================================================================

// Enable commitment plans for predictable pricing and cost optimization
// Provides reserved capacity at discounted rates for consistent workloads
@description('Enable commitment plans for cost management')
param enableCommitmentPlans bool = false

// Configuration for commitment plan pricing and capacity reservations
// Defines the committed usage levels and pricing tiers
@description('Commitment plan configurations')
param commitmentPlans array = []

// ============================================================================
// VARIABLES
// ============================================================================

var cognitiveServicesNameGenerated = !empty(cognitiveServicesName) ? cognitiveServicesName : 'cog-${projectName}-${environment}-${substring(uniqueString(resourceGroup().id), 0, 6)}'
var customSubdomainNameGenerated = !empty(customSubdomainName) ? customSubdomainName : replace(cognitiveServicesNameGenerated, '-', '')
var privateEndpointName = '${cognitiveServicesNameGenerated}-pe${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : ''}'
var networkInterfaceName = '${privateEndpointName}-nic'

var defaultTags = {
  Environment: environment
  Project: projectName
  Service: 'Cognitive Services'
  ManagedBy: 'Bicep'
}

var allTags = union(defaultTags, tags)

// ============================================================================
// RESOURCES
// ============================================================================

// Cognitive Services Account with comprehensive security configuration
resource cognitiveServices 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: cognitiveServicesNameGenerated
  location: location
  tags: allTags
  sku: {
    name: cognitiveServicesSku
  }
  kind: cognitiveServicesKind
  identity: {
    type: enableSystemAssignedIdentity && !empty(userAssignedIdentityIds) ? 'SystemAssigned, UserAssigned' : enableSystemAssignedIdentity ? 'SystemAssigned' : !empty(userAssignedIdentityIds) ? 'UserAssigned' : 'None'
    userAssignedIdentities: !empty(userAssignedIdentityIds) ? reduce(userAssignedIdentityIds, {}, (cur, identityId) => union(cur, { '${identityId}': {} })) : null
  }
  properties: {
    customSubDomainName: enableCustomSubdomain ? customSubdomainNameGenerated : null
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAcls: networkAcls
    disableLocalAuth: disableLocalAuth
    encryption: enableCustomerManagedEncryption && !empty(keyVaultUri) && !empty(userAssignedIdentityId) ? {
      keySource: 'Microsoft.KeyVault'
      keyVaultProperties: {
        keyName: encryptionKeyName
        keyVaultUri: keyVaultUri
        identityClientId: !empty(userAssignedIdentityId) ? userAssignedIdentityId : null
      }
    } : {
      keySource: 'Microsoft.CognitiveServices'
    }
    userOwnedStorage: userOwnedStorage
    apiProperties: apiProperties
    allowedFqdnList: allowedFqdnList
  }
}

// Commitment Plans for cost optimization (if enabled)
resource commitmentPlan 'Microsoft.CognitiveServices/commitmentPlans@2023-05-01' = [for plan in commitmentPlans: if (enableCommitmentPlans) {
  name: '${cognitiveServicesNameGenerated}-${plan.name}'
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Commitment plan for ${plan.name}'
  })
  sku: {
    name: plan.skuName
  }
  kind: plan.kind
  properties: {
    commitmentPlanGuid: plan.?commitmentPlanGuid
    autoRenew: plan.?autoRenew ?? true
    current: {
      tier: plan.tier
      count: plan.count
    }
    next: plan.?next
  }
}]

// Private Endpoint for Cognitive Services
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enablePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: privateEndpointName
  location: location
  tags: union(tags, {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for Cognitive Services'
  })
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-connection'
        properties: {
          privateLinkServiceId: cognitiveServices.id
          groupIds: ['account']
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved private endpoint for Cognitive Services'
          }
        }
      }
    ]
    customNetworkInterfaceName: networkInterfaceName
  }
}

// Private DNS Zone Group
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enablePrivateEndpoint && !empty(privateDnsZoneId)) {
  name: 'default'
  parent: privateEndpoint
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'cognitiveservices-config'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// Diagnostic Settings
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticStorageAccountId))) {
  name: '${cognitiveServicesNameGenerated}-diagnostics'
  scope: cognitiveServices
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 90
        }
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 30
        }
      }
    ]
  }
}

// Role Assignments for managed identities (if using user-assigned identities)
resource cognitiveServicesUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for identityId in userAssignedIdentityIds: if (!empty(userAssignedIdentityIds)) {
  name: guid(cognitiveServices.id, identityId, 'Cognitive Services User')
  scope: cognitiveServices
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908') // Cognitive Services User
    principalId: identityId
    principalType: 'ServicePrincipal'
    description: 'Cognitive Services User access for managed identity'
  }
}]

// Custom Vision specific resources (if kind is CustomVision)
resource customVisionTrainingAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (cognitiveServicesKind == 'CustomVision.Training') {
  name: take('${substring(cognitiveServicesNameGenerated, 0, 55)}-train', 64)
  location: location
  tags: allTags
  sku: {
    name: cognitiveServicesSku
  }
  kind: 'CustomVision.Training'
  properties: {
    customSubDomainName: enableCustomSubdomain ? '${customSubdomainNameGenerated}training' : null
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAcls: networkAcls
    disableLocalAuth: disableLocalAuth
  }
}

resource customVisionPredictionAccount 'Microsoft.CognitiveServices/accounts@2023-05-01' = if (cognitiveServicesKind == 'CustomVision.Training') {
  name: take('${substring(cognitiveServicesNameGenerated, 0, 54)}-predict', 64)
  location: location
  tags: allTags
  sku: {
    name: cognitiveServicesSku
  }
  kind: 'CustomVision.Prediction'
  properties: {
    customSubDomainName: enableCustomSubdomain ? '${customSubdomainNameGenerated}prediction' : null
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'
    networkAcls: networkAcls
    disableLocalAuth: disableLocalAuth
  }
}

// Outputs
@description('Cognitive Services account resource ID')
output cognitiveServicesId string = cognitiveServices.id

@description('Cognitive Services account name')
output cognitiveServicesName string = cognitiveServices.name

@description('Cognitive Services endpoint')
output endpoint string = cognitiveServices.properties.endpoint

@description('Custom subdomain name')
output customSubdomain string = enableCustomSubdomain ? customSubdomainNameGenerated : ''

@description('Private endpoint information')
output privateEndpoint object = enablePrivateEndpoint && !empty(privateEndpointSubnetId) ? {
  id: privateEndpoint.id
  name: privateEndpoint.name
  fqdn: '${customSubdomainNameGenerated}.cognitiveservices.azure.com'
} : {}

@description('System-assigned managed identity principal ID')
output systemAssignedIdentityPrincipalId string = enableSystemAssignedIdentity ? cognitiveServices.identity.principalId : ''

@description('Custom Vision account information (if applicable)')
output customVisionAccounts object = cognitiveServicesKind == 'CustomVision.Training' ? {
  training: {
    id: customVisionTrainingAccount.id
    name: customVisionTrainingAccount.name
    endpoint: customVisionTrainingAccount!.properties.endpoint
  }
  prediction: {
    id: customVisionPredictionAccount.id
    name: customVisionPredictionAccount.name
    endpoint: customVisionPredictionAccount!.properties.endpoint
  }
} : {
  training: {}
  prediction: {}
}

@description('Commitment plans information')
output commitmentPlansInfo array = [for (plan, index) in commitmentPlans: enableCommitmentPlans ? {
  name: commitmentPlan[index].name
  id: commitmentPlan[index].id
  skuName: plan.skuName
  tier: plan.tier
  count: plan.count
} : {}]

@description('Service configuration summary')
output serviceConfig object = {
  kind: cognitiveServicesKind
  sku: cognitiveServicesSku
  customSubdomainEnabled: enableCustomSubdomain
  privateEndpointEnabled: enablePrivateEndpoint
  localAuthDisabled: disableLocalAuth
  customerManagedEncryption: enableCustomerManagedEncryption
  publicNetworkAccess: publicNetworkAccess
}

@description('Network configuration for application settings')
output networkConfig object = {
  endpoint: cognitiveServices.properties.endpoint
  customSubdomain: enableCustomSubdomain ? customSubdomainNameGenerated : ''
  privateEndpointFqdn: enablePrivateEndpoint ? '${customSubdomainNameGenerated}.cognitiveservices.azure.com' : ''
}
