// Policy Definition: SFI-W1-Def-KeyVault-RequireRBAC
@description('Ensures Azure Key Vaults use Azure RBAC for authorization instead of vault access policies.')
param policyName string = 'SFI-W1-Def-KeyVault-RequireRBAC'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require RBAC Authorization'
param policyDescription string = 'Ensures Azure Key Vaults use Azure RBAC for authorization to provide centralized and granular access control.'

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
            field: 'Microsoft.KeyVault/vaults/enableRbacAuthorization'
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
