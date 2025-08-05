// ============================================================================
// Azure Compute Infrastructure - Enterprise Security Configuration
// ============================================================================
// Version: 1.0
// Last Modified: 2025-08-04
// Description: Comprehensive compute infrastructure including VM Scale Sets,
//              Function Apps, and App Service Plans with enterprise security
// ============================================================================

metadata name = 'Azure Compute Infrastructure - Enterprise Edition'
metadata description = 'Enterprise compute infrastructure with VMs, scale sets, function apps, and advanced security'
metadata author = 'Azure AI Platform Team'
metadata version = '1.0.0'

// ============================================================================
// BASIC CONFIGURATION PARAMETERS
// ============================================================================

// Azure region where all resources will be deployed
// Critical for data residency and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet your data sovereignty requirements
@description('Location for all resources')
param location string = resourceGroup().location

// Environment designation for resource tagging and configuration differentiation
// Used to apply environment-specific security policies and access controls
// 🔒 SECURITY ENHANCEMENT: Use different encryption keys and access policies per environment
@description('Environment name for resource naming and tagging')
@allowed(['dev', 'test', 'staging', 'prod'])
param environment string = 'dev'

// Project identifier for resource naming and organizational purposes
// Used in resource naming conventions and cost allocation
@description('Project name for resource naming and tagging')
@minLength(2)
@maxLength(10)
param projectName string = 'ai-enclave'

// Resource tags for governance, cost management, and compliance tracking
// Essential for enterprise resource management and security auditing
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Tags to apply to all resources')
param tags object = {}

// ============================================================================
// NETWORK CONFIGURATION
// ============================================================================

// Subnet resource ID where compute resources will be deployed
// Must be a subnet with adequate address space and appropriate security controls
// 🔒 SECURITY ENHANCEMENT: Use dedicated subnet with NSG rules and no public IP access
@description('Subnet resource ID for compute resources')
param subnetId string

// Enable public IP addresses for VM Scale Set instances
// Controls whether VMs have direct internet connectivity
// 🔒 SECURITY ENHANCEMENT: Always set to false for enterprise security and use private connectivity
@description('Enable public IP addresses for VMSS instances')
param enableVmssPublicIp bool = false

// Network security group resource ID for additional VM protection
// Provides additional network-level security controls
// 🔒 SECURITY ENHANCEMENT: Use NSG with restrictive rules for compute workloads
@description('Network Security Group resource ID for VMs')
param networkSecurityGroupId string = ''

// ============================================================================
// VIRTUAL MACHINE SCALE SET CONFIGURATION
// ============================================================================

// Azure VM size determining CPU, memory, and storage characteristics
// Controls the performance and cost of VM instances
// 🔒 SECURITY ENHANCEMENT: Use sizes with encryption support and sufficient resources
@description('VM size for Scale Set instances')
@allowed([
  'Standard_D2s_v3'    // 2 vCPU, 8 GB RAM - Development
  'Standard_D4s_v3'    // 4 vCPU, 16 GB RAM - Standard workloads
  'Standard_D8s_v3'    // 8 vCPU, 32 GB RAM - Intensive workloads
  'Standard_D16s_v3'   // 16 vCPU, 64 GB RAM - High-performance
  'Standard_E4s_v3'    // 4 vCPU, 32 GB RAM - Memory optimized
  'Standard_E8s_v3'    // 8 vCPU, 64 GB RAM - Memory intensive
  'Standard_F4s_v2'    // 4 vCPU, 8 GB RAM - Compute optimized
  'Standard_F8s_v2'    // 8 vCPU, 16 GB RAM - CPU intensive
])
param vmSize string = 'Standard_D4s_v3'

// Initial number of VM instances in the Scale Set
// Determines the baseline capacity for compute workloads
@description('Initial number of VM instances in Scale Set')
@minValue(0)
@maxValue(100)
param instanceCount int = 2

// Administrator username for VM access
// Used for local admin account creation (when local auth is enabled)
// 🔒 SECURITY ENHANCEMENT: Use Azure AD authentication instead of local accounts
@description('VM administrator username')
@minLength(1)
@maxLength(20)
param vmAdminUsername string = 'azureuser'

// Administrator password for VM access
// Required for local admin account (when local auth is enabled)
// 🔒 SECURITY ENHANCEMENT: Use strong passwords and prefer Azure AD authentication
@description('VM administrator password')
@secure()
@minLength(12)
param vmAdminPassword string

// Operating system type for VM instances
// Determines the OS family and available security features
// 🔒 SECURITY ENHANCEMENT: Use latest OS versions with security updates
@description('Operating system type for VMs')
@allowed(['Windows', 'Linux'])
param osType string = 'Windows'

// Specific OS image configuration for Windows VMs
// Controls the exact OS version and publisher
// 🔒 SECURITY ENHANCEMENT: Use latest security-hardened images
@description('Windows OS image configuration')
param windowsImageReference object = {
  publisher: 'MicrosoftWindowsServer'
  offer: 'WindowsServer'
  sku: '2022-datacenter-azure-edition'
  version: 'latest'
}

// Specific OS image configuration for Linux VMs
// Controls the exact OS version and publisher
// 🔒 SECURITY ENHANCEMENT: Use hardened Linux distributions with security updates
@description('Linux OS image configuration')
param linuxImageReference object = {
  publisher: 'Canonical'
  offer: '0001-com-ubuntu-server-jammy'
  sku: '22_04-lts-gen2'
  version: 'latest'
}

// OS disk size in GB for VM instances
// Determines the storage capacity for the operating system
@description('OS disk size in GB')
@minValue(30)
@maxValue(2048)
param osDiskSizeGB int = 128

// Storage account type for VM OS disks
// Controls performance and redundancy characteristics
// 🔒 SECURITY ENHANCEMENT: Use Premium_LRS for better performance and encryption support
@description('Storage account type for OS disks')
@allowed(['Standard_LRS', 'Premium_LRS', 'StandardSSD_LRS', 'UltraSSD_LRS'])
param osDiskStorageType string = 'Premium_LRS'

// ============================================================================
// SCALE SET ADVANCED CONFIGURATION
// ============================================================================

// Enable automatic OS upgrades for security patches
// Provides automated security update management
// 🔒 SECURITY ENHANCEMENT: Always enable for automated security patching
@description('Enable automatic OS upgrades')
param enableAutomaticOSUpgrade bool = true

// Enable accelerated networking for improved network performance
// Provides SR-IOV to VMs for better network performance
// 🔒 SECURITY ENHANCEMENT: Enable for better network security and performance
@description('Enable accelerated networking')
param enableAcceleratedNetworking bool = true

// Enable Trusted Launch security features for VMs
// Provides secure boot and virtual TPM capabilities
// 🔒 SECURITY ENHANCEMENT: Always enable for enhanced VM security
@description('Enable Trusted Launch security features')
param enableTrustedLaunch bool = true

// Zone distribution for high availability across availability zones
// Controls deployment across Azure availability zones
// 🔒 SECURITY ENHANCEMENT: Use zone distribution for resilience against failures
@description('Availability zones for VM deployment')
param availabilityZones array = ['1', '2', '3']

// ============================================================================
// AUTO-SCALING CONFIGURATION
// ============================================================================

// Enable auto-scaling for the VM Scale Set
// Provides automatic scaling based on metrics and schedules
@description('Enable auto-scaling for VMSS')
param enableAutoScaling bool = true

// Minimum number of VM instances for auto-scaling
// Sets the lower bound for automatic scaling operations
@description('Minimum number of instances for auto-scaling')
@minValue(0)
@maxValue(50)
param minInstanceCount int = 1

// Maximum number of VM instances for auto-scaling
// Sets the upper bound for automatic scaling operations
@description('Maximum number of instances for auto-scaling')
@minValue(1)
@maxValue(100)
param maxInstanceCount int = 10

// CPU percentage threshold for scale-up operations
// Triggers additional instances when CPU usage exceeds this value
@description('CPU percentage threshold for scaling up')
@minValue(50)
@maxValue(95)
param scaleUpCpuThreshold int = 75

// CPU percentage threshold for scale-down operations
// Triggers instance removal when CPU usage falls below this value
@description('CPU percentage threshold for scaling down')
@minValue(5)
@maxValue(50)
param scaleDownCpuThreshold int = 25

// ============================================================================
// FUNCTION APP CONFIGURATION
// ============================================================================

// Enable Azure Function App deployment
// Controls whether Function App resources are created
@description('Enable Function App deployment')
param enableFunctionApp bool = true

// App Service Plan SKU for Function App hosting
// Determines the performance and features available to Function Apps
// 🔒 SECURITY ENHANCEMENT: Use Premium plans for VNet integration and advanced security
@description('App Service Plan SKU for Function App')
@allowed([
  'Y1'   // Consumption plan
  'EP1'  // Elastic Premium 1
  'EP2'  // Elastic Premium 2
  'EP3'  // Elastic Premium 3
  'P1v2' // Premium v2
  'P2v2' // Premium v2
  'P3v2' // Premium v2
])
param functionAppPlanSku string = 'EP1'

// .NET runtime version for Function App
// Controls the .NET framework version used by functions
// 🔒 SECURITY ENHANCEMENT: Use latest supported versions for security updates
@description('Function App .NET runtime version')
@allowed(['v6.0', 'v8.0'])
param functionAppNetFrameworkVersion string = 'v8.0'

// Function App runtime version
// Controls the Azure Functions runtime version
@description('Function App runtime version')
@allowed(['~3', '~4'])
param functionsExtensionVersion string = '~4'

// Function App worker runtime
// Determines the language runtime for function execution
@description('Function App worker runtime')
@allowed(['dotnet', 'node', 'python', 'java', 'powershell'])
param functionsWorkerRuntime string = 'dotnet'

// ============================================================================
// IDENTITY CONFIGURATION
// ============================================================================

// Enable system-assigned managed identity for VM Scale Set
// Provides an identity for secure Azure service authentication
// 🔒 SECURITY ENHANCEMENT: Use managed identities instead of service principal credentials
@description('Enable system-assigned managed identity for VMSS')
param enableVmssSystemManagedIdentity bool = true

// Enable system-assigned managed identity for Function App
// Provides an identity for secure Azure service authentication
// 🔒 SECURITY ENHANCEMENT: Use managed identities for Function App authentication
@description('Enable system-assigned managed identity for Function App')
param enableFunctionAppSystemManagedIdentity bool = true

// User-assigned managed identity resource IDs
// Allows for shared identities across multiple resources
// 🔒 SECURITY ENHANCEMENT: Use dedicated identities for different access patterns
@description('User-assigned managed identity resource IDs')
param userAssignedIdentities array = []

// ============================================================================
// ENCRYPTION CONFIGURATION
// ============================================================================

// Enable customer-managed encryption for VM disks
// Provides customer control over encryption keys
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments requiring key control
@description('Enable customer-managed encryption for VM disks')
param enableCustomerManagedEncryption bool = false

// Disk encryption set resource ID for customer-managed keys
// Used for encrypting VM disks with customer-controlled keys
// 🔒 SECURITY ENHANCEMENT: Use disk encryption sets with HSM-backed keys
@description('Disk encryption set resource ID')
param diskEncryptionSetId string = ''

// Enable infrastructure encryption for enhanced security
// Provides double encryption for data at rest
// 🔒 SECURITY ENHANCEMENT: Enable for maximum data protection
@description('Enable infrastructure encryption')
param requireInfrastructureEncryption bool = true

// ============================================================================
// MONITORING AND DIAGNOSTICS
// ============================================================================

// Log Analytics workspace resource ID for diagnostic data collection
// Used for centralized logging, monitoring, and security analytics
// 🔒 SECURITY ENHANCEMENT: Always configure for security monitoring and compliance auditing
@description('Log Analytics workspace resource ID for diagnostics')
param logAnalyticsWorkspaceId string = ''

// Application Insights connection string for application monitoring
// Provides deep application performance and usage analytics
// 🔒 SECURITY ENHANCEMENT: Monitor for security events and performance anomalies
@description('Application Insights connection string')
param applicationInsightsConnectionString string = ''

// Enable Azure Monitor Agent installation on VMs
// Provides advanced monitoring and security data collection
// 🔒 SECURITY ENHANCEMENT: Essential for security monitoring and compliance
@description('Enable Azure Monitor Agent on VMs')
param enableAzureMonitorAgent bool = true

// ============================================================================
// STORAGE CONFIGURATION
// ============================================================================

// Storage account type for Function App storage requirements
// Controls performance and redundancy for Function App storage
// 🔒 SECURITY ENHANCEMENT: Use Standard_GRS for production workloads
@description('Storage account type for Function App')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS'])
param storageAccountType string = 'Standard_LRS'

// Enable secure transfer for storage account (HTTPS only)
// Enforces encryption in transit for all storage operations
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise security
@description('Enable secure transfer for storage account')
param enableStorageSecureTransfer bool = true

// Minimum TLS version for storage account access
// Controls the minimum encryption level for storage connections
// 🔒 SECURITY ENHANCEMENT: Use TLS 1.2 minimum for strong encryption
@description('Minimum TLS version for storage account')
@allowed(['TLS1_0', 'TLS1_1', 'TLS1_2'])
param storageMinimumTlsVersion string = 'TLS1_2'

// ============================================================================
// SECURITY CONFIGURATION
// ============================================================================

// Enable Azure AD authentication for VM login
// Provides centralized identity management and conditional access
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise identity management
@description('Enable Azure AD authentication for VM login')
param enableAzureAdAuth bool = true

// Enable VM encryption at host
// Provides encryption for temporary disks and OS/data disk caches
// 🔒 SECURITY ENHANCEMENT: Enable for comprehensive data protection
@description('Enable encryption at host for VMs')
param enableEncryptionAtHost bool = false

// IP restrictions for Function App access
// Controls which IP addresses can access the Function App
// 🔒 SECURITY ENHANCEMENT: Restrict access to known IP ranges only
@description('IP restrictions for Function App access')
param functionAppIpRestrictions array = [
  {
    action: 'Deny'
    priority: 2147483647
    name: 'Deny all'
    description: 'Deny all access'
  }
]

// Enable private endpoints for Function App
// Provides private network connectivity without public internet exposure
// 🔒 SECURITY ENHANCEMENT: Always enable for enterprise deployments
@description('Enable private endpoints for Function App')
param enableFunctionAppPrivateEndpoint bool = false

// ============================================================================
// RESOURCE NAMING
// ============================================================================

// Resource naming follows Azure naming conventions with environment and location
var resourceSuffix = '${projectName}-${environment}-${location}'
var resourceSuffixShort = '${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}'

// VM Scale Set naming
var vmssName = 'vmss-${resourceSuffix}'

// Function App related naming
var functionAppName = 'func-${projectName}-${environment}-${uniqueString(resourceGroup().id)}'
var appServicePlanName = 'asp-${resourceSuffix}'
var storageAccountName = take('stfunc${resourceSuffixShort}', 24) // Storage names max 24 chars

// Security and monitoring naming
var autoScaleSettingsName = 'autoscale-${vmssName}'
var vmssDiagnosticsName = 'vmss-diagnostics'
var functionAppDiagnosticsName = 'function-app-diagnostics'

// ============================================================================
// RESOURCE IMPLEMENTATIONS
// ============================================================================

// Storage Account for Function App with enhanced security configuration
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = if (enableFunctionApp) {
  name: storageAccountName
  location: location
  tags: union({
    Environment: environment
    Project: projectName
    Purpose: 'Storage for Function App'
  }, tags)
  sku: {
    name: storageAccountType
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: storageMinimumTlsVersion
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    supportsHttpsTrafficOnly: enableStorageSecureTransfer
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
      requireInfrastructureEncryption: requireInfrastructureEncryption
    }
    accessTier: 'Hot'
    publicNetworkAccess: enableFunctionAppPrivateEndpoint ? 'Disabled' : 'Enabled'
    networkAcls: {
      defaultAction: 'Deny'
      bypass: 'AzureServices'
    }
  }
}

// App Service Plan for Function App with configurable SKU
resource appServicePlan 'Microsoft.Web/serverfarms@2022-09-01' = if (enableFunctionApp) {
  name: appServicePlanName
  location: location
  tags: union({
    Environment: environment
    Project: projectName
    Purpose: 'App Service Plan for Function Apps'
  }, tags)
  sku: {
    name: functionAppPlanSku
    tier: functionAppPlanSku == 'Y1' ? 'Dynamic' : functionAppPlanSku == 'EP1' ? 'ElasticPremium' : functionAppPlanSku == 'EP2' ? 'ElasticPremium' : functionAppPlanSku == 'EP3' ? 'ElasticPremium' : 'PremiumV2'
    family: functionAppPlanSku == 'Y1' ? 'Y' : contains(functionAppPlanSku, 'EP') ? 'EP' : 'Pv2'
    capacity: functionAppPlanSku == 'Y1' ? 0 : 1
  }
  kind: functionAppPlanSku == 'Y1' ? 'functionapp' : 'elastic'
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: functionAppPlanSku != 'Y1'
    maximumElasticWorkerCount: functionAppPlanSku != 'Y1' ? 10 : null
    isSpot: false
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Function App with comprehensive security configuration
resource functionApp 'Microsoft.Web/sites@2022-09-01' = if (enableFunctionApp) {
  name: functionAppName
  location: location
  tags: union({
    Environment: environment
    Project: projectName
    Purpose: 'Function App for AI processing'
  }, tags)
  kind: 'functionapp'
  identity: {
    type: enableFunctionAppSystemManagedIdentity && empty(userAssignedIdentities) ? 'SystemAssigned' : !enableFunctionAppSystemManagedIdentity && !empty(userAssignedIdentities) ? 'UserAssigned' : enableFunctionAppSystemManagedIdentity && !empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'None'
    userAssignedIdentities: !empty(userAssignedIdentities) ? reduce(userAssignedIdentities, {}, (cur, next) => union(cur, { '${next}': {} })) : null
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    publicNetworkAccess: enableFunctionAppPrivateEndpoint ? 'Disabled' : 'Enabled'
    virtualNetworkSubnetId: functionAppPlanSku != 'Y1' ? subnetId : null
    vnetRouteAllEnabled: functionAppPlanSku != 'Y1'
    siteConfig: {
      ftpsState: 'Disabled'
      minTlsVersion: '1.2'
      scmMinTlsVersion: '1.2'
      use32BitWorkerProcess: false
      netFrameworkVersion: functionAppNetFrameworkVersion
      powerShellVersion: functionsWorkerRuntime == 'powershell' ? '7.2' : null
      functionAppScaleLimit: functionAppPlanSku != 'Y1' ? 10 : 200
      minimumElasticInstanceCount: functionAppPlanSku != 'Y1' ? 1 : null
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount!.name};AccountKey=${storageAccount!.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount!.name};AccountKey=${storageAccount!.listKeys().keys[0].value};EndpointSuffix=${az.environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: functionsExtensionVersion
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionsWorkerRuntime
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: applicationInsightsConnectionString
        }
      ]
      cors: {
        allowedOrigins: []
        supportCredentials: false
      }
      ipSecurityRestrictions: functionAppIpRestrictions
      scmIpSecurityRestrictions: functionAppIpRestrictions
      scmIpSecurityRestrictionsUseMain: false
    }
  }
}

// Virtual Machine Scale Set with comprehensive configuration
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2023-09-01' = {
  name: vmssName
  location: location
  tags: union({
    Environment: environment
    Project: projectName
    Purpose: 'VM Scale Set for AI training workloads'
  }, tags)
  sku: {
    name: vmSize
    capacity: instanceCount
  }
  identity: {
    type: enableVmssSystemManagedIdentity && empty(userAssignedIdentities) ? 'SystemAssigned' : !enableVmssSystemManagedIdentity && !empty(userAssignedIdentities) ? 'UserAssigned' : enableVmssSystemManagedIdentity && !empty(userAssignedIdentities) ? 'SystemAssigned, UserAssigned' : 'None'
    userAssignedIdentities: !empty(userAssignedIdentities) ? reduce(userAssignedIdentities, {}, (cur, next) => union(cur, { '${next}': {} })) : null
  }
  properties: {
    upgradePolicy: {
      mode: 'Automatic'
      automaticOSUpgradePolicy: {
        enableAutomaticOSUpgrade: enableAutomaticOSUpgrade
        disableAutomaticRollback: false
      }
    }
    virtualMachineProfile: {
      osProfile: osType == 'Windows' ? {
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
      } : {
        computerNamePrefix: 'vm-ai'
        adminUsername: vmAdminUsername
        adminPassword: vmAdminPassword
        linuxConfiguration: {
          disablePasswordAuthentication: false
          provisionVMAgent: true
          patchSettings: {
            patchMode: 'ImageDefault'
          }
        }
      }
      storageProfile: {
        osDisk: {
          createOption: 'FromImage'
          caching: 'ReadWrite'
          managedDisk: {
            storageAccountType: osDiskStorageType
            diskEncryptionSet: !empty(diskEncryptionSetId) && enableCustomerManagedEncryption ? {
              id: diskEncryptionSetId
            } : null
          }
          diskSizeGB: osDiskSizeGB
        }
        imageReference: osType == 'Windows' ? windowsImageReference : linuxImageReference
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'nic-config'
            properties: {
              primary: true
              enableAcceleratedNetworking: enableAcceleratedNetworking
              networkSecurityGroup: !empty(networkSecurityGroupId) ? {
                id: networkSecurityGroupId
              } : null
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                    privateIPAddressVersion: 'IPv4'
                    publicIPAddressConfiguration: enableVmssPublicIp ? {
                      name: 'publicip-config'
                      properties: {
                        idleTimeoutInMinutes: 4
                      }
                    } : null
                  }
                }
              ]
            }
          }
        ]
      }
      securityProfile: enableTrustedLaunch ? {
        securityType: 'TrustedLaunch'
        uefiSettings: {
          secureBootEnabled: true
          vTpmEnabled: true
        }
        encryptionAtHost: enableEncryptionAtHost
      } : {
        encryptionAtHost: enableEncryptionAtHost
      }
      extensionProfile: {
        extensions: union(
          enableAzureAdAuth && osType == 'Windows' ? [
            {
              name: 'AADLoginForWindows'
              properties: {
                publisher: 'Microsoft.Azure.ActiveDirectory'
                type: 'AADLoginForWindows'
                typeHandlerVersion: '1.0'
                autoUpgradeMinorVersion: true
              }
            }
          ] : enableAzureAdAuth && osType == 'Linux' ? [
            {
              name: 'AADSSHLoginForLinux'
              properties: {
                publisher: 'Microsoft.Azure.ActiveDirectory'
                type: 'AADSSHLoginForLinux'
                typeHandlerVersion: '1.0'
                autoUpgradeMinorVersion: true
              }
            }
          ] : [],
          enableAzureMonitorAgent ? [
            {
              name: osType == 'Windows' ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
              properties: {
                publisher: 'Microsoft.Azure.Monitor'
                type: osType == 'Windows' ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
                typeHandlerVersion: '1.0'
                autoUpgradeMinorVersion: true
                enableAutomaticUpgrade: true
              }
            }
          ] : []
        )
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
  zones: availabilityZones
}

// Auto Scale Settings for VMSS
resource autoScaleSettings 'Microsoft.Insights/autoscalesettings@2022-10-01' = if (enableAutoScaling) {
  name: autoScaleSettingsName
  location: location
  tags: union({
    Environment: environment
    Project: projectName
    Purpose: 'Auto-scale settings for VMSS'
  }, tags)
  properties: {
    enabled: true
    targetResourceUri: vmss.id
    profiles: [
      {
        name: 'Default'
        capacity: {
          minimum: string(minInstanceCount)
          maximum: string(maxInstanceCount)
          default: string(instanceCount)
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
              threshold: scaleUpCpuThreshold
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
              threshold: scaleDownCpuThreshold
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

// Diagnostic Settings for VMSS
resource vmssDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: vmss
  name: vmssDiagnosticsName
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

// Diagnostic Settings for Function App
resource functionAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (enableFunctionApp && !empty(logAnalyticsWorkspaceId)) {
  scope: functionApp
  name: functionAppDiagnosticsName
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

// ============================================================================
// OUTPUTS
// ============================================================================

// VM Scale Set outputs
output vmssId string = vmss.id
output vmssName string = vmss.name
output vmssPrincipalId string = enableVmssSystemManagedIdentity ? vmss.identity.principalId : ''

// Function App outputs (conditional)
output functionAppId string = enableFunctionApp ? functionApp!.id : ''
output functionAppName string = enableFunctionApp ? functionApp!.name : ''
output functionAppDefaultHostName string = enableFunctionApp ? functionApp!.properties.defaultHostName : ''
output functionAppPrincipalId string = enableFunctionApp && enableFunctionAppSystemManagedIdentity ? functionApp!.identity.principalId : ''

// App Service Plan outputs (conditional)
output appServicePlanId string = enableFunctionApp ? appServicePlan!.id : ''

// Storage Account outputs (conditional)
output storageAccountId string = enableFunctionApp ? storageAccount!.id : ''
output storageAccountName string = enableFunctionApp ? storageAccount!.name : ''
