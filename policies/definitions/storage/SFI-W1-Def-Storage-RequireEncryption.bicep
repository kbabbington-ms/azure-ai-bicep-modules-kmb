// Policy Definition: SFI-W1-Def-Storage-RequireEncryption
@description('Require encryption at rest and in transit for all storage accounts for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-Storage-RequireEncryption'
param policyDisplayName string = 'SFI-W1-Def-Storage: Require Double Encryption'
param policyDescription string = 'Enforce encryption at rest with customer-managed keys and encryption in transit for all storage accounts to meet SFI-W1 compliance requirements.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Storage'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.Storage/storageAccounts'
      }
      then: {
        effect: 'deny'
        details: {
          type: 'Microsoft.Storage/storageAccounts'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Storage/storageAccounts/encryption.services.blob.enabled'
                equals: true
              }
              {
                field: 'Microsoft.Storage/storageAccounts/encryption.services.file.enabled'
                equals: true
              }
              {
                field: 'Microsoft.Storage/storageAccounts/encryption.requireInfrastructureEncryption'
                equals: true
              }
              {
                field: 'Microsoft.Storage/storageAccounts/supportsHttpsTrafficOnly'
                equals: true
              }
              {
                field: 'Microsoft.Storage/storageAccounts/allowBlobPublicAccess'
                equals: false
              }
              {
                field: 'Microsoft.Storage/storageAccounts/allowSharedKeyAccess'
                equals: false
              }
              {
                field: 'Microsoft.Storage/storageAccounts/minimumTlsVersion'
                equals: 'TLS1_2'
              }
            ]
          }
        }
      }
    }
  }
}

output policyDefinitionId string = policyDefinition.id
