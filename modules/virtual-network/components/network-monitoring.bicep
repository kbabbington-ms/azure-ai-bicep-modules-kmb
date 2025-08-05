@description('Network Watcher and monitoring for AI Enclave')
param location string = resourceGroup().location
param environment string
param projectName string
param logAnalyticsWorkspaceId string
param storageAccountId string
param networkSecurityGroups array

// Network Watcher (Auto-created in most regions, but ensuring it exists)
resource networkWatcher 'Microsoft.Network/networkWatchers@2023-11-01' = {
  name: 'NetworkWatcher_${location}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Network monitoring and diagnostics'
  }
  properties: {}
}

// Connection Monitor for AI Services connectivity
resource connectionMonitor 'Microsoft.Network/networkWatchers/connectionMonitors@2023-11-01' = {
  parent: networkWatcher
  name: 'cm-ai-services-${projectName}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'AI services connectivity monitoring'
  }
  properties: {
    endpoints: [
      {
        name: 'ai-services-endpoint'
        type: 'AzureSubnet'
        resourceId: '' // Would be populated with AI services subnet ID
        scope: {
          include: [
            {
              address: '10.1.0.0/16'
            }
          ]
        }
      }
      {
        name: 'azure-openai-endpoint'
        type: 'ExternalAddress'
        address: 'api.openai.azure.com'
      }
    ]
    testConfigurations: [
      {
        name: 'ai-services-test'
        protocol: 'Tcp'
        testFrequencySec: 30
        tcpConfiguration: {
          port: 443
          disableTraceRoute: false
        }
        successThreshold: {
          checksFailedPercent: 5
          roundTripTimeMs: 1000
        }
      }
    ]
    testGroups: [
      {
        name: 'ai-services-connectivity'
        destinations: ['azure-openai-endpoint']
        sources: ['ai-services-endpoint']
        testConfigurations: ['ai-services-test']
      }
    ]
    outputs: [
      {
        type: 'Workspace'
        workspaceSettings: {
          workspaceResourceId: logAnalyticsWorkspaceId
        }
      }
    ]
  }
}

// Flow logs for each NSG
resource nsgFlowLogs 'Microsoft.Network/networkWatchers/flowLogs@2023-11-01' = [for (nsg, index) in networkSecurityGroups: {
  parent: networkWatcher
  name: 'fl-${last(split(nsg.id, '/'))}-${environment}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'NSG flow logs'
  }
  properties: {
    targetResourceId: nsg.id
    storageId: storageAccountId
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
}]

// Outputs
output networkWatcherId string = networkWatcher.id
output connectionMonitorId string = connectionMonitor.id
output flowLogIds array = [for i in range(0, length(networkSecurityGroups)): nsgFlowLogs[i].id]
