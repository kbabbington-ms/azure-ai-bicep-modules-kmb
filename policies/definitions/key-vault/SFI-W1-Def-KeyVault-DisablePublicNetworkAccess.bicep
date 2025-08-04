// Policy Definition: SFI-W1-Def-KeyVault-DisablePublicNetworkAccess
@description('Ensures Azure Key Vaults disable public network access.')
param policyName string = 'SFI-W1-Def-KeyVault-DisablePublicNetworkAccess'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Disable Public Network Access'
param policyDescription string = 'Ensures Azure Key Vaults have public network access disabled and only allow access via private endpoints.'

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
            field: 'Microsoft.KeyVault/vaults/publicNetworkAccess'
            notEquals: 'Disabled'
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
