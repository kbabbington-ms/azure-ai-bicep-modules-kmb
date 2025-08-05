targetScope = 'subscription'

param initiativeName string = 'SFI-W1-Ini-AIFoundry'
param displayName string = 'SFI-W1 Azure AI Foundry Compliance Initiative'
param policyDescription string = 'Comprehensive Azure AI Foundry security and compliance initiative implementing SFI-W1 standards including network security, data protection, identity management, compute security, and monitoring controls for AI Foundry hubs and projects.'
param category string = 'AI Foundry'
param version string = '2.0.0'

// Import policy definitions (these need to be deployed first)
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-RequirePrivateEndpoints'
    policyDefinitionReferenceId: 'RequirePrivateEndpoints'
    groupNames: ['NetworkSecurity']
    parameters: {
      effect: {
        value: '[parameters(\'privateEndpointsEffect\')]'
      }
      allowedLocations: {
        value: '[parameters(\'allowedLocations\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
      minPrivateEndpoints: {
        value: '[parameters(\'minPrivateEndpoints\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-RequireCustomerManagedKeys'
    policyDefinitionReferenceId: 'RequireCustomerManagedKeys'
    groupNames: ['DataProtection']
    parameters: {
      effect: {
        value: '[parameters(\'encryptionEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
      allowedKeyVaultLocations: {
        value: '[parameters(\'allowedLocations\')]'
      }
      requireKeyRotation: {
        value: '[parameters(\'requireKeyRotation\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-DisablePublicNetworkAccess'
    policyDefinitionReferenceId: 'DisablePublicNetworkAccess'
    groupNames: ['NetworkSecurity']
    parameters: {
      effect: {
        value: '[parameters(\'publicNetworkAccessEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-RequireUserAssignedIdentity'
    policyDefinitionReferenceId: 'RequireUserAssignedIdentity'
    groupNames: ['IdentityManagement']
    parameters: {
      effect: {
        value: '[parameters(\'identityEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-DisableComputeLocalAuth'
    policyDefinitionReferenceId: 'DisableComputeLocalAuth'
    groupNames: ['ComputeSecurity']
    parameters: {
      effect: {
        value: '[parameters(\'computeAuthEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-AIFoundry-RequireDiagnosticSettings'
    policyDefinitionReferenceId: 'RequireDiagnosticSettings'
    groupNames: ['Monitoring']
    parameters: {
      effect: {
        value: '[parameters(\'diagnosticsEffect\')]'
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
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
]

// Policy group definitions
var policyDefinitionGroups = [
  {
    name: 'NetworkSecurity'
    displayName: 'Network Security Controls'
    description: 'Policies ensuring secure network configuration and zero-trust architecture for AI Foundry hubs'
  }
  {
    name: 'DataProtection'
    displayName: 'Data Protection Controls'
    description: 'Policies ensuring data encryption, key management, and data sovereignty for AI workloads'
  }
  {
    name: 'IdentityManagement'
    displayName: 'Identity and Access Management'
    description: 'Policies ensuring proper identity configuration and secure access for AI Foundry resources'
  }
  {
    name: 'ComputeSecurity'
    displayName: 'Compute Security Controls'
    description: 'Policies ensuring secure compute instance and cluster configuration'
  }
  {
    name: 'Monitoring'
    displayName: 'Monitoring and Compliance'
    description: 'Policies ensuring comprehensive logging, monitoring, and audit trail for AI operations'
  }
]

var initiativeParameters = {
  // Global Controls
  enableNetworkSecurity: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Network Security Policies'
      description: 'Enable or disable network security policy group'
    }
    defaultValue: true
  }
  enableDataProtection: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Data Protection Policies'
      description: 'Enable or disable data protection policy group'
    }
    defaultValue: true
  }
  enableIdentityManagement: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Identity Management Policies'
      description: 'Enable or disable identity management policy group'
    }
    defaultValue: true
  }
  enableComputeSecurity: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Compute Security Policies'
      description: 'Enable or disable compute security policy group'
    }
    defaultValue: true
  }
  enableMonitoring: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Monitoring Policies'
      description: 'Enable or disable monitoring policy group'
    }
    defaultValue: true
  }
  
  // Effect Parameters
  privateEndpointsEffect: {
    type: 'String'
    metadata: {
      displayName: 'Private Endpoints Effect'
      description: 'Policy effect for private endpoints requirement'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  encryptionEffect: {
    type: 'String'
    metadata: {
      displayName: 'Encryption Effect'
      description: 'Policy effect for customer-managed keys requirement'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  publicNetworkAccessEffect: {
    type: 'String'
    metadata: {
      displayName: 'Public Network Access Effect'
      description: 'Policy effect for disabling public network access'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  identityEffect: {
    type: 'String'
    metadata: {
      displayName: 'Identity Effect'
      description: 'Policy effect for user-assigned managed identity requirement'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  computeAuthEffect: {
    type: 'String'
    metadata: {
      displayName: 'Compute Authentication Effect'
      description: 'Policy effect for disabling compute local authentication'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  diagnosticsEffect: {
    type: 'String'
    metadata: {
      displayName: 'Diagnostics Effect'
      description: 'Policy effect for diagnostic settings requirement'
    }
    allowedValues: [
      'AuditIfNotExists'
      'DeployIfNotExists'
      'Disabled'
    ]
    defaultValue: 'AuditIfNotExists'
  }

  // Configuration Parameters
  allowedLocations: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Locations'
      description: 'List of allowed Azure regions for AI Foundry hubs'
    }
    defaultValue: [
      'eastus'
      'eastus2'
      'westus2'
      'westeurope'
      'northeurope'
    ]
  }
  excludedResourceGroups: {
    type: 'Array'
    metadata: {
      displayName: 'Excluded Resource Groups'
      description: 'Resource groups to exclude from all policies'
    }
    defaultValue: []
  }
  minPrivateEndpoints: {
    type: 'Integer'
    metadata: {
      displayName: 'Minimum Private Endpoints'
      description: 'Minimum number of private endpoint connections required'
    }
    defaultValue: 1
  }
  requireKeyRotation: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Key Rotation'
      description: 'Whether to require automatic key rotation'
    }
    defaultValue: true
  }

  // Monitoring Parameters
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
}

resource policySetDefinition 'Microsoft.Authorization/policySetDefinitions@2021-06-01' = {
  name: initiativeName
  properties: {
    displayName: displayName
    description: policyDescription
    policyType: 'Custom'
    metadata: {
      version: version
      category: category
      'SFI-W1-Initiative': true
      Coverage: 'Comprehensive AI Foundry Security and Compliance'
      'Policy-Groups': [
        'Network Security'
        'Data Protection'
        'Identity Management'
        'Compute Security'
        'Monitoring'
      ]
      'Compliance-Frameworks': [
        'SFI-W1'
        'AzTS'
        'NIST 800-53'
        'ISO 27001'
        'SOC 2'
        'FedRAMP'
        'GDPR'
      ]
    }
    parameters: initiativeParameters
    policyDefinitions: [for (policy, index) in policyDefinitions: {
      policyDefinitionId: policy.policyDefinitionId
      policyDefinitionReferenceId: policy.policyDefinitionReferenceId
      groupNames: policy.groupNames
      parameters: policy.parameters
    }]
    policyDefinitionGroups: policyDefinitionGroups
  }
}

output policySetDefinitionId string = policySetDefinition.id
output policySetDefinitionName string = policySetDefinition.name
