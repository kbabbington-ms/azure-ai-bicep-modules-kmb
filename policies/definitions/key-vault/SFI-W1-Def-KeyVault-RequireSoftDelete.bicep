// Policy Definition: SFI-W1-Def-KeyVault-RequireSoftDelete
@description('Ensures Azure Key Vaults have soft delete enabled with minimum retention period.')
param policyName string = 'SFI-W1-Def-KeyVault-RequireSoftDelete'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require Soft Delete'
param policyDescription string = 'Ensures Azure Key Vaults have soft delete enabled with minimum 90-day retention period.'

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
    parameters: {
      minimumRetentionDays: {
        type: 'Integer'
        defaultValue: 90
        metadata: {
          displayName: 'Minimum Retention Days'
          description: 'Minimum number of days to retain deleted keys, secrets, and certificates'
        }
        allowedValues: [
          7
          14
          30
          60
          90
        ]
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.KeyVault/vaults'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.KeyVault/vaults/enableSoftDelete'
                notEquals: true
              }
              {
                field: 'Microsoft.KeyVault/vaults/softDeleteRetentionInDays'
                less: '[parameters(\'minimumRetentionDays\')]'
              }
            ]
          }
        ]
      }
      then: {
        effect: 'deny'
      }
    }
  }
}
