// Policy Definition: SFI-W1-Def-KeyVault-RequirePurgeProtection
@description('Ensures Azure Key Vaults have purge protection enabled to prevent permanent deletion.')
param policyName string = 'SFI-W1-Def-KeyVault-RequirePurgeProtection'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require Purge Protection'
param policyDescription string = 'Ensures Azure Key Vaults have purge protection enabled to prevent permanent deletion of vaults and keys.'

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
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.KeyVault/vaults'
          }
          {
            field: 'Microsoft.KeyVault/vaults/enablePurgeProtection'
            notEquals: true
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
