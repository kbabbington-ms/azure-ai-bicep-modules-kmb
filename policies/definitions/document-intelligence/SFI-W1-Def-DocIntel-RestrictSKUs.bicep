targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-DocIntel-RestrictSKUs'
param displayName string = 'Azure Document Intelligence should use approved SKUs'
param policyDescription string = 'This policy restricts Azure Document Intelligence accounts to approved SKU tiers for cost control and standardization, meeting SFI-W1 resource governance requirements.'
param category string = 'Cognitive Services'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.CognitiveServices/accounts'
      }
      {
        field: 'Microsoft.CognitiveServices/accounts/kind'
        equals: 'FormRecognizer'
      }
      {
        anyOf: [
          {
            field: 'Microsoft.CognitiveServices/accounts/sku.name'
            notIn: '[parameters(\'allowedSKUs\')]'
          }
          {
            allOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/sku.name'
                in: '[parameters(\'highTierSKUs\')]'
              }
              {
                field: 'tags[\'ApprovalRequired\']'
                notEquals: 'true'
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
      description: 'The list of allowed SKU names for Document Intelligence accounts'
    }
    defaultValue: [
      'F0'
      'S0'
    ]
  }
  highTierSKUs: {
    type: 'Array'
    metadata: {
      displayName: 'High Tier SKUs'
      description: 'SKUs that require special approval'
    }
    defaultValue: [
      'S0'
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
        'Resource Governance'
        'Cost Control'
        'Performance Standards'
        'Approval Workflows'
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
