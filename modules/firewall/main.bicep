@description('Azure Firewall Premium for AI Enclave - Centralized security and threat protection')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param firewallSubnetId string
param logAnalyticsWorkspaceId string = ''
param enableDnsProxy bool = true
param enableTlsInspection bool = true

// Resource naming
var firewallName = 'fw-${projectName}-${environment}-${location}'
var firewallPolicyName = 'fwpol-${projectName}-${environment}'
var firewallPublicIpName = 'pip-fw-${projectName}-${environment}'

// Public IP for Azure Firewall
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2023-11-01' = {
  name: firewallPublicIpName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Public IP for Azure Firewall'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
    publicIPAddressVersion: 'IPv4'
    dnsSettings: {
      domainNameLabel: 'fw-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
    }
  }
}

// Firewall Policy
resource firewallPolicy 'Microsoft.Network/firewallPolicies@2023-11-01' = {
  name: firewallPolicyName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Firewall policy for AI Enclave'
  }
  properties: {
    sku: {
      tier: 'Premium'
    }
    dnsSettings: {
      servers: []
      enableProxy: enableDnsProxy
    }
    threatIntelMode: 'Alert'
    intrusionDetection: {
      mode: 'Alert'
      configuration: {
        signatureOverrides: []
        bypassTrafficSettings: []
      }
    }
    transportSecurity: {
      certificateAuthority: enableTlsInspection ? {
        keyVaultSecretId: '' // Would be configured with actual certificate
        name: 'ai-enclave-ca'
      } : null
    }
  }
}

// Network Rule Collection Group
resource networkRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = {
  parent: firewallPolicy
  name: 'NetworkRuleCollectionGroup'
  properties: {
    priority: 200
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowAzureServices'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowAzureCloud'
            ipProtocols: ['TCP', 'UDP']
            sourceAddresses: ['10.0.0.0/8']
            destinationAddresses: ['AzureCloud']
            destinationPorts: ['443', '80']
          }
          {
            ruleType: 'NetworkRule'
            name: 'AllowAzureMonitor'
            ipProtocols: ['TCP']
            sourceAddresses: ['10.0.0.0/8']
            destinationAddresses: ['AzureMonitor']
            destinationPorts: ['443']
          }
          {
            ruleType: 'NetworkRule'
            name: 'AllowAzureActiveDirectory'
            ipProtocols: ['TCP']
            sourceAddresses: ['10.0.0.0/8']
            destinationAddresses: ['AzureActiveDirectory']
            destinationPorts: ['443']
          }
        ]
      }
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowTimeServices'
        priority: 110
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'NetworkRule'
            name: 'AllowNTP'
            ipProtocols: ['UDP']
            sourceAddresses: ['10.0.0.0/8']
            destinationAddresses: ['*']
            destinationPorts: ['123']
          }
        ]
      }
    ]
  }
}

// Application Rule Collection Group
resource applicationRuleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2023-11-01' = {
  parent: firewallPolicy
  name: 'ApplicationRuleCollectionGroup'
  properties: {
    priority: 300
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: 'AllowAzureServices'
        priority: 100
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: 'AllowAzureOpenAI'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: ['10.1.0.0/16'] // AI Services spoke
            targetFqdns: ['*.openai.azure.com', '*.cognitiveservices.azure.com']
            fqdnTags: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowAzureML'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: ['10.1.0.0/16', '10.2.0.0/16'] // AI Services and Compute spokes
            targetFqdns: ['*.api.azureml.ms', '*.notebooks.azure.net', '*.studio.azureml.net']
            fqdnTags: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowContainerRegistry'
            protocols: [
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: ['10.2.0.0/16'] // Compute spoke
            targetFqdns: ['*.azurecr.io']
            fqdnTags: []
          }
          {
            ruleType: 'ApplicationRule'
            name: 'AllowWindowsUpdate'
            protocols: [
              {
                protocolType: 'Http'
                port: 80
              }
              {
                protocolType: 'Https'
                port: 443
              }
            ]
            sourceAddresses: ['10.0.0.0/8']
            targetFqdns: []
            fqdnTags: ['WindowsUpdate']
          }
        ]
      }
    ]
  }
  dependsOn: [networkRuleCollectionGroup]
}

// Azure Firewall
resource azureFirewall 'Microsoft.Network/azureFirewalls@2023-11-01' = {
  name: firewallName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Centralized firewall for AI Enclave'
  }
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Premium'
    }
    firewallPolicy: {
      id: firewallPolicy.id
    }
    ipConfigurations: [
      {
        name: 'configuration'
        properties: {
          subnet: {
            id: firewallSubnetId
          }
          publicIPAddress: {
            id: firewallPublicIp.id
          }
        }
      }
    ]
    threatIntelMode: 'Alert'
  }
}

// Diagnostic Settings for Firewall
resource firewallDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: azureFirewall
  name: 'firewall-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AzureFirewallApplicationRule'
        enabled: true
      }
      {
        category: 'AzureFirewallNetworkRule'
        enabled: true
      }
      {
        category: 'AzureFirewallDnsProxy'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

// Outputs
output firewallId string = azureFirewall.id
output firewallName string = azureFirewall.name
output firewallPrivateIp string = azureFirewall.properties.ipConfigurations[0].properties.privateIPAddress
output firewallPublicIp string = firewallPublicIp.properties.ipAddress
output firewallPolicyId string = firewallPolicy.id
