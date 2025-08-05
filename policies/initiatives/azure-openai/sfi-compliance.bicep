// Policy Initiative: Azure OpenAI SFI-W1 Compliance
// Description: Comprehensive initiative for Azure OpenAI SFI-W1 and AzTS compliance
// Includes network security, encryption, content safety, and governance controls

targetScope = 'subscription'

resource azureOpenAISFIInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: 'azure-openai-sfi-compliance'
  properties: {
    displayName: 'Azure OpenAI SFI-W1 Compliance Initiative'
    policyType: 'Custom'
    description: 'Comprehensive policy initiative ensuring Azure OpenAI accounts comply with Microsoft Secure Future Initiative (SFI-W1) and Azure Trusted Security (AzTS) requirements including network isolation, encryption, content safety, and governance controls.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Complete SFI-W1 Coverage'
      aztsCompliance: 'Complete AzTS Coverage'
      preview: false
    }
    parameters: {
      privateEndpointsEffect: {
        type: 'String'
        metadata: {
          displayName: 'Private Endpoints Effect'
          description: 'Effect for private endpoints policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      encryptionEffect: {
        type: 'String'
        metadata: {
          displayName: 'Encryption Effect'
          description: 'Effect for customer-managed keys policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      contentFilteringEffect: {
        type: 'String'
        metadata: {
          displayName: 'Content Filtering Effect'
          description: 'Effect for content filtering policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      skuRestrictionEffect: {
        type: 'String'
        metadata: {
          displayName: 'SKU Restriction Effect'
          description: 'Effect for SKU restriction policy'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Deny'
      }
      allowedSKUs: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed SKUs'
          description: 'List of approved SKUs for Azure OpenAI accounts'
        }
        defaultValue: [
          'S0'
        ]
      }
      allowedContentFilteringPolicies: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Content Filtering Policies'
          description: 'List of approved content filtering policy names'
        }
        defaultValue: [
          'Microsoft.Default'
          'Microsoft.DefaultV2'
        ]
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/require-openai-private-endpoints'
        parameters: {
          effect: {
            value: '[parameters(\'privateEndpointsEffect\')]'
          }
        }
        policyDefinitionReferenceId: 'require-openai-private-endpoints'
      }
      {
        policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/require-openai-customer-managed-keys'
        parameters: {
          effect: {
            value: '[parameters(\'encryptionEffect\')]'
          }
        }
        policyDefinitionReferenceId: 'require-openai-customer-managed-keys'
      }
      {
        policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/require-openai-content-filtering'
        parameters: {
          effect: {
            value: '[parameters(\'contentFilteringEffect\')]'
          }
          allowedContentFilteringPolicies: {
            value: '[parameters(\'allowedContentFilteringPolicies\')]'
          }
        }
        policyDefinitionReferenceId: 'require-openai-content-filtering'
      }
      {
        policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/restrict-openai-skus'
        parameters: {
          effect: {
            value: '[parameters(\'skuRestrictionEffect\')]'
          }
          allowedSKUs: {
            value: '[parameters(\'allowedSKUs\')]'
          }
        }
        policyDefinitionReferenceId: 'restrict-openai-skus'
      }
    ]
  }
}

output initiativeId string = azureOpenAISFIInitiative.id
output initiativeName string = azureOpenAISFIInitiative.name
