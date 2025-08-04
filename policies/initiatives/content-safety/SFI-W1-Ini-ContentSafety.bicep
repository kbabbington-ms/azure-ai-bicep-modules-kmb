targetScope = 'subscription'

// SFI-W1 Content Safety Initiative
// Groups SFI-W1 compliance policies for Azure AI Content Safety workloads
param initiativeName string = 'SFI-W1-Ini-ContentSafety'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure AI Content Safety'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure AI Content Safety services including content moderation, brand safety, and compliance automation.'

// SFI-W1 Content Safety Policy Initiative
resource contentSafetyInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure AI Content Safety SFI'
    }
    policyDefinitions: [
      {
        policyDefinitionReferenceId: 'contentSafetyCompliance'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-ContentSafety')
      }
      {
        policyDefinitionReferenceId: 'requireDiagnosticLogging'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireDiagnosticLogging')
      }
      {
        policyDefinitionReferenceId: 'restrictPublicNetworkAccess'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RestrictPublicNetworkAccess')
      }
      {
        policyDefinitionReferenceId: 'requireEncryptionAtRest'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireEncryptionAtRest')
      }
      {
        policyDefinitionReferenceId: 'enforceManagedIdentityUsage'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-EnforceManagedIdentityUsage')
      }
      {
        policyDefinitionReferenceId: 'requireCreatedByTag'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-RequireCreatedByTag')
      }
      {
        policyDefinitionReferenceId: 'privateEndpointContentSafety'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-PrivateEndpointAI')
      }
      {
        policyDefinitionReferenceId: 'keyVaultIntegration'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-KeyVaultAISecrets')
      }
      {
        policyDefinitionReferenceId: 'dataResidencyCompliance'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-DataResidency')
      }
      {
        policyDefinitionReferenceId: 'encryptionInTransit'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-EncryptionTransitAI')
      }
      {
        policyDefinitionReferenceId: 'auditLogRetention'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogRetentionAI')
      }
    ]
  }
}

output initiativeId string = contentSafetyInitiative.id
output initiativeName string = contentSafetyInitiative.name
