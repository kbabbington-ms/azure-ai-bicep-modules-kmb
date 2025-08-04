// Policy Definition: SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint (SFI Compliance)
@description('Ensures Azure Key Vaults are only accessible via private endpoints.')
param policyName string = 'SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Require Private Endpoint for Key Vaults'
param policyDescription string = 'Ensures Azure Key Vaults are only accessible via private endpoints.'

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
        field: 'Microsoft.KeyVault/vaults/privateEndpointConnections[*]'
        exists: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
