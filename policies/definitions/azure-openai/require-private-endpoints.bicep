// Policy: Require Private Endpoints for Azure OpenAI
// Description: Ensures Azure OpenAI accounts use private endpoints for SFI-W1 compliance
// SFI-W1: Network isolation and zero-trust architecture
// AzTS: Network security controls

targetScope = 'subscription'

resource requireOpenAIPrivateEndpoints 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-openai-private-endpoints'
  properties: {
    displayName: 'Azure OpenAI accounts should use private endpoints'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure OpenAI accounts should be configured with private endpoints to ensure secure communication and compliance with SFI-W1 zero-trust principles. This policy ensures network isolation and prevents exposure to public internet.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Network Security, Zero-Trust Architecture'
      aztsCompliance: 'Network Controls, Private Connectivity'
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
            equals: 'Microsoft.CognitiveServices/accounts'
          }
          {
            field: 'Microsoft.CognitiveServices/accounts/kind'
            equals: 'OpenAI'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/publicNetworkAccess'
                notEquals: 'Disabled'
              }
              {
                count: {
                  field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*]'
                  where: {
                    field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*].privateLinkServiceConnectionState.status'
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

// Output the policy definition ID for use in initiatives
output policyDefinitionId string = requireOpenAIPrivateEndpoints.id
