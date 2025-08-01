// =============================================================================
// Azure Key Vault Bicep Module - Enterprise Security Configuration
// =============================================================================
// Version: 1.0
// Last Modified: 2025-08-01
// Description: Highly secure Azure Key Vault following Microsoft security best practices
// =============================================================================

targetScope = 'resourceGroup'

// =============================================================================
// REQUIRED PARAMETERS
// =============================================================================

@minLength(3)
@maxLength(24)
@description('Required. Name of the Key Vault. Must be globally unique, 3-24 characters, alphanumeric and hyphens only.')
param keyVaultName string

@description('Required. Azure region where the Key Vault will be deployed. This affects performance, compliance, and data residency.')
param location string = resourceGroup().location

@description('Required. Azure AD tenant ID for the Key Vault. Must be a valid GUID.')
param tenantId string

// =============================================================================
// SKU AND PERFORMANCE
// =============================================================================

@allowed([
  'standard' // Standard tier with software-based keys
  'premium'  // Premium tier with HSM-backed keys
])
@description('Required. Key Vault SKU. Premium recommended for production workloads requiring HSM-backed keys.')
param skuName string = 'premium'

// =============================================================================
// SECURITY PARAMETERS
// =============================================================================

@description('SECURITY: Enable soft delete. Once enabled, cannot be disabled. Provides recovery capabilities for deleted vaults and objects.')
param enableSoftDelete bool = true

@minValue(7)
@maxValue(90)
@description('SECURITY: Soft delete retention period in days. Minimum 7 days, maximum 90 days. Longer periods provide better recovery capabilities.')
param softDeleteRetentionInDays int = 90

@description('SECURITY: Enable purge protection. Once enabled, cannot be disabled. Prevents permanent deletion during retention period.')
param enablePurgeProtection bool = true

@description('SECURITY: Enable RBAC authorization for data plane operations. Recommended over access policies for better security and management.')
param enableRbacAuthorization bool = true

@description('SECURITY: Enable Azure Virtual Machines to retrieve certificates stored as secrets. Only enable if required.')
param enabledForDeployment bool = false

@description('SECURITY: Enable Azure Disk Encryption to retrieve secrets and unwrap keys. Only enable if required for disk encryption.')
param enabledForDiskEncryption bool = false

@description('SECURITY: Enable Azure Resource Manager to retrieve secrets during template deployment. Only enable if required.')
param enabledForTemplateDeployment bool = false

@allowed([
  'enabled'  // Allow public network access (with firewall rules)
  'disabled' // Block all public network access (private endpoints only)
])
@description('SECURITY: Public network access setting. Use "disabled" for maximum security with private endpoints only.')
param publicNetworkAccess string = 'disabled'

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

@description('SECURITY: Array of IP addresses or CIDR ranges allowed to access the Key Vault. Use for specific trusted networks.')
param allowedIpAddresses array = []

@description('SECURITY: Array of virtual network subnet resource IDs allowed to access the Key Vault.')
param allowedSubnetIds array = []

@description('SECURITY: Ignore missing VNet service endpoint when adding VNet rules. Set to true for cross-subscription scenarios.')
param ignoreMissingVnetServiceEndpoint bool = false

// =============================================================================
// ACCESS POLICIES (when RBAC is disabled)
// =============================================================================

@description('Access policies for the Key Vault. Only used when enableRbacAuthorization is false. Use RBAC instead for better security.')
param accessPolicies array = []

// =============================================================================
// RBAC ROLE ASSIGNMENTS
// =============================================================================

@description('SECURITY: Array of role assignments for RBAC authorization. Used when enableRbacAuthorization is true.')
param roleAssignments array = []

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

@description('Enable Azure Monitor alerts for Key Vault operations. Recommended for security monitoring.')
param enableAlerts bool = true

@description('Email addresses for alert notifications.')
param alertEmailAddresses array = []

@description('Enable alerts for key vault access events.')
param enableAccessAlerts bool = true

@description('Enable alerts for failed authentication attempts.')
param enableFailureAlerts bool = true

@description('Enable alerts for administrative operations.')
param enableAdminAlerts bool = true

// =============================================================================
// BACKUP AND RECOVERY (Note: Backup is configured post-deployment)
// =============================================================================
// Key Vault backup is typically handled through Azure Backup or
// custom backup solutions, not during initial vault creation

@description('Compliance standards to monitor (e.g., SOC2, HIPAA, PCI).')
param complianceStandards array = ['SOC2', 'ISO27001']

// =============================================================================
// TAGGING
// =============================================================================

@description('Resource tags for organization, cost management, and governance.')
param tags object = {}

// =============================================================================
// ADVANCED CONFIGURATION
// =============================================================================

@description('Create mode for the Key Vault. Use "recover" to restore a soft-deleted vault.')
@allowed([
  'default' // Create new vault
  'recover' // Recover soft-deleted vault
])
param createMode string = 'default'

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

var networkAcls = {
  defaultAction: networkAclsDefaultAction
  bypass: networkAclsBypass
  ipRules: ipRules
  virtualNetworkRules: virtualNetworkRules
}

// Generate private endpoint name if not provided
var privateEndpointNameGenerated = !empty(privateEndpointName) ? privateEndpointName : '${keyVaultName}-pe'

// Common diagnostic categories
var diagnosticCategories = [
  'AuditEvent'
  'AzurePolicyEvaluationDetails'
]

var diagnosticMetrics = [
  'AllMetrics'
]

// Built-in role definitions for Key Vault
var keyVaultRoles = {
  'Key Vault Administrator': '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  'Key Vault Crypto Officer': '14b46e9e-c2b7-41b4-b07b-48a6ebf60603'
  'Key Vault Crypto User': '12338af0-0e69-4776-bea7-57ae8d297424'
  'Key Vault Reader': '21090545-7ca7-4776-b22c-e363652d74d2'
  'Key Vault Secrets Officer': 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
  'Key Vault Secrets User': '4633458b-17de-408a-b874-0445c86b69e6'
  'Key Vault Certificate Officer': 'a4417e6f-fecd-4de8-b567-7b0420556985'
  'Key Vault Crypto Service Encryption User': 'e147488a-f6f5-4113-8e2d-b22465e65bf6'
}

// =============================================================================
// KEY VAULT RESOURCE
// =============================================================================

@description('Azure Key Vault with comprehensive security and configuration options')
resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    // Core configuration
    tenantId: tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    
    // Create mode
    createMode: createMode
    
    // Security settings
    enableSoftDelete: enableSoftDelete
    softDeleteRetentionInDays: enableSoftDelete ? softDeleteRetentionInDays : null
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    
    // Service integrations
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    
    // Network access
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    
    // Access policies (only when RBAC is disabled)
    accessPolicies: !enableRbacAuthorization ? accessPolicies : null
  }
}

// =============================================================================
// RBAC ROLE ASSIGNMENTS
// =============================================================================

@description('Role assignments for RBAC-based access control')
resource rbacAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (assignment, index) in roleAssignments: if (enableRbacAuthorization) {
  name: guid(keyVault.id, assignment.principalId, assignment.roleDefinitionId)
  scope: keyVault
  properties: {
    roleDefinitionId: contains(keyVaultRoles, assignment.roleDefinitionId) ? subscriptionResourceId('Microsoft.Authorization/roleDefinitions', keyVaultRoles[assignment.roleDefinitionId]) : assignment.roleDefinitionId
    principalId: assignment.principalId
    principalType: assignment.principalType
    description: assignment.description
  }
}]

// =============================================================================
// PRIVATE ENDPOINT
// =============================================================================

@description('Private endpoint for secure Key Vault connectivity')
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
        name: '${keyVaultName}-pls'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
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
        name: 'privatelink-vaultcore-azure-net'
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

@description('Diagnostic settings for Key Vault audit logging')
resource diagnosticSettings 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableDiagnosticSettings) {
  name: '${keyVaultName}-diagnostics'
  scope: keyVault
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
  name: '${keyVaultName}-alerts'
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: substring('${keyVaultName}-ag', 0, 12)
    enabled: true
    emailReceivers: [for (email, index) in alertEmailAddresses: {
      name: 'email${index}'
      emailAddress: email
      useCommonAlertSchema: true
    }]
  }
}

@description('Key Vault access alerts')
resource accessAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableAccessAlerts) {
  name: '${keyVaultName}-access-alert'
  location: 'Global'
  tags: tags
  properties: {
    description: 'Alert when Key Vault access patterns are unusual'
    severity: 2
    enabled: true
    scopes: [
      keyVault.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'HighAccessVolume'
          metricName: 'ServiceApiHit'
          operator: 'GreaterThan'
          threshold: 100
          timeAggregation: 'Count'
        }
      ]
    }
    actions: enableAlerts && !empty(alertEmailAddresses) ? [
      {
        actionGroupId: actionGroup.id
      }
    ] : []
  }
}

@description('Key Vault authentication failure alerts')
resource failureAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableFailureAlerts) {
  name: '${keyVaultName}-failure-alert'
  location: 'Global'
  tags: tags
  properties: {
    description: 'Alert on authentication failures and unauthorized access attempts'
    severity: 1
    enabled: true
    scopes: [
      keyVault.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'AuthenticationFailures'
          metricName: 'ServiceApiResult'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'StatusCode'
              operator: 'Include'
              values: ['401', '403']
            }
          ]
        }
      ]
    }
    actions: enableAlerts && !empty(alertEmailAddresses) ? [
      {
        actionGroupId: actionGroup.id
      }
    ] : []
  }
}

@description('Key Vault administrative operation alerts')
resource adminAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = if (enableAlerts && enableAdminAlerts) {
  name: '${keyVaultName}-admin-alert'
  location: 'Global'
  tags: tags
  properties: {
    description: 'Alert on administrative operations like key creation, deletion, or policy changes'
    severity: 2
    enabled: true
    scopes: [
      keyVault.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'AdminOperations'
          metricName: 'ServiceApiHit'
          operator: 'GreaterThan'
          threshold: 5
          timeAggregation: 'Count'
          dimensions: [
            {
              name: 'ActivityName'
              operator: 'Include'
              values: ['KeyCreate', 'KeyDelete', 'SecretSet', 'SecretDelete', 'PolicyChange']
            }
          ]
        }
      ]
    }
    actions: enableAlerts && !empty(alertEmailAddresses) ? [
      {
        actionGroupId: actionGroup.id
      }
    ] : []
  }
}

// =============================================================================
// OUTPUTS
// =============================================================================

@description('Key Vault resource ID')
output keyVaultId string = keyVault.id

@description('Key Vault name')
output keyVaultName string = keyVault.name

@description('Key Vault location')
output location string = keyVault.location

@description('Key Vault URI for operations')
output keyVaultUri string = keyVault.properties.vaultUri

@description('Key Vault tenant ID')
output tenantId string = keyVault.properties.tenantId

@description('Key Vault SKU')
output skuName string = keyVault.properties.sku.name

@description('Private endpoint resource ID')
output privateEndpointId string = enablePrivateEndpoint && !empty(privateEndpointSubnetId) ? privateEndpoint.id : ''

@description('Private endpoint IP address (available after deployment)')
output privateEndpointIpAddress string = enablePrivateEndpoint && !empty(privateEndpointSubnetId) ? 'Available after deployment' : ''

@description('Diagnostic settings resource ID')
output diagnosticSettingsId string = enableDiagnosticSettings ? diagnosticSettings.id : ''

@description('Action group resource ID')
output actionGroupId string = enableAlerts && !empty(alertEmailAddresses) ? actionGroup.id : ''

@description('Key Vault configuration summary')
output keyVaultConfig object = {
  name: keyVault.name
  uri: keyVault.properties.vaultUri
  tenantId: keyVault.properties.tenantId
  skuName: keyVault.properties.sku.name
  softDeleteEnabled: keyVault.properties.enableSoftDelete
  purgeProtectionEnabled: keyVault.properties.enablePurgeProtection
  rbacEnabled: keyVault.properties.enableRbacAuthorization
  publicNetworkAccess: keyVault.properties.publicNetworkAccess
  privateEndpointEnabled: enablePrivateEndpoint
  diagnosticsEnabled: enableDiagnosticSettings
  alertsEnabled: enableAlerts
}

@description('Security configuration summary')
output securityConfig object = {
  softDeleteRetentionDays: keyVault.properties.softDeleteRetentionInDays
  purgeProtectionEnabled: keyVault.properties.enablePurgeProtection
  rbacAuthorizationEnabled: keyVault.properties.enableRbacAuthorization
  publicNetworkAccess: keyVault.properties.publicNetworkAccess
  networkAclsDefaultAction: keyVault.properties.networkAcls.defaultAction
  privateEndpointConfigured: enablePrivateEndpoint && !empty(privateEndpointSubnetId)
  diagnosticLoggingEnabled: enableDiagnosticSettings
  alertingEnabled: enableAlerts
}

@description('Network configuration summary')
output networkConfig object = {
  publicNetworkAccess: keyVault.properties.publicNetworkAccess
  defaultAction: keyVault.properties.networkAcls.defaultAction
  bypass: keyVault.properties.networkAcls.bypass
  ipRulesCount: length(keyVault.properties.networkAcls.ipRules)
  vnetRulesCount: length(keyVault.properties.networkAcls.virtualNetworkRules)
  privateEndpointEnabled: enablePrivateEndpoint
}

@description('Compliance configuration summary')
output complianceConfig object = {
  auditLoggingEnabled: enableDiagnosticSettings
  softDeleteEnabled: keyVault.properties.enableSoftDelete
  purgeProtectionEnabled: keyVault.properties.enablePurgeProtection
  rbacEnabled: keyVault.properties.enableRbacAuthorization
  privateAccessOnly: keyVault.properties.publicNetworkAccess == 'disabled'
  encryptionAtRest: true // Key Vault always encrypts at rest
  complianceStandards: complianceStandards
}
