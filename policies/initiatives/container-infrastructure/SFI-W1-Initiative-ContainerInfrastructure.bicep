// SFI Initiative: Container Infrastructure Security Controls
@description('SFI-W1 Initiative for Container Infrastructure security compliance including private registries and secure image sources.')
param initiativeName string = 'SFI-W1-Initiative-ContainerInfrastructure'
param initiativeDisplayName string = 'SFI-W1: Container Infrastructure Security Controls'
param initiativeDescription string = 'Comprehensive security controls for container infrastructure including ACR and AKS to ensure private registries and supply chain security compliance with Microsoft Secure Future Initiative (SFI-W1).'

targetScope = 'subscription'

// Policy Definitions to include
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Container-RequirePrivateRegistries'
    parameters: {
      allowedRegistries: {
        value: '[parameters(\'allowedRegistries\')]'
      }
    }
  }
]

resource sfiContainerInfrastructureInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      category: 'Container Registry'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    parameters: {
      allowedRegistries: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Container Registries'
          description: 'List of allowed private container registries'
        }
        defaultValue: [
          '*.azurecr.io'
          'mcr.microsoft.com'
        ]
      }
    }
    policyDefinitions: policyDefinitions
  }
}

output initiativeId string = sfiContainerInfrastructureInitiative.id
output initiativeName string = sfiContainerInfrastructureInitiative.name
