@description('Network Security Groups for AI Enclave - Zero-trust security rules')
param location string = resourceGroup().location
param environment string
param projectName string
param logAnalyticsWorkspaceId string = ''

// Hub NSG - Shared Services
resource hubNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-hub-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Hub network security'
  }
  properties: {
    securityRules: [
      // Azure Bastion inbound rules
      {
        name: 'AllowBastionInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['22', '3389']
          sourceAddressPrefix: '10.0.1.0/24' // Bastion subnet
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      // Azure Firewall management
      {
        name: 'AllowFirewallManagement'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureFirewallManager'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      // Deny all other inbound
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
      // Allow outbound to Azure services
      {
        name: 'AllowAzureServicesOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

// AI Services NSG - Restrictive rules for AI workloads
resource aiServicesNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-ai-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'AI services network security'
  }
  properties: {
    securityRules: [
      // Allow inbound from compute subnets
      {
        name: 'AllowComputeInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.2.0.0/16' // Compute VNet
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      // Allow inbound from data services
      {
        name: 'AllowDataServicesInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '10.3.0.0/16' // Data VNet
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      // Deny all other inbound
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
      // Allow outbound to Azure AI services
      {
        name: 'AllowAzureAIOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'CognitiveServicesManagement'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Compute NSG - Container and VM security
resource computeNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-compute-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Compute services network security'
  }
  properties: {
    securityRules: [
      // Allow inbound from application gateway
      {
        name: 'AllowAppGatewayInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['80', '443']
          sourceAddressPrefix: '10.0.5.0/24' // App Gateway subnet
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      // Allow AKS API server access
      {
        name: 'AllowAKSApiServer'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'AzureCloud'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      // Allow outbound to AI services
      {
        name: 'AllowAIServicesOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '10.1.0.0/16' // AI services VNet
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

// Data Services NSG - Database and storage security
resource dataServicesNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: 'nsg-data-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Data services network security'
  }
  properties: {
    securityRules: [
      // Allow inbound from AI services and compute
      {
        name: 'AllowInternalInbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRanges: ['1433', '5432', '6379', '443']
          sourceAddressPrefixes: ['10.1.0.0/16', '10.2.0.0/16'] // AI and Compute VNets
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      // Deny all other inbound
      {
        name: 'DenyAllInbound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 4000
          direction: 'Inbound'
        }
      }
      // Allow outbound for backup and replication
      {
        name: 'AllowBackupOutbound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Storage'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
    ]
  }
}

// NSG Flow Logs (requires Network Watcher)
resource hubNsgFlowLogs 'Microsoft.Network/networkWatchers/flowLogs@2023-11-01' = if (!empty(logAnalyticsWorkspaceId)) {
  name: 'NetworkWatcher_${location}/fl-hub-nsg-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Hub NSG flow logs'
  }
  properties: {
    targetResourceId: hubNsg.id
    storageId: '' // Would need storage account ID
    enabled: true
    retentionPolicy: {
      days: 30
      enabled: true
    }
    format: {
      type: 'JSON'
      version: 2
    }
    flowAnalyticsConfiguration: {
      networkWatcherFlowAnalyticsConfiguration: {
        enabled: true
        workspaceResourceId: logAnalyticsWorkspaceId
        trafficAnalyticsInterval: 10
      }
    }
  }
}

// Outputs
output hubNsgId string = hubNsg.id
output aiServicesNsgId string = aiServicesNsg.id
output computeNsgId string = computeNsg.id
output dataServicesNsgId string = dataServicesNsg.id
output nsgIds object = {
  hub: hubNsg.id
  aiServices: aiServicesNsg.id
  compute: computeNsg.id
  dataServices: dataServicesNsg.id
}
