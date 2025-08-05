targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-AIFoundry-RequireCustomerManagedKeys'
param displayName string = 'Azure AI Foundry hubs should be encrypted with customer-managed keys'
param policyDescription string = 'This policy ensures that Azure AI Foundry hubs use customer-managed keys for encryption at rest, meeting SFI-W1 data protection requirements and providing customer control over encryption keys.'
param category string = 'AI Foundry'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces'
      }
      {
        field: 'Microsoft.MachineLearningServices/workspaces/workspaceHubConfig'
        exists: true
      }
      {
        anyOf: [
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.status'
            notEquals: 'Enabled'
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.keyVaultProperties.keyVaultArmId'
            exists: false
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/encryption.keyVaultProperties.keyIdentifier'
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
      description: 'List of allowed Azure regions for Key Vault containing encryption keys'
    }
    defaultValue: [
      'eastus'
      'eastus2'
      'westus2'
      'westeurope'
      'northeurope'
    ]
  }
  requireKeyRotation: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Automatic Key Rotation'
      description: 'Whether to require automatic key rotation to be enabled'
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
        'Data Protection'
        'Encryption at Rest'
        'Key Management'
        'Customer Data Control'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'FedRAMP'
        'GDPR'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
