// SFI-W1-Def-OpenAI-RestrictSKUs
// Restricts Azure OpenAI to approved SKUs for cost control and SFI-W1 compliance
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param policyName string = 'SFI-W1-Def-OpenAI-RestrictSKUs'
param policyDisplayName string = 'SFI-W1-Def-OpenAI: Restrict Azure OpenAI to Approved SKUs'
param policyDescription string = 'This policy restricts Azure OpenAI account deployments to approved SKU tiers to ensure cost control, standardized performance levels, and compliance with SFI-W1 resource governance requirements.'

resource sfiOpenAISKURestrictionPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Resource Governance, Cost Control, Performance Standards'
      aztsCompliance: 'Resource Management, Service Configuration, Compliance'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      policySet: 'SFI-W1-Ini-OpenAI'
      securityControls: [
        'CM-6: Configuration Settings'
        'AC-3: Access Enforcement'
        'SC-6: Resource Availability'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'ISO 27001'
        'SOC 2'
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
        defaultValue: 'Deny'
      }
      allowedSKUs: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed SKUs'
          description: 'List of allowed Azure OpenAI SKU names'
        }
        defaultValue: [
          'S0'
          'S1'
          'S2'
          'S3'
        ]
      }
      allowedModelVersions: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Model Versions'
          description: 'List of allowed model versions for deployments'
        }
        defaultValue: [
          'gpt-35-turbo'
          'gpt-4'
          'gpt-4-32k'
          'text-embedding-ada-002'
          'text-davinci-003'
        ]
      }
      maxDeploymentsPerAccount: {
        type: 'Integer'
        metadata: {
          displayName: 'Maximum Deployments Per Account'
          description: 'Maximum number of model deployments allowed per OpenAI account'
        }
        allowedValues: [1, 2, 3, 4, 5, 10]
        defaultValue: 5
      }
      excludedResourceGroups: {
        type: 'Array'
        metadata: {
          displayName: 'Excluded Resource Groups'
          description: 'List of resource groups to exclude from this policy (e.g., for testing or research)'
        }
        defaultValue: []
      }
      requireApprovalForHighTierSKUs: {
        type: 'Boolean'
        metadata: {
          displayName: 'Require Approval for High-Tier SKUs'
          description: 'Whether to require approval for high-tier SKUs (S2, S3, etc.)'
        }
        defaultValue: true
      }
    }
    policyRule: {
      if: {
        allOf: [
          {
            anyOf: [
              // Check OpenAI account SKU
              {
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
              // Check OpenAI deployment models
              {
                allOf: [
                  {
                    field: 'type'
                    equals: 'Microsoft.CognitiveServices/accounts/deployments'
                  }
                  {
                    field: 'Microsoft.CognitiveServices/accounts/deployments/properties.model.name'
                    notIn: '[parameters(\'allowedModelVersions\')]'
                  }
                ]
              }
            ]
          }
          {
            not: {
              field: 'resourceGroup'
              in: '[parameters(\'excludedResourceGroups\')]'
            }
          }
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.CognitiveServices/accounts'
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
                  accountName: {
                    type: 'string'
                  }
                  location: {
                    type: 'string'
                  }
                  skuName: {
                    type: 'string'
                  }
                }
                resources: []
                outputs: {
                  policy: {
                    type: 'string'
                    value: 'Azure OpenAI account must use approved SKUs for SFI-W1 compliance'
                  }
                  approvedSKUs: {
                    type: 'array'
                    value: '[parameters(\'allowedSKUs\')]'
                  }
                }
              }
              parameters: {
                accountName: {
                  value: '[field(\'name\')]'
                }
                location: {
                  value: '[field(\'location\')]'
                }
                skuName: {
                  value: '[field(\'Microsoft.CognitiveServices/accounts/sku.name\')]'
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
output policyDefinitionId string = sfiOpenAISKURestrictionPolicy.id
output policyName string = policyName
output policyDisplayName string = policyDisplayName
output sfiCompliance array = [
  'Resource Governance'
  'Cost Control'
  'Performance Standards'
]
output aztsCompliance array = [
  'Resource Management'
  'Service Configuration'
  'Compliance'
]
