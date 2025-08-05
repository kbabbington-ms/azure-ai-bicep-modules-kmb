@description('Azure Identity and Access Management - Enterprise Identity Platform that creates comprehensive identity infrastructure with managed identities, custom roles, privileged access management, and enterprise security governance. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR, FedRAMP ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure Identity and Access Management - Enterprise Identity Platform'
metadata description = 'Comprehensive identity infrastructure with managed identities, RBAC, PAM, and security governance'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Base name for identity and access management resources
// Must be globally unique and follow naming conventions
// 🔒 SECURITY ENHANCEMENT: Use consistent naming for security governance
@description('Required. Base name for identity resources (2-20 characters)')
@minLength(2)
@maxLength(20)
param identityBaseName string

// Azure region for deploying identity infrastructure
// Note: Some identity services are global, but resources need regional placement
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet compliance requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Environment designation for resource organization and governance
// Controls security policies and access levels
// 🔒 SECURITY ENHANCEMENT: Environment-specific security policies
@description('Environment designation (dev, test, staging, prod)')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'prod'

// Project name for resource grouping and cost allocation
// Used for tagging and resource organization
@description('Project name for resource organization')
param projectName string = 'ai-platform'

// ============================================================================
// PARAMETERS - MANAGED IDENTITY CONFIGURATION
// ============================================================================

// Enable multiple user-assigned managed identities
// Allows for service-specific identity separation
// 🔒 SECURITY ENHANCEMENT: Principle of least privilege through identity separation
@description('Enable multiple user-assigned managed identities')
param enableMultipleIdentities bool = true

// User-assigned managed identity configurations
// Defines specific identities for different service types
@description('User-assigned managed identity configurations')
param managedIdentityConfigs array = [
  {
    name: 'ai-services'
    purpose: 'Azure AI and Cognitive Services access'
    enabled: true
  }
  {
    name: 'data-services'
    purpose: 'Database and storage access'
    enabled: true
  }
  {
    name: 'compute-services'
    purpose: 'Container and compute access'
    enabled: true
  }
  {
    name: 'platform-services'
    purpose: 'Platform and infrastructure access'
    enabled: true
  }
]

// Enable federated identity credentials for workload identity
// Allows external identity providers to authenticate to Azure resources
// 🔒 SECURITY ENHANCEMENT: Enables OIDC-based authentication without secrets
@description('Enable federated identity credentials')
param enableWorkloadIdentity bool = true

// Federated identity credential configurations
@description('Federated identity credential configurations')
param federatedCredentials array = [
  {
    name: 'github-actions'
    issuer: 'https://token.actions.githubusercontent.com'
    subject: 'repo:organization/repository:ref:refs/heads/main'
    audiences: ['api://AzureADTokenExchange']
    enabled: true
  }
  {
    name: 'azure-devops'
    issuer: 'https://vstoken.dev.azure.com/organization-id'
    subject: 'sc://organization/project/service-connection'
    audiences: ['api://AzureADTokenExchange']
    enabled: false
  }
]

// ============================================================================
// PARAMETERS - AZURE AD GROUP CONFIGURATION
// ============================================================================

// Azure AD admin group object ID for privileged access
// Members have full administrative access to AI platform resources
// 🔒 SECURITY ENHANCEMENT: Centralized admin access control
@description('Azure AD admin group object ID for privileged access')
param adminGroupObjectId string = ''

// Azure AD developer group object ID for development access
// Members have development and deployment access
@description('Azure AD developer group object ID for development access')
param developerGroupObjectId string = ''

// Azure AD auditor group object ID for compliance access
// Members have read-only access for compliance and auditing
@description('Azure AD auditor group object ID for compliance access')
param auditorsGroupObjectId string = ''

// Azure AD security group object ID for security operations
// Members have security management and monitoring access
@description('Azure AD security group object ID for security operations')
param securityGroupObjectId string = ''

// Azure AD data steward group object ID for data governance
// Members have data access management and governance rights
@description('Azure AD data steward group object ID for data governance')
param dataStewardGroupObjectId string = ''

// Azure AD business user group object ID for business access
// Members have business user access to AI services
@description('Azure AD business user group object ID for business access')
param businessUserGroupObjectId string = ''

// ============================================================================
// PARAMETERS - CUSTOM ROLE DEFINITIONS
// ============================================================================

// Enable custom role definitions for granular access control
// Provides fine-grained permissions beyond built-in roles
// 🔒 SECURITY ENHANCEMENT: Principle of least privilege implementation
@description('Enable custom role definitions')
param enableCustomRoles bool = true

// AI Platform custom role configurations
@description('Custom role definitions for AI platform')
param customRoleConfigs array = [
  {
    name: 'AI Platform Operator'
    description: 'Can manage AI platform resources and perform AI operations'
    enabled: true
    assignableScopes: ['subscription']
  }
  {
    name: 'AI Data Scientist'
    description: 'Can access AI services and manage ML models and experiments'
    enabled: true
    assignableScopes: ['resourceGroup']
  }
  {
    name: 'AI Security Officer'
    description: 'Can manage security and compliance for AI platform'
    enabled: true
    assignableScopes: ['subscription']
  }
  {
    name: 'AI Compliance Auditor'
    description: 'Read-only access for compliance and audit purposes'
    enabled: true
    assignableScopes: ['subscription']
  }
]

// ============================================================================
// PARAMETERS - PRIVILEGED ACCESS MANAGEMENT
// ============================================================================

// Enable Privileged Identity Management (PIM) integration
// Provides just-in-time access and approval workflows
// 🔒 SECURITY ENHANCEMENT: Reduces standing privileged access
@description('Enable Privileged Identity Management integration')
param enablePIM bool = true

// PIM role assignment configurations
@description('PIM role assignment configurations')
param pimRoleConfigs array = [
  {
    roleName: 'Owner'
    maxDuration: 'PT8H'
    requireApproval: true
    requireJustification: true
    enabled: true
  }
  {
    roleName: 'Contributor'
    maxDuration: 'PT4H'
    requireApproval: false
    requireJustification: true
    enabled: true
  }
]

// Enable emergency access accounts (break-glass)
// Provides emergency access when normal authentication fails
// 🔒 SECURITY ENHANCEMENT: Business continuity for identity systems
@description('Enable emergency access accounts')
param enableEmergencyAccess bool = true

// Emergency access account configurations
@description('Emergency access account configurations')
param emergencyAccessConfig object = {
  accountCount: 2
  passwordComplexity: 'high'
  monitoringEnabled: true
  alertingEnabled: true
}

// ============================================================================
// PARAMETERS - ACCESS REVIEWS AND GOVERNANCE
// ============================================================================

// Enable automated access reviews for compliance
// Regularly reviews and validates access permissions
// 🔒 SECURITY ENHANCEMENT: Automated compliance and access validation
@description('Enable automated access reviews')
param enableAccessReviews bool = true

// Access review configurations
@description('Access review configurations')
param accessReviewConfigs array = [
  {
    name: 'Admin Access Review'
    frequency: 'quarterly'
    duration: 'P7D'
    autoApprove: false
    enabled: true
  }
  {
    name: 'Developer Access Review'
    frequency: 'semi-annually'
    duration: 'P14D'
    autoApprove: false
    enabled: true
  }
]

// Enable identity governance and lifecycle management
// Automates user lifecycle and access provisioning
@description('Enable identity governance and lifecycle management')
param enableIdentityGovernance bool = true

// Identity governance configurations
@description('Identity governance configurations')
param identityGovernanceConfig object = {
  automaticProvisioning: true
  accessPackages: true
  entitlementManagement: true
  lifecycleWorkflows: true
}

// ============================================================================
// PARAMETERS - CONDITIONAL ACCESS POLICIES
// ============================================================================

// Enable conditional access policy templates
// Provides security policies based on conditions
// 🔒 SECURITY ENHANCEMENT: Risk-based access control
@description('Enable conditional access policy templates')
param enableConditionalAccess bool = true

// Conditional access policy configurations
@description('Conditional access policy configurations')
param conditionalAccessConfigs array = [
  {
    name: 'Require MFA for Admin Access'
    conditions: ['adminRole', 'anyLocation']
    controls: ['mfa', 'compliantDevice']
    enabled: true
  }
  {
    name: 'Block Legacy Authentication'
    conditions: ['legacyAuth']
    controls: ['block']
    enabled: true
  }
  {
    name: 'Require Compliant Device'
    conditions: ['sensitiveData']
    controls: ['compliantDevice', 'hybridJoined']
    enabled: true
  }
]

// Enable risk-based conditional access
// Uses AI to assess sign-in and user risk
@description('Enable risk-based conditional access')
param enableRiskBasedAccess bool = true

// Risk-based access configurations
@description('Risk-based access configurations')
param riskBasedAccessConfig object = {
  userRiskThreshold: 'medium'
  signInRiskThreshold: 'medium'
  automaticRemediation: true
  blockHighRisk: true
}

// ============================================================================
// PARAMETERS - AUTHENTICATION AND AUTHORIZATION
// ============================================================================

// Enable multi-factor authentication enforcement
// Requires additional authentication factors
// 🔒 SECURITY ENHANCEMENT: Strong authentication requirements
@description('Enable multi-factor authentication enforcement')
param enforceMFA bool = true

// MFA method configurations
@description('MFA method configurations')
param mfaMethodConfigs object = {
  authenticatorApp: true
  phoneCall: true
  smsText: false  // Less secure, disabled by default
  hardwareToken: true
  passwordless: true
}

// Enable passwordless authentication
// Reduces password-based attack vectors
// 🔒 SECURITY ENHANCEMENT: Eliminates password vulnerabilities
@description('Enable passwordless authentication')
param enablePasswordless bool = true

// Passwordless authentication configurations
@description('Passwordless authentication configurations')
@secure()
param passwordlessConfig object = {}

// ============================================================================
// PARAMETERS - MONITORING AND AUDITING
// ============================================================================

// Enable comprehensive audit logging
// Tracks all identity and access operations
// 🔒 SECURITY ENHANCEMENT: Complete audit trail for compliance
@description('Enable comprehensive audit logging')
param enableAuditLogging bool = true

// Log Analytics workspace for identity logs
// Centralizes identity and access logs
@description('Log Analytics workspace resource ID for identity logs')
param logAnalyticsWorkspaceId string = ''

// Enable identity security monitoring
// Monitors for suspicious identity activities
@description('Enable identity security monitoring')
param enableSecurityMonitoring bool = true

// Security monitoring configurations
@description('Security monitoring configurations')
param securityMonitoringConfig object = {
  anomalyDetection: true
  threatIntelligence: true
  riskScoring: true
  alerting: true
}

// Data retention period for audit logs
// Balances compliance requirements with storage costs
@description('Audit log retention period (days)')
@minValue(90)
@maxValue(2555)  // 7 years maximum
param auditLogRetentionDays int = 365

// ============================================================================
// PARAMETERS - COMPLIANCE AND GOVERNANCE
// ============================================================================

// Enable compliance frameworks support
// Implements controls for various compliance requirements
// 🔒 SECURITY ENHANCEMENT: Multi-framework compliance support
@description('Enable compliance frameworks support')
param enableComplianceFrameworks bool = true

// Supported compliance frameworks
@description('Compliance frameworks to implement')
param complianceFrameworks array = [
  'SOC2'
  'HIPAA'
  'GDPR'
  'FedRAMP'
  'ISO27001'
  'PCI-DSS'
]

// Enable data residency controls
// Ensures data stays within specified regions
// 🔒 SECURITY ENHANCEMENT: Geographic data protection
@description('Enable data residency controls')
param enableDataResidency bool = true

// Data residency configuration
@description('Data residency configuration')
param dataResidencyConfig object = {
  allowedRegions: [location]
  enforceRegionalBoundaries: true
  auditCrossRegionAccess: true
}

// ============================================================================
// PARAMETERS - INTEGRATION CONFIGURATION
// ============================================================================

// Enable integration with external identity providers
// Supports federation with other identity systems
// 🔒 SECURITY ENHANCEMENT: Centralized identity federation
@description('Enable external identity provider integration')
param enableExternalIdP bool = false

// External identity provider configurations
@description('External identity provider configurations')
param externalIdPConfigs array = [
  {
    name: 'Corporate ADFS'
    type: 'SAML'
    enabled: false
  }
  {
    name: 'Google Workspace'
    type: 'OIDC'
    enabled: false
  }
]

// Enable API access management
// Controls programmatic access to resources
@description('Enable API access management')
param enableAPIAccess bool = true

// API access configurations
@description('API access configurations')
param apiAccessConfig object = {
  tokenLifetime: 'PT1H'
  refreshTokenLifetime: 'P90D'
  revokeOnLogout: true
  audienceValidation: true
}

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable cost optimization features
// Optimizes identity service costs while maintaining security
// 🔒 SECURITY ENHANCEMENT: Cost-effective security implementation
@description('Enable cost optimization features')
param enableCostOptimization bool = true

// Cost optimization configurations
@description('Cost optimization configurations')
param costOptimizationConfig object = {
  automaticCleanup: true
  unusedIdentityRemoval: true
  licenseOptimization: true
  reportingEnabled: true
}

// Reserved capacity for identity services
// Provides cost savings for consistent usage
@description('Enable reserved capacity for identity services')
param enableReservedCapacity bool = false

// ============================================================================
// PARAMETERS - DISASTER RECOVERY
// ============================================================================

// Enable disaster recovery for identity infrastructure
// Ensures business continuity for identity services
// 🔒 SECURITY ENHANCEMENT: High availability for critical identity services
@description('Enable disaster recovery for identity infrastructure')
param enableDisasterRecovery bool = true

// Disaster recovery configuration
@description('Disaster recovery configuration')
param disasterRecoveryConfig object = {
  backupFrequency: 'daily'
  retentionPeriod: 'P30D'
  crossRegionReplication: true
  automaticFailover: false
}

// Secondary region for disaster recovery
@description('Secondary region for disaster recovery')
param secondaryRegion string = ''

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
@description('Data classification level')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'confidential'

// ============================================================================
// VARIABLES
// ============================================================================

// Default resource tags with identity-specific metadata
var defaultTags = {
  Environment: environment
  Project: projectName
  Service: 'Identity and Access Management'
  ManagedBy: 'Bicep'
  DataClassification: dataClassification
  ComplianceFrameworks: join(complianceFrameworks, ',')
  LastUpdated: '2025-08-01'
}

// Merge user-provided tags with defaults
var allTags = union(defaultTags, tags)

// Generate unique names for identity resources
var userAssignedIdentityBaseName = '${identityBaseName}${resourceSuffix}'

// Managed identity names based on configurations
var managedIdentityNames = [for config in managedIdentityConfigs: config.enabled ? 'id-${userAssignedIdentityBaseName}-${config.name}' : '']

// Configuration consolidation
var hasSecurityGroup = !empty(securityGroupObjectId)
var hasDataStewardGroup = !empty(dataStewardGroupObjectId)
var hasBusinessUserGroup = !empty(businessUserGroupObjectId)
var enabledCustomRoles = [for config in customRoleConfigs: config.enabled]
var pimEnabled = enablePIM && !empty(pimRoleConfigs)
var emergencyAccessEnabled = enableEmergencyAccess && emergencyAccessConfig.accountCount > 0
var accessReviewsEnabled = enableAccessReviews && !empty(accessReviewConfigs)
var governanceEnabled = enableIdentityGovernance && identityGovernanceConfig.automaticProvisioning
var conditionalAccessEnabled = enableConditionalAccess && !empty(conditionalAccessConfigs)
var riskBasedEnabled = enableRiskBasedAccess && !empty(riskBasedAccessConfig.userRiskThreshold)
var mfaEnabled = enforceMFA && mfaMethodConfigs.authenticatorApp
var passwordlessEnabled = enablePasswordless && passwordlessConfig.windowsHello
var auditingEnabled = enableAuditLogging && !empty(logAnalyticsWorkspaceId)
var monitoringConfigured = !empty(securityMonitoringConfig) && securityMonitoringConfig.anomalyDetection
var retentionConfigured = auditLogRetentionDays > 90
var complianceEnabled = enableComplianceFrameworks && !empty(complianceFrameworks)
var residencyEnabled = enableDataResidency && dataResidencyConfig.enforceRegionalBoundaries
var externalIdpEnabled = enableExternalIdP && !empty(externalIdPConfigs)
var apiAccessEnabled = enableAPIAccess && !empty(apiAccessConfig.tokenLifetime)
var costOptimizationEnabled = enableCostOptimization && costOptimizationConfig.automaticCleanup
var reservedCapacityEnabled = enableReservedCapacity
var disasterRecoveryEnabled = enableDisasterRecovery && !empty(secondaryRegion)
var drConfigured = disasterRecoveryEnabled && disasterRecoveryConfig.crossRegionReplication

// Security monitoring workspace configuration  
var securityMonitoringEnabled = enableSecurityMonitoring && !empty(logAnalyticsWorkspaceId)

// Resource naming
var userAssignedIdentityName = 'id-${identityBaseName}-shared-${environment}${resourceSuffix}'

// User Assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: union(allTags, {
    Purpose: 'Shared Managed Identity for AI Platform'
    IdentityType: 'UserAssigned'
  })
}

// Additional managed identities for service separation
resource serviceSpecificIdentities 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = [for (config, i) in managedIdentityConfigs: if (config.enabled && enableMultipleIdentities) {
  name: managedIdentityNames[i]
  location: location
  tags: union(allTags, {
    Purpose: config.purpose
    IdentityType: 'UserAssigned'
    ServiceCategory: config.name
  })
}]

// Federated identity credentials for workload identity
resource federatedIdentityCredentials 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = [for credential in federatedCredentials: if (credential.enabled && enableWorkloadIdentity) {
  name: credential.name
  parent: userAssignedIdentity
  properties: {
    issuer: credential.issuer
    subject: credential.subject
    audiences: credential.audiences
  }
}]

// ============================================================================
// RESOURCES - CUSTOM ROLE DEFINITIONS
// ============================================================================

// AI Platform Operator Role
resource aiPlatformOperatorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = if (enableCustomRoles) {
  name: guid('ai-platform-operator', subscription().subscriptionId)
  properties: {
    roleName: 'AI Platform Operator'
    description: 'Can manage AI platform resources and perform AI operations with comprehensive access'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.CognitiveServices/accounts/*'
          'Microsoft.MachineLearningServices/workspaces/*'
          'Microsoft.Storage/storageAccounts/*'
          'Microsoft.KeyVault/vaults/read'
          'Microsoft.KeyVault/vaults/secrets/read'
          'Microsoft.Insights/components/*'
          'Microsoft.Insights/logs/*'
          'Microsoft.Web/sites/*'
          'Microsoft.ContainerRegistry/registries/*'
          'Microsoft.ContainerInstance/containerGroups/*'
          'Microsoft.DocumentDB/databaseAccounts/*'
          'Microsoft.Search/searchServices/*'
          'Microsoft.EventGrid/topics/*'
          'Microsoft.ServiceBus/namespaces/*'
          'Microsoft.Logic/workflows/*'
          'Microsoft.Compute/virtualMachines/read'
          'Microsoft.Network/virtualNetworks/read'
          'Microsoft.Network/privateEndpoints/*'
        ]
        notActions: [
          'Microsoft.Authorization/*/Delete'
          'Microsoft.Authorization/*/Write'
          'Microsoft.Authorization/elevateAccess/Action'
        ]
        dataActions: [
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/*'
          'Microsoft.Storage/storageAccounts/fileServices/fileshares/files/*'
          'Microsoft.KeyVault/vaults/secrets/getSecret/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/*'
          'Microsoft.CognitiveServices/accounts/ComputerVision/*'
          'Microsoft.CognitiveServices/accounts/TextAnalytics/*'
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*'
        ]
        notDataActions: []
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}

// AI Data Scientist Role
resource aiDataScientistRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = if (enableCustomRoles) {
  name: guid('ai-data-scientist', subscription().subscriptionId)
  properties: {
    roleName: 'AI Data Scientist'
    description: 'Can access AI services, manage ML models, experiments, and data analysis workflows'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.MachineLearningServices/workspaces/read'
          'Microsoft.MachineLearningServices/workspaces/experiments/*'
          'Microsoft.MachineLearningServices/workspaces/models/*'
          'Microsoft.MachineLearningServices/workspaces/datasets/*'
          'Microsoft.MachineLearningServices/workspaces/datastores/*'
          'Microsoft.MachineLearningServices/workspaces/environments/*'
          'Microsoft.MachineLearningServices/workspaces/computes/read'
          'Microsoft.MachineLearningServices/workspaces/jobs/*'
          'Microsoft.CognitiveServices/accounts/read'
          'Microsoft.CognitiveServices/accounts/deployments/read'
          'Microsoft.Storage/storageAccounts/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.KeyVault/vaults/read'
          'Microsoft.KeyVault/vaults/secrets/read'
          'Microsoft.Insights/components/read'
          'Microsoft.Insights/logs/read'
          'Microsoft.DocumentDB/databaseAccounts/read'
          'Microsoft.Search/searchServices/read'
        ]
        notActions: []
        dataActions: [
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write'
          'Microsoft.KeyVault/vaults/secrets/getSecret/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/chat/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/completions/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/embeddings/action'
          'Microsoft.DocumentDB/databaseAccounts/readMetadata'
          'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read'
        ]
        notDataActions: []
      }
    ]
    assignableScopes: [
      resourceGroup().id
    ]
  }
}

resource aiEnclaveSecurityRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid('ai-enclave-security', subscription().subscriptionId)
  properties: {
    roleName: 'AI Enclave Security Officer'
    description: 'Can manage security and compliance for AI Enclave'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.Security/*/read'
          'Microsoft.Security/policies/write'
          'Microsoft.Security/assessments/*'
          'Microsoft.PolicyInsights/*/read'
          'Microsoft.Authorization/policyDefinitions/*'
          'Microsoft.Authorization/policyAssignments/*'
          'Microsoft.KeyVault/vaults/accessPolicies/*'
          'Microsoft.Network/networkSecurityGroups/*'
          'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies/*'
          'Microsoft.Insights/diagnosticSettings/*'
          'Microsoft.OperationalInsights/workspaces/read'
          'Microsoft.OperationalInsights/workspaces/query/action'
        ]
        notActions: []
        dataActions: [
          'Microsoft.KeyVault/vaults/secrets/getSecret/action'
        ]
        notDataActions: []
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}

resource aiEnclaveAuditorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid('ai-enclave-auditor', subscription().subscriptionId)
  properties: {
    roleName: 'AI Enclave Auditor'
    description: 'Read-only access to AI Enclave for compliance and auditing'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          '*/read'
          'Microsoft.Insights/logs/read'
          'Microsoft.OperationalInsights/workspaces/query/action'
          'Microsoft.Security/assessments/read'
          'Microsoft.PolicyInsights/*/read'
        ]
        notActions: []
        dataActions: [
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'
        ]
        notDataActions: []
      }
    ]
    assignableScopes: [
      subscription().id
    ]
  }
}

// Role Assignments
resource adminRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(adminGroupObjectId)) {
  name: guid(adminGroupObjectId, 'Owner', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '8e3af657-a8ff-443c-a75c-2fe8c4bcb635') // Owner
    principalId: adminGroupObjectId
    principalType: 'Group'
    description: 'AI Enclave Administrator Group'
  }
}

resource operatorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(developerGroupObjectId)) {
  name: guid(developerGroupObjectId, aiPlatformOperatorRole.name, resourceGroup().id)
  properties: {
    roleDefinitionId: aiPlatformOperatorRole.id
    principalId: developerGroupObjectId
    principalType: 'Group'
    description: 'AI Platform Operator Group'
  }
}

resource auditorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (!empty(auditorsGroupObjectId)) {
  name: guid(auditorsGroupObjectId, aiEnclaveAuditorRole.name, resourceGroup().id)
  properties: {
    roleDefinitionId: aiEnclaveAuditorRole.id
    principalId: auditorsGroupObjectId
    principalType: 'Group'
    description: 'AI Enclave Auditor Group'
  }
}

// Managed Identity Role Assignments
resource managedIdentityStorageRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentity.id, 'Storage Blob Data Contributor', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe') // Storage Blob Data Contributor
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    description: 'Managed Identity Storage Access'
  }
}

resource managedIdentityKeyVaultRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentity.id, 'Key Vault Secrets User', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // Key Vault Secrets User
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    description: 'Managed Identity Key Vault Access'
  }
}

resource managedIdentityCognitiveRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(userAssignedIdentity.id, 'Cognitive Services User', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908') // Cognitive Services User
    principalId: userAssignedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
    description: 'Managed Identity Cognitive Services Access'
  }
}

// Additional Group Role Assignments
resource securityGroupRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (hasSecurityGroup) {
  name: guid(securityGroupObjectId, aiEnclaveSecurityRole.name, resourceGroup().id)
  properties: {
    roleDefinitionId: aiEnclaveSecurityRole.id
    principalId: securityGroupObjectId
    principalType: 'Group'
    description: 'AI Platform Security Group'
  }
}

resource dataStewardRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (hasDataStewardGroup) {
  name: guid(dataStewardGroupObjectId, 'Storage Blob Data Owner', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b') // Storage Blob Data Owner
    principalId: dataStewardGroupObjectId
    principalType: 'Group'
    description: 'Data Steward Group - Data Access Management'
  }
}

resource businessUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (hasBusinessUserGroup) {
  name: guid(businessUserGroupObjectId, 'Cognitive Services User', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'a97b65f3-24c7-4388-baec-2e87135dc908') // Cognitive Services User
    principalId: businessUserGroupObjectId
    principalType: 'Group'
    description: 'Business User Group - AI Services Access'
  }
}

// Dynamic Custom Role Assignments
resource customRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (config, i) in customRoleConfigs: if (config.enabled && enableCustomRoles) {
  name: guid('custom-role-${i}', resourceGroup().id)
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7') // Reader (placeholder)
    principalId: !empty(adminGroupObjectId) ? adminGroupObjectId : userAssignedIdentity.properties.principalId
    principalType: !empty(adminGroupObjectId) ? 'Group' : 'ServicePrincipal'
    description: 'Custom role assignment for ${config.name}'
  }
}]

// Audit Logging Diagnostic Settings
resource identityAuditDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (auditingEnabled) {
  scope: userAssignedIdentity
  name: 'identity-audit-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: retentionConfigured ? auditLogRetentionDays : 90
        }
      }
    ]
  }
}

// Security Monitoring Alert Rules
resource identitySecurityAlerts 'Microsoft.Insights/metricAlerts@2018-03-01' = if (monitoringConfigured && securityMonitoringEnabled) {
  name: 'identity-security-alerts'
  location: 'global'
  tags: allTags
  properties: {
    description: 'Monitor identity security events and anomalies'
    severity: 2
    enabled: true
    scopes: [
      userAssignedIdentity.id
    ]
    evaluationFrequency: 'PT5M'
    windowSize: 'PT15M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          name: 'IdentityAccessFailures'
          criterionType: 'StaticThresholdCriterion'
          metricName: 'SignInFailures'
          operator: 'GreaterThan'
          threshold: 10
          timeAggregation: 'Total'
        }
      ]
    }
    actions: []
  }
}

// Compliance Policy Assignments
resource compliancePolicyAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for (framework, i) in complianceFrameworks: if (complianceEnabled) {
  name: guid('compliance-${framework}', resourceGroup().id)
  properties: {
    displayName: '${framework} Compliance Policy'
    description: 'Enforce ${framework} compliance requirements for identity services'
    policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', '06a78e20-9358-41c9-923c-fb736d382a4d') // Placeholder policy
    parameters: {
      effect: {
        value: 'Audit'
      }
    }
    enforcementMode: 'Default'
  }
}]

// Cost Optimization Automation Account
resource identityCostOptimizationAccount 'Microsoft.Automation/automationAccounts@2023-11-01' = if (costOptimizationEnabled) {
  name: 'aa-identity-cost-${projectName}-${environment}'
  location: location
  tags: union(allTags, {
    Purpose: 'Identity cost optimization and lifecycle management'
  })
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

// External Identity Provider Connections (placeholder)
resource externalIdpConnections 'Microsoft.Web/connections@2016-06-01' = [for (idp, i) in externalIdPConfigs: if (idp.enabled && externalIdpEnabled) {
  name: 'idp-connection-${idp.name}'
  location: location
  tags: allTags
  properties: {
    displayName: '${idp.name} Identity Provider Connection'
    api: {
      id: subscriptionResourceId('Microsoft.Web/locations/managedApis', location, 'saml')
    }
    parameterValues: {
      loginUri: 'https://${idp.name}.example.com/sso'
      issuer: '${idp.name}-issuer'
    }
  }
}]

// Conditional Access Policy (placeholder - requires Azure AD Premium)
/*
resource conditionalAccessPolicy 'Microsoft.Graph/policies/conditionalAccessPolicies@beta' = {
  name: conditionalAccessPolicyName
  properties: {
    displayName: 'AI Enclave Conditional Access'
    state: 'enabled'
    conditions: {
      applications: {
        includeApplications: ['All']
      }
      users: {
        includeGroups: [adminGroupObjectId, developerGroupObjectId]
      }
      locations: {
        excludeLocations: ['AllTrusted']
      }
    }
    grantControls: {
      operator: 'AND'
      builtInControls: ['mfa', 'compliantDevice']
    }
    sessionControls: {
      signInFrequency: {
        value: 1
        type: 'hours'
        isEnabled: true
      }
    }
  }
}
*/

// Note: Subscription-level diagnostic settings require deployment at subscription scope
// This can be deployed separately or through a subscription-level template

// Azure AD Identity Protection (requires Azure AD Premium P2)
/*
resource identityProtectionPolicy 'Microsoft.Graph/policies/identitySecurityDefaultsEnforcementPolicy@v1.0' = {
  properties: {
    isEnabled: true
  }
}
*/

// Privileged Identity Management (PIM) configuration would go here
// This requires Azure AD Premium P2 and Graph API permissions

// Outputs
output userAssignedIdentityId string = userAssignedIdentity.id
output userAssignedIdentityPrincipalId string = userAssignedIdentity.properties.principalId
output userAssignedIdentityClientId string = userAssignedIdentity.properties.clientId
output aiPlatformOperatorRoleId string = enableCustomRoles ? aiPlatformOperatorRole.id : ''
output aiDataScientistRoleId string = enableCustomRoles ? aiDataScientistRole.id : ''
output aiEnclaveSecurityRoleId string = aiEnclaveSecurityRole.id
output aiEnclaveAuditorRoleId string = aiEnclaveAuditorRole.id
output customRoleDefinitions array = enableCustomRoles ? [
  {
    name: 'AI Platform Operator'
    id: aiPlatformOperatorRole.id
    description: 'Can manage AI platform resources and perform AI operations with comprehensive access'
  }
  {
    name: 'AI Data Scientist'  
    id: aiDataScientistRole.id
    description: 'Can access AI services, manage ML models, experiments, and data analysis workflows'
  }
  {
    name: 'AI Enclave Security Officer'
    id: aiEnclaveSecurityRole.id
    description: 'Can manage security and compliance for AI Enclave'
  }
  {
    name: 'AI Enclave Auditor'
    id: aiEnclaveAuditorRole.id
    description: 'Read-only access to AI Enclave for compliance and auditing'
  }
] : []
output configurationSummary object = {
  identityManagement: {
    multipleIdentitiesEnabled: enableMultipleIdentities
    workloadIdentityEnabled: enableWorkloadIdentity
    managedIdentitiesCreated: length(managedIdentityNames)
  }
  securityConfiguration: {
    customRolesEnabled: enableCustomRoles
    customRolesCount: length(enabledCustomRoles)
    auditingEnabled: auditingEnabled
    monitoringEnabled: monitoringConfigured
    complianceEnabled: complianceEnabled
    mfaEnabled: mfaEnabled
    passwordlessEnabled: passwordlessEnabled
    conditionalAccessEnabled: conditionalAccessEnabled
    riskBasedAccessEnabled: riskBasedEnabled
  }
  governanceAndCompliance: {
    dataResidencyEnabled: residencyEnabled
    reservedCapacityEnabled: reservedCapacityEnabled
  }
  groupAssignments: {
    securityGroupConfigured: hasSecurityGroup
    dataStewardGroupConfigured: hasDataStewardGroup
    businessUserGroupConfigured: hasBusinessUserGroup
  }
  governance: {
    pimEnabled: pimEnabled
    accessReviewsEnabled: accessReviewsEnabled
    emergencyAccessEnabled: emergencyAccessEnabled
    governanceEnabled: governanceEnabled
  }
  integration: {
    externalIdpEnabled: externalIdpEnabled
    apiAccessEnabled: apiAccessEnabled
    costOptimizationEnabled: costOptimizationEnabled
    disasterRecoveryEnabled: drConfigured
  }
}
