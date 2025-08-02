// Policy Definition: SFI-W1-Def-Foundry-RequireEncryptionAtRest (SFI Compliance)
@description('Ensures storage accounts have encryption at rest enabled.')
param policyName string = 'SFI-W1-Def-Foundry-RequireEncryptionAtRest'
param policyDisplayName string = 'SFI-W1-Def-Foundry: Require Encryption at Rest'
param policyDescription string = 'Ensures storage accounts have encryption at rest enabled.'

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
        field: 'Microsoft.Storage/storageAccounts.encryption.enabled'
        equals: false
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
