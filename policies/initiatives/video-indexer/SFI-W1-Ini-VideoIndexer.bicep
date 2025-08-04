targetScope = 'subscription'

// SFI-W1 Video Indexer Initiative
// Groups SFI-W1 compliance policies for Azure AI Video Indexer workloads
param initiativeName string = 'SFI-W1-Ini-VideoIndexer'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure AI Video Indexer'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure AI Video Indexer services including video analysis, content insights, and media intelligence workloads.'

// SFI-W1 Video Indexer Policy Initiative
resource videoIndexerInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure AI Video Indexer SFI'
    }
    policyDefinitions: [
      {
        policyDefinitionReferenceId: 'videoIndexerCompliance'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-VideoIndexer')
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
        policyDefinitionReferenceId: 'privateEndpointVideoIndexer'
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
        policyDefinitionReferenceId: 'mediaAuditLogging'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogRetentionAI')
      }
    ]
  }
}

output initiativeId string = videoIndexerInitiative.id
output initiativeName string = videoIndexerInitiative.name
