// Policy Definition: SFI-W1-Def-Foundry-ManagedIdentityAI
@description('Require managed identities for all AI services.')
param policyName string = 'SFI-W1-Def-Foundry-ManagedIdentityAI'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Managed Identity Enforcement for AI Services'
param policyDescription string = 'Require managed identities for all AI services.'

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
        field: 'identity.type'
        notEquals: 'UserAssigned'
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
