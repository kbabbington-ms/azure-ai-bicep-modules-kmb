targetScope = 'subscription'

// SFI-W1 Cognitive Services Initiative
// Groups SFI-W1 compliance policies for Azure Cognitive Services workloads
param initiativeName string = 'SFI-W1-Ini-CognitiveServices'
param initiativeDisplayName string = 'SFI-W1 Initiative for Azure Cognitive Services'
param initiativeDescription string = 'Groups SFI-W1 compliance policies for Azure Cognitive Services workloads including OpenAI, Language, Vision, and other cognitive AI services.'

// SFI-W1 Cognitive Services Policy Initiative
resource cognitiveServicesInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure Cognitive Services SFI'
    }
    policyDefinitions: [
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
        policyDefinitionReferenceId: 'allowedCognitiveServicesSku'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-AllowedAISku')
      }
      {
        policyDefinitionReferenceId: 'privateEndpointCognitiveServices'
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
        policyDefinitionReferenceId: 'logRetentionPolicy'
        policyDefinitionId: subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'SFI-W1-Def-Foundry-LogRetentionAI')
      }
    ]
  }
}

output initiativeId string = cognitiveServicesInitiative.id
output initiativeName string = cognitiveServicesInitiative.name
