// SFI-W1-Def-OpenAI-RequireDiagnosticSettings
// Ensures Azure OpenAI accounts have diagnostic settings configured for SFI-W1 compliance
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param policyName string = 'SFI-W1-Def-OpenAI-RequireDiagnosticSettings'
param policyDisplayName string = 'SFI-W1-Def-OpenAI: Require Diagnostic Settings for Azure OpenAI Services'
param policyDescription string = 'This policy ensures that Azure OpenAI accounts are configured with comprehensive diagnostic settings to enable audit logging, security monitoring, and compliance with SFI-W1 observability requirements.'

resource sfiOpenAIDiagnosticsPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Audit Logging, Security Monitoring, Observability'
      aztsCompliance: 'Monitoring Controls, Audit Trail, Compliance Reporting'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      policySet: 'SFI-W1-Ini-OpenAI'
      securityControls: [
        'AU-2: Event Logging'
        'AU-6: Audit Review, Analysis, and Reporting'
        'SI-4: Information System Monitoring'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'HIPAA'
        'PCI-DSS'
      ]
    }
    parameters: {
      effect: {
        type: 'String'
        metadata: {
          displayName: 'Policy Effect'
          description: 'Enable or disable the execution of the policy. DeployIfNotExists will auto-configure diagnostic settings.'
        }
        allowedValues: [
          'AuditIfNotExists'
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'DeployIfNotExists'
      }
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace ID'
          description: 'Resource ID of the Log Analytics workspace for diagnostic logs'
        }
        defaultValue: ''
      }
      storageAccountId: {
        type: 'String'
        metadata: {
          displayName: 'Storage Account ID'
          description: 'Resource ID of the storage account for long-term log retention'
        }
        defaultValue: ''
      }
      eventHubAuthorizationRuleId: {
        type: 'String'
        metadata: {
          displayName: 'Event Hub Authorization Rule ID'
          description: 'Resource ID of the Event Hub authorization rule for real-time streaming'
        }
        defaultValue: ''
      }
      requiredLogCategories: {
        type: 'Array'
        metadata: {
          displayName: 'Required Log Categories'
          description: 'List of log categories that must be enabled'
        }
        defaultValue: [
          'Audit'
          'RequestResponse'
          'Trace'
        ]
      }
      requiredMetrics: {
        type: 'Array'
        metadata: {
          displayName: 'Required Metrics'
          description: 'List of metric categories that must be enabled'
        }
        defaultValue: [
          'AllMetrics'
        ]
      }
      logRetentionDays: {
        type: 'Integer'
        metadata: {
          displayName: 'Log Retention Days'
          description: 'Number of days to retain logs for compliance'
        }
        allowedValues: [30, 60, 90, 180, 365, 730]
        defaultValue: 365
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
        ]
      }
      then: {
        effect: '[parameters(\'effect\')]'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: 'SFI-OpenAI-DiagnosticSettings'
          evaluationDelay: 'AfterProvisioning'
          existenceCondition: {
            allOf: [
              {
                count: {
                  field: 'Microsoft.Insights/diagnosticSettings/logs[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].category'
                        in: '[parameters(\'requiredLogCategories\')]'
                      }
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                        equals: true
                      }
                    ]
                  }
                }
                greaterOrEquals: '[length(parameters(\'requiredLogCategories\'))]'
              }
              {
                count: {
                  field: 'Microsoft.Insights/diagnosticSettings/metrics[*]'
                  where: {
                    allOf: [
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/metrics[*].category'
                        in: '[parameters(\'requiredMetrics\')]'
                      }
                      {
                        field: 'Microsoft.Insights/diagnosticSettings/metrics[*].enabled'
                        equals: true
                      }
                    ]
                  }
                }
                greaterOrEquals: '[length(parameters(\'requiredMetrics\'))]'
              }
            ]
          }
          roleDefinitionIds: [
            '/providers/microsoft.authorization/roleDefinitions/25fbc0a9-bd7c-42a3-aa1a-3b75d497ee68'  // Cognitive Services Contributor
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'  // Contributor
            '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'  // Log Analytics Contributor
          ]
          deployment: {
            properties: {
              mode: 'incremental'
              template: {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                contentVersion: '1.0.0.0'
                parameters: {
                  resourceName: {
                    type: 'string'
                  }
                  logAnalyticsWorkspaceId: {
                    type: 'string'
                  }
                  storageAccountId: {
                    type: 'string'
                  }
                  eventHubAuthorizationRuleId: {
                    type: 'string'
                  }
                  requiredLogCategories: {
                    type: 'array'
                  }
                  requiredMetrics: {
                    type: 'array'
                  }
                  logRetentionDays: {
                    type: 'int'
                  }
                }
                variables: {
                  diagnosticSettingsName: 'SFI-OpenAI-DiagnosticSettings'
                }
                resources: [
                  {
                    type: 'Microsoft.CognitiveServices/accounts/providers/diagnosticSettings'
                    apiVersion: '2021-05-01-preview'
                    name: '[concat(parameters(\'resourceName\'), \'/microsoft.insights/\', variables(\'diagnosticSettingsName\'))]'
                    properties: {
                      workspaceId: '[if(empty(parameters(\'logAnalyticsWorkspaceId\')), null(), parameters(\'logAnalyticsWorkspaceId\'))]'
                      storageAccountId: '[if(empty(parameters(\'storageAccountId\')), null(), parameters(\'storageAccountId\'))]'
                      eventHubAuthorizationRuleId: '[if(empty(parameters(\'eventHubAuthorizationRuleId\')), null(), parameters(\'eventHubAuthorizationRuleId\'))]'
                      logs: [
                        {
                          category: 'Audit'
                          enabled: true
                          retentionPolicy: {
                            enabled: true
                            days: 365
                          }
                        }
                        {
                          category: 'RequestResponse'
                          enabled: true
                          retentionPolicy: {
                            enabled: true
                            days: 365
                          }
                        }
                        {
                          category: 'Trace'
                          enabled: true
                          retentionPolicy: {
                            enabled: true
                            days: 365
                          }
                        }
                      ]
                      metrics: [
                        {
                          category: 'AllMetrics'
                          enabled: true
                          retentionPolicy: {
                            enabled: true
                            days: 365
                          }
                        }
                      ]
                    }
                  }
                ]
                outputs: {
                  policy: {
                    type: 'string'
                    value: 'Azure OpenAI diagnostic settings configured for SFI-W1 compliance'
                  }
                }
              }
              parameters: {
                resourceName: {
                  value: '[field(\'name\')]'
                }
                logAnalyticsWorkspaceId: {
                  value: '[parameters(\'logAnalyticsWorkspaceId\')]'
                }
                storageAccountId: {
                  value: '[parameters(\'storageAccountId\')]'
                }
                eventHubAuthorizationRuleId: {
                  value: '[parameters(\'eventHubAuthorizationRuleId\')]'
                }
                requiredLogCategories: {
                  value: '[parameters(\'requiredLogCategories\')]'
                }
                requiredMetrics: {
                  value: '[parameters(\'requiredMetrics\')]'
                }
                logRetentionDays: {
                  value: '[parameters(\'logRetentionDays\')]'
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
output policyDefinitionId string = sfiOpenAIDiagnosticsPolicy.id
output policyName string = policyName
output policyDisplayName string = policyDisplayName
output sfiCompliance array = [
  'Audit Logging'
  'Security Monitoring'
  'Observability'
]
output aztsCompliance array = [
  'Monitoring Controls'
  'Audit Trail'
  'Compliance Reporting'
]
