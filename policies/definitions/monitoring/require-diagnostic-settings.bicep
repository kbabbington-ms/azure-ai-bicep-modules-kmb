// Policy: Require Diagnostic Settings for AI Services
// Description: Ensures all AI services have diagnostic settings configured
// SFI-W1: Audit logging and monitoring requirements
// AzTS: Compliance monitoring and audit trails

targetScope = 'subscription'

resource requireAIDiagnosticSettings 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: 'require-ai-diagnostic-settings'
  properties: {
    displayName: 'AI services should have diagnostic settings configured'
    policyType: 'Custom'
    mode: 'Indexed'
    description: 'AI services should be configured with diagnostic settings to ensure comprehensive audit logging, monitoring, and compliance with SFI-W1 observability requirements.'
    metadata: {
      version: '1.0.0'
      category: 'Monitoring'
      sfiCompliance: 'Audit Logging, Monitoring Requirements'
      aztsCompliance: 'Compliance Monitoring, Audit Trails'
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
          'AuditIfNotExists'
          'DeployIfNotExists'
          'Disabled'
        ]
        defaultValue: 'AuditIfNotExists'
      }
      requiredLogCategories: {
        type: 'Array'
        metadata: {
          displayName: 'Required Log Categories'
          description: 'List of required log categories for diagnostic settings'
        }
        defaultValue: [
          'Audit'
          'RequestResponse'
          'Trace'
        ]
      }
    }
    policyRule: {
      if: {
        anyOf: [
          {
            field: 'type'
            equals: 'Microsoft.CognitiveServices/accounts'
          }
          {
            field: 'type'
            equals: 'Microsoft.MachineLearningServices/workspaces'
          }
          {
            field: 'type'
            equals: 'Microsoft.Search/searchServices'
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
                field: 'Microsoft.Insights/diagnosticSettings/logs[*].category'
                in: '[parameters(\'requiredLogCategories\')]'
              }
              {
                field: 'Microsoft.Insights/diagnosticSettings/logs[*].enabled'
                equals: 'true'
              }
            ]
          }
        }
      }
    }
  }
}

output policyDefinitionId string = requireAIDiagnosticSettings.id
