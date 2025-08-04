@description('Compute infrastructure for AI Enclave - VMs, Scale Sets, Function Apps')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param subnetId string
param logAnalyticsWorkspaceId string = ''
param vmAdminUsername string = 'azureuser'

@secure()
param vmAdminPassword string

param vmSize string = 'Standard_D4s_v3'
param instanceCount int = 2

// Resource naming
var vmssName = 'vmss-${projectName}-${environment}-${location}'
var functionAppName = 'func-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var appServicePlanName = 'asp-${projectName}-${environment}-${location}'
var storageAccountName = 'stfunc${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}'

// Storage Account for Function App
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Storage for Function App'
  }
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        blob: {
          enabled: true
          keyType: 'Account'
        }
        file: {
          enabled: true
          keyType: 'Account'
        }
      }
      keySource: 'Microsoft.Storage'
      requireInfrastructureEncryption: true
    }
    accessTier: 'Hot'
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// App Service Plan for Function App
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServicePlanName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'App Service Plan for Function Apps'
  }
  sku: {
    name: 'EP1'
    tier: 'ElasticPremium'
    family: 'EP'
    capacity: 1
  }
  kind: 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: true
    maximumElasticWorkerCount: 10
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Function App
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Function App for AI processing'
  }
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    publicNetworkAccess: 'Disabled'
    virtualNetworkSubnetId: subnetId
    vnetRouteAllEnabled: true
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      use32BitWorkerProcess: false
      netFrameworkVersion: 'v6.0'
      powerShellVersion: '7.2'
      functionAppScaleLimit: 10
      minimumElasticInstanceCount: 1
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: ''
        }
      ]
      cors: {
        allowedOrigins: []
        supportCredentials: false
      }
      ipSecurityRestrictions: [
        {
          action: 'Deny'
          priority: 2147483647
          name: 'Deny all'
          description: 'Deny all access'
        }
      ]
      scmIpSecurityRestrictions: [
        {
          action: 'Deny'
          priority: 2147483647
          name: 'Deny all'
          description: 'Deny all access'
        }
      ]
      scmIpSecurityRestrictionsUseMain: false
    }
  }
}

// Virtual Machine Scale Set
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: vmssName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'VM Scale Set for AI training workloads'
  }
  sku: {
    name: vmSize
    capacity: instanceCount
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    upgradePolicy: {
      mode: 'Automatic'
      automaticOSUpgradePolicy: {
        enableAutomaticOSUpgrade: true
        disableAutomaticRollback: false
      }
    }
    virtualMachineProfile: {
      osProfile: {
        computerNamePrefix: 'vm-ai'
        adminUsername: vmAdminUsername
        adminPassword: vmAdminPassword
        windowsConfiguration: {
          enableAutomaticUpdates: true
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'AutomaticByOS'
            automaticByPlatformSettings: {
              rebootSetting: 'IfRequired'
            }
          }
        }
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: 'Premium_LRS'
          }
          diskSizeGB: 128
        }
        imageReference: {
          publisher: 'MicrosoftWindowsServer'
          offer: 'WindowsServer'
          sku: '2022-datacenter-azure-edition'
          version: 'latest'
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-config'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                    privateIPAddressVersion: 'IPv4'
                  }
                }
              ]
            }
          }
        ]
      }
      securityProfile: {
        securityType: 'TrustedLaunch'
        uefiSettings: {
          secureBootEnabled: true
          vTpmEnabled: true
        }
      }
      extensionProfile: {
        extensions: [
          {
            name: 'AADLoginForWindows'
            properties: {
              publisher: 'Microsoft.Azure.ActiveDirectory'
              type: 'AADLoginForWindows'
              typeHandlerVersion: '1.0'
              autoUpgradeMinorVersion: true
            }
          }
          {
            name: 'AzureMonitorWindowsAgent'
            properties: {
              publisher: 'Microsoft.Azure.Monitor'
              type: 'AzureMonitorWindowsAgent'
              typeHandlerVersion: '1.0'
              autoUpgradeMinorVersion: true
              enableAutomaticUpgrade: true
            }
          }
        ]
      }
    }
    automaticRepairsPolicy: {
      enabled: true
      gracePeriod: 'PT30M'
    }
    scaleInPolicy: {
      rules: ['NewestVM']
    }
  }
  zones: ['1', '2', '3']
}

// Auto Scale Settings for VMSS
resource autoScaleSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = {
  name: 'autoscale-${vmssName}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Auto-scale settings for VMSS'
  }
  properties: {
    enabled: true
    targetResourceUri: vmss.id
    profiles: [
      {
        name: 'Default'
        capacity: {
          minimum: '1'
          maximum: '10'
          default: '2'
        }
        rules: [
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'Microsoft.Compute/virtualMachineScaleSets'
              metricResourceUri: vmss.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'GreaterThan'
              threshold: 75
            }
            scaleAction: {
              direction: 'Increase'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
          {
            metricTrigger: {
              metricName: 'Percentage CPU'
              metricNamespace: 'Microsoft.Compute/virtualMachineScaleSets'
              metricResourceUri: vmss.id
              timeGrain: 'PT1M'
              statistic: 'Average'
              timeWindow: 'PT5M'
              timeAggregation: 'Average'
              operator: 'LessThan'
              threshold: 25
            }
            scaleAction: {
              direction: 'Decrease'
              type: 'ChangeCount'
              value: '1'
              cooldown: 'PT5M'
            }
          }
        ]
      }
    ]
  }
}

// Diagnostic Settings
resource vmssDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: vmss
  name: 'vmss-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource functionAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: functionApp
  name: 'function-app-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'FunctionAppLogs'
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
output vmssId string = vmss.id
output vmssName string = vmss.name
output functionAppId string = functionApp.id
output functionAppName string = functionApp.name
output functionAppDefaultHostName string = functionApp.properties.defaultHostName
output appServicePlanId string = appServicePlan.id
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
