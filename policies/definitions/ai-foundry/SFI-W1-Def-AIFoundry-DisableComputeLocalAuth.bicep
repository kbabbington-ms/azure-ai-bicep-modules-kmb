targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-AIFoundry-DisableComputeLocalAuth'
param displayName string = 'Azure AI Foundry compute instances should disable local authentication'
param policyDescription string = 'This policy ensures that compute instances and clusters in Azure AI Foundry hubs have local authentication (SSH) disabled, meeting SFI-W1 authentication requirements by requiring Azure AD authentication exclusively.'
param category string = 'AI Foundry'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces/computes'
      }
      {
        anyOf: [
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/computeType'
                equals: 'ComputeInstance'
              }
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/disableLocalAuth'
                notEquals: true
              }
            ]
          }
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/computeType'
                equals: 'AmlCompute'
              }
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/disableLocalAuth'
                notEquals: true
              }
            ]
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
        'Authentication'
        'Access Control'
        'Zero-Trust Identity'
        'Compute Security'
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
