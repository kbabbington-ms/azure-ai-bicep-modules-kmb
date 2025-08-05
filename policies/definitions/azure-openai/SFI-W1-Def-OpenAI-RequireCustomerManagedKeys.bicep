// SFI-W1-Def-OpenAI-RequireCustomerManagedKeys
// Ensures Azure OpenAI accounts use customer-managed encryption keys for SFI-W1 compliance
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param policyName string = 'SFI-W1-Def-OpenAI-RequireCustomerManagedKeys'
param policyDisplayName string = 'SFI-W1-Def-OpenAI: Require Customer Managed Keys for Azure OpenAI Services'
param policyDescription string = 'This policy ensures that Azure OpenAI accounts are configured with customer-managed encryption keys (CMK) to maintain data sovereignty, enhance security posture, and comply with SFI-W1 data protection requirements.'

resource sfiOpenAICMKPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Data Protection, Encryption at Rest, Data Sovereignty'
      aztsCompliance: 'Encryption Controls, Key Management, Data Protection'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      policySet: 'SFI-W1-Ini-OpenAI'
      securityControls: [
        'SC-28: Protection of Information at Rest'
        'SC-12: Cryptographic Key Establishment and Management'
        'SI-7: Software, Firmware, and Information Integrity'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'HIPAA'
        'FedRAMP'
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
      allowedKeyVaultLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Key Vault Locations'
          description: 'List of locations where Key Vault with customer-managed keys can be located'
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
      requireKeyRotation: {
        type: 'Boolean'
        metadata: {
          displayName: 'Require Key Rotation'
          description: 'Whether to enforce automatic key rotation for customer-managed keys'
        }
        defaultValue: true
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
            not: {
              field: 'resourceGroup'
              in: '[parameters(\'excludedResourceGroups\')]'
            }
          }
          {
            anyOf: [
              // Check if encryption is not configured
              {
                field: 'Microsoft.CognitiveServices/accounts/encryption'
                exists: false
              }
              // Check if not using customer-managed keys
              {
                field: 'Microsoft.CognitiveServices/accounts/encryption.keySource'
                notEquals: 'Microsoft.KeyVault'
              }
              // Check if key vault configuration is missing
              {
                anyOf: [
                  {
                    field: 'Microsoft.CognitiveServices/accounts/encryption.keyVaultProperties'
                    exists: false
                  }
                  {
                    field: 'Microsoft.CognitiveServices/accounts/encryption.keyVaultProperties.keyName'
                    exists: false
                  }
                  {
                    field: 'Microsoft.CognitiveServices/accounts/encryption.keyVaultProperties.keyVaultUri'
                    exists: false
                  }
                ]
              }
              // Check if identity is not properly configured for key access
              {
                anyOf: [
                  {
                    field: 'identity'
                    exists: false
                  }
                  {
                    field: 'identity.type'
                    notIn: [
                      'SystemAssigned'
                      'UserAssigned'
                      'SystemAssigned,UserAssigned'
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
                    value: 'Azure OpenAI account must use customer-managed keys for SFI-W1 compliance'
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
output policyDefinitionId string = sfiOpenAICMKPolicy.id
output policyName string = policyName
output policyDisplayName string = policyDisplayName
output sfiCompliance array = [
  'Data Protection'
  'Encryption at Rest'
  'Data Sovereignty'
]
output aztsCompliance array = [
  'Encryption Controls'
  'Key Management'
  'Data Protection'
]
