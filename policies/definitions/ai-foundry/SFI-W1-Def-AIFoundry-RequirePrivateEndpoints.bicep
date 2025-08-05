targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-AIFoundry-RequirePrivateEndpoints'
param displayName string = 'Azure AI Foundry hubs should use private endpoints'
param policyDescription string = 'This policy ensures that Azure AI Foundry hubs are configured with private endpoints for secure network access, meeting SFI-W1 network isolation requirements and reducing data leakage risks.'
param category string = 'AI Foundry'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces'
      }
      {
        field: 'Microsoft.MachineLearningServices/workspaces/workspaceHubConfig'
        exists: true
      }
      {
        count: {
          field: 'Microsoft.MachineLearningServices/workspaces/privateEndpointConnections[*]'
          where: {
            field: 'Microsoft.MachineLearningServices/workspaces/privateEndpointConnections[*].properties.privateLinkServiceConnectionState.status'
            equals: 'Approved'
          }
        }
        less: '[parameters(\'minPrivateEndpoints\')]'
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
  minPrivateEndpoints: {
    type: 'Integer'
    metadata: {
      displayName: 'Minimum Private Endpoints'
      description: 'Minimum number of approved private endpoint connections required'
    }
    defaultValue: 1
  }
  allowedLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Locations'
      description: 'List of allowed Azure regions for AI Foundry hubs'
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
        'Data Protection'
        'Private Connectivity'
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
