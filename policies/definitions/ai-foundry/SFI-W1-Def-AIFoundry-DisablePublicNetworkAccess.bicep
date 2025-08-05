targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-AIFoundry-DisablePublicNetworkAccess'
param displayName string = 'Azure AI Foundry hubs should disable public network access'
param policyDescription string = 'This policy ensures that Azure AI Foundry hubs disable public network access, meeting SFI-W1 network security requirements. Hubs should be accessible only through private endpoints to prevent data leakage risks.'
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
        field: 'Microsoft.MachineLearningServices/workspaces/publicNetworkAccess'
        notEquals: 'Disabled'
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
        'Access Control'
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
