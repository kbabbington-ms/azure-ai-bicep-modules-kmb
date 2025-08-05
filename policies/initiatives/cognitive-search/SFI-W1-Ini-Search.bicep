targetScope = 'subscription'

param initiativeName string = 'SFI-W1-Ini-Search'
param displayName string = 'SFI-W1 Azure Cognitive Search Compliance Initiative'
param policyDescription string = 'Comprehensive Azure Cognitive Search security and compliance initiative implementing SFI-W1 standards including network security, data protection, identity management, resource governance, and monitoring controls.'
param category string = 'Search'
param version string = '2.0.0'

// Import policy definitions (these need to be deployed first)
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RequirePrivateEndpoints'
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
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RequireCustomerManagedKeys'
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
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RequireManagedIdentity'
    policyDefinitionReferenceId: 'RequireManagedIdentity'
    groupNames: ['IdentityManagement']
    parameters: {
      effect: {
        value: '[parameters(\'identityEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
      requiredIdentityType: {
        value: '[parameters(\'requiredIdentityType\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RestrictSKUs'
    policyDefinitionReferenceId: 'RestrictSKUs'
    groupNames: ['ResourceGovernance']
    parameters: {
      effect: {
        value: '[parameters(\'skuRestrictionEffect\')]'
      }
      allowedSKUs: {
        value: '[parameters(\'allowedSKUs\')]'
      }
      maxReplicas: {
        value: '[parameters(\'maxReplicas\')]'
      }
      maxPartitions: {
        value: '[parameters(\'maxPartitions\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RequireHTTPS'
    policyDefinitionReferenceId: 'RequireHTTPS'
    groupNames: ['SecureCommunication']
    parameters: {
      effect: {
        value: '[parameters(\'httpsEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
      requireDisableLocalAuth: {
        value: '[parameters(\'requireDisableLocalAuth\')]'
      }
      allowedAuthenticationMethods: {
        value: '[parameters(\'allowedAuthenticationMethods\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-Search-RequireDiagnosticSettings'
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
    }
  }
]

// Policy group definitions
var policyDefinitionGroups = [
  {
    name: 'NetworkSecurity'
    displayName: 'Network Security Controls'
    description: 'Policies ensuring secure network configuration and zero-trust architecture'
  }
  {
    name: 'DataProtection'
    displayName: 'Data Protection Controls'
    description: 'Policies ensuring data encryption, key management, and data sovereignty'
  }
  {
    name: 'IdentityManagement'
    displayName: 'Identity and Access Management'
    description: 'Policies ensuring proper identity configuration and secure access'
  }
  {
    name: 'ResourceGovernance'
    displayName: 'Resource Governance'
    description: 'Policies ensuring cost control, resource standards, and capacity management'
  }
  {
    name: 'SecureCommunication'
    displayName: 'Secure Communication'
    description: 'Policies ensuring secure protocols and authentication methods'
  }
  {
    name: 'Monitoring'
    displayName: 'Monitoring and Compliance'
    description: 'Policies ensuring comprehensive logging, monitoring, and audit trail'
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
  enableResourceGovernance: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Resource Governance Policies'
      description: 'Enable or disable resource governance policy group'
    }
    defaultValue: true
  }
  enableSecureCommunication: {
    type: 'Boolean'
    metadata: {
      displayName: 'Enable Secure Communication Policies'
      description: 'Enable or disable secure communication policy group'
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
  identityEffect: {
    type: 'String'
    metadata: {
      displayName: 'Identity Effect'
      description: 'Policy effect for managed identity requirement'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  skuRestrictionEffect: {
    type: 'String'
    metadata: {
      displayName: 'SKU Restriction Effect'
      description: 'Policy effect for SKU restrictions'
    }
    allowedValues: [
      'Audit'
      'Deny'
      'Disabled'
    ]
    defaultValue: 'Audit'
  }
  httpsEffect: {
    type: 'String'
    metadata: {
      displayName: 'HTTPS Effect'
      description: 'Policy effect for secure communication requirement'
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
      description: 'List of allowed Azure regions for Search services'
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
  requiredIdentityType: {
    type: 'String'
    metadata: {
      displayName: 'Required Identity Type'
      description: 'Required managed identity type for search services'
    }
    allowedValues: [
      'SystemAssigned'
      'UserAssigned'
      'SystemAssigned,UserAssigned'
    ]
    defaultValue: 'SystemAssigned'
  }
  allowedSKUs: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed SKUs'
      description: 'Approved SKU names for Search services'
    }
    defaultValue: [
      'basic'
      'standard'
      'standard2'
      'standard3'
    ]
  }
  maxReplicas: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Replicas'
      description: 'Maximum replicas allowed for search services'
    }
    defaultValue: 12
  }
  maxPartitions: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Partitions'
      description: 'Maximum partitions allowed for search services'
    }
    defaultValue: 12
  }
  requireDisableLocalAuth: {
    type: 'Boolean'
    metadata: {
      displayName: 'Require Disable Local Auth'
      description: 'Whether to require disabling local authentication'
    }
    defaultValue: true
  }
  allowedAuthenticationMethods: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Authentication Methods'
      description: 'Approved authentication methods for search services'
    }
    defaultValue: [
      'aadOrApiKey'
      'aad'
    ]
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
      'OperationLogs'
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
    defaultValue: 'SearchDiagnosticSettings'
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
      Coverage: 'Comprehensive Search Security and Compliance'
      'Policy-Groups': [
        'Network Security'
        'Data Protection'
        'Identity Management'
        'Resource Governance'
        'Secure Communication'
        'Monitoring'
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
