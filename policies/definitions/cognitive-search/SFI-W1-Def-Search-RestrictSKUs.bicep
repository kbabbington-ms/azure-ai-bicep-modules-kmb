targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-Search-RestrictSKUs'
param displayName string = 'Azure Cognitive Search should use approved SKUs'
param policyDescription string = 'This policy restricts Azure Cognitive Search services to approved SKU tiers for cost control and standardization, meeting SFI-W1 resource governance requirements.'
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
            field: 'Microsoft.Search/searchServices/sku.name'
            notIn: '[parameters(\'allowedSKUs\')]'
          }
          {
            allOf: [
              {
                field: 'Microsoft.Search/searchServices/replicaCount'
                exists: true
              }
              {
                field: 'Microsoft.Search/searchServices/replicaCount'
                greater: '[parameters(\'maxReplicas\')]'
              }
            ]
          }
          {
            allOf: [
              {
                field: 'Microsoft.Search/searchServices/partitionCount'
                exists: true
              }
              {
                field: 'Microsoft.Search/searchServices/partitionCount'
                greater: '[parameters(\'maxPartitions\')]'
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
  allowedSKUs: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed SKUs'
      description: 'The list of allowed SKU names for Cognitive Search services'
    }
    defaultValue: [
      'free'
      'basic'
      'standard'
      'standard2'
      'standard3'
    ]
  }
  maxReplicas: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Replicas'
      description: 'Maximum number of replicas allowed for search services'
    }
    defaultValue: 12
  }
  maxPartitions: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Partitions'
      description: 'Maximum number of partitions allowed for search services'
    }
    defaultValue: 12
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
