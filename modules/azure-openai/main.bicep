@description('Azure OpenAI Service - Dedicated module for enterprise generative AI with advanced features including model deployments, content filtering, multi-region support, and enterprise security. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure OpenAI Service - Enterprise Edition'
metadata description = 'Dedicated Azure OpenAI module with advanced model deployment and enterprise security'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Resource name for the Azure OpenAI service account
// Must be globally unique across Azure and follow DNS naming conventions
// 🔒 SECURITY ENHANCEMENT: Use predictable naming with environment suffixes for security scanning
@description('Required. Name of the Azure OpenAI service account (2-64 characters, globally unique)')
@minLength(2)
@maxLength(64)
param openAIAccountName string

// Azure region for deploying the OpenAI service and model deployments
// Regional availability varies by model - check Azure OpenAI model availability
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for OpenAI service deployment')
param location string = resourceGroup().location

// Service tier determining capacity, features, and pricing model
// Controls throughput limits, SLA guarantees, and available model types
// 🔒 SECURITY ENHANCEMENT: Use S0 for production with dedicated capacity and enhanced security
@description('Required. Service tier determining capacity and features')
@allowed([
  'F0'    // Free tier - Limited requests, shared capacity
  'S0'    // Standard tier - Production workloads, dedicated capacity
])
param skuName string = 'S0'

// Custom subdomain enabling Azure AD authentication and private endpoints
// Required for token-based authentication instead of API keys
// 🔒 SECURITY ENHANCEMENT: Custom subdomain is required for Azure AD auth and private connectivity
@description('Required. Custom subdomain for Azure AD authentication (must be globally unique)')
@minLength(2)
@maxLength(64)
param customSubDomainName string

// ============================================================================
// PARAMETERS - MODEL DEPLOYMENTS
// ============================================================================

// Array of model deployments to create within the OpenAI service
// Each deployment provides access to specific models with dedicated capacity
// 🔒 SECURITY ENHANCEMENT: Use specific model versions instead of 'latest' for consistent behavior
@description('Model deployments to create within the OpenAI service')
param modelDeployments array = [
  {
    name: 'gpt-4o'
    model: {
      format: 'OpenAI'
      name: 'gpt-4o'
      version: '2024-08-06'  // Specific version for consistency
    }
    capacity: 10  // Tokens per minute (thousands)
    raiPolicyName: ''  // Optional custom content filtering policy
  }
  {
    name: 'text-embedding-3-small'
    model: {
      format: 'OpenAI'
      name: 'text-embedding-3-small'
      version: '1'
    }
    capacity: 120  // Higher capacity for embedding workloads
    raiPolicyName: ''
  }
]

// ============================================================================
// PARAMETERS - SECURITY CONFIGURATION
// ============================================================================

// Public network access control for the OpenAI service endpoint
// Controls whether the service can be accessed from public internet
// 🔒 SECURITY ENHANCEMENT: Set to 'Disabled' for maximum security with private endpoints only
@description('Public network access control')
@allowed([
  'Enabled'   // Allow public internet access (with network rules)
  'Disabled'  // Private endpoints only (recommended for enterprise)
])
param publicNetworkAccess string = 'Disabled'

// Disable API key authentication in favor of Azure AD tokens
// Forces use of managed identities and Azure AD authentication
// 🔒 SECURITY ENHANCEMENT: Always disable API keys for production environments
@description('Disable API key authentication (Azure AD only)')
param disableLocalAuth bool = true

// Default network access action when no specific rules match
// Controls baseline access when network ACLs are configured
// 🔒 SECURITY ENHANCEMENT: Use 'Deny' with explicit allow rules for zero-trust architecture
@description('Default network access action')
@allowed([
  'Allow'  // Allow by default (less secure)
  'Deny'   // Deny by default (recommended)
])
param networkAclsDefaultAction string = 'Deny'

// IP addresses and CIDR ranges allowed to access the service
// Specify corporate IP ranges or specific trusted addresses
// 🔒 SECURITY ENHANCEMENT: Limit to specific IP ranges instead of 0.0.0.0/0
@description('Array of IP addresses/CIDR ranges allowed access')
param allowedIpAddresses array = []

// Virtual network subnet IDs allowed to access the service
// Enables secure access from specific VNet subnets
// 🔒 SECURITY ENHANCEMENT: Use service endpoints or private endpoints instead of subnet rules
@description('Array of VNet subnet IDs allowed access')
param allowedSubnetIds array = []

// ============================================================================
// PARAMETERS - CONTENT FILTERING & RAI POLICIES
// ============================================================================

// Enable advanced content filtering beyond default Azure OpenAI policies
// Provides additional content safety and responsible AI governance
// 🔒 SECURITY ENHANCEMENT: Enable for enterprise deployments with custom content policies
@description('Enable advanced content filtering and custom RAI policies')
param enableAdvancedContentFiltering bool = true

// Custom Responsible AI (RAI) policies for content filtering
// Define organization-specific content filtering rules and thresholds
// 🔒 SECURITY ENHANCEMENT: Create strict policies for sensitive industries (healthcare, finance)
@description('Custom RAI policies for content filtering')
param customRaiPolicies array = [
  {
    name: 'strict-enterprise-policy'
    properties: {
      basePolicyName: 'Microsoft.Default'
      completionBlockLists: [
        {
          blockListName: 'enterprise-blocklist'
          enabled: true
        }
      ]
      promptBlockLists: [
        {
          blockListName: 'enterprise-blocklist'
          enabled: true
        }
      ]
      filters: [
        {
          name: 'hate'
          blocking: true
          enabled: true
          severityThreshold: 'low'
        }
        {
          name: 'sexual'
          blocking: true
          enabled: true
          severityThreshold: 'low'
        }
        {
          name: 'violence'
          blocking: true
          enabled: true
          severityThreshold: 'low'
        }
        {
          name: 'self_harm'
          blocking: true
          enabled: true
          severityThreshold: 'low'
        }
      ]
    }
  }
]

// ============================================================================
// PARAMETERS - PRIVATE ENDPOINT CONFIGURATION
// ============================================================================

// Enable private endpoint for secure, private connectivity to OpenAI service
// Provides access through private IP addresses within your VNet
// 🔒 SECURITY ENHANCEMENT: Required for enterprise deployments to prevent data exfiltration
@description('Enable private endpoint for secure connectivity')
param enablePrivateEndpoint bool = true

// Virtual Network ID where the private endpoint will be created
// Must be in the same region as the OpenAI service
// 🔒 SECURITY ENHANCEMENT: Use dedicated AI services VNet with network segmentation
@description('Virtual Network ID for private endpoint (required if enablePrivateEndpoint is true)')
param vnetId string = ''

// Subnet ID within the VNet for the private endpoint placement
// Subnet must have private endpoint network policies disabled
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet for AI service private endpoints
@description('Subnet ID for private endpoint placement')
param privateEndpointSubnetId string = ''

// Optional name for the private endpoint resource
// If not specified, will be auto-generated based on OpenAI account name
// 🔒 SECURITY ENHANCEMENT: Use consistent naming convention for security scanning
@description('Optional name for the private endpoint')
param privateEndpointName string = ''

// Optional suffix for private endpoint naming when multiple endpoints needed
// Useful for multi-region deployments or different access patterns
@description('Optional suffix for private endpoint naming')
param privateEndpointNameSuffix string = ''

// ============================================================================
// PARAMETERS - IDENTITY & RBAC CONFIGURATION
// ============================================================================

// Type of managed identity to assign to the OpenAI service
// Controls how the service authenticates to other Azure resources
// 🔒 SECURITY ENHANCEMENT: Use SystemAssigned for simplified management, UserAssigned for shared scenarios
@description('Type of managed identity for the OpenAI service')
@allowed([
  'None'           // No managed identity
  'SystemAssigned' // Azure-managed identity (recommended)
  'UserAssigned'   // Customer-managed identity
  'SystemAssigned, UserAssigned'  // Both types (note space in string)
])
param managedIdentityType string = 'SystemAssigned'

// Array of user-assigned managed identity resource IDs
// Used when managedIdentityType includes 'UserAssigned'
// 🔒 SECURITY ENHANCEMENT: Use for cross-resource scenarios requiring specific identity permissions
@description('Array of user-assigned managed identity resource IDs')
param userAssignedIdentities array = []

// Enable automatic RBAC role assignments for common scenarios
// Simplifies access management for typical AI development patterns
// 🔒 SECURITY ENHANCEMENT: Use principle of least privilege with specific role assignments
@description('Enable automatic RBAC role assignments')
param enableRbacAssignments bool = true

// OpenAI administrators with full service management permissions
// Should be limited to security team and senior AI engineers
// 🔒 SECURITY ENHANCEMENT: Limit admin access and use break-glass procedures
@description('Array of OpenAI service administrators')
param openAIAdministrators array = []

// OpenAI developers with model deployment and inference permissions
// Typical role for AI developers and data scientists
// 🔒 SECURITY ENHANCEMENT: Use Azure AD groups instead of individual user assignments
@description('Array of OpenAI developers')
param openAIDevelopers array = []

// OpenAI users with inference-only permissions (no administrative access)
// Appropriate for applications and end-user access scenarios
// 🔒 SECURITY ENHANCEMENT: Use managed identities for application access
@description('Array of OpenAI users')
param openAIUsers array = []

// ============================================================================
// PARAMETERS - CUSTOMER-MANAGED ENCRYPTION
// ============================================================================

// Enable customer-managed encryption using Azure Key Vault
// Provides additional control over encryption keys and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Required for regulated industries and enhanced security posture
@description('Enable customer-managed encryption with Key Vault')
param enableCustomerManagedEncryption bool = false

// Azure Key Vault resource ID containing the encryption key
// Key Vault must be in the same region and tenant as the OpenAI service
// 🔒 SECURITY ENHANCEMENT: Use dedicated Key Vault with HSM backing for maximum security
@description('Key Vault resource ID for customer-managed encryption')
param keyVaultId string = ''

// Key Vault key identifier (full URI) for encryption
// Must be an RSA or RSA-HSM key with appropriate permissions
// 🔒 SECURITY ENHANCEMENT: Use HSM-backed keys and implement key rotation policies
@description('Key Vault key identifier for encryption')
param keyVaultKeyIdentifier string = ''

// User-assigned managed identity for accessing encryption keys
// Required for customer-managed encryption scenarios
// 🔒 SECURITY ENHANCEMENT: Use dedicated identity with minimal Key Vault permissions
@description('User-assigned managed identity for Key Vault access')
param encryptionIdentityId string = ''

// ============================================================================
// PARAMETERS - MONITORING & DIAGNOSTICS
// ============================================================================

// Enable comprehensive diagnostic logging and monitoring
// Essential for security auditing, compliance, and operational insights
// 🔒 SECURITY ENHANCEMENT: Always enable for production to detect anomalous usage patterns
@description('Enable diagnostic settings and monitoring')
param enableDiagnostics bool = true

// Log Analytics workspace for centralized log collection
// Enables advanced querying, alerting, and security analysis
// 🔒 SECURITY ENHANCEMENT: Use dedicated Log Analytics workspace with appropriate retention
@description('Log Analytics workspace resource ID for diagnostic logs')
param logAnalyticsWorkspaceId string = ''

// Storage account for long-term log retention and compliance
// Useful for regulatory requirements and forensic analysis
// 🔒 SECURITY ENHANCEMENT: Use immutable storage with legal hold for compliance scenarios
@description('Storage account resource ID for diagnostic logs archive')
param diagnosticsStorageAccountId string = ''

// Event Hub for real-time log streaming and SIEM integration
// Enables integration with external security tools and monitoring systems
// 🔒 SECURITY ENHANCEMENT: Stream security events to SIEM for real-time threat detection
@description('Event Hub authorization rule ID for log streaming')
param eventHubAuthorizationRuleId string = ''

// Event Hub name for log streaming destination
// Must exist within the Event Hub namespace specified in authorization rule
@description('Event Hub name for log streaming')
param eventHubName string = ''

// Diagnostic log categories to collect
// Controls which types of activities are logged for analysis
// 🔒 SECURITY ENHANCEMENT: Include all categories for comprehensive security monitoring
@description('Diagnostic log categories to enable')
param diagnosticLogsCategories array = [
  'Audit'           // Administrative operations and configuration changes
  'RequestResponse' // API requests and responses (be mindful of data sensitivity)
  'Trace'          // Detailed execution traces for troubleshooting
]

// Diagnostic metrics categories for performance monitoring
// Provides insights into service performance and capacity utilization
@description('Diagnostic metrics categories to enable')
param diagnosticMetricsCategories array = [
  'AllMetrics'  // All available performance and utilization metrics
]

// Retention period for diagnostic logs in days
// Balances compliance requirements with storage costs
// 🔒 SECURITY ENHANCEMENT: Set based on compliance requirements (90+ days for most regulations)
@description('Diagnostic logs retention period in days (0 = unlimited)')
@minValue(0)
@maxValue(365)
param diagnosticLogsRetentionInDays int = 90

// ============================================================================
// PARAMETERS - TAGGING & METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
// Helps maintain naming conventions in multi-environment deployments
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with OpenAI-specific metadata
var defaultTags = {
  Environment: tags.?Environment ?? 'Production'
  Service: 'Azure OpenAI'
  ManagedBy: 'Bicep'
  OpenAIEnabled: 'true'
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Identity configuration object for the OpenAI service
var identityConfig = managedIdentityType == 'None' ? null : {
  type: managedIdentityType
  userAssignedIdentities: !empty(userAssignedIdentities) ? reduce(userAssignedIdentities, {}, (acc, identityId) => union(acc, {
    '${identityId}': {}
  })) : null
}

// Customer-managed encryption configuration
var encryptionConfig = enableCustomerManagedEncryption && !empty(keyVaultKeyIdentifier) ? {
  keySource: 'Microsoft.KeyVault'
  keyVaultProperties: {
    keyVaultUri: keyVaultId
    keyName: last(split(keyVaultKeyIdentifier, '/'))
    keyVersion: ''  // Use latest version
    identityClientId: !empty(encryptionIdentityId) ? encryptionIdentityId : null
  }
} : {
  keySource: 'Microsoft.CognitiveServices'
}

// IP rules for network ACLs
var ipRules = [for ipAddress in allowedIpAddresses: {
  value: ipAddress
}]

// Virtual network rules for network ACLs
var virtualNetworkRules = [for subnetId in allowedSubnetIds: {
  id: subnetId
  ignoreMissingVnetServiceEndpoint: false
}]

// Network ACLs configuration for access control
var networkAcls = {
  defaultAction: networkAclsDefaultAction
  ipRules: ipRules
  virtualNetworkRules: virtualNetworkRules
}

// Built-in Azure role definitions for OpenAI service
var roleDefinitions = {
  owner: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635')
  contributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
  reader: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
  cognitiveServicesOpenAIContributor: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a001fd3d-188f-4b5d-821b-7da978bf7442')
  cognitiveServicesOpenAIUser: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd')
  cognitiveServicesUser: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908')
}

// ============================================================================
// RESOURCES
// ============================================================================

// Azure OpenAI Service Account
resource openAIAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: openAIAccountName
  location: location
  tags: allTags
  kind: 'OpenAI'
  identity: identityConfig
  sku: {
    name: skuName
  }
  properties: {
    customSubDomainName: customSubDomainName
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
    disableLocalAuth: disableLocalAuth
    encryption: encryptionConfig
    restrictOutboundNetworkAccess: false  // Allow outbound for model inference
    allowedFqdnList: []  // Optional FQDN allowlist for outbound traffic
  }
}

// Model Deployments
resource modelDeployment 'Microsoft.CognitiveServices/accounts/deployments@2024-10-01' = [for deployment in modelDeployments: {
  parent: openAIAccount
  name: deployment.name
  properties: {
    model: deployment.model
    raiPolicyName: !empty(deployment.raiPolicyName) ? deployment.raiPolicyName : null
  }
  sku: {
    name: 'Standard'
    capacity: deployment.capacity
  }
}]

// Custom RAI Policies for Content Filtering
resource raiPolicy 'Microsoft.CognitiveServices/accounts/raiPolicies@2024-10-01' = [for policy in customRaiPolicies: if (enableAdvancedContentFiltering) {
  parent: openAIAccount
  name: policy.name
  properties: policy.properties
}]

// Private Endpoint for Secure Connectivity
resource openAIPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = if (enablePrivateEndpoint && !empty(vnetId) && !empty(privateEndpointSubnetId)) {
  name: !empty(privateEndpointName) ? privateEndpointName : 'pe-${openAIAccountName}${!empty(privateEndpointNameSuffix) ? '-${privateEndpointNameSuffix}' : resourceSuffix}'
  location: location
  tags: allTags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'openai-connection'
        properties: {
          privateLinkServiceId: openAIAccount.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

// Diagnostic Settings for Monitoring and Compliance
resource openAIDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnostics && (!empty(logAnalyticsWorkspaceId) || !empty(diagnosticsStorageAccountId) || !empty(eventHubAuthorizationRuleId))) {
  scope: openAIAccount
  name: 'diag-${openAIAccountName}'
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

// RBAC Role Assignments for Administrators
resource openAIAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (admin, i) in openAIAdministrators: if (enableRbacAssignments) {
  scope: openAIAccount
  name: guid(openAIAccount.id, admin.principalId, 'OpenAIContributor')
  properties: {
    roleDefinitionId: roleDefinitions.cognitiveServicesOpenAIContributor
    principalId: admin.principalId
    principalType: admin.principalType
    description: 'OpenAI administrator access with full service management'
  }
}]

// RBAC Role Assignments for Developers
resource openAIDeveloperRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (developer, i) in openAIDevelopers: if (enableRbacAssignments) {
  scope: openAIAccount
  name: guid(openAIAccount.id, developer.principalId, 'OpenAIUser')
  properties: {
    roleDefinitionId: roleDefinitions.cognitiveServicesOpenAIUser
    principalId: developer.principalId
    principalType: developer.principalType
    description: 'OpenAI developer access for model deployment and inference'
  }
}]

// RBAC Role Assignments for Users
resource openAIUserRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (user, i) in openAIUsers: if (enableRbacAssignments) {
  scope: openAIAccount
  name: guid(openAIAccount.id, user.principalId, 'CognitiveServicesUser')
  properties: {
    roleDefinitionId: roleDefinitions.cognitiveServicesUser
    principalId: user.principalId
    principalType: user.principalType
    description: 'OpenAI user access for inference only'
  }
}]

// ============================================================================
// OUTPUTS
// ============================================================================

@description('Azure OpenAI service resource ID')
output openAIId string = openAIAccount.id

@description('Azure OpenAI service name')
output openAIName string = openAIAccount.name

@description('Azure OpenAI service endpoint URL')
output openAIEndpoint string = openAIAccount.properties.endpoint

@description('Azure OpenAI custom subdomain')
output customSubDomain string = openAIAccount.properties.customSubDomainName

@description('System-assigned managed identity principal ID')
output systemAssignedIdentityPrincipalId string = managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned, UserAssigned' ? openAIAccount.identity.principalId : ''

@description('System-assigned managed identity tenant ID')
output systemAssignedIdentityTenantId string = managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned, UserAssigned' ? openAIAccount.identity.tenantId : ''

@description('User-assigned managed identities')
output userAssignedIdentities object = managedIdentityType == 'UserAssigned' || managedIdentityType == 'SystemAssigned, UserAssigned' ? openAIAccount.identity.userAssignedIdentities : {}

@description('Private endpoint resource ID')
output privateEndpointId string = enablePrivateEndpoint ? openAIPrivateEndpoint.id : ''

@description('Model deployments created')
output modelDeployments array = [for (deployment, i) in modelDeployments: {
  name: deployment.name
  model: deployment.model
  capacity: deployment.capacity
  status: modelDeployment[i].properties.provisioningState
}]

@description('OpenAI service configuration summary')
output openAIConfig object = {
  accountName: openAIAccount.name
  endpoint: openAIAccount.properties.endpoint
  customSubDomain: openAIAccount.properties.customSubDomainName
  publicNetworkAccess: publicNetworkAccess
  disableLocalAuth: disableLocalAuth
  skuName: skuName
  location: location
}

@description('Security configuration summary')
output securityConfig object = {
  publicNetworkAccess: publicNetworkAccess
  disableLocalAuth: disableLocalAuth
  networkAclsDefaultAction: networkAclsDefaultAction
  privateEndpointEnabled: enablePrivateEndpoint
  customerManagedEncryption: enableCustomerManagedEncryption
  managedIdentityType: managedIdentityType
}

@description('Network configuration summary')
output networkConfig object = {
  allowedIpAddresses: allowedIpAddresses
  allowedSubnetIds: allowedSubnetIds
  privateEndpointEnabled: enablePrivateEndpoint
  privateEndpointId: enablePrivateEndpoint ? openAIPrivateEndpoint.id : ''
}
