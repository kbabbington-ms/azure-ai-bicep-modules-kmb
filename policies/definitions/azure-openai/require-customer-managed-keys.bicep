// Policy: Require Customer-Managed Keys for Azure OpenAI
// Description: Ensures Azure OpenAI accounts use customer-managed encryption keys
// SFI-W1: Data protection and encryption requirements
// AzTS: Encryption controls and key management

targetScope = 'subscription'

resource requireOpenAICustomerManagedKeys 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-openai-customer-managed-keys'
  properties: {
    displayName: 'Azure OpenAI accounts should use customer-managed keys for encryption'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure OpenAI accounts should be configured with customer-managed keys to ensure data sovereignty and enhanced security. This policy enforces SFI-W1 encryption requirements for sensitive AI workloads.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Data Protection, Encryption at Rest'
      aztsCompliance: 'Key Management, Data Sovereignty'
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
                field: 'Microsoft.CognitiveServices/accounts/encryption.keySource'
                notEquals: 'Microsoft.Keyvault'
              }
              {
                field: 'Microsoft.CognitiveServices/accounts/encryption.keyVaultProperties.keyName'
                exists: 'false'
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

output policyDefinitionId string = requireOpenAICustomerManagedKeys.id
