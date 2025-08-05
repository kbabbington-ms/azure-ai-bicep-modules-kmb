// Policy: Require Private Endpoints for Cognitive Search
// Description: Ensures Cognitive Search services use private endpoints
// SFI-W1: Network isolation and zero-trust architecture
// AzTS: Search service security controls

targetScope = 'subscription'

resource requireSearchPrivateEndpoints 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-search-private-endpoints'
  properties: {
    displayName: 'Azure Cognitive Search services should use private endpoints'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure Cognitive Search services should be configured with private endpoints to ensure secure communication and compliance with SFI-W1 zero-trust principles for search workloads.'
    metadata: {
      version: '1.0.0'
      category: 'Search'
      sfiCompliance: 'Network Security, Zero-Trust Architecture'
      aztsCompliance: 'Network Controls, Search Security'
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
            equals: 'Microsoft.Search/searchServices'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.Search/searchServices/publicNetworkAccess'
                notEquals: 'disabled'
              }
              {
                count: {
                  field: 'Microsoft.Search/searchServices/privateEndpointConnections[*]'
                  where: {
                    field: 'Microsoft.Search/searchServices/privateEndpointConnections[*].privateLinkServiceConnectionState.status'
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

output policyDefinitionId string = requireSearchPrivateEndpoints.id
