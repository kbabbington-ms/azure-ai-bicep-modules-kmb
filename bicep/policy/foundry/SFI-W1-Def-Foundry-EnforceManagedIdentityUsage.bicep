// Policy Definition: SFI-W1-Def-Foundry-EnforceManagedIdentityUsage (SFI Compliance)
@description('Ensures resources use managed identities for authentication.')
param policyName string = 'SFI-W1-Def-Foundry-EnforceManagedIdentityUsage'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Enforce Managed Identity Usage'
param policyDescription string = 'Ensures resources use managed identities for authentication.'

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
