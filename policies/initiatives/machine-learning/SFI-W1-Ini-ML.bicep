targetScope = 'subscription'

param initiativeName string = 'SFI-W1-Ini-ML'
param displayName string = 'SFI-W1 Azure Machine Learning Compliance Initiative'
param policyDescription string = 'Comprehensive Azure Machine Learning security and compliance initiative implementing SFI-W1 standards including network security, data protection, identity management, resource governance, and monitoring controls.'
param category string = 'Machine Learning'
param version string = '2.0.0'

// Import policy definitions (these need to be deployed first)
var policyDefinitions = [
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RequirePrivateEndpoints'
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
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RequireCustomerManagedKeys'
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
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RequireManagedIdentity'
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
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RestrictSKUs'
    policyDefinitionReferenceId: 'RestrictSKUs'
    groupNames: ['ResourceGovernance']
    parameters: {
      effect: {
        value: '[parameters(\'skuRestrictionEffect\')]'
      }
      allowedVMSizes: {
        value: '[parameters(\'allowedVMSizes\')]'
      }
      maxNodes: {
        value: '[parameters(\'maxNodes\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RequireDatastoreEncryption'
    policyDefinitionReferenceId: 'RequireDatastoreEncryption'
    groupNames: ['DataProtection']
    parameters: {
      effect: {
        value: '[parameters(\'datastoreEncryptionEffect\')]'
      }
      excludedResourceGroups: {
        value: '[parameters(\'excludedResourceGroups\')]'
      }
      allowedDatastoreTypes: {
        value: '[parameters(\'allowedDatastoreTypes\')]'
      }
    }
  }
  {
    policyDefinitionId: '/subscriptions/{subscription-id}/providers/Microsoft.Authorization/policyDefinitions/SFI-W1-Def-ML-RequireDiagnosticSettings'
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
  datastoreEncryptionEffect: {
    type: 'String'
    metadata: {
      displayName: 'Datastore Encryption Effect'
      description: 'Policy effect for datastore encryption requirement'
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
      description: 'List of allowed Azure regions for ML workspaces'
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
      description: 'Required managed identity type for workspaces'
    }
    allowedValues: [
      'SystemAssigned'
      'UserAssigned'
      'SystemAssigned,UserAssigned'
    ]
    defaultValue: 'SystemAssigned'
  }
  allowedVMSizes: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed VM Sizes'
      description: 'Approved VM sizes for ML compute'
    }
    defaultValue: [
      'Standard_DS2_v2'
      'Standard_DS3_v2'
      'Standard_DS4_v2'
      'Standard_DS11_v2'
      'Standard_DS12_v2'
      'Standard_DS13_v2'
      'Standard_DS14_v2'
      'Standard_NC6'
      'Standard_NC12'
      'Standard_NC24'
    ]
  }
  maxNodes: {
    type: 'Integer'
    metadata: {
      displayName: 'Maximum Nodes'
      description: 'Maximum nodes allowed in compute clusters'
    }
    defaultValue: 10
  }
  allowedDatastoreTypes: {
    type: 'Array'
    metadata: {
      displayName: 'Allowed Datastore Types'
      description: 'Approved datastore types for ML workspaces'
    }
    defaultValue: [
      'AzureBlob'
      'AzureFile'
      'AzureDataLakeGen2'
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
    defaultValue: 'MLDiagnosticSettings'
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
      Coverage: 'Comprehensive ML Security and Compliance'
      'Policy-Groups': [
        'Network Security'
        'Data Protection'
        'Identity Management'
        'Resource Governance'
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
