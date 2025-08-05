targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-Search-RequirePrivateEndpoints'
param displayName string = 'Azure Cognitive Search should use private endpoints'
param policyDescription string = 'This policy ensures that Azure Cognitive Search services use private endpoints for secure communication and network isolation, meeting SFI-W1 zero-trust architecture requirements.'
param category string = 'Search'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.Search/searchServices'
      }
      {
        anyOf: [
          {
            field: 'Microsoft.Search/searchServices/publicNetworkAccess'
            notEquals: 'disabled'
          }
          {
            count: {
              field: 'Microsoft.Search/searchServices/privateEndpointConnections[*]'
              where: {
                field: 'Microsoft.Search/searchServices/privateEndpointConnections[*].privateLinkServiceConnectionState.status'
                equals: 'Approved'
              }
            }
            less: '[parameters(\'minPrivateEndpoints\')]'
          }
          {
            not: {
              field: 'location'
              in: '[parameters(\'allowedLocations\')]'
            }
          }
        ]
      }
      {
        not: {
          field: 'resourceGroup'
          in: '[parameters(\'excludedResourceGroups\')]'
        }
      }
    ]
  }
  then: {
    effect: '[parameters(\'effect\')]'
  }
}

var policyParameters = {
  effect: {
    type: 'String'
    metadata: {
      displayName: 'Effect'
      description: 'The effect determines what happens when the policy rule is evaluated to match'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  allowedLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Locations'
      description: 'The list of allowed locations for Azure Cognitive Search services'
    }
    defaultValue: [
      'eastus'
      'eastus2'
      'westus2'
      'westeurope'
      'northeurope'
    ]
  }
  excludedResourceGroups: {
    type: 'Array'
    metadata: {
      displayName: 'Excluded Resource Groups'
      description: 'Resource groups to exclude from this policy'
    }
    defaultValue: []
  }
  minPrivateEndpoints: {
    type: 'Integer'
    metadata: {
      displayName: 'Minimum Private Endpoints'
      description: 'Minimum number of approved private endpoint connections required'
    }
    allowedValues: [
      1
      2
      3
      4
      5
    ]
    defaultValue: 1
  }
}

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyDefinitionName
  properties: {
    displayName: displayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: version
      category: category
      'SFI-W1-Controls': [
        'Network Security'
        'Zero-Trust Architecture'
        'Data Residency'
        'Secure Communication'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
