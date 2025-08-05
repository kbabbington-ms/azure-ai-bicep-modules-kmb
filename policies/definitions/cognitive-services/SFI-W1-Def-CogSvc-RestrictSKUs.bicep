targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-CogSvc-RestrictSKUs'
param displayName string = 'Azure Cognitive Services should use approved SKUs'
param policyDescription string = 'This policy restricts Azure Cognitive Services accounts to approved SKU tiers for cost control and standardization, meeting SFI-W1 resource governance requirements.'
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
        notIn: [
          'OpenAI'
          'FormRecognizer'
        ]
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
          {
            allOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/kind'
                in: '[parameters(\'restrictedKinds\')]'
              }
              {
                field: 'tags[\'SpecialApproval\']'
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
      description: 'The list of allowed SKU names for Cognitive Services accounts'
    }
    defaultValue: [
      'F0'
      'S0'
      'S1'
      'S2'
      'S3'
      'S4'
    ]
  }
  highTierSKUs: {
    type: 'Array'
    metadata: {
      displayName: 'High Tier SKUs'
      description: 'SKUs that require special approval'
    }
    defaultValue: [
      'S3'
      'S4'
    ]
  }
  restrictedKinds: {
    type: 'Array'
    metadata: {
      displayName: 'Restricted Service Kinds'
      description: 'Cognitive Services kinds that require special approval'
    }
    defaultValue: [
      'Face'
      'CustomVision.Training'
      'PersonalizerChatCompletion'
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
        'Service Restrictions'
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
