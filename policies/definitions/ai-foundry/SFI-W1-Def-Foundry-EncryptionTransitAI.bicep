// Policy Definition: SFI-W1-Def-Foundry-EncryptionTransitAI
@description('Enforce that all data sent to and from AI services is encrypted in transit.')
param policyName string = 'SFI-W1-Def-Foundry-EncryptionTransitAI'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Encryption of Data in Transit for AI Services'
param policyDescription string = 'Enforce that all data sent to and from AI services is encrypted in transit.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Security'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
    }
    parameters: {}
    policyRule: {
      if: {
        field: 'Microsoft.CognitiveServices/accounts/properties.encryptionInTransit'
        equals: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
