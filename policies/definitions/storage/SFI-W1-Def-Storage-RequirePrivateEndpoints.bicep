// Policy Definition: SFI-W1-Def-Storage-RequirePrivateEndpoints
@description('Require private endpoints for all storage accounts to prevent public network access for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-Storage-RequirePrivateEndpoints'
param policyDisplayName string = 'SFI-W1-Def-Storage: Require Private Endpoints'
param policyDescription string = 'Enforce private endpoints for storage accounts and disable public network access to maintain zero-trust architecture for SFI-W1 compliance.'

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
                field: 'Microsoft.Storage/storageAccounts/publicNetworkAccess'
                equals: 'Disabled'
              }
              {
                field: 'Microsoft.Storage/storageAccounts/networkAcls.defaultAction'
                equals: 'Deny'
              }
            ]
          }
        }
      }
    }
  }
}

output policyDefinitionId string = policyDefinition.id
