// Policy: Require Private Endpoints for Document Intelligence
// Description: Ensures Document Intelligence accounts use private endpoints
// SFI-W1: Network isolation for document processing workloads
// AzTS: Document processing security controls

targetScope = 'subscription'

resource requireDocumentIntelligencePrivateEndpoints 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-document-intelligence-private-endpoints'
  properties: {
    displayName: 'Azure Document Intelligence accounts should use private endpoints'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure Document Intelligence accounts should be configured with private endpoints to ensure secure document processing and compliance with SFI-W1 zero-trust principles.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Network Security, Zero-Trust Architecture'
      aztsCompliance: 'Network Controls, Document Security'
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
            equals: 'FormRecognizer'
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

output policyDefinitionId string = requireDocumentIntelligencePrivateEndpoints.id
