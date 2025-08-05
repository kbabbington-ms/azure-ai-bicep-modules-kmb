targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-DocIntel-RequireManagedIdentity'
param displayName string = 'Azure Document Intelligence should use managed identity'
param policyDescription string = 'This policy ensures that Azure Document Intelligence accounts use managed identity for secure authentication and access to Azure resources, meeting SFI-W1 identity and access management requirements.'
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
            field: 'identity.type'
            exists: false
          }
          {
            field: 'identity.type'
            equals: 'None'
          }
          {
            allOf: [
              {
                field: 'identity.type'
                notIn: [
                  'SystemAssigned'
                  'UserAssigned'
                  'SystemAssigned,UserAssigned'
                ]
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
  requiredIdentityType: {
    type: 'String'
    metadata: {
      displayName: 'Required Identity Type'
      description: 'The type of managed identity required for the account'
    }
    allowedValues: [
      'SystemAssigned'
      'UserAssigned'
      'SystemAssigned,UserAssigned'
    ]
    defaultValue: 'SystemAssigned'
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
        'Identity Management'
        'Authentication'
        'Zero-Trust Identity'
        'Secure Access'
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
