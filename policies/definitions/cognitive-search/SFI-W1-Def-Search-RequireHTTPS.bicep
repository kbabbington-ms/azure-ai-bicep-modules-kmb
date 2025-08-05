targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-Search-RequireHTTPS'
param displayName string = 'Azure Cognitive Search should require secure connections'
param policyDescription string = 'This policy ensures that Azure Cognitive Search services require HTTPS connections and disable insecure protocols, meeting SFI-W1 secure communication requirements.'
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
            field: 'Microsoft.Search/searchServices/disableLocalAuth'
            notEquals: true
          }
          {
            field: 'Microsoft.Search/searchServices/authOptions.apiKeyOnly'
            equals: true
          }
          {
            field: 'Microsoft.Search/searchServices/hostingMode'
            equals: 'default'
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
  allowedAuthenticationMethods: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Authentication Methods'
      description: 'The list of allowed authentication methods'
    }
    defaultValue: [
      'aadOrApiKey'
      'aad'
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
        'API Security'
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
