targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-CogSvc-RequireHTTPS'
param displayName string = 'Azure Cognitive Services should require secure connections'
param policyDescription string = 'This policy ensures that Azure Cognitive Services accounts require HTTPS connections and disable insecure protocols, meeting SFI-W1 secure communication requirements.'
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
            field: 'Microsoft.CognitiveServices/accounts/disableLocalAuth'
            notEquals: true
          }
          {
            field: 'Microsoft.CognitiveServices/accounts/properties.customSubDomainName'
            exists: false
          }
          {
            allOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/networkAcls.defaultAction'
                exists: true
              }
              {
                field: 'Microsoft.CognitiveServices/accounts/networkAcls.defaultAction'
                equals: 'Allow'
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
  requireDisableLocalAuth: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Disable Local Auth'
      description: 'Whether to require disabling local authentication (API keys)'
    }
    defaultValue: true
  }
  requireCustomSubdomain: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Custom Subdomain'
      description: 'Whether to require custom subdomain for enhanced security'
    }
    defaultValue: true
  }
  allowedNetworkDefaultActions: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Network Default Actions'
      description: 'The list of allowed network access default actions'
    }
    defaultValue: [
      'Deny'
    ]
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
        'Secure Communication'
        'Authentication Security'
        'Protocol Security'
        'Network Access Control'
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
