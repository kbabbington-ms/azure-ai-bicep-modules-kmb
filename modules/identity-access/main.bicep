@description('Advanced Identity and Access Management for AI Enclave')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param adminGroupObjectId string = ''
param developerGroupObjectId string = ''
param auditorsGroupObjectId string = ''

// Resource naming
var userAssignedIdentityName = 'id-${projectName}-${environment}-${location}'

// User Assigned Managed Identity
resource userAssignedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: userAssignedIdentityName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Shared Managed Identity for AI Enclave'
  }
}

// Custom Role Definitions
resource aiEnclaveOperatorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' = {
  name: guid('ai-enclave-operator', subscription().subscriptionId)
  properties: {
    roleName: 'AI Enclave Operator'
    description: 'Can manage AI Enclave resources and perform AI operations'
    type: 'CustomRole'
    permissions: [
      {
        actions: [
          'Microsoft.CognitiveServices/accounts/read'
          'Microsoft.CognitiveServices/accounts/write'
          'Microsoft.CognitiveServices/accounts/deployments/*'
          'Microsoft.MachineLearningServices/workspaces/read'
          'Microsoft.MachineLearningServices/workspaces/write'
          'Microsoft.MachineLearningServices/workspaces/experiments/*'
          'Microsoft.MachineLearningServices/workspaces/models/*'
          'Microsoft.Storage/storageAccounts/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/write'
          'Microsoft.KeyVault/vaults/read'
          'Microsoft.KeyVault/vaults/secrets/read'
          'Microsoft.Insights/components/read'
          'Microsoft.Insights/logs/read'
          'Microsoft.Web/sites/read'
          'Microsoft.Web/sites/config/*'
          'Microsoft.ContainerRegistry/registries/read'
          'Microsoft.ContainerRegistry/registries/pull/read'
          'Microsoft.ContainerRegistry/registries/push/write'
        ]
        notActions: []
        dataActions: [
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read'
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/write'
          'Microsoft.Storage/storageAccounts/blobServices/containers/blobs/delete'
          'Microsoft.KeyVault/vaults/secrets/getSecret/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/chat/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/completions/action'
          'Microsoft.CognitiveServices/accounts/OpenAI/deployments/embeddings/action'
        ]
        notDataActions: []
      }
    ]
    assignableScopes: [
      subscription().id
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
  name: guid(developerGroupObjectId, aiEnclaveOperatorRole.name, resourceGroup().id)
  properties: {
    roleDefinitionId: aiEnclaveOperatorRole.id
    principalId: developerGroupObjectId
    principalType: 'Group'
    description: 'AI Enclave Operator Group'
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
output aiEnclaveOperatorRoleId string = aiEnclaveOperatorRole.id
output aiEnclaveSecurityRoleId string = aiEnclaveSecurityRole.id
output aiEnclaveAuditorRoleId string = aiEnclaveAuditorRole.id
output customRoleDefinitions array = [
  {
    name: aiEnclaveOperatorRole.properties.roleName
    id: aiEnclaveOperatorRole.id
    description: aiEnclaveOperatorRole.properties.description
  }
  {
    name: aiEnclaveSecurityRole.properties.roleName
    id: aiEnclaveSecurityRole.id
    description: aiEnclaveSecurityRole.properties.description
  }
  {
    name: aiEnclaveAuditorRole.properties.roleName
    id: aiEnclaveAuditorRole.id
    description: aiEnclaveAuditorRole.properties.description
  }
]
