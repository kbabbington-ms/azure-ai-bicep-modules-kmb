@description('Container infrastructure for AI Enclave - AKS, Container Registry, Container Apps')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param subnetId string
param logAnalyticsWorkspaceId string = ''
param enablePrivateCluster bool = true
param kubernetesVersion string = '1.28.3'
param nodeCount int = 3
param nodeVmSize string = 'Standard_D4s_v3'

// Resource naming
var aksClusterName = 'aks-${projectName}-${environment}-${location}'
var acrName = 'acr${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}'
var containerAppEnvironmentName = 'cae-${projectName}-${environment}-${location}'
var managedIdentityName = 'id-${projectName}-container-${environment}'

// User Assigned Managed Identity for AKS
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Managed identity for container infrastructure'
  }
}

// Azure Container Registry
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Container registry for AI workloads'
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    adminUserEnabled: false
    networkRuleSet: {
      defaultAction: 'Deny'
      ipRules: [
        // IP rules can be added here if needed
      ]
    }
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
    encryption: {
      status: 'enabled'
    }
    policies: {
      trustPolicy: {
        type: 'Notary'
        status: 'enabled'
      }
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
}

// Private Endpoint for Container Registry
resource acrPrivateEndpoint 'Microsoft.Network/privateEndpoints@2023-11-01' = {
  name: 'pe-${acrName}'
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Private endpoint for Container Registry'
  }
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: 'acr-connection'
        properties: {
          privateLinkServiceId: containerRegistry.id
          groupIds: ['registry']
        }
      }
    ]
  }
}

// AKS Cluster
resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: aksClusterName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Kubernetes cluster for AI workloads'
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    enableRBAC: true
    dnsPrefix: '${aksClusterName}-dns'
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: nodeCount
        vmSize: nodeVmSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: true
        minCount: 1
        maxCount: 5
        vnetSubnetID: subnetId
        enableNodePublicIP: false
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        availabilityZones: ['1', '2', '3']
        enableEncryptionAtHost: true
        tags: {
          Environment: environment
          Project: projectName
        }
      }
      {
        name: 'workerpool'
        count: nodeCount
        vmSize: 'Standard_D8s_v3'
        osType: 'Linux'
        mode: 'User'
        enableAutoScaling: true
        minCount: 0
        maxCount: 10
        vnetSubnetID: subnetId
        enableNodePublicIP: false
        maxPods: 30
        type: 'VirtualMachineScaleSets'
        availabilityZones: ['1', '2', '3']
        enableEncryptionAtHost: true
        nodeTaints: ['workload=ai:NoSchedule']
        nodeLabels: {
          workload: 'ai'
        }
        tags: {
          Environment: environment
          Project: projectName
          Purpose: 'AI workload nodes'
        }
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
      serviceCidrs: ['172.16.0.0/16']
      dnsServiceIP: '172.16.0.10'
      outboundType: 'userDefinedRouting'
      loadBalancerSku: 'standard'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
      privateDNSZone: enablePrivateCluster ? 'system' : null
      enablePrivateClusterPublicFQDN: false
    }
    addonProfiles: {
      omsagent: {
        enabled: !empty(logAnalyticsWorkspaceId)
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
        }
      }
      azurepolicy: {
        enabled: true
      }
    }
    podIdentityProfile: {
      enabled: false
    }
    workloadAutoScalerProfile: {
      keda: {
        enabled: true
      }
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
      imageCleaner: {
        enabled: true
        intervalHours: 24
      }
    }
  }
}

// Role Assignment for AKS to pull from ACR
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: containerRegistry
  name: guid(containerRegistry.id, managedIdentity.id, 'AcrPull')
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull role
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Container Apps Environment
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: containerAppEnvironmentName
  location: location
  tags: {
    Environment: environment
    Project: projectName
    Purpose: 'Container Apps environment for AI services'
  }
  properties: {
    vnetConfiguration: {
      infrastructureSubnetId: subnetId
      internal: true
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: !empty(logAnalyticsWorkspaceId) ? reference(logAnalyticsWorkspaceId, '2022-10-01').customerId : ''
        sharedKey: !empty(logAnalyticsWorkspaceId) ? listKeys(logAnalyticsWorkspaceId, '2022-10-01').primarySharedKey : ''
      }
    }
    zoneRedundant: true
  }
}

// Diagnostic Settings for AKS
resource aksDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(logAnalyticsWorkspaceId)) {
  scope: aksCluster
  name: 'aks-diagnostics'
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'kube-apiserver'
        enabled: true
      }
      {
        category: 'kube-audit'
        enabled: true
      }
      {
        category: 'kube-controller-manager'
        enabled: true
      }
      {
        category: 'kube-scheduler'
        enabled: true
      }
      {
        category: 'cluster-autoscaler'
        enabled: true
      }
      {
        category: 'cloud-controller-manager'
        enabled: true
      }
      {
        category: 'guard'
        enabled: true
      }
      {
        category: 'csi-azuredisk-controller'
        enabled: true
      }
      {
        category: 'csi-azurefile-controller'
        enabled: true
      }
      {
        category: 'csi-snapshot-controller'
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
output aksClusterId string = aksCluster.id
output aksClusterName string = aksCluster.name
output aksFqdn string = aksCluster.properties.fqdn
output containerRegistryId string = containerRegistry.id
output containerRegistryName string = containerRegistry.name
output containerRegistryLoginServer string = containerRegistry.properties.loginServer
output containerAppEnvironmentId string = containerAppEnvironment.id
output containerAppEnvironmentName string = containerAppEnvironment.name
output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
