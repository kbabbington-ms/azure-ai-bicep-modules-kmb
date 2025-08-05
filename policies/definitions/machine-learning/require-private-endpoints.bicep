// Policy: Require Private Endpoints for Machine Learning Workspaces
// Description: Ensures ML workspaces use private endpoints for SFI-W1 compliance
// SFI-W1: Network isolation and zero-trust architecture
// AzTS: Network security controls for ML workloads

targetScope = 'subscription'

resource requireMLPrivateEndpoints 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-ml-private-endpoints'
  properties: {
    displayName: 'Azure Machine Learning workspaces should use private endpoints'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure Machine Learning workspaces should be configured with private endpoints to ensure secure communication and compliance with SFI-W1 zero-trust principles for ML workloads.'
    metadata: {
      version: '1.0.0'
      category: 'Machine Learning'
      sfiCompliance: 'Network Security, Zero-Trust Architecture'
      aztsCompliance: 'Network Controls, ML Security'
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
    }
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.MachineLearningServices/workspaces'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.MachineLearningServices/workspaces/publicNetworkAccess'
                notEquals: 'Disabled'
              }
              {
                count: {
                  field: 'Microsoft.MachineLearningServices/workspaces/privateEndpointConnections[*]'
                  where: {
                    field: 'Microsoft.MachineLearningServices/workspaces/privateEndpointConnections[*].privateLinkServiceConnectionState.status'
                    equals: 'Approved'
                  }
                }
                less: 1
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output policyDefinitionId string = requireMLPrivateEndpoints.id
