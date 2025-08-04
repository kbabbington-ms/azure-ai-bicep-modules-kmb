// Policy Definition: SFI-W1-Def-Foundry-PrivateEndpointAI
@description('Require private endpoints for all Azure AI services.')
param policyName string = 'SFI-W1-Def-Foundry-PrivateEndpointAI'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Private Endpoint Enforcement for AI Services'
param policyDescription string = 'Require private endpoints for all Azure AI services.'

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
        field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*]'
        exists: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
