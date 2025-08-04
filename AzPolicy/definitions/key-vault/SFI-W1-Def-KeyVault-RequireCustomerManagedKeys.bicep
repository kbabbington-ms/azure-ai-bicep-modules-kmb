// Policy Definition: SFI-W1-Def-KeyVault-RequireCustomerManagedKeys
@description('Ensures Azure Key Vaults use customer-managed keys for encryption.')
param policyName string = 'SFI-W1-Def-KeyVault-RequireCustomerManagedKeys'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require Customer-Managed Keys'
param policyDescription string = 'Ensures Azure Key Vaults are configured with customer-managed keys for additional encryption control.'

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
      allowedKeyTypes: {
        type: 'Array'
        defaultValue: [
          'RSA'
          'RSA-HSM'
        ]
        metadata: {
          displayName: 'Allowed Key Types'
          description: 'List of allowed key types for customer-managed keys'
        }
      }
      minimumKeySize: {
        type: 'Integer'
        defaultValue: 2048
        metadata: {
          displayName: 'Minimum Key Size'
          description: 'Minimum key size in bits'
        }
        allowedValues: [
          2048
          3072
          4096
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
            field: 'Microsoft.KeyVault/vaults/sku.name'
            in: [
              'premium'
            ]
          }
        ]
      }
      then: {
        effect: 'auditIfNotExists'
        details: {
          type: 'Microsoft.KeyVault/vaults/keys'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.KeyVault/vaults/keys/kty'
                in: '[parameters(\'allowedKeyTypes\')]'
              }
              {
                field: 'Microsoft.KeyVault/vaults/keys/keySize'
                greaterOrEquals: '[parameters(\'minimumKeySize\')]'
              }
            ]
          }
        }
      }
    }
  }
}
