// SFI Initiative: Data Services Security Controls
@description('SFI-W1 Initiative for Data Services security compliance including SSL/TLS encryption and access controls.')
param initiativeName string = 'SFI-W1-Initiative-DataServices'
param initiativeDisplayName string = 'SFI-W1: Data Services Security Controls'
param initiativeDescription string = 'Comprehensive security controls for database services including SQL, MySQL, PostgreSQL, and Cosmos DB to ensure encrypted connections and secure access compliance with Microsoft Secure Future Initiative (SFI-W1).'

targetScope = 'subscription'

// Policy Definitions to include
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-DataServices-RequireSSLOnly'
    parameters: {}
  }
]

resource sfiDataServicesInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'SQL'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyDefinitions: policyDefinitions
  }
}

output initiativeId string = sfiDataServicesInitiative.id
output initiativeName string = sfiDataServicesInitiative.name
