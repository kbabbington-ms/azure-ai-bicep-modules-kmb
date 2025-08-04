// Policy Definition: SFI-W1-Def-KeyVault-RequireDiagnosticSettings
@description('Ensures Azure Key Vaults have diagnostic settings configured to send logs to Log Analytics.')
param policyName string = 'SFI-W1-Def-KeyVault-RequireDiagnosticSettings'
param policyDisplayName string = 'SFI-W1-Def-KeyVault: Require Diagnostic Settings'
param policyDescription string = 'Ensures Azure Key Vaults have diagnostic settings configured to send audit logs to Log Analytics workspace for compliance monitoring.'

targetScope = 'subscription'

resource policyDefinition 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: {
    displayName: policyDisplayName
    description: policyDescription
    policyType: 'Custom'
    mode: 'All'
    metadata: {
      category: 'Monitoring'
      version: '1.0.0'
      source: 'Azure AI Foundry SFI'
    }
    parameters: {
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace ID'
          description: 'The Log Analytics workspace ID to send diagnostic logs to'
        }
      }
      requiredLogCategories: {
        type: 'Array'
        defaultValue: [
          'AuditEvent'
          'AzurePolicyEvaluationDetails'
        ]
        metadata: {
          displayName: 'Required Log Categories'
          description: 'List of log categories that must be enabled'
        }
      }
    }
    policyRule: {
      if: {
        field: 'type'
        equals: 'Microsoft.KeyVault/vaults'
      }
      then: {
        effect: 'auditIfNotExists'
        details: {
          type: 'Microsoft.Insights/diagnosticSettings'
          name: 'KeyVaultDiagnosticSettings'
          existenceCondition: {
            allOf: [
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs[*].category'
                in: '[parameters(\'requiredLogCategories\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                equals: true
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/workspaceId'
                equals: '[parameters(\'logAnalyticsWorkspaceId\')]'
              }
            ]
          }
        }
      }
    }
  }
}
