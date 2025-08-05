// Policy: Require Managed Identity for AI Services
// Description: Ensures AI services use managed identities instead of access keys
// SFI-W1: Identity-based authentication requirements
// AzTS: Zero-trust authentication controls

targetScope = 'subscription'

resource requireManagedIdentityForAI 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-managed-identity-ai-services'
  properties: {
    displayName: 'AI services should use managed identities for authentication'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'AI services should be configured with managed identities to eliminate the need for stored credentials and ensure secure, identity-based authentication in compliance with SFI-W1 zero-trust principles.'
    metadata: {
      version: '1.0.0'
      category: 'Identity'
      sfiCompliance: 'Identity-Based Authentication, Zero-Trust'
      aztsCompliance: 'Authentication Controls, Credential Management'
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
      requiredIdentityType: {
        type: 'String'
        metadata: {
          displayName: 'Required Identity Type'
          description: 'Type of managed identity required'
        }
        allowedValues: [
          'SystemAssigned'
          'UserAssigned'
          'SystemAssigned,UserAssigned'
        ]
        defaultValue: 'SystemAssigned'
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            anyOf: [
              {
                field: 'type'
                equals: 'Microsoft.CognitiveServices/accounts'
              }
              {
                field: 'type'
                equals: 'Microsoft.MachineLearningServices/workspaces'
              }
              {
                field: 'type'
                equals: 'Microsoft.Search/searchServices'
              }
            ]
          }
          {
            anyOf: [
              {
                field: 'identity.type'
                exists: 'false'
              }
              {
                field: 'identity.type'
                notContains: '[parameters(\'requiredIdentityType\')]'
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

output policyDefinitionId string = requireManagedIdentityForAI.id
