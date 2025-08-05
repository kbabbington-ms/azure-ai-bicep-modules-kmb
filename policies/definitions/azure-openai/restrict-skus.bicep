// Policy: Restrict Azure OpenAI SKUs
// Description: Ensures only approved SKUs are used for Azure OpenAI accounts
// SFI-W1: Resource governance and cost control
// AzTS: Service tier restrictions and compliance

targetScope = 'subscription'

resource restrictOpenAISKUs 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'restrict-openai-skus'
  properties: {
    displayName: 'Azure OpenAI accounts should use approved SKUs only'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure OpenAI accounts should only use approved SKUs to ensure cost control, performance standards, and compliance with organizational governance policies.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Resource Governance, Cost Control'
      aztsCompliance: 'Service Tier Management, Compliance'
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
            field: 'Microsoft.CognitiveServices/accounts/sku.name'
            notIn: '[parameters(\'allowedSKUs\')]'
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
      }
    }
  }
}

output policyDefinitionId string = restrictOpenAISKUs.id
