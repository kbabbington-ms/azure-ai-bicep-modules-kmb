// =============================================================================
// Azure Cognitive Services Account - Enterprise Security Configuration
// =============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// Description: Highly secure Azure Cognitive Services account supporting all AI services
// =============================================================================

targetScope = 'resourceGroup'

// BASIC CONFIGURATION PARAMETERS
// =============================================================================

// Unique name for the Azure Cognitive Services account resource
// Must be globally unique across Azure as it forms part of the service endpoint URL
// 🔒 SECURITY ENHANCEMENT: Use naming conventions that don't expose sensitive information
@minLength(2)
@maxLength(64)
@description('Required. Name of the Cognitive Services account. Must be 2-64 characters, alphanumeric and hyphens only.')
param cognitiveServiceName string

// Azure region where the Cognitive Services account will be deployed
// Critical for data residency, compliance, and AI model availability
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Required. Azure region where the Cognitive Services account will be deployed.')
param location string = resourceGroup().location

// Type of Cognitive Services account determining available AI capabilities and APIs
// Controls which AI services and models are accessible through this account
// 🔒 SECURITY ENHANCEMENT: Use specific service types instead of 'CognitiveServices' for tighter access control
@allowed([
  'OpenAI'                    // Azure OpenAI Service
  'SpeechServices'           // Speech Services (Speech-to-Text, Text-to-Speech, Speech Translation)
  'ComputerVision'           // Computer Vision API
  'Face'                     // Face API
  'TextAnalytics'            // Text Analytics and Language Understanding
  'FormRecognizer'           // Form Recognizer (Document Intelligence)
  'CognitiveServices'        // Multi-service resource
  'CustomVision.Training'    // Custom Vision Training
  'CustomVision.Prediction'  // Custom Vision Prediction
  'Luis'                     // Language Understanding (LUIS)
  'QnAMaker'                 // QnA Maker
  'TextTranslation'          // Translator Text API
  'AnomalyDetector'          // Anomaly Detector
  'Personalizer'             // Personalizer
  'MetricsAdvisor'           // Metrics Advisor
  'ImmersiveReader'          // Immersive Reader
  'HealthInsights'           // Health Insights
])
@description('Required. The kind of Cognitive Services account to create. OpenAI for Azure OpenAI Service, CognitiveServices for multi-service.')
param kind string

// ============================================================================
// SKU AND PRICING CONFIGURATION
// ============================================================================

// Pricing tier and performance level for the Cognitive Services account
// Controls throughput limits, SLA guarantees, and feature availability
// 🔒 SECURITY ENHANCEMENT: Use S0 or higher for production workloads requiring SLA and support
@allowed([
  'F0'   // Free tier
  'S0'   // Standard tier
  'S1'   // Standard tier (higher throughput)
  'S2'   // Standard tier (even higher throughput)
  'S3'   // Standard tier (highest throughput)
  'S4'   // Standard tier (premium)
])
@description('Required. The pricing tier for the Cognitive Services account. S0 recommended for production, F0 for development/testing.')
param skuName string = 'S0'

@minValue(1)
@description('SKU capacity. Number of units for the selected SKU. Higher capacity provides more throughput.')
param skuCapacity int = 1

// =============================================================================
// SECURITY PARAMETERS
// =============================================================================

@description('SECURITY: Disable local authentication (API keys). Forces Azure AD authentication only. Recommended for enhanced security.')
param disableLocalAuth bool = true

@allowed([
  'Enabled'  // Allow public network access
  'Disabled' // Block public network access (private endpoints only)
])
@description('SECURITY: Public network access setting. Use Disabled for maximum security with private endpoints only.')
param publicNetworkAccess string = 'Disabled'

@description('SECURITY: Restrict outbound network access. Prevents the service from making outbound calls except to allowed FQDNs.')
param restrictOutboundNetworkAccess bool = true

@description('SECURITY: List of allowed fully qualified domain names for outbound network access.')
param allowedFqdnList array = []

@description('SECURITY: Custom subdomain name for token-based authentication. Required for private endpoints and Azure AD authentication.')
param customSubDomainName string = ''

// =============================================================================
// NETWORK ACCESS CONTROL
// =============================================================================

@allowed([
  'Allow' // Allow access by default
  'Deny'  // Deny access by default (recommended for security)
])
@description('SECURITY: Default network access rule. Deny recommended for zero-trust security model.')
param networkAclsDefaultAction string = 'Deny'

@allowed([
  'AzureServices' // Allow trusted Azure services
  'None'          // No bypass rules
])
@description('SECURITY: Network ACL bypass rules. AzureServices commonly needed for Azure platform services.')
param networkAclsBypass string = 'AzureServices'

@description('SECURITY: Array of IP addresses or CIDR ranges allowed to access the Cognitive Services account.')
param allowedIpAddresses array = []

@description('SECURITY: Array of virtual network subnet resource IDs allowed to access the Cognitive Services account.')
param allowedSubnetIds array = []

@description('SECURITY: Ignore missing VNet service endpoint when adding VNet rules.')
param ignoreMissingVnetServiceEndpoint bool = false

// =============================================================================
// ENCRYPTION SETTINGS
// =============================================================================

@allowed([
  'Microsoft.CognitiveServices' // Platform-managed keys (default)
  'Microsoft.KeyVault'         // Customer-managed keys (enhanced security)
])
@description('SECURITY: Encryption key source. Microsoft.KeyVault recommended for customer-managed encryption keys.')
param encryptionKeySource string = 'Microsoft.CognitiveServices'

@description('SECURITY: Key Vault URI for customer-managed keys. Required if encryptionKeySource is Microsoft.KeyVault.')
param keyVaultUri string = ''

@description('SECURITY: Key Vault key name for customer-managed keys. Required if encryptionKeySource is Microsoft.KeyVault.')
param keyVaultKeyName string = ''

@description('SECURITY: Key Vault key version for customer-managed keys. Leave empty for latest version.')
param keyVaultKeyVersion string = ''

@description('SECURITY: User-assigned managed identity client ID for Key Vault access. Required for customer-managed keys.')
param encryptionIdentityClientId string = ''

// =============================================================================
// MANAGED IDENTITY
// =============================================================================

@allowed([
  'None'                             // No managed identity
  'SystemAssigned'                   // System-assigned managed identity
  'UserAssigned'                     // User-assigned managed identity
  'SystemAssigned, UserAssigned'     // Both types
])
@description('SECURITY: Managed identity type. SystemAssigned recommended for most scenarios.')
param managedIdentityType string = 'SystemAssigned'

@description('SECURITY: User-assigned managed identity resource IDs. Required if managedIdentityType includes UserAssigned.')
param userAssignedIdentityIds object = {}

// =============================================================================
// MULTI-REGION SETTINGS
// =============================================================================

@description('Enable multi-region deployment for global availability and load distribution.')
param enableMultiRegion bool = false

@allowed([
  'Priority'    // Route to primary region first
  'Weighted'    // Distribute load based on weights
  'Performance' // Route to best performing region
])
@description('Multi-region routing method. Performance recommended for optimal user experience.')
param multiRegionRoutingMethod string = 'Performance'

@description('Additional regions for multi-region deployment. Array of objects with name, value, and customsubdomain properties.')
param additionalRegions array = []

// =============================================================================
// PRIVATE ENDPOINT CONFIGURATION
// =============================================================================

@description('SECURITY: Enable private endpoint for secure connectivity. Recommended for production workloads.')
param enablePrivateEndpoint bool = true

@description('SECURITY: Resource ID of the subnet for private endpoint. Required if enablePrivateEndpoint is true.')
param privateEndpointSubnetId string = ''

@description('SECURITY: Name for the private endpoint. Auto-generated if not provided.')
param privateEndpointName string = ''

@description('SECURITY: Resource ID of the private DNS zone for private endpoint.')
param privateDnsZoneId string = ''

// =============================================================================
// USER-OWNED STORAGE
// =============================================================================

@description('SECURITY: Enable user-owned storage for data residency and control. Required for some compliance scenarios.')
param enableUserOwnedStorage bool = false

@description('SECURITY: Array of user-owned storage account configurations.')
param userOwnedStorageAccounts array = []

// =============================================================================
// DIAGNOSTIC SETTINGS
// =============================================================================

@description('SECURITY: Enable diagnostic settings for audit logging. Recommended for compliance and security monitoring.')
param enableDiagnosticSettings bool = true

@description('SECURITY: Resource ID of Log Analytics workspace for diagnostic logs.')
param logAnalyticsWorkspaceId string = ''

@description('SECURITY: Resource ID of storage account for diagnostic logs archive.')
param diagnosticStorageAccountId string = ''

@description('SECURITY: Resource ID of Event Hub for diagnostic logs streaming.')
param eventHubAuthorizationRuleId string = ''

@description('SECURITY: Event Hub name for diagnostic logs streaming.')
param eventHubName string = ''

@minValue(1)
@maxValue(365)
@description('SECURITY: Diagnostic logs retention period in days. Longer periods provide better audit trails.')
param diagnosticLogsRetentionDays int = 90

// =============================================================================
// MONITORING AND ALERTING
// =============================================================================

@description('Enable Azure Monitor alerts for Cognitive Services operations.')
param enableAlerts bool = true

@description('Email addresses for alert notifications.')
param alertEmailAddresses array = []

@description('Enable dynamic throttling to automatically adjust request limits based on usage patterns.')
param enableDynamicThrottling bool = true

// =============================================================================
// RBAC ROLE ASSIGNMENTS
// =============================================================================

@description('SECURITY: Array of role assignments for RBAC authorization.')
param roleAssignments array = []

// =============================================================================
// TAGGING
// =============================================================================

@description('Resource tags for organization, cost management, and governance.')
param tags object = {}

// =============================================================================
// ADVANCED CONFIGURATION
// =============================================================================

@description('Migration token for resource migration scenarios.')
param migrationToken string = ''

@description('Restore deleted account. Set to true when restoring a previously deleted account.')
param restore bool = false

// =============================================================================
// VARIABLES
// =============================================================================

// Build network ACLs object
var ipRules = [for ip in allowedIpAddresses: {
  value: ip
}]

var virtualNetworkRules = [for subnetId in allowedSubnetIds: {
  id: subnetId
  ignoreMissingVnetServiceEndpoint: ignoreMissingVnetServiceEndpoint
}]

var networkAcls = (networkAclsDefaultAction == 'Deny' || !empty(allowedIpAddresses) || !empty(allowedSubnetIds)) ? {
  defaultAction: networkAclsDefaultAction
  bypass: networkAclsBypass
  ipRules: ipRules
  virtualNetworkRules: virtualNetworkRules
} : null

// Build encryption object
var encryption = encryptionKeySource == 'Microsoft.KeyVault' ? {
  keySource: encryptionKeySource
  keyVaultProperties: {
    keyVaultUri: keyVaultUri
    keyName: keyVaultKeyName
    keyVersion: !empty(keyVaultKeyVersion) ? keyVaultKeyVersion : null
    identityClientId: !empty(encryptionIdentityClientId) ? encryptionIdentityClientId : null
  }
} : null

// Build managed identity object
var identity = managedIdentityType != 'None' ? {
  type: managedIdentityType
  userAssignedIdentities: contains(managedIdentityType, 'UserAssigned') ? userAssignedIdentityIds : null
} : null

// Generate private endpoint name if not provided
var privateEndpointNameGenerated = !empty(privateEndpointName) ? privateEndpointName : '${cognitiveServiceName}-pe'

// Multi-region settings
var multiRegionSettings = enableMultiRegion ? {
  routingMethod: multiRegionRoutingMethod
  regions: additionalRegions
} : null

// User-owned storage configuration
var userOwnedStorage = enableUserOwnedStorage ? userOwnedStorageAccounts : null

// Built-in role definitions for Cognitive Services
var cognitiveServicesRoles = {
  'Cognitive Services Contributor': '25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'
  'Cognitive Services Data Reader': 'b59867f0-fa02-499b-be73-45a86b5b3e1c'
  'Cognitive Services Face Recognizer': '9894cab4-e18a-44aa-828b-cb588cd6f2d7'
  'Cognitive Services OpenAI Contributor': 'a001fd3d-188f-4b5d-821b-7da978bf7442'
  'Cognitive Services OpenAI User': '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
  'Cognitive Services User': 'a97b65f3-24c7-4388-baec-2e87135dc908'
  'Cognitive Services Usages Reader': '2c56ea50-c6b3-40a6-83c0-9d98858bc7d6'
}

// Common diagnostic categories
var diagnosticCategories = [
  'Audit'
  'RequestResponse'
  'Trace'
]

var diagnosticMetrics = [
  'AllMetrics'
]

// =============================================================================
// COGNITIVE SERVICES ACCOUNT RESOURCE
// =============================================================================

@description('Azure Cognitive Services account with comprehensive security and configuration options')
resource cognitiveServicesAccount 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: cognitiveServiceName
  location: location
  tags: tags
  kind: kind
  identity: identity
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  properties: {
    // Custom subdomain (required for private endpoints and Azure AD auth)
    customSubDomainName: !empty(customSubDomainName) ? customSubDomainName : null
    
    // Security settings
    disableLocalAuth: disableLocalAuth
    publicNetworkAccess: publicNetworkAccess
    restrictOutboundNetworkAccess: restrictOutboundNetworkAccess
    allowedFqdnList: !empty(allowedFqdnList) ? allowedFqdnList : null
    
    // Network access control
    networkAcls: networkAcls
    
    // Encryption
    encryption: encryption
    
    // Multi-region configuration
    locations: multiRegionSettings
    
    // User-owned storage
    userOwnedStorage: userOwnedStorage
    
    // Advanced settings
    migrationToken: !empty(migrationToken) ? migrationToken : null
    restore: restore
    dynamicThrottlingEnabled: enableDynamicThrottling
  }
}

// =============================================================================
// RBAC ROLE ASSIGNMENTS
// =============================================================================

@description('Role assignments for RBAC-based access control')
resource rbacAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: {
  name: guid(cognitiveServicesAccount.id, assignment.principalId, assignment.roleDefinitionId)
  scope: cognitiveServicesAccount
  properties: {
    roleDefinitionId: contains(cognitiveServicesRoles, assignment.roleDefinitionId) ? subscriptionResourceId('Microsoft.Authorization/roleDefinitions', cognitiveServicesRoles[assignment.roleDefinitionId]) : assignment.roleDefinitionId
    principalId: assignment.principalId
    principalType: assignment.principalType
    description: assignment.description
  }
}]

// =============================================================================
// PRIVATE ENDPOINT
// =============================================================================

@description('Private endpoint for secure Cognitive Services connectivity')
resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = if (enablePrivateEndpoint && !empty(privateEndpointSubnetId)) {
  name: privateEndpointNameGenerated
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${cognitiveServiceName}-pls'
        properties: {
          privateLinkServiceId: cognitiveServicesAccount.id
          groupIds: [
            'account'
          ]
        }
      }
    ]
  }
}

@description('Private DNS zone group for private endpoint')
resource privateDnsZoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = if (enablePrivateEndpoint && !empty(privateDnsZoneId)) {
  parent: privateEndpoint
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-cognitiveservices-azure-com'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

// =============================================================================
// DIAGNOSTIC SETTINGS
// =============================================================================

@description('Diagnostic settings for Cognitive Services audit logging')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSettings) {
  name: '${cognitiveServiceName}-diagnostics'
  scope: cognitiveServicesAccount
  properties: {
    workspaceId: !empty(logAnalyticsWorkspaceId) ? logAnalyticsWorkspaceId : null
    storageAccountId: !empty(diagnosticStorageAccountId) ? diagnosticStorageAccountId : null
    eventHubAuthorizationRuleId: !empty(eventHubAuthorizationRuleId) ? eventHubAuthorizationRuleId : null
    eventHubName: !empty(eventHubName) ? eventHubName : null
    
    logs: [for category in diagnosticCategories: {
      category: category
      enabled: true
      retentionPolicy: {
        enabled: !empty(diagnosticStorageAccountId)
        days: diagnosticLogsRetentionDays
      }
    }]
    
    metrics: [for metric in diagnosticMetrics: {
      category: metric
      enabled: true
      retentionPolicy: {
        enabled: !empty(diagnosticStorageAccountId)
        days: diagnosticLogsRetentionDays
      }
    }]
  }
}

// =============================================================================
// MONITORING ALERTS
// =============================================================================

@description('Action group for alert notifications')
resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = if (enableAlerts && !empty(alertEmailAddresses)) {
  name: '${cognitiveServiceName}-alerts'
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: substring('${cognitiveServiceName}-ag', 0, 12)
    enabled: true
    emailReceivers: [for (email, index) in alertEmailAddresses: {
      name: 'email${index}'
      emailAddress: email
      useCommonAlertSchema: true
    }]
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Cognitive Services account resource ID')
output cognitiveServiceId string = cognitiveServicesAccount.id

@description('Cognitive Services account name')
output cognitiveServiceName string = cognitiveServicesAccount.name

@description('Cognitive Services account location')
output location string = cognitiveServicesAccount.location

@description('Cognitive Services account kind')
output kind string = cognitiveServicesAccount.kind

@description('Cognitive Services account endpoint')
output endpoint string = cognitiveServicesAccount.properties.endpoint

@description('Cognitive Services account endpoints dictionary')
output endpoints object = cognitiveServicesAccount.properties.endpoints

@description('Cognitive Services account custom subdomain')
output customSubDomainName string = !empty(customSubDomainName) ? cognitiveServicesAccount.properties.customSubDomainName : ''

@description('System-assigned managed identity principal ID')
output systemAssignedIdentityPrincipalId string = (managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned, UserAssigned') ? cognitiveServicesAccount.identity.principalId : ''

@description('System-assigned managed identity tenant ID')
output systemAssignedIdentityTenantId string = (managedIdentityType == 'SystemAssigned' || managedIdentityType == 'SystemAssigned, UserAssigned') ? cognitiveServicesAccount.identity.tenantId : ''

@description('User-assigned managed identities')
output userAssignedIdentities object = contains(managedIdentityType, 'UserAssigned') ? cognitiveServicesAccount.identity.userAssignedIdentities : {}

@description('Private endpoint resource ID')
output privateEndpointId string = enablePrivateEndpoint && !empty(privateEndpointSubnetId) ? privateEndpoint.id : ''

@description('Diagnostic settings resource ID')
output diagnosticSettingsId string = enableDiagnosticSettings ? diagnosticSettings.id : ''

@description('Action group resource ID')
output actionGroupId string = enableAlerts && !empty(alertEmailAddresses) ? actionGroup.id : ''

@description('Cognitive Services account provisioning state')
output provisioningState string = cognitiveServicesAccount.properties.provisioningState

@description('Cognitive Services account configuration summary')
output cognitiveServiceConfig object = {
  name: cognitiveServicesAccount.name
  kind: cognitiveServicesAccount.kind
  skuName: cognitiveServicesAccount.sku.name
  skuCapacity: cognitiveServicesAccount.sku.capacity
  endpoint: cognitiveServicesAccount.properties.endpoint
  customSubDomainName: cognitiveServicesAccount.properties.customSubDomainName
  localAuthDisabled: cognitiveServicesAccount.properties.disableLocalAuth
  publicNetworkAccess: cognitiveServicesAccount.properties.publicNetworkAccess
  privateEndpointEnabled: enablePrivateEndpoint
  encryptionKeySource: encryptionKeySource
  multiRegionEnabled: enableMultiRegion
  diagnosticsEnabled: enableDiagnosticSettings
  alertsEnabled: enableAlerts
}

@description('Security configuration summary')
output securityConfig object = {
  localAuthDisabled: cognitiveServicesAccount.properties.disableLocalAuth
  publicNetworkAccess: cognitiveServicesAccount.properties.publicNetworkAccess
  restrictOutboundNetworkAccess: cognitiveServicesAccount.properties.restrictOutboundNetworkAccess
  networkAclsDefaultAction: networkAclsDefaultAction
  privateEndpointConfigured: enablePrivateEndpoint && !empty(privateEndpointSubnetId)
  customerManagedKeysEnabled: encryptionKeySource == 'Microsoft.KeyVault'
  diagnosticLoggingEnabled: enableDiagnosticSettings
  alertingEnabled: enableAlerts
  managedIdentityType: managedIdentityType
}

@description('Network configuration summary')
output networkConfig object = {
  publicNetworkAccess: cognitiveServicesAccount.properties.publicNetworkAccess
  defaultAction: networkAclsDefaultAction
  bypass: networkAclsBypass
  ipRulesCount: length(allowedIpAddresses)
  vnetRulesCount: length(allowedSubnetIds)
  privateEndpointEnabled: enablePrivateEndpoint
  customSubDomainEnabled: !empty(customSubDomainName)
  restrictOutboundNetworkAccess: cognitiveServicesAccount.properties.restrictOutboundNetworkAccess
}
