// Policy: Require Content Filtering for Azure OpenAI
// Description: Ensures Azure OpenAI deployments have appropriate content filtering enabled
// SFI-W1: Content safety and responsible AI requirements
// AzTS: AI governance and content moderation

targetScope = 'subscription'

resource requireOpenAIContentFiltering 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-openai-content-filtering'
  properties: {
    displayName: 'Azure OpenAI deployments should have content filtering enabled'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'Azure OpenAI model deployments should be configured with appropriate content filtering policies to ensure responsible AI usage and compliance with organizational safety standards.'
    metadata: {
      version: '1.0.0'
      category: 'Cognitive Services'
      sfiCompliance: 'Responsible AI, Content Safety'
      aztsCompliance: 'AI Governance, Content Moderation'
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
    policyRule: {
      if: {
        allOf: [
          {
            field: 'type'
            equals: 'Microsoft.CognitiveServices/accounts/deployments'
          }
          {
            field: 'Microsoft.CognitiveServices/accounts/deployments/model.format'
            equals: 'OpenAI'
          }
          {
            anyOf: [
              {
                field: 'Microsoft.CognitiveServices/accounts/deployments/raiPolicyName'
                exists: 'false'
              }
              {
                field: 'Microsoft.CognitiveServices/accounts/deployments/raiPolicyName'
                notIn: '[parameters(\'allowedContentFilteringPolicies\')]'
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

output policyDefinitionId string = requireOpenAIContentFiltering.id
