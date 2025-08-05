targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-ML-RestrictSKUs'
param displayName string = 'Azure Machine Learning compute should use approved SKUs'
param policyDescription string = 'This policy restricts Azure Machine Learning compute instances and clusters to approved SKU types for cost control and standardization, meeting SFI-W1 resource governance requirements.'
param category string = 'Machine Learning'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        anyOf: [
          {
            field: 'type'
            equals: 'Microsoft.MachineLearningServices/workspaces/computes'
          }
          {
            field: 'type'
            equals: 'Microsoft.MachineLearningServices/workspaces/computeInstances'
          }
        ]
      }
      {
        anyOf: [
          {
            field: 'Microsoft.MachineLearningServices/workspaces/computes/computeType'
            equals: 'ComputeInstance'
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/computes/computeType'
            equals: 'AmlCompute'
          }
        ]
      }
      {
        anyOf: [
          {
            field: 'Microsoft.MachineLearningServices/workspaces/computes/properties.vmSize'
            notIn: '[parameters(\'allowedVMSizes\')]'
          }
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/properties.scaleSettings.maxNodeCount'
                exists: true
              }
              {
                field: 'Microsoft.MachineLearningServices/workspaces/computes/properties.scaleSettings.maxNodeCount'
                greater: '[parameters(\'maxNodes\')]'
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
  allowedVMSizes: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed VM Sizes'
      description: 'The list of allowed VM sizes for Machine Learning compute'
    }
    defaultValue: [
      'Standard_DS2_v2'
      'Standard_DS3_v2'
      'Standard_DS4_v2'
      'Standard_DS11_v2'
      'Standard_DS12_v2'
      'Standard_DS13_v2'
      'Standard_DS14_v2'
      'Standard_NC6'
      'Standard_NC12'
      'Standard_NC24'
    ]
  }
  maxNodes: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Nodes'
      description: 'Maximum number of nodes allowed in compute clusters'
    }
    defaultValue: 10
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
        'Resource Governance'
        'Cost Control'
        'Performance Standards'
        'Capacity Management'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'Cost Management'
        'Resource Optimization'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
