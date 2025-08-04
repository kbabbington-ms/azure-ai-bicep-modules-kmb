// Policy Definition: SFI-W1-Def-VNet-RequirePrivateSubnets
@description('Require all subnets to be private (no public IP assignments) for SFI-W1 compliance.')
param policyName string = 'SFI-W1-Def-VNet-RequirePrivateSubnets'
param policyDisplayName string = 'SFI-W1-Def-VNet: Require Private Subnets Only'
param policyDescription string = 'Enforce that all subnets in virtual networks disable public IP assignments to maintain zero-trust architecture for SFI-W1 compliance.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Network'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
      sfiCompliance: 'W1'
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.Network/virtualNetworks'
          }
          {
            count: {
              field: 'Microsoft.Network/virtualNetworks/subnets[*]'
              where: {
                anyOf: [
                  {
                    field: 'Microsoft.Network/virtualNetworks/subnets[*].privateEndpointNetworkPolicies'
                    exists: false
                  }
                  {
                    field: 'Microsoft.Network/virtualNetworks/subnets[*].privateEndpointNetworkPolicies'
                    notEquals: 'Disabled'
                  }
                ]
              }
            }
            greater: 0
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
