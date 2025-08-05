targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-ML-RequireCustomerManagedKeys'
param displayName string = 'Azure Machine Learning workspaces should use customer-managed keys'
param policyDescription string = 'This policy ensures that Azure Machine Learning workspaces use customer-managed encryption keys for enhanced data protection and sovereignty, meeting SFI-W1 data protection requirements.'
param category string = 'Machine Learning'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces'
      }
      {
        anyOf: [
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.status'
            notEquals: 'Enabled'
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.keyVaultProperties.keyVaultUri'
            exists: false
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.keyVaultProperties.keyIdentifier'
            exists: false
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.identity.userAssignedIdentity'
            exists: false
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
  allowedKeyVaultLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Key Vault Locations'
      description: 'The list of allowed locations for Key Vaults containing encryption keys'
    }
    defaultValue: [
      'eastus'
      'eastus2'
      'westus2'
      'westeurope'
      'northeurope'
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
        'Key Management'
        'Data Sovereignty'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'FedRAMP'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
