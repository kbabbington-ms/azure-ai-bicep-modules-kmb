// SFI-W1-Def-OpenAI-RequireContentFiltering
// Ensures Azure OpenAI deployments use content filtering for responsible AI and SFI-W1 compliance
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param policyName string = 'SFI-W1-Def-OpenAI-RequireContentFiltering'
param policyDisplayName string = 'SFI-W1-Def-OpenAI: Require Content Filtering for Azure OpenAI Deployments'
param policyDescription string = 'This policy ensures that Azure OpenAI model deployments are configured with appropriate content filtering to prevent harmful content generation, ensure responsible AI usage, and comply with SFI-W1 governance requirements.'

resource sfiOpenAIContentFilteringPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Responsible AI, Content Safety, Governance Controls'
      aztsCompliance: 'AI Governance, Content Moderation, Risk Management'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      policySet: 'SFI-W1-Ini-OpenAI'
      securityControls: [
        'AC-4: Information Flow Enforcement'
        'SI-12: Information Handling and Retention'
        'CM-6: Configuration Settings'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'Responsible AI'
        'EU AI Act'
        'ISO 27001'
      ]
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Policy Effect'
          description: 'Enable or disable the execution of the policy. Audit mode for monitoring, Deny mode for enforcement.'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      allowedContentFilterLevel: {
        type: 'String'
        metadata: {
          displayName: 'Minimum Content Filter Level'
          description: 'Minimum content filtering level required for model deployments'
        }
        allowedValues: [
          'low'
          'medium'
          'high'
        ]
        defaultValue: 'medium'
      }
      requiredFilterCategories: {
        type: 'Array'
        metadata: {
          displayName: 'Required Filter Categories'
          description: 'Content filtering categories that must be enabled'
        }
        defaultValue: [
          'hate'
          'violence'
          'sexual'
          'selfHarm'
        ]
      }
      excludedResourceGroups: {
        type: 'Array'
        metadata: {
          displayName: 'Excluded Resource Groups'
          description: 'List of resource groups to exclude from this policy (e.g., for research or testing)'
        }
        defaultValue: []
      }
      allowExceptions: {
        type: 'Boolean'
        metadata: {
          displayName: 'Allow Exceptions'
          description: 'Whether to allow exceptions for specific use cases with proper justification'
        }
        defaultValue: false
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
            field: 'Microsoft.CognitiveServices/accounts/deployments/properties.model.name'
            like: 'gpt-*'
          }
          {
            not: {
              field: 'resourceGroup'
              in: '[parameters(\'excludedResourceGroups\')]'
            }
          }
          {
            anyOf: [
              // Check if content filter is not configured
              {
                field: 'Microsoft.CognitiveServices/accounts/deployments/properties.contentFilter'
                exists: false
              }
              // Check if content filter is disabled
              {
                field: 'Microsoft.CognitiveServices/accounts/deployments/properties.contentFilter.enabled'
                equals: false
              }
              // Check if content filter level is insufficient
              {
                field: 'Microsoft.CognitiveServices/accounts/deployments/properties.contentFilter.level'
                notIn: '[parameters(\'allowedContentFilterLevel\')]'
              }
              // Check if required filter categories are missing
              {
                count: {
                  field: 'Microsoft.CognitiveServices/accounts/deployments/properties.contentFilter.categories[*]'
                  where: {
                    field: 'Microsoft.CognitiveServices/accounts/deployments/properties.contentFilter.categories[*].category'
                    in: '[parameters(\'requiredFilterCategories\')]'
                  }
                }
                less: '[length(parameters(\'requiredFilterCategories\'))]'
              }
            ]
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.CognitiveServices/accounts/deployments'
          name: '[field(\'name\')]'
          evaluationDelay: 'AfterProvisioning'
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'  // Cognitive Services Contributor
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'  // Contributor
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  deploymentName: {
                    type: 'string'
                  }
                  accountName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                }
                resources: []
                outputs: {
                  policy: {
                    type: 'string'
                    value: 'Azure OpenAI deployment must use content filtering for responsible AI compliance'
                  }
                }
              }
              parameters: {
                deploymentName: {
                  value: '[field(\'name\')]'
                }
                accountName: {
                  value: '[field(\'Microsoft.CognitiveServices/accounts/name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
  }
}

// Output for initiative inclusion
output policyDefinitionId string = sfiOpenAIContentFilteringPolicy.id
output policyName string = policyName
output policyDisplayName string = policyDisplayName
output sfiCompliance array = [
  'Responsible AI'
  'Content Safety'
  'Governance Controls'
]
output aztsCompliance array = [
  'AI Governance'
  'Content Moderation'
  'Risk Management'
]
