// SFI-W1-Def-OpenAI-RequirePrivateEndpoints
// Ensures Azure OpenAI accounts use private endpoints for SFI-W1 compliance
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param policyName string = 'SFI-W1-Def-OpenAI-RequirePrivateEndpoints'
param policyDisplayName string = 'SFI-W1-Def-OpenAI: Require Private Endpoints for Azure OpenAI Services'
param policyDescription string = 'This policy ensures that Azure OpenAI accounts are configured with private endpoints to maintain network isolation, prevent public internet exposure, and comply with SFI-W1 zero-trust security principles. Supports audit and deny modes for flexible enforcement.'

resource sfiOpenAIPrivateEndpointsPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Network Security, Zero-Trust Architecture, Data Residency'
      aztsCompliance: 'Network Controls, Private Connectivity, Secure Communication'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      policySet: 'SFI-W1-Ini-OpenAI'
      securityControls: [
        'SC-7: Boundary Protection'
        'SC-8: Transmission Confidentiality and Integrity'
        'AC-4: Information Flow Enforcement'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
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
        defaultValue: 'Audit'
      }
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Locations'
          description: 'List of locations where Azure OpenAI resources can be deployed for data residency compliance'
        }
        defaultValue: [
          'eastus'
          'westus2'
          'westeurope'
          'southeastasia'
        ]
      }
      excludedResourceGroups: {
        type: 'Array'
        metadata: {
          displayName: 'Excluded Resource Groups'
          description: 'List of resource groups to exclude from this policy (e.g., for testing or legacy systems)'
        }
        defaultValue: []
      }
      minPrivateEndpoints: {
        type: 'Integer'
        metadata: {
          displayName: 'Minimum Private Endpoints'
          description: 'Minimum number of approved private endpoint connections required'
        }
        allowedValues: [1, 2, 3, 4, 5]
        defaultValue: 1
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
            field: 'location'
            in: '[parameters(\'allowedLocations\')]'
          }
          {
            not: {
              field: 'resourceGroup'
              in: '[parameters(\'excludedResourceGroups\')]'
            }
          }
          {
            anyOf: [
              // Check for public network access enabled
              {
                field: 'Microsoft.CognitiveServices/accounts/publicNetworkAccess'
                notEquals: 'Disabled'
              }
              // Check for insufficient private endpoint connections
              {
                count: {
                  field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*].privateLinkServiceConnectionState.status'
                        equals: 'Approved'
                      }
                      {
                        field: 'Microsoft.CognitiveServices/accounts/privateEndpointConnections[*].provisioningState'
                        equals: 'Succeeded'
                      }
                    ]
                  }
                }
                less: '[parameters(\'minPrivateEndpoints\')]'
              }
              // Check for missing network access rules (if public access not disabled)
              {
                allOf: [
                  {
                    field: 'Microsoft.CognitiveServices/accounts/publicNetworkAccess'
                    notEquals: 'Disabled'
                  }
                  {
                    anyOf: [
                      {
                        field: 'Microsoft.CognitiveServices/accounts/networkAcls'
                        exists: false
                      }
                      {
                        field: 'Microsoft.CognitiveServices/accounts/networkAcls.defaultAction'
                        notEquals: 'Deny'
                      }
                    ]
                  }
                ]
              }
            ]
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
                }
                resources: []
                outputs: {
                  policy: {
                    type: 'string'
                    value: 'Azure OpenAI account must use private endpoints for SFI-W1 compliance'
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
              }
            }
          }
        }
      }
    }
  }
}

// Output for initiative inclusion
output policyDefinitionId string = sfiOpenAIPrivateEndpointsPolicy.id
output policyName string = policyName
output policyDisplayName string = policyDisplayName
output sfiCompliance array = [
  'Network Security'
  'Zero-Trust Architecture'
  'Data Residency'
]
output aztsCompliance array = [
  'Network Controls'
  'Private Connectivity'
  'Secure Communication'
]
