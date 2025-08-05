targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-CogSvc-RestrictDataResidency'
param displayName string = 'Azure Cognitive Services should comply with data residency requirements'
param policyDescription string = 'This policy ensures that Azure Cognitive Services accounts comply with data residency and sovereignty requirements by restricting deployments to approved regions and requiring appropriate data processing controls.'
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
            not: {
              field: 'location'
              in: '[parameters(\'allowedLocations\')]'
            }
          }
          {
            allOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/kind'
                in: '[parameters(\'dataProcessingKinds\')]'
              }
              {
                not: {
                  field: 'location'
                  in: '[parameters(\'dataProcessingLocations\')]'
                }
              }
            ]
          }
          {
            allOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/properties.restrictOutboundNetworkAccess'
                exists: true
              }
              {
                field: 'Microsoft.CognitiveServices/accounts/properties.restrictOutboundNetworkAccess'
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
  allowedLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Locations'
      description: 'The list of allowed locations for Cognitive Services accounts'
    }
    defaultValue: [
      'eastus'
      'eastus2'
      'westus2'
      'westeurope'
      'northeurope'
    ]
  }
  dataProcessingKinds: {
    type: 'Array'
    metadata: {
      displayName: 'Data Processing Service Kinds'
      description: 'Cognitive Services kinds that require strict data residency controls'
    }
    defaultValue: [
      'TextAnalytics'
      'Face'
      'SpeechServices'
      'LUIS'
      'QnAMaker'
      'Translator'
    ]
  }
  dataProcessingLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Data Processing Allowed Locations'
      description: 'Restricted locations for data processing services'
    }
    defaultValue: [
      'eastus'
      'westeurope'
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
  requireRestrictOutboundAccess: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Restrict Outbound Access'
      description: 'Whether to require restricting outbound network access'
    }
    defaultValue: true
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
        'Data Residency'
        'Data Sovereignty'
        'Geographic Restrictions'
        'Compliance Controls'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'GDPR'
        'Data Protection Act'
        'Regional Compliance'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
