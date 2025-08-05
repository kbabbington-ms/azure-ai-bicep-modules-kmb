targetScope = 'subscription'

param policyDefinitionName string = 'SFI-W1-Def-AIFoundry-RequireDiagnosticSettings'
param displayName string = 'Azure AI Foundry hubs should have diagnostic settings enabled'
param policyDescription string = 'This policy ensures that Azure AI Foundry hubs have diagnostic settings configured to send resource logs to Log Analytics workspace, meeting SFI-W1 monitoring and audit requirements.'
param category string = 'AI Foundry'
param version string = '2.0.0'

var policyRule = {
  if: {
    allOf: [
      {
        field: 'type'
        equals: 'Microsoft.MachineLearningServices/workspaces'
      }
      {
        field: 'Microsoft.MachineLearningServices/workspaces/workspaceHubConfig'
        exists: true
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
      type: 'Microsoft.Insights/diagnosticSettings'
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
                matchInsensitively: '[parameters(\'logAnalyticsWorkspaceId\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/storageAccountId'
                matchInsensitively: '[parameters(\'storageAccountId\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId'
                matchInsensitively: '[parameters(\'eventHubAuthorizationRuleId\')]'
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
                type: 'String'
              }
              logAnalyticsWorkspaceId: {
                type: 'String'
              }
              storageAccountId: {
                type: 'String'
              }
              eventHubAuthorizationRuleId: {
                type: 'String'
              }
              requiredLogCategories: {
                type: 'Array'
              }
              logRetentionDays: {
                type: 'Int'
              }
              diagnosticSettingsName: {
                type: 'String'
              }
            }
            resources: [
              {
                type: 'Microsoft.MachineLearningServices/workspaces/providers/diagnosticSettings'
                apiVersion: '2021-05-01-preview'
                name: '[[concat(parameters(\'resourceName\'), \'/Microsoft.Insights/\', parameters(\'diagnosticSettingsName\'))]'
                properties: {
                  workspaceId: '[[if(empty(parameters(\'logAnalyticsWorkspaceId\')), null(), parameters(\'logAnalyticsWorkspaceId\'))]'
                  storageAccountId: '[[if(empty(parameters(\'storageAccountId\')), null(), parameters(\'storageAccountId\'))]'
                  eventHubAuthorizationRuleId: '[[if(empty(parameters(\'eventHubAuthorizationRuleId\')), null(), parameters(\'eventHubAuthorizationRuleId\'))]'
                  logs: '[[map(parameters(\'requiredLogCategories\'), lambda(\'category\', createObject(\'category\', lambdaVariables(\'category\'), \'enabled\', true(), \'retentionPolicy\', createObject(\'enabled\', true(), \'days\', parameters(\'logRetentionDays\')))))]'
                }
              }
            ]
          }
          parameters: {
            resourceName: {
              value: '[[field(\'name\')]'
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
      description: 'Enable or disable the execution of the policy'
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
      description: 'Resource ID of the Log Analytics workspace for diagnostic settings'
    }
    defaultValue: ''
  }
  storageAccountId: {
    type: 'String'
    metadata: {
      displayName: 'Storage Account ID'
      description: 'Resource ID of the storage account for diagnostic settings'
    }
    defaultValue: ''
  }
  eventHubAuthorizationRuleId: {
    type: 'String'
    metadata: {
      displayName: 'Event Hub Authorization Rule ID'
      description: 'Resource ID of the Event Hub authorization rule for diagnostic settings'
    }
    defaultValue: ''
  }
  requiredLogCategories: {
    type: 'Array'
    metadata: {
      displayName: 'Required Log Categories'
      description: 'Required log categories for diagnostic settings'
    }
    defaultValue: [
      'AmlComputeClusterEvent'
      'AmlComputeClusterNodeEvent'
      'AmlComputeJobEvent'
      'AmlComputeCpuGpuUtilization'
      'AmlRunStatusChangedEvent'
    ]
  }
  logRetentionDays: {
    type: 'Integer'
    metadata: {
      displayName: 'Log Retention Days'
      description: 'Number of days to retain diagnostic logs'
    }
    defaultValue: 365
  }
  diagnosticSettingsName: {
    type: 'String'
    metadata: {
      displayName: 'Diagnostic Settings Name'
      description: 'Name for the diagnostic settings configuration'
    }
    defaultValue: 'AIFoundryDiagnosticSettings'
  }
  excludedResourceGroups: {
    type: 'Array'
    metadata: {
      displayName: 'Excluded Resource Groups'
      description: 'Resource groups to exclude from this policy'
    }
    defaultValue: []
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
        'Monitoring'
        'Audit Logging'
        'Compliance Reporting'
        'Security Analytics'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'FedRAMP'
      ]
    }
    parameters: policyParameters
    policyRule: policyRule
  }
}

output policyDefinitionId string = policyDefinition.id
output policyDefinitionName string = policyDefinition.name
