targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-ML-RequireDatastoreEncryption'
param displayName string = 'Azure Machine Learning datastores should require encryption'
param policyDescription string = 'This policy ensures that Azure Machine Learning datastores require encryption for data protection, meeting SFI-W1 data security requirements.'
param category string = 'Machine Learning'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces/datastores'
      }
      {
        anyOf: [
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/datastores/datastoreType'
                equals: 'AzureBlob'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.MachineLearningServices/workspaces/datastores/accountKey'
                    exists: true
                  }
                  {
                    field: 'Microsoft.MachineLearningServices/workspaces/datastores/containerName'
                    exists: true
                  }
                ]
              }
            ]
          }
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/datastores/datastoreType'
                equals: 'AzureFile'
              }
              {
                field: 'Microsoft.MachineLearningServices/workspaces/datastores/accountKey'
                exists: true
              }
            ]
          }
          {
            allOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/datastores/datastoreType'
                equals: 'AzureDataLakeGen2'
              }
              {
                anyOf: [
                  {
                    field: 'Microsoft.MachineLearningServices/workspaces/datastores/accountKey'
                    exists: true
                  }
                  {
                    field: 'Microsoft.MachineLearningServices/workspaces/datastores/servicePrincipalId'
                    exists: false
                  }
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
  allowedDatastoreTypes: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Datastore Types'
      description: 'The list of allowed datastore types'
    }
    defaultValue: [
      'AzureBlob'
      'AzureFile'
      'AzureDataLakeGen2'
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
        'Data Protection'
        'Encryption at Rest'
        'Secure Storage'
        'Data Governance'
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
