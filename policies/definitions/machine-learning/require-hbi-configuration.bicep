// Policy: Require HBI Configuration for Machine Learning Workspaces
// Description: Ensures ML workspaces are configured for High Business Impact scenarios
// SFI-W1: Data classification and protection requirements
// AzTS: Data handling and sensitivity controls

targetScope = 'subscription'

resource requireMLHBI 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-ml-hbi-configuration'
  properties: {
    displayName: 'Azure Machine Learning workspaces should be configured for High Business Impact'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure Machine Learning workspaces handling sensitive data should be configured with High Business Impact (HBI) settings to ensure appropriate data protection and compliance with SFI-W1 requirements.'
    metadata: {
      version: '1.0.0'
      category: 'Machine Learning'
      sfiCompliance: 'Data Classification, Protection Controls'
      aztsCompliance: 'Data Sensitivity, Handling Controls'
      preview: false
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Effect'
          description: 'Enable or disable the execution of the policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      requireHBI: {
        type: 'Boolean'
        metadata: {
          displayName: 'Require HBI Configuration'
          description: 'Whether to require High Business Impact configuration for all ML workspaces'
        }
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.MachineLearningServices/workspaces'
          }
          {
            field: 'Microsoft.MachineLearningServices/workspaces/hbiWorkspace'
            equals: false
          }
          {
            value: '[parameters(\'requireHBI\')]'
            equals: true
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output policyDefinitionId string = requireMLHBI.id
