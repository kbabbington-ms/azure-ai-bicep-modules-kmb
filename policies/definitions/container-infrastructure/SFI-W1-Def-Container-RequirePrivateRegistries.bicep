// Policy Definition: SFI-W1-Def-Container-RequirePrivateRegistries
@description('Require private container registries and secure image sources for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-Container-RequirePrivateRegistries'
param policyDisplayName string = 'SFI-W1-Def-Container: Require Private Registries'
param policyDescription string = 'Enforce private container registries and restrict public image sources for all container workloads to maintain supply chain security for SFI-W1 compliance.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
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
    policyRule: {
      if: {
        anyOf: [
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.ContainerRegistry/registries'
              }
              {
                field: 'Microsoft.ContainerRegistry/registries/publicNetworkAccess'
                notEquals: 'Disabled'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'type'
                equals: 'Microsoft.ContainerService/managedClusters'
              }
              {
                field: 'Microsoft.ContainerService/managedClusters/agentPoolProfiles[*].enableNodePublicIP'
                equals: true
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

output policyDefinitionId string = policyDefinition.id
