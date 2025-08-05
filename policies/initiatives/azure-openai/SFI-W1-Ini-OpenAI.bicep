// SFI-W1-Ini-OpenAI
// Azure OpenAI SFI-W1 Compliance Initiative
// Version: 2.0.0 | SFI-W1 Enhanced | Updated: 2025-08-04

targetScope = 'subscription'

param initiativeName string = 'SFI-W1-Ini-OpenAI'
param initiativeDisplayName string = 'SFI-W1-Ini-OpenAI: Azure OpenAI Comprehensive Security and Compliance Initiative'
param initiativeDescription string = 'Comprehensive policy initiative ensuring Azure OpenAI services comply with SFI-W1 security standards, including network isolation, encryption, content filtering, monitoring, and governance controls.'

// Import policy definitions
module privateEndpointsPolicy '../../definitions/azure-openai/SFI-W1-Def-OpenAI-RequirePrivateEndpoints.bicep' = {
  name: 'sfi-openai-private-endpoints-policy'
}

module customerManagedKeysPolicy '../../definitions/azure-openai/SFI-W1-Def-OpenAI-RequireCustomerManagedKeys.bicep' = {
  name: 'sfi-openai-cmk-policy'
}

module contentFilteringPolicy '../../definitions/azure-openai/SFI-W1-Def-OpenAI-RequireContentFiltering.bicep' = {
  name: 'sfi-openai-content-filtering-policy'
}

module skuRestrictionPolicy '../../definitions/azure-openai/SFI-W1-Def-OpenAI-RestrictSKUs.bicep' = {
  name: 'sfi-openai-sku-restriction-policy'
}

module diagnosticSettingsPolicy '../../definitions/azure-openai/SFI-W1-Def-OpenAI-RequireDiagnosticSettings.bicep' = {
  name: 'sfi-openai-diagnostic-settings-policy'
}

resource sfiOpenAIInitiative 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: initiativeDisplayName
    description: initiativeDescription
    policyType: 'Custom'
    metadata: {
      version: '2.0.0'
      category: 'AI Services'
      sfiCompliance: 'Complete SFI-W1 Coverage for Azure OpenAI'
      aztsCompliance: 'Full AzTS Integration and Monitoring'
      preview: false
      lastUpdated: '2025-08-04'
      source: 'Azure AI SFI Framework'
      coverage: {
        networkSecurity: 'Private Endpoints, Network Isolation'
        dataProtection: 'Customer Managed Keys, Encryption at Rest'
        responsibleAI: 'Content Filtering, Safety Controls'
        governance: 'SKU Restrictions, Resource Controls'
        monitoring: 'Diagnostic Settings, Audit Logging'
      }
      securityControls: [
        'SC-7: Boundary Protection'
        'SC-8: Transmission Confidentiality and Integrity'  
        'SC-28: Protection of Information at Rest'
        'SC-12: Cryptographic Key Establishment'
        'AU-2: Event Logging'
        'AU-6: Audit Review and Analysis'
        'AC-4: Information Flow Enforcement'
        'CM-6: Configuration Settings'
      ]
      complianceFrameworks: [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'HIPAA'
        'FedRAMP'
        'Responsible AI'
        'EU AI Act'
      ]
    }
    parameters: {
      // Global effect parameter
      globalEffect: {
        type: 'String'
        metadata: {
          displayName: 'Global Policy Effect'
          description: 'Global effect to apply to all policies in this initiative'
        }
        allowedValues: [
          'Audit'
          'Deny'
          'Disabled'
        ]
        defaultValue: 'Audit'
      }
      
      // Network Security Controls
      enableNetworkSecurity: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Network Security Controls'
          description: 'Enable private endpoint and network isolation requirements'
        }
        defaultValue: true
      }
      
      allowedLocations: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed Locations'
          description: 'List of allowed Azure regions for OpenAI deployment'
        }
        defaultValue: [
          'eastus'
          'westus2'
          'westeurope'
          'southeastasia'
        ]
      }
      
      // Data Protection Controls
      enableEncryption: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Encryption Controls'
          description: 'Enable customer-managed keys and encryption requirements'
        }
        defaultValue: true
      }
      
      // Responsible AI Controls
      enableContentFiltering: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Content Filtering'
          description: 'Enable content filtering and responsible AI controls'
        }
        defaultValue: true
      }
      
      contentFilterLevel: {
        type: 'String'
        metadata: {
          displayName: 'Content Filter Level'
          description: 'Minimum content filtering level required'
        }
        allowedValues: [
          'low'  
          'medium'
          'high'
        ]
        defaultValue: 'medium'
      }
      
      // Governance Controls
      enableGovernance: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Governance Controls'
          description: 'Enable SKU restrictions and resource governance'
        }
        defaultValue: true
      }
      
      allowedSKUs: {
        type: 'Array'
        metadata: {
          displayName: 'Allowed OpenAI SKUs'
          description: 'List of allowed Azure OpenAI SKU names'
        }
        defaultValue: [
          'S0'
          'S1'
          'S2'
          'S3'
        ]
      }
      
      // Monitoring Controls
      enableMonitoring: {
        type: 'Boolean'
        metadata: {
          displayName: 'Enable Monitoring Controls'
          description: 'Enable diagnostic settings and audit logging'
        }
        defaultValue: true
      }
      
      logAnalyticsWorkspaceId: {
        type: 'String'
        metadata: {
          displayName: 'Log Analytics Workspace ID'
          description: 'Resource ID of Log Analytics workspace for centralized logging'
        }
        defaultValue: ''
      }
      
      // Exception Handling  
      excludedResourceGroups: {
        type: 'Array'
        metadata: {
          displayName: 'Excluded Resource Groups'
          description: 'Resource groups to exclude from policy enforcement'
        }
        defaultValue: []
      }
    }
    policyDefinitions: [
      // Network Security Policy
      {
        policyDefinitionId: privateEndpointsPolicy.outputs.policyDefinitionId
        policyDefinitionReferenceId: 'SFI-OpenAI-RequirePrivateEndpoints'
        parameters: {
          effect: {
            value: '[if(parameters(\'enableNetworkSecurity\'), parameters(\'globalEffect\'), \'Disabled\')]'
          }
          allowedLocations: {
            value: '[parameters(\'allowedLocations\')]'
          }
          excludedResourceGroups: {
            value: '[parameters(\'excludedResourceGroups\')]'
          }
        }
        groupNames: [
          'Network Security'
          'Zero-Trust Architecture'
        ]
      }
      
      // Data Protection Policy
      {
        policyDefinitionId: customerManagedKeysPolicy.outputs.policyDefinitionId
        policyDefinitionReferenceId: 'SFI-OpenAI-RequireCustomerManagedKeys'
        parameters: {
          effect: {
            value: '[if(parameters(\'enableEncryption\'), parameters(\'globalEffect\'), \'Disabled\')]'
          }
          excludedResourceGroups: {
            value: '[parameters(\'excludedResourceGroups\')]'
          }
        }
        groupNames: [
          'Data Protection'
          'Encryption Controls'
        ]
      }
      
      // Responsible AI Policy
      {
        policyDefinitionId: contentFilteringPolicy.outputs.policyDefinitionId
        policyDefinitionReferenceId: 'SFI-OpenAI-RequireContentFiltering'
        parameters: {
          effect: {
            value: '[if(parameters(\'enableContentFiltering\'), parameters(\'globalEffect\'), \'Disabled\')]'
          }
          allowedContentFilterLevel: {
            value: '[parameters(\'contentFilterLevel\')]'
          }
          excludedResourceGroups: {
            value: '[parameters(\'excludedResourceGroups\')]'
          }
        }
        groupNames: [
          'Responsible AI'
          'Content Safety'
        ]
      }
      
      // Governance Policy
      {
        policyDefinitionId: skuRestrictionPolicy.outputs.policyDefinitionId
        policyDefinitionReferenceId: 'SFI-OpenAI-RestrictSKUs'
        parameters: {
          effect: {
            value: '[if(parameters(\'enableGovernance\'), parameters(\'globalEffect\'), \'Disabled\')]'
          }
          allowedSKUs: {
            value: '[parameters(\'allowedSKUs\')]'
          }
          excludedResourceGroups: {
            value: '[parameters(\'excludedResourceGroups\')]'
          }
        }
        groupNames: [
          'Resource Governance'
          'Cost Control'
        ]
      }
      
      // Monitoring Policy
      {
        policyDefinitionId: diagnosticSettingsPolicy.outputs.policyDefinitionId
        policyDefinitionReferenceId: 'SFI-OpenAI-RequireDiagnosticSettings'
        parameters: {
          effect: {
            value: '[if(parameters(\'enableMonitoring\'), \'DeployIfNotExists\', \'Disabled\')]'
          }
          logAnalyticsWorkspaceId: {
            value: '[parameters(\'logAnalyticsWorkspaceId\')]'
          }
        }
        groupNames: [
          'Monitoring'
          'Audit Logging'
        ]
      }
    ]
    policyDefinitionGroups: [
      {
        name: 'Network Security'
        displayName: 'Network Security and Isolation'
        description: 'Policies ensuring network-level security controls and zero-trust architecture'
        category: 'Network Security'
      }
      {
        name: 'Zero-Trust Architecture'
        displayName: 'Zero-Trust Architecture'
        description: 'Policies implementing zero-trust security principles'
        category: 'Security Architecture'
      }
      {
        name: 'Data Protection'
        displayName: 'Data Protection and Encryption'
        description: 'Policies ensuring data protection through encryption and key management'
        category: 'Data Security'
      }
      {
        name: 'Encryption Controls'
        displayName: 'Encryption Controls'
        description: 'Policies enforcing encryption standards and key management'
        category: 'Cryptography'
      }
      {
        name: 'Responsible AI'
        displayName: 'Responsible AI and Ethics'
        description: 'Policies ensuring responsible AI usage and ethical considerations'
        category: 'AI Governance'
      }
      {
        name: 'Content Safety'
        displayName: 'Content Safety and Moderation'
        description: 'Policies ensuring content safety and harmful content prevention'
        category: 'Content Governance'
      }
      {
        name: 'Resource Governance'
        displayName: 'Resource Governance and Standards'
        description: 'Policies enforcing resource configuration standards and governance'
        category: 'Governance'
      }
      {
        name: 'Cost Control'
        displayName: 'Cost Control and Optimization'
        description: 'Policies ensuring cost control and resource optimization'
        category: 'Cost Management'
      }
      {
        name: 'Monitoring'
        displayName: 'Monitoring and Observability'
        description: 'Policies ensuring comprehensive monitoring and observability'
        category: 'Observability'
      }
      {
        name: 'Audit Logging'
        displayName: 'Audit Logging and Compliance'
        description: 'Policies ensuring comprehensive audit logging for compliance'
        category: 'Compliance'
      }
    ]
  }
}

// Outputs
output initiativeId string = sfiOpenAIInitiative.id
output initiativeName string = initiativeName
output initiativeDisplayName string = initiativeDisplayName

output sfiCompliance object = {
  networkSecurity: privateEndpointsPolicy.outputs.sfiCompliance
  dataProtection: customerManagedKeysPolicy.outputs.sfiCompliance
  responsibleAI: contentFilteringPolicy.outputs.sfiCompliance
  governance: skuRestrictionPolicy.outputs.sfiCompliance
  monitoring: diagnosticSettingsPolicy.outputs.sfiCompliance
}

output aztsCompliance object = {
  networkSecurity: privateEndpointsPolicy.outputs.aztsCompliance
  dataProtection: customerManagedKeysPolicy.outputs.aztsCompliance
  responsibleAI: contentFilteringPolicy.outputs.aztsCompliance
  governance: skuRestrictionPolicy.outputs.aztsCompliance
  monitoring: diagnosticSettingsPolicy.outputs.aztsCompliance
}

output policyCount int = 5
output deploymentSummary object = {
  status: 'SFI-W1 Azure OpenAI Initiative deployed successfully'
  policiesIncluded: [
    'Private Endpoints Requirement'
    'Customer Managed Keys Requirement'
    'Content Filtering Requirement'
    'SKU Restrictions'
    'Diagnostic Settings Requirement'
  ]
  securityControls: 8
  complianceFrameworks: 9
  lastUpdated: '2025-08-04'
}
