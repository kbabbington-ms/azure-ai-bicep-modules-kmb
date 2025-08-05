# Container Infrastructure Module

Enterprise container platform with Azure Kubernetes Service (AKS), Azure Container Registry (ACR), and Container Apps for secure AI workload deployment.

## Features

- **📦 Azure Container Registry**: Secure container image storage with geo-replication
- **☸️ Private AKS Cluster**: Kubernetes with network isolation and enterprise security
- **🔐 Security Scanning**: Vulnerability assessment and compliance checking
- **🔒 Image Signing**: Container image trust policies and content verification
- **🛡️ Network Security**: Private endpoints and network policies
- **📊 Monitoring**: Container insights and performance monitoring
- **⚡ Auto-scaling**: Horizontal and vertical pod autoscaling

## Usage

```bicep
module containerInfra 'modules/container-infrastructure/main.bicep' = {
  name: 'enterprise-containers'
  params: {
    location: 'eastus'
    environment: 'prod'
    projectName: 'ai-platform'
    
    // Network configuration
    subnetId: '/subscriptions/.../providers/Microsoft.Network/virtualNetworks/vnet/subnets/container-subnet'
    
    // AKS configuration
    enablePrivateCluster: true
    kubernetesVersion: '1.28.3'
    nodeCount: 3
    nodeVmSize: 'Standard_D4s_v3'
    
    // Monitoring
    logAnalyticsWorkspaceId: '/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/logs'
    
    tags: {
      Environment: 'Production'
      Application: 'AI Platform'
      Purpose: 'Container Platform'
    }
  }
}
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `location` | string | `resourceGroup().location` | Azure region for deployment |
| `environment` | string | `'dev'` | Environment designation (dev/test/prod) |
| `projectName` | string | `'ai-enclave'` | Project name for resource naming |
| `subnetId` | string | *Required* | Subnet ID for private endpoints |
| `enablePrivateCluster` | bool | `true` | Enable private AKS cluster |
| `kubernetesVersion` | string | `'1.28.3'` | Kubernetes version |
| `nodeCount` | int | `3` | Initial node count |
| `nodeVmSize` | string | `'Standard_D4s_v3'` | Node VM size |
| `logAnalyticsWorkspaceId` | string | `''` | Log Analytics workspace for monitoring |

## Security Features

- **🔒 Private AKS Cluster**: API server accessible only from private network
- **📦 Premium Container Registry**: Enterprise-grade image storage
- **🔐 Image Signing**: Content trust with Notary v2
- **🛡️ Network Policies**: Kubernetes network security policies
- **👤 Managed Identities**: Azure AD workload identity integration
- **🔍 Security Scanning**: Vulnerability assessment for container images
- **🚫 Admission Controllers**: Policy enforcement with Azure Policy for AKS

## Container Registry Features

- **🌍 Geo-replication**: Multi-region image replication
- **🔒 Private Endpoints**: Secure access without public internet
- **🔐 Content Trust**: Image signing and verification
- **📊 Vulnerability Scanning**: Automated security assessment
- **🏷️ Image Tagging**: Immutable tags and retention policies
- **⚡ Performance**: Zone-redundant storage for high availability

## AKS Cluster Features

- **☸️ Private Cluster**: API server with private IP
- **🔄 Auto-scaling**: Cluster and horizontal pod autoscaling
- **🛡️ Security**: Azure AD integration and RBAC
- **📊 Monitoring**: Container insights and log analytics
- **🔒 Network Security**: Azure CNI with network policies
- **💾 Storage**: CSI drivers for Azure Disk and Files

## Outputs

| Output | Type | Description |
|--------|------|-------------|
| `aksClusterId` | string | Resource ID of AKS cluster |
| `aksClusterName` | string | Name of AKS cluster |
| `acrId` | string | Resource ID of container registry |
| `acrLoginServer` | string | Container registry login server |
| `managedIdentityId` | string | Resource ID of managed identity |
| `containerAppEnvironmentId` | string | Resource ID of container app environment |

## AI/ML Workload Optimization

This container platform is optimized for AI/ML workloads with:
- **🤖 GPU Support**: GPU-enabled node pools for ML training
- **📊 Large Models**: High-memory instances for large language models
- **⚡ Fast Storage**: Premium SSD and NVMe storage options
- **🔗 Service Mesh**: Istio integration for microservices communication
- **📈 Scaling**: Predictive scaling for AI inference workloads

## DevOps Integration

- **🔄 CI/CD Pipelines**: GitHub Actions and Azure DevOps integration
- **📦 Helm Charts**: Pre-configured charts for AI services
- **🔍 Monitoring**: Prometheus and Grafana for metrics
- **📊 Logging**: Centralized logging with Fluent Bit
- **🚀 GitOps**: ArgoCD and Flux for declarative deployments

## Best Practices

- **🔒 Security**: Least privilege access and network segmentation
- **📊 Monitoring**: Comprehensive observability and alerting
- **💾 Backup**: Regular backup of cluster configuration and data
- **🔄 Updates**: Automated security updates and patch management
- **📈 Capacity**: Right-sizing and cost optimization

## Compliance

This module supports the following compliance standards:
- **SOC 2 Type II**: Container security and access controls
- **ISO 27001**: Information security management
- **CIS Benchmarks**: Container and Kubernetes security standards
- **NIST**: Cybersecurity framework compliance
