targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-CogSvc-RequireDiagnosticSettings'
param displayName string = 'Azure Cognitive Services should have diagnostic settings configured'
param policyDescription string = 'This policy ensures that Azure Cognitive Services accounts have diagnostic settings configured for comprehensive logging and monitoring, meeting SFI-W1 audit and compliance requirements.'
param category string = 'Cognitive Services'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.CognitiveServices/accounts'
      }
      {
        field: 'Microsoft.CognitiveServices/accounts/kind'
        notIn: [
          'OpenAI'
          'FormRecognizer'
        ]
      }
    ]
  }
  then: {
    effect: '[parameters(\'effect\')]'
    details: {
      type: 'Microsoft.Insights/diagnosticSettings'
      name: '[parameters(\'diagnosticSettingsName\')]'
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
            anyOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: '[parameters(\'logAnalyticsWorkspaceId\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/storageAccountId'
                equals: '[parameters(\'storageAccountId\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId'
                equals: '[parameters(\'eventHubAuthorizationRuleId\')]'
              }
            ]
          }
        ]
      }
      deployment: {
        properties: {
          mode: 'Incremental'
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
              logRetentionDays: {
                type: 'int'
              }
              diagnosticSettingsName: {
                type: 'string'
              }
            }
            resources: [
              {
                type: 'Microsoft.CognitiveServices/accounts/providers/diagnosticSettings'
                apiVersion: '2021-05-01-preview'
                name: '[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/\', parameters(\'diagnosticSettingsName\'))]'
                properties: {
                  workspaceId: '[if(empty(parameters(\'logAnalyticsWorkspaceId\')), null(), parameters(\'logAnalyticsWorkspaceId\'))]'
                  storageAccountId: '[if(empty(parameters(\'storageAccountId\')), null(), parameters(\'storageAccountId\'))]'
                  eventHubAuthorizationRuleId: '[if(empty(parameters(\'eventHubAuthorizationRuleId\')), null(), parameters(\'eventHubAuthorizationRuleId\'))]'
                  logs: '[map(parameters(\'requiredLogCategories\'), lambda(\'category\', createObject(\'category\', lambdaVariables(\'category\'), \'enabled\', true(), \'retentionPolicy\', createObject(\'enabled\', true(), \'days\', parameters(\'logRetentionDays\')))))]'
                  metrics: [
                    {
                      category: 'AllMetrics'
                      enabled: true
                      retentionPolicy: {
                        enabled: true
                        days: '[parameters(\'logRetentionDays\')]'
                      }
                    }
                  ]
                }
              }
            ]
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
            logRetentionDays: {
              value: '[parameters(\'logRetentionDays\')]'
            }
            diagnosticSettingsName: {
              value: '[parameters(\'diagnosticSettingsName\')]'
            }
          }
        }
      }
      roleDefinitionIds: [
        '/providers/microsoft.authorization/roleDefinitions/749f88d5-cbae-40b8-bcfc-e573ddc772fa'
        '/providers/microsoft.authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293'
      ]
    }
  }
}

var policyParameters = {
  effect: {
    type: 'String'
    metadata: {
      displayName: 'Effect'
      description: 'The effect determines what happens when the policy rule is evaluated to match'
    }
    allowedValues: [
      'AuditIfNotExists'
      'DeployIfNotExists'
      'Disabled'
    ]
    defaultValue: 'AuditIfNotExists'
  }
  logAnalyticsWorkspaceId: {
    type: 'String'
    metadata: {
      displayName: 'Log Analytics Workspace ID'
      description: 'The Log Analytics workspace ID for diagnostic settings'
    }
    defaultValue: ''
  }
  storageAccountId: {
    type: 'String'
    metadata: {
      displayName: 'Storage Account ID'
      description: 'The storage account ID for diagnostic settings'
    }
    defaultValue: ''
  }
  eventHubAuthorizationRuleId: {
    type: 'String'
    metadata: {
      displayName: 'Event Hub Authorization Rule ID'
      description: 'The Event Hub authorization rule ID for diagnostic settings'
    }
    defaultValue: ''
  }
  requiredLogCategories: {
    type: 'Array'
    metadata: {
      displayName: 'Required Log Categories'
      description: 'The list of required log categories for diagnostic settings'
    }
    defaultValue: [
      'Audit'
      'RequestResponse'
      'Trace'
    ]
  }
  logRetentionDays: {
    type: 'Integer'
    metadata: {
      displayName: 'Log Retention Days'
      description: 'The number of days to retain logs'
    }
    defaultValue: 365
  }
  diagnosticSettingsName: {
    type: 'String'
    metadata: {
      displayName: 'Diagnostic Settings Name'
      description: 'The name of the diagnostic settings configuration'
    }
    defaultValue: 'CogSvcDiagnosticSettings'
  }
}

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyDefinitionName
  properties: {
    displayName: displayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'Indexed'
    metadata: {
      version: version
      category: category
      'SFI-W1-Controls': [
        'Audit and Accountability'
        'Continuous Monitoring'
        'Security Logging'
        'Compliance Reporting'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'PCI DSS'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
