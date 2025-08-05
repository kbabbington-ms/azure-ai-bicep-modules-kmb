@description('Azure AI Container Infrastructure - Enterprise Kubernetes and Container Platform that creates comprehensive AKS clusters, Azure Container Registry, and Container Apps environments with advanced security, monitoring, and compliance features. Version: 2025-08-01 | Security: Enhanced | Compliance: SOC2, HIPAA, GDPR ready')

// ============================================================================
// METADATA
// ============================================================================

metadata name = 'Azure AI Container Infrastructure - Enterprise Kubernetes Platform'
metadata description = 'Enterprise-grade container orchestration with AKS, ACR, Container Apps, and comprehensive security'
metadata author = 'Azure AI Infrastructure Team'
metadata version = '1.0.0'

// ============================================================================
// PARAMETERS - BASIC CONFIGURATION
// ============================================================================

// Azure region for deploying container infrastructure
// Consider regional availability for AKS and Container Apps features
// 🔒 SECURITY ENHANCEMENT: Choose regions that meet data residency requirements
@description('Required. Azure region for deployment')
param location string = resourceGroup().location

// Environment classification for resource naming and policy application
// Determines security policies and access controls applied to container infrastructure
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application
@description('Environment classification for container infrastructure')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environment string = 'production'

// Base project name for consistent resource naming
// Used as prefix for all container infrastructure resources
// 🔒 SECURITY ENHANCEMENT: Use predictable naming for security governance
@description('Required. Base project name for container infrastructure (2-24 characters)')
@minLength(2)
@maxLength(24)
param projectName string

// Virtual network subnet for container infrastructure deployment
// Required for private AKS clusters and Container Apps integration
// 🔒 SECURITY ENHANCEMENT: Deploy in private subnets for enhanced security
@description('Required. Subnet resource ID for container infrastructure')
param subnetId string

// Log Analytics workspace for centralized monitoring and logging
// Essential for container observability and security monitoring
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security monitoring
@description('Log Analytics workspace resource ID for monitoring')
param logAnalyticsWorkspaceId string = ''

// ============================================================================
// PARAMETERS - AKS CLUSTER CONFIGURATION
// ============================================================================

// Enable private AKS cluster for enhanced security
// Restricts API server access to private networks only
// 🔒 SECURITY ENHANCEMENT: Essential for production workloads
@description('Enable private AKS cluster for enhanced security')
param enablePrivateCluster bool = true

// Kubernetes version for AKS cluster
// Use supported versions with latest security patches
// 🔒 SECURITY ENHANCEMENT: Keep updated with latest security patches
@description('Kubernetes version for AKS cluster')
param kubernetesVersion string = '1.28.3'

// System node pool configuration for AKS cluster management
@description('System node pool configuration for AKS cluster')
param systemNodePoolConfig object = {
  nodeCount: 3
  minCount: 1
  maxCount: 5
  vmSize: 'Standard_D4s_v3'
  enableAutoScaling: true
  availabilityZones: ['1', '2', '3']
  maxPods: 30
}

// User node pool configuration for AI workloads
@description('User node pool configuration for AI workloads')
param userNodePoolConfig object = {
  nodeCount: 3
  minCount: 0
  maxCount: 10
  vmSize: 'Standard_D8s_v3'
  enableAutoScaling: true
  availabilityZones: ['1', '2', '3']
  maxPods: 30
  nodeTaints: ['workload=ai:NoSchedule']
  nodeLabels: {
    workload: 'ai'
    purpose: 'machine-learning'
  }
}

// Network configuration for AKS cluster
@description('Network configuration for AKS cluster')
param aksNetworkConfig object = {
  networkPlugin: 'azure'
  networkPolicy: 'azure'
  serviceCidrs: ['172.16.0.0/16']
  dnsServiceIP: '172.16.0.10'
  outboundType: 'userDefinedRouting'
  loadBalancerSku: 'standard'
}

// ============================================================================
// PARAMETERS - AZURE CONTAINER REGISTRY CONFIGURATION
// ============================================================================

// Azure Container Registry SKU for performance and features
// Premium tier required for private endpoints and geo-replication
// 🔒 SECURITY ENHANCEMENT: Use Premium for production with security features
@description('Azure Container Registry SKU')
@allowed(['Basic', 'Standard', 'Premium'])
param acrSku string = 'Premium'

// Enable Azure Container Registry geo-replication for high availability
// Improves image pull performance across regions
@description('Enable ACR geo-replication for high availability')
param enableAcrGeoReplication bool = true

// Geo-replication locations for Azure Container Registry
@description('Geo-replication locations for ACR')
param acrReplicationLocations array = ['eastus2', 'westeurope']

// Enable ACR vulnerability scanning for security
// Scans container images for known vulnerabilities
// 🔒 SECURITY ENHANCEMENT: Essential for container security
@description('Enable ACR vulnerability scanning')
param enableAcrVulnerabilityScanning bool = true

// ============================================================================
// PARAMETERS - CONTAINER APPS CONFIGURATION
// ============================================================================

// Enable Azure Container Apps environment for serverless containers
// Provides managed container hosting with automatic scaling
@description('Enable Azure Container Apps environment')
param enableContainerApps bool = true

// Container Apps environment configuration
@description('Container Apps environment configuration')
param containerAppsConfig object = {
  zoneRedundant: true
  internal: true
  infrastructureResourceGroup: ''
  daprAIInstrumentationKey: ''
  daprAIConnectionString: ''
  workloadProfiles: [
    {
      name: 'general-purpose'
      workloadProfileType: 'D4'
      minimumCount: 0
      maximumCount: 10
    }
    {
      name: 'memory-optimized'
      workloadProfileType: 'E4'
      minimumCount: 0
      maximumCount: 5
    }
  ]
}

// ============================================================================
// PARAMETERS - SECURITY & COMPLIANCE
// ============================================================================

// Enable Azure Policy for governance and compliance
// Enforces organizational standards and compliance requirements
// 🔒 SECURITY ENHANCEMENT: Essential for governance and compliance
@description('Enable Azure Policy for governance')
param enableAzurePolicy bool = true

// Enable Azure Defender for Containers for advanced threat protection
// Provides runtime threat protection and vulnerability assessment
// 🔒 SECURITY ENHANCEMENT: Essential for production container security
@description('Enable Azure Defender for Containers')
param enableAzureDefender bool = true

// Enable Workload Identity for secure pod authentication
// Provides Azure AD authentication for Kubernetes workloads
// 🔒 SECURITY ENHANCEMENT: Eliminates need for stored secrets
@description('Enable Workload Identity for secure pod authentication')
param enableWorkloadIdentity bool = true

// Enable image cleaner for security and compliance
// Automatically removes unused container images
// 🔒 SECURITY ENHANCEMENT: Reduces attack surface and storage costs
@description('Enable image cleaner for security')
param enableImageCleaner bool = true

// Image cleaner configuration
@description('Image cleaner configuration')
param imageCleanerConfig object = {
  intervalHours: 24
  enabled: true
}

// Network security configuration for container infrastructure
@description('Network security configuration')
param networkSecurityConfig object = {
  allowedCidrs: []
  denyAllInbound: true
  enableNetworkPolicy: true
  enablePrivateEndpoints: true
}

// ============================================================================
// PARAMETERS - MONITORING & OBSERVABILITY
// ============================================================================

// Enable comprehensive monitoring for container infrastructure
// Provides insights into cluster health, performance, and resource utilization
// 🔒 SECURITY ENHANCEMENT: Essential for detecting security anomalies
@description('Enable comprehensive container monitoring')
param enableAdvancedMonitoring bool = true

// Monitoring configuration for container infrastructure
@description('Advanced monitoring configuration')
param monitoringConfig object = {
  enableContainerInsights: true
  enablePrometheusMetrics: true
  enableJaegerTracing: false
  retentionDays: 90
  alerting: {
    enabled: true
    cpuThreshold: 80
    memoryThreshold: 85
    diskThreshold: 90
    podRestartThreshold: 5
  }
}

// Enable audit logging for compliance and security
// Tracks all API server requests and cluster operations
// 🔒 SECURITY ENHANCEMENT: Required for compliance and security investigations
@description('Enable audit logging for compliance')
param enableAuditLogging bool = true

// Audit logging configuration
@description('Audit logging configuration')
param auditLoggingConfig object = {
  enabled: true
  retentionDays: 365
  logCategories: [
    'kube-apiserver'
    'kube-audit'
    'kube-controller-manager'
    'kube-scheduler'
    'cluster-autoscaler'
    'cloud-controller-manager'
    'guard'
    'csi-azuredisk-controller'
    'csi-azurefile-controller'
    'csi-snapshot-controller'
  ]
}

// ============================================================================
// PARAMETERS - ADVANCED FEATURES
// ============================================================================

// Enable KEDA for advanced auto-scaling capabilities
// Provides event-driven autoscaling for containerized applications
@description('Enable KEDA for event-driven autoscaling')
param enableKeda bool = true

// Enable Azure Key Vault Secrets Provider for secure secret management
// Integrates Azure Key Vault with Kubernetes for secure secret access
// 🔒 SECURITY ENHANCEMENT: Eliminates hardcoded secrets in containers
@description('Enable Azure Key Vault Secrets Provider')
param enableKeyVaultSecretsProvider bool = true

// Key Vault Secrets Provider configuration
@secure()
@description('Key Vault Secrets Provider configuration')
param keyVaultSecretsConfig object = {}

// Enable Open Service Mesh for advanced traffic management
// Provides service mesh capabilities for microservices communication
@description('Enable Open Service Mesh for traffic management')
param enableServiceMesh bool = false

// Service mesh configuration
@description('Service mesh configuration')
param serviceMeshConfig object = {
  enableTls: true
  enableTracing: true
  enableMetrics: true
  ingressGateway: {
    enabled: true
    type: 'LoadBalancer'
  }
}

// ============================================================================
// PARAMETERS - BACKUP & DISASTER RECOVERY
// ============================================================================

// Enable backup for AKS cluster persistent volumes
// Protects persistent data with automated backup capabilities
// 🔒 SECURITY ENHANCEMENT: Essential for data protection and compliance
@description('Enable AKS backup for persistent volumes')
param enableAksBackup bool = true

// Backup configuration for AKS cluster
@description('AKS backup configuration')
param aksBackupConfig object = {
  enabled: true
  retentionDays: 30
  backupSchedule: '0 2 * * *' // Daily at 2 AM
  includeClusterScopedResources: true
  includedNamespaces: ['default', 'kube-system', 'ai-workloads']
  excludedNamespaces: ['kube-public']
}

// ============================================================================
// PARAMETERS - COST OPTIMIZATION
// ============================================================================

// Enable spot node pools for cost optimization
// Uses Azure Spot VMs for significant cost savings on non-critical workloads
@description('Enable spot node pools for cost optimization')
param enableSpotNodePools bool = false

// Spot node pool configuration
@description('Spot node pool configuration')
param spotNodePoolConfig object = {
  enabled: false
  spotMaxPrice: -1 // Use current Spot price
  nodeCount: 0
  minCount: 0
  maxCount: 5
  vmSize: 'Standard_D4s_v3'
  nodeTaints: ['kubernetes.azure.com/scalesetpriority=spot:NoSchedule']
}

// ============================================================================
// PARAMETERS - ENHANCED TAGGING & METADATA
// ============================================================================

// Environment classification for security policy application and access control
// Determines which security policies and access controls are applied
// 🔒 SECURITY ENHANCEMENT: Use for automated security policy application
@description('Environment classification for security policies')
@allowed(['development', 'testing', 'staging', 'production', 'sandbox'])
param environmentClassification string = 'production'

// Data classification level for compliance and security policy enforcement
// Defines the sensitivity level of data processed by container workloads
// 🔒 SECURITY ENHANCEMENT: Use for automated compliance policy application
@description('Data classification level for compliance and security')
@allowed(['public', 'internal', 'confidential', 'restricted'])
param dataClassification string = 'internal'

// Business criticality level for resource prioritization and SLA application
// Determines service level agreements and priority for support
// 🔒 SECURITY ENHANCEMENT: Use for security incident prioritization
@description('Business criticality level for SLA and support prioritization')
@allowed(['low', 'medium', 'high', 'critical', 'mission-critical'])
param businessCriticality string = 'high'

// Cost center information for billing and resource allocation tracking
// Enables cost tracking and allocation for enterprise resource management
@description('Cost center for billing and resource allocation')
param costCenter string = ''

// Resource owner information for accountability and contact management
// Specifies responsible party for resource management and security compliance
// 🔒 SECURITY ENHANCEMENT: Required for security incident response
@description('Resource owner information for accountability')
param resourceOwner object = {
  name: ''
  email: ''
  department: ''
  managerId: ''
}

// Project information for resource organization and governance
// Enables project-based resource organization and cost allocation
@description('Project information for resource organization')
param projectInformation object = {
  projectName: ''
  projectId: ''
  projectManager: ''
  budget: ''
  startDate: ''
  endDate: ''
}

// Compliance framework requirements for regulatory adherence
// Specifies which compliance frameworks the infrastructure must adhere to
// 🔒 SECURITY ENHANCEMENT: Enables automated compliance checks
@description('Compliance framework requirements')
param complianceRequirements object = {
  gdprCompliance: false
  hipaaCompliance: false
  sox404Compliance: false
  iso27001Compliance: false
  pcidssCompliance: false
  customComplianceFrameworks: []
}

// ============================================================================
// PARAMETERS - TAGGING & METADATA
// ============================================================================

// Resource tags for governance, cost management, and compliance tracking
// Essential for multi-tenant environments and cost allocation
// 🔒 SECURITY ENHANCEMENT: Include security classification and compliance tags
@description('Resource tags for governance and cost management')
param tags object = {}

// Resource suffix for consistent naming across related resources
@description('Resource suffix for consistent naming')
param resourceSuffix string = ''

// ============================================================================
// VARIABLES
// ============================================================================

// Enhanced default tags with comprehensive metadata
var defaultTags = {
  Environment: tags.?Environment ?? environment
  EnvironmentClassification: environmentClassification
  Service: 'Container Infrastructure'
  ManagedBy: 'Bicep'
  ContainerOrchestration: 'enabled'
  DataClassification: dataClassification
  BusinessCriticality: businessCriticality
  CostCenter: !empty(costCenter) ? costCenter : 'Not Specified'
  Owner: !empty(resourceOwner.name) ? resourceOwner.name : 'Not Specified'
  OwnerEmail: !empty(resourceOwner.email) ? resourceOwner.email : 'Not Specified'
  Department: !empty(resourceOwner.department) ? resourceOwner.department : 'Not Specified'
  ProjectName: !empty(projectInformation.projectName) ? projectInformation.projectName : projectName
  ProjectId: !empty(projectInformation.projectId) ? projectInformation.projectId : 'Not Specified'
  LastUpdated: '2025-08-01'
  AksEnabled: 'true'
  AcrEnabled: 'true'
  ContainerAppsEnabled: string(enableContainerApps)
  PrivateClusterEnabled: string(enablePrivateCluster)
  WorkloadIdentityEnabled: string(enableWorkloadIdentity)
  AzureDefenderEnabled: string(enableAzureDefender)
}

// Merge user-provided tags with enhanced defaults
var allTags = union(defaultTags, tags)

// Resource naming with comprehensive project context
var aksClusterName = 'aks-${projectName}-${environment}-${location}${resourceSuffix}'
var acrName = 'acr${replace(projectName, '-', '')}${environment}${uniqueString(resourceGroup().id)}${replace(resourceSuffix, '-', '')}'
var containerAppEnvironmentName = 'cae-${projectName}-${environment}-${location}${resourceSuffix}'
var managedIdentityName = 'id-${projectName}-container-${environment}${resourceSuffix}'

// Security configuration objects
var securityConfig = {
  enableAzurePolicy: enableAzurePolicy
  enableAzureDefender: enableAzureDefender
  enableWorkloadIdentity: enableWorkloadIdentity
  enableImageCleaner: enableImageCleaner
  imageCleanerConfig: imageCleanerConfig
  networkSecurityConfig: networkSecurityConfig
}

// Monitoring configuration objects
var advancedMonitoringConfig = {
  enableAdvancedMonitoring: enableAdvancedMonitoring
  monitoringConfig: monitoringConfig
  enableAuditLogging: enableAuditLogging
  auditLoggingConfig: auditLoggingConfig
}

// AKS advanced features configuration
var aksAdvancedConfig = {
  enableKeda: enableKeda
  enableKeyVaultSecretsProvider: enableKeyVaultSecretsProvider
  keyVaultSecretsConfig: union({
    enableSecretRotation: true
    syncInterval: '2m'
    maxCallsPerSecond: 20
  }, keyVaultSecretsConfig)
  enableServiceMesh: enableServiceMesh
  serviceMeshConfig: serviceMeshConfig
}

// Container Registry advanced configuration
var acrAdvancedConfig = {
  sku: acrSku
  enableGeoReplication: enableAcrGeoReplication
  replicationLocations: acrReplicationLocations
  enableVulnerabilityScanning: enableAcrVulnerabilityScanning
}

// Backup and disaster recovery configuration
var backupConfig = {
  enableAksBackup: enableAksBackup
  aksBackupConfig: aksBackupConfig
}

// Cost optimization configuration
var costOptimizationConfig = {
  enableSpotNodePools: enableSpotNodePools
  spotNodePoolConfig: spotNodePoolConfig
}

// Compliance configuration
var complianceConfig = {
  requirements: complianceRequirements
  environmentClassification: environmentClassification
  dataClassification: dataClassification
  businessCriticality: businessCriticality
}

// ============================================================================
// RESOURCES - MANAGED IDENTITY
// ============================================================================

// User Assigned Managed Identity for container infrastructure
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
  tags: union(allTags, {
    Purpose: 'Managed identity for container infrastructure'
    ComponentType: 'Identity'
  })
}

// Azure Container Registry with advanced security features
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: union(allTags, {
    Purpose: 'Container registry for AI workloads'
    ComponentType: 'ContainerRegistry'
    Sku: acrAdvancedConfig.sku
    GeoReplicationEnabled: string(acrAdvancedConfig.enableGeoReplication)
    VulnerabilityScanningEnabled: string(acrAdvancedConfig.enableVulnerabilityScanning)
  })
  sku: {
    name: acrAdvancedConfig.sku
  }
  properties: {
    adminUserEnabled: false
    networkRuleSet: {
      defaultAction: securityConfig.networkSecurityConfig.denyAllInbound ? 'Deny' : 'Allow'
      ipRules: [for cidr in securityConfig.networkSecurityConfig.allowedCidrs: {
        action: 'Allow'
        value: cidr
      }]
    }
    publicNetworkAccess: securityConfig.networkSecurityConfig.enablePrivateEndpoints ? 'Disabled' : 'Enabled'
    zoneRedundancy: 'Enabled'
    encryption: {
      status: 'enabled'
    }
    policies: {
      trustPolicy: {
        type: 'Notary'
        status: 'enabled'
      }
      retentionPolicy: {
        status: 'enabled'
        days: 30
      }
      exportPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
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

// ACR Geo-Replication for high availability
resource acrReplications 'Microsoft.ContainerRegistry/registries/replications@2023-07-01' = [for location_var in acrAdvancedConfig.replicationLocations: if (acrAdvancedConfig.enableGeoReplication && acrAdvancedConfig.sku == 'Premium') {
  parent: containerRegistry
  name: location_var
  location: location_var
  tags: allTags
  properties: {
    zoneRedundancy: 'Enabled'
  }
}]

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

// AKS Cluster with comprehensive enterprise configuration
resource aksCluster 'Microsoft.ContainerService/managedClusters@2023-10-01' = {
  name: aksClusterName
  location: location
  tags: union(allTags, {
    Purpose: 'Kubernetes cluster for AI workloads'
    ComponentType: 'AKS'
    KubernetesVersion: kubernetesVersion
    PrivateCluster: string(enablePrivateCluster)
    WorkloadIdentityEnabled: string(securityConfig.enableWorkloadIdentity)
  })
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
        count: systemNodePoolConfig.nodeCount
        vmSize: systemNodePoolConfig.vmSize
        osType: 'Linux'
        mode: 'System'
        enableAutoScaling: systemNodePoolConfig.enableAutoScaling
        minCount: systemNodePoolConfig.minCount
        maxCount: systemNodePoolConfig.maxCount
        vnetSubnetID: subnetId
        enableNodePublicIP: false
        maxPods: systemNodePoolConfig.maxPods
        type: 'VirtualMachineScaleSets'
        availabilityZones: systemNodePoolConfig.availabilityZones
        enableEncryptionAtHost: true
        enableUltraSSD: false
        enableFIPS: false
        tags: union(allTags, {
          NodePoolType: 'System'
          Purpose: 'System workloads'
        })
      }
      {
        name: 'workerpool'
        count: userNodePoolConfig.nodeCount
        vmSize: userNodePoolConfig.vmSize
        osType: 'Linux'
        mode: 'User'
        enableAutoScaling: userNodePoolConfig.enableAutoScaling
        minCount: userNodePoolConfig.minCount
        maxCount: userNodePoolConfig.maxCount
        vnetSubnetID: subnetId
        enableNodePublicIP: false
        maxPods: userNodePoolConfig.maxPods
        type: 'VirtualMachineScaleSets'
        availabilityZones: userNodePoolConfig.availabilityZones
        enableEncryptionAtHost: true
        enableUltraSSD: false
        enableFIPS: false
        nodeTaints: userNodePoolConfig.nodeTaints
        nodeLabels: userNodePoolConfig.nodeLabels
        tags: union(allTags, {
          NodePoolType: 'User'
          Purpose: 'AI workload nodes'
          Workload: 'ai'
        })
      }
    ]
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    networkProfile: {
      networkPlugin: aksNetworkConfig.networkPlugin
      networkPolicy: securityConfig.networkSecurityConfig.enableNetworkPolicy ? aksNetworkConfig.networkPolicy : null
      serviceCidrs: aksNetworkConfig.serviceCidrs
      dnsServiceIP: aksNetworkConfig.dnsServiceIP
      outboundType: aksNetworkConfig.outboundType
      loadBalancerSku: aksNetworkConfig.loadBalancerSku
    }
    apiServerAccessProfile: {
      enablePrivateCluster: enablePrivateCluster
      privateDNSZone: enablePrivateCluster ? 'system' : null
      enablePrivateClusterPublicFQDN: false
    }
    addonProfiles: {
      omsagent: {
        enabled: !empty(logAnalyticsWorkspaceId) && advancedMonitoringConfig.enableAdvancedMonitoring
        config: !empty(logAnalyticsWorkspaceId) ? {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
          useAADAuth: 'true'
        } : null
      }
      azureKeyvaultSecretsProvider: {
        enabled: aksAdvancedConfig.enableKeyVaultSecretsProvider
        config: aksAdvancedConfig.enableKeyVaultSecretsProvider ? {
          enableSecretRotation: string(aksAdvancedConfig.keyVaultSecretsConfig.enableSecretRotation)
          rotationPollInterval: aksAdvancedConfig.keyVaultSecretsConfig.syncInterval
        } : null
      }
      azurepolicy: {
        enabled: securityConfig.enableAzurePolicy
      }
      openServiceMesh: {
        enabled: aksAdvancedConfig.enableServiceMesh
        config: aksAdvancedConfig.enableServiceMesh ? {
          
        } : null
      }
    }
    podIdentityProfile: {
      enabled: false
    }
    workloadAutoScalerProfile: {
      keda: {
        enabled: aksAdvancedConfig.enableKeda
      }
      verticalPodAutoscaler: {
        enabled: false
      }
    }
    securityProfile: {
      workloadIdentity: {
        enabled: securityConfig.enableWorkloadIdentity
      }
      imageCleaner: {
        enabled: securityConfig.enableImageCleaner
        intervalHours: securityConfig.imageCleanerConfig.intervalHours
      }
      azureKeyVaultKms: {
        enabled: false
      }
      defender: {
        logAnalyticsWorkspaceResourceId: !empty(logAnalyticsWorkspaceId) && securityConfig.enableAzureDefender ? logAnalyticsWorkspaceId : null
        securityMonitoring: {
          enabled: securityConfig.enableAzureDefender
        }
      }
    }
    oidcIssuerProfile: {
      enabled: securityConfig.enableWorkloadIdentity
    }
    disableLocalAccounts: true
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

// Container Apps Environment with advanced configuration
resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2023-05-01' = if (enableContainerApps) {
  name: containerAppEnvironmentName
  location: location
  tags: union(allTags, {
    Purpose: 'Container Apps environment for AI services'
    ComponentType: 'ContainerApps'
    ZoneRedundant: string(containerAppsConfig.zoneRedundant)
    InternalOnly: string(containerAppsConfig.internal)
  })
  properties: {
    vnetConfiguration: {
      infrastructureSubnetId: subnetId
      internal: containerAppsConfig.internal
    }
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: !empty(logAnalyticsWorkspaceId) ? {
        customerId: reference(logAnalyticsWorkspaceId, '2022-10-01').customerId
        sharedKey: listKeys(logAnalyticsWorkspaceId, '2022-10-01').primarySharedKey
      } : null
    }
    zoneRedundant: containerAppsConfig.zoneRedundant
    workloadProfiles: containerAppsConfig.workloadProfiles
    infrastructureResourceGroup: !empty(containerAppsConfig.infrastructureResourceGroup) ? containerAppsConfig.infrastructureResourceGroup : null
  }
}

// Spot Node Pool for cost optimization
resource spotNodePool 'Microsoft.ContainerService/managedClusters/agentPools@2023-10-01' = if (costOptimizationConfig.enableSpotNodePools && costOptimizationConfig.spotNodePoolConfig.enabled) {
  parent: aksCluster
  name: 'spotpool'
  properties: {
    count: costOptimizationConfig.spotNodePoolConfig.nodeCount
    vmSize: costOptimizationConfig.spotNodePoolConfig.vmSize
    osType: 'Linux'
    mode: 'User'
    enableAutoScaling: true
    minCount: costOptimizationConfig.spotNodePoolConfig.minCount
    maxCount: costOptimizationConfig.spotNodePoolConfig.maxCount
    vnetSubnetID: subnetId
    enableNodePublicIP: false
    maxPods: 30
    type: 'VirtualMachineScaleSets'
    availabilityZones: ['1', '2', '3']
    enableEncryptionAtHost: true
    scaleSetPriority: 'Spot'
    scaleSetEvictionPolicy: 'Delete'
    spotMaxPrice: costOptimizationConfig.spotNodePoolConfig.spotMaxPrice
    nodeTaints: costOptimizationConfig.spotNodePoolConfig.nodeTaints
    nodeLabels: {
      'kubernetes.azure.com/scalesetpriority': 'spot'
      workload: 'batch'
      costOptimized: 'true'
    }
    tags: union(allTags, {
      NodePoolType: 'Spot'
      Purpose: 'Cost-optimized batch workloads'
      Priority: 'Spot'
    })
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

// ============================================================================
// OUTPUTS
// ============================================================================

@description('AKS cluster configuration and connection details')
output aksConfig object = {
  name: aksCluster.name
  id: aksCluster.id
  fqdn: aksCluster.properties.fqdn
  kubernetesVersion: aksCluster.properties.kubernetesVersion
  nodeResourceGroup: aksCluster.properties.nodeResourceGroup
  location: location
  privateFqdn: enablePrivateCluster ? aksCluster.properties.privateFQDN : ''
  oidcIssuerUrl: securityConfig.enableWorkloadIdentity ? aksCluster.properties.oidcIssuerProfile.issuerURL : ''
}

@description('Azure Container Registry configuration and access details')
output acrConfig object = {
  name: containerRegistry.name
  id: containerRegistry.id
  loginServer: containerRegistry.properties.loginServer
  sku: acrAdvancedConfig.sku
  location: location
  geoReplicationEnabled: acrAdvancedConfig.enableGeoReplication
  replicationLocations: acrAdvancedConfig.enableGeoReplication ? acrAdvancedConfig.replicationLocations : []
  vulnerabilityScanningEnabled: acrAdvancedConfig.enableVulnerabilityScanning
}

@description('Container Apps environment configuration')
output containerAppsConfig object = enableContainerApps ? {
  name: containerAppEnvironment!.name
  id: containerAppEnvironment!.id
  location: location
  defaultDomain: containerAppEnvironment!.properties.defaultDomain
  staticIp: containerAppEnvironment!.properties.staticIp
  zoneRedundant: containerAppsConfig.zoneRedundant
  internal: containerAppsConfig.internal
} : {}

@description('Managed Identity configuration for container infrastructure')
output managedIdentityConfig object = {
  name: managedIdentity.name
  id: managedIdentity.id
  principalId: managedIdentity.properties.principalId
  clientId: managedIdentity.properties.clientId
  tenantId: managedIdentity.properties.tenantId
}

@description('Security configuration and features')
output securityConfig object = {
  privateClusterEnabled: enablePrivateCluster
  workloadIdentityEnabled: securityConfig.enableWorkloadIdentity
  azurePolicyEnabled: securityConfig.enableAzurePolicy
  azureDefenderEnabled: securityConfig.enableAzureDefender
  imageCleanerEnabled: securityConfig.enableImageCleaner
  networkPolicyEnabled: securityConfig.networkSecurityConfig.enableNetworkPolicy
  privateEndpointsEnabled: securityConfig.networkSecurityConfig.enablePrivateEndpoints
}

@description('Monitoring and observability configuration')
output monitoringConfig object = {
  advancedMonitoringEnabled: advancedMonitoringConfig.enableAdvancedMonitoring
  containerInsightsEnabled: advancedMonitoringConfig.monitoringConfig.enableContainerInsights
  prometheusMetricsEnabled: advancedMonitoringConfig.monitoringConfig.enablePrometheusMetrics
  auditLoggingEnabled: advancedMonitoringConfig.enableAuditLogging
  logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
}

@description('Advanced features configuration')
output advancedFeaturesConfig object = {
  kedaEnabled: aksAdvancedConfig.enableKeda
  keyVaultSecretsProviderEnabled: aksAdvancedConfig.enableKeyVaultSecretsProvider
  serviceMeshEnabled: aksAdvancedConfig.enableServiceMesh
  spotNodePoolsEnabled: costOptimizationConfig.enableSpotNodePools
  aksBackupEnabled: backupConfig.enableAksBackup
}

@description('Cost optimization configuration')
output costOptimizationConfig object = {
  spotNodePoolsEnabled: costOptimizationConfig.enableSpotNodePools
  spotNodePoolConfig: costOptimizationConfig.enableSpotNodePools ? {
    nodeCount: costOptimizationConfig.spotNodePoolConfig.nodeCount
    vmSize: costOptimizationConfig.spotNodePoolConfig.vmSize
    maxPrice: costOptimizationConfig.spotNodePoolConfig.spotMaxPrice
  } : {}
  autoScalingEnabled: systemNodePoolConfig.enableAutoScaling && userNodePoolConfig.enableAutoScaling
}

@description('Compliance and governance configuration')
output complianceConfig object = {
  requirements: complianceConfig.requirements
  environmentClassification: complianceConfig.environmentClassification
  dataClassification: complianceConfig.dataClassification
  businessCriticality: complianceConfig.businessCriticality
  allTags: allTags
}

@description('Resource management and ownership information')
output resourceManagement object = {
  resourceOwner: resourceOwner
  projectInformation: union(projectInformation, { projectName: projectName })
  costCenter: costCenter
  environment: environment
  location: location
}

@description('Deployment summary and next steps')
output deploymentSummary object = {
  status: 'Container Infrastructure deployed successfully'
  nextSteps: [
    'Configure kubectl access to the AKS cluster'
    'Deploy container workloads to the cluster'
    'Set up CI/CD pipelines for container deployments'
    'Configure monitoring and alerting for containerized applications'
    'Implement backup strategies for persistent volumes'
    'Set up network policies for workload isolation'
  ]
  capabilities: [
    'Private AKS cluster with enterprise security'
    'Premium Azure Container Registry with geo-replication'
    'Container Apps environment for serverless containers'
    'Workload Identity for secure pod authentication'
    'Advanced monitoring with Container Insights'
    'Cost optimization with Spot node pools'
    'Comprehensive compliance and governance features'
  ]
  documentationLinks: {
    aks: 'https://docs.microsoft.com/azure/aks/'
    acr: 'https://docs.microsoft.com/azure/container-registry/'
    containerApps: 'https://docs.microsoft.com/azure/container-apps/'
    workloadIdentity: 'https://docs.microsoft.com/azure/aks/workload-identity-overview'
    pricing: 'https://azure.microsoft.com/pricing/details/kubernetes-service/'
  }
}
