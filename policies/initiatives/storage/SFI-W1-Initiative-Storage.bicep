// SFI Initiative: Storage Security Controls
@description('SFI-W1 Initiative for Storage security compliance including encryption, private endpoints, and access controls.')
param initiativeName string = 'SFI-W1-Initiative-Storage'
param initiativeDisplayName string = 'SFI-W1: Storage Security Controls'
param initiativeDescription string = 'Comprehensive security controls for storage accounts to ensure encryption at rest/transit and zero-trust network access compliance with Microsoft Secure Future Initiative (SFI-W1).'

targetScope = 'subscription'

// Policy Definitions to include
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Storage-RequireEncryption'
    parameters: {}
  }
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Storage-RequirePrivateEndpoints'
    parameters: {}
  }
]

resource sfiStorageInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Storage'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyDefinitions: policyDefinitions
  }
}

output initiativeId string = sfiStorageInitiative.id
output initiativeName string = sfiStorageInitiative.name
