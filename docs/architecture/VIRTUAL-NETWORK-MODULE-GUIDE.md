# 🌐 Virtual Network Module - Implementation Guide

## 📋 **Quick Reference**

| **Property** | **Value** |
|--------------|-----------|
| **Module Name** | `virtual-network` |
| **Priority** | 🚩 **CRITICAL - TIER 1** |
| **Dependencies** | None (Foundation module) |
| **Deployment Time** | ~15-20 minutes |
| **Security Level** | Maximum |

---

## 🏗️ **Module Structure**

```
modules/virtual-network/
├── main.bicep                      # Main module orchestrator
├── main.parameters.json            # Default parameters
├── README.md                       # Module documentation
├── components/
│   ├── hub-vnet.bicep              # Hub virtual network
│   ├── spoke-vnet.bicep            # Spoke virtual networks
│   ├── network-security-groups.bicep # NSG configurations
│   ├── route-tables.bicep          # Custom routing
│   ├── nat-gateway.bicep           # Secure outbound internet
│   ├── bastion.bicep               # Secure administrative access
│   ├── ddos-protection.bicep       # DDoS protection
│   └── peering.bicep               # VNet peering configurations
├── policies/
│   ├── network-security-policies.json
│   └── network-compliance-policies.json
└── scripts/
    ├── deploy.ps1                 # PowerShell deployment
    ├── deploy.sh                  # Bash deployment
    └── validate.ps1               # Validation script
```

---

## 🎯 **AI Enclave Network Design**

### **Hub-Spoke Topology**
```
                    ┌─────────────────┐
                    │   Hub VNet      │
                    │ 10.0.0.0/16     │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │   Bastion   │ │
                    │ │ 10.0.1.0/24 │ │
                    │ └─────────────┘ │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │  Firewall   │ │
                    │ │ 10.0.2.0/24 │ │
                    │ └─────────────┘ │
                    │                 │
                    │ ┌─────────────┐ │
                    │ │   Gateway   │ │
                    │ │ 10.0.3.0/24 │ │
                    │ └─────────────┘ │
                    └─────────────────┘
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
┌───────▼────────┐  ┌────────▼────────┐  ┌───────▼────────┐
│ AI Services    │  │ Compute         │  │ Data Services  │
│ Spoke VNet     │  │ Spoke VNet      │  │ Spoke VNet     │
│ 10.1.0.0/16    │  │ 10.2.0.0/16     │  │ 10.3.0.0/16    │
└────────────────┘  └─────────────────┘  └────────────────┘
```

### **Subnet Segmentation**

#### **🏛️ Hub VNet (10.0.0.0/16)**
| **Subnet** | **CIDR** | **Purpose** | **NSG Rules** |
|------------|----------|-------------|---------------|
| **AzureBastionSubnet** | 10.0.1.0/24 | Secure admin access | Azure managed |
| **AzureFirewallSubnet** | 10.0.2.0/24 | Centralized firewall | Azure managed |
| **GatewaySubnet** | 10.0.3.0/24 | VPN/ExpressRoute | Azure managed |
| **SharedServicesSubnet** | 10.0.4.0/24 | DNS, monitoring | Restricted |

#### **🤖 AI Services Spoke (10.1.0.0/16)**
| **Subnet** | **CIDR** | **Purpose** | **Services** |
|------------|----------|-------------|--------------|
| **OpenAISubnet** | 10.1.1.0/24 | Azure OpenAI | Private endpoints |
| **CognitiveServicesSubnet** | 10.1.2.0/24 | Cognitive Services | Private endpoints |
| **MLWorkspaceSubnet** | 10.1.3.0/24 | ML Workspace | Private endpoints |
| **AIFoundrySubnet** | 10.1.4.0/24 | AI Foundry | Private endpoints |
| **DocumentIntelSubnet** | 10.1.5.0/24 | Document Intelligence | Private endpoints |
| **CognitiveSearchSubnet** | 10.1.6.0/24 | Cognitive Search | Private endpoints |

#### **🖥️ Compute Spoke (10.2.0.0/16)**
| **Subnet** | **CIDR** | **Purpose** | **Services** |
|------------|----------|-------------|--------------|
| **AKSSubnet** | 10.2.1.0/23 | Kubernetes cluster | Container workloads |
| **VMSSSubnet** | 10.2.3.0/24 | VM Scale Sets | AI training VMs |
| **ContainerAppsSubnet** | 10.2.4.0/24 | Container Apps | Managed containers |
| **FunctionAppsSubnet** | 10.2.5.0/24 | Function Apps | Serverless compute |

#### **🗄️ Data Spoke (10.3.0.0/16)**
| **Subnet** | **CIDR** | **Purpose** | **Services** |
|------------|----------|-------------|--------------|
| **StorageSubnet** | 10.3.1.0/24 | Storage accounts | Private endpoints |
| **DatabaseSubnet** | 10.3.2.0/24 | Databases | SQL, Cosmos, Redis |
| **KeyVaultSubnet** | 10.3.3.0/24 | Key Vault | Private endpoints |
| **BackupSubnet** | 10.3.4.0/24 | Backup services | Recovery vault |

---

## 🔒 **Security Configuration**

### **Network Security Groups (NSGs)**

#### **🛡️ AI Services NSG Rules**
```bicep
// High-security rules for AI services
var aiServicesNsgRules = [
  {
    name: 'AllowHTTPSInbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'DenyAllInbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowVNetOutbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 100
      direction: 'Outbound'
    }
  }
  {
    name: 'DenyInternetOutbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      access: 'Deny'
      priority: 200
      direction: 'Outbound'
    }
  }
]
```

#### **💻 Compute NSG Rules**
```bicep
// Compute-specific security rules
var computeNsgRules = [
  {
    name: 'AllowHTTPInbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRanges: ['80', '443']
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  {
    name: 'AllowKubernetesAPI'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
]
```

### **🛣️ Route Tables**

#### **AI Services Route Table**
```bicep
var aiServicesRoutes = [
  {
    name: 'RouteToInternet'
    properties: {
      addressPrefix: '0.0.0.0/0'
      nextHopType: 'VirtualAppliance'
      nextHopIpAddress: '10.0.2.4' // Azure Firewall IP
    }
  }
  {
    name: 'RouteToHub'
    properties: {
      addressPrefix: '10.0.0.0/16'
      nextHopType: 'VNetLocal'
    }
  }
  {
    name: 'RouteToCompute'
    properties: {
      addressPrefix: '10.2.0.0/16'
      nextHopType: 'VirtualNetworkGateway'
    }
  }
]
```

---

## 📦 **Implementation Templates**

### **1. main.bicep - Module Orchestrator**

```bicep
@description('Virtual Network module for AI Enclave')
param location string = resourceGroup().location
param environment string = 'dev'
param projectName string = 'ai-enclave'
param enableDdosProtection bool = true
param enableBastion bool = true
param enableFirewall bool = true

// Hub VNet Configuration
module hubVNet './components/hub-vnet.bicep' = {
  name: 'hubVNet-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    enableDdosProtection: enableDdosProtection
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'AzureBastionSubnet'
        addressPrefix: '10.0.1.0/24'
        delegation: null
        serviceEndpoints: []
      }
      {
        name: 'AzureFirewallSubnet'
        addressPrefix: '10.0.2.0/24'
        delegation: null
        serviceEndpoints: []
      }
      {
        name: 'GatewaySubnet'
        addressPrefix: '10.0.3.0/24'
        delegation: null
        serviceEndpoints: []
      }
      {
        name: 'SharedServicesSubnet'
        addressPrefix: '10.0.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.KeyVault', 'Microsoft.Storage']
      }
    ]
  }
}

// AI Services Spoke VNet
module aiServicesSpoke './components/spoke-vnet.bicep' = {
  name: 'aiServicesSpoke-deployment'
  params: {
    location: location
    environment: environment
    spokeName: 'ai-services'
    addressPrefix: '10.1.0.0/16'
    hubVNetId: hubVNet.outputs.vnetId
    subnets: [
      {
        name: 'OpenAISubnet'
        addressPrefix: '10.1.1.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'CognitiveServicesSubnet'
        addressPrefix: '10.1.2.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'MLWorkspaceSubnet'
        addressPrefix: '10.1.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.MachineLearningServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'AIFoundrySubnet'
        addressPrefix: '10.1.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'DocumentIntelSubnet'
        addressPrefix: '10.1.5.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.CognitiveServices']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'CognitiveSearchSubnet'
        addressPrefix: '10.1.6.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Search']
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
  dependsOn: [hubVNet]
}

// Compute Spoke VNet
module computeSpoke './components/spoke-vnet.bicep' = {
  name: 'computeSpoke-deployment'
  params: {
    location: location
    environment: environment
    spokeName: 'compute'
    addressPrefix: '10.2.0.0/16'
    hubVNetId: hubVNet.outputs.vnetId
    subnets: [
      {
        name: 'AKSSubnet'
        addressPrefix: '10.2.1.0/23'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage', 'Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'VMSSSubnet'
        addressPrefix: '10.2.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'ContainerAppsSubnet'
        addressPrefix: '10.2.4.0/24'
        delegation: 'Microsoft.App/environments'
        serviceEndpoints: []
        privateEndpointNetworkPolicies: 'Enabled'
      }
      {
        name: 'FunctionAppsSubnet'
        addressPrefix: '10.2.5.0/24'
        delegation: 'Microsoft.Web/serverFarms'
        serviceEndpoints: ['Microsoft.Storage', 'Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Enabled'
      }
    ]
  }
  dependsOn: [hubVNet]
}

// Data Services Spoke VNet
module dataSpoke './components/spoke-vnet.bicep' = {
  name: 'dataSpoke-deployment'
  params: {
    location: location
    environment: environment
    spokeName: 'data'
    addressPrefix: '10.3.0.0/16'
    hubVNetId: hubVNet.outputs.vnetId
    subnets: [
      {
        name: 'StorageSubnet'
        addressPrefix: '10.3.1.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'DatabaseSubnet'
        addressPrefix: '10.3.2.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Sql', 'Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'KeyVaultSubnet'
        addressPrefix: '10.3.3.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.KeyVault']
        privateEndpointNetworkPolicies: 'Disabled'
      }
      {
        name: 'BackupSubnet'
        addressPrefix: '10.3.4.0/24'
        delegation: null
        serviceEndpoints: ['Microsoft.Storage']
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
  }
  dependsOn: [hubVNet]
}

// Azure Bastion (Optional)
module bastion './components/bastion.bicep' = if (enableBastion) {
  name: 'bastion-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    vnetName: hubVNet.outputs.vnetName
    bastionSubnetId: hubVNet.outputs.bastionSubnetId
  }
  dependsOn: [hubVNet]
}

// NAT Gateway for secure outbound
module natGateway './components/nat-gateway.bicep' = {
  name: 'natGateway-deployment'
  params: {
    location: location
    environment: environment
    projectName: projectName
    subnetsToAssociate: [
      aiServicesSpoke.outputs.subnetIds[0] // OpenAI subnet
      computeSpoke.outputs.subnetIds[0]    // AKS subnet
    ]
  }
  dependsOn: [aiServicesSpoke, computeSpoke]
}

// Outputs
output hubVNetId string = hubVNet.outputs.vnetId
output aiServicesSpokeId string = aiServicesSpoke.outputs.vnetId
output computeSpokeId string = computeSpoke.outputs.vnetId
output dataServicesSpokeId string = dataSpoke.outputs.vnetId
output bastionFqdn string = enableBastion ? bastion.outputs.bastionFqdn : ''
output networkSecurityGroupIds object = {
  aiServices: aiServicesSpoke.outputs.nsgId
  compute: computeSpoke.outputs.nsgId
  dataServices: dataSpoke.outputs.nsgId
}
```

### **2. main.parameters.json - Default Configuration**

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "East US 2"
    },
    "environment": {
      "value": "dev"
    },
    "projectName": {
      "value": "secure-ai-enclave"
    },
    "enableDdosProtection": {
      "value": true
    },
    "enableBastion": {
      "value": true
    },
    "enableFirewall": {
      "value": true
    }
  }
}
```

---

## 🚀 **Deployment Instructions**

### **PowerShell Deployment**
```powershell
# Set deployment parameters
$resourceGroupName = "rg-ai-enclave-network-dev"
$location = "East US 2"
$templateFile = "./main.bicep"
$parametersFile = "./main.parameters.json"

# Create resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Deploy the virtual network module
New-AzResourceGroupDeployment `
  -ResourceGroupName $resourceGroupName `
  -TemplateFile $templateFile `
  -TemplateParameterFile $parametersFile `
  -Verbose
```

### **Azure CLI Deployment**
```bash
#!/bin/bash

# Set deployment parameters
RESOURCE_GROUP="rg-ai-enclave-network-dev"
LOCATION="eastus2"
TEMPLATE_FILE="./main.bicep"
PARAMETERS_FILE="./main.parameters.json"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Deploy the virtual network module
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file $TEMPLATE_FILE \
  --parameters @$PARAMETERS_FILE \
  --verbose
```

---

## ✅ **Validation Checklist**

### **🔍 Post-Deployment Validation**
- [ ] Hub VNet deployed with correct address space (10.0.0.0/16)
- [ ] All three spoke VNets deployed and peered to hub
- [ ] NSGs applied to all subnets with correct rules
- [ ] Route tables configured for traffic flow through firewall
- [ ] Bastion host accessible for secure admin access
- [ ] NAT Gateway associated with appropriate subnets
- [ ] DDoS Protection enabled on hub VNet
- [ ] Private endpoint network policies disabled where needed

### **🧪 Connectivity Tests**
```powershell
# Test VNet peering
Test-NetConnection -ComputerName "10.1.1.4" -Port 443

# Test bastion connectivity
Get-AzBastion -ResourceGroupName $resourceGroupName

# Validate NSG rules
Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName
```

---

## 📊 **Monitoring & Troubleshooting**

### **🔧 Common Issues**

| **Issue** | **Cause** | **Solution** |
|-----------|-----------|--------------|
| Peering fails | Overlapping address spaces | Update address prefixes |
| NSG blocks traffic | Incorrect rule priority | Review NSG rule order |
| Bastion unreachable | Subnet naming incorrect | Use exact "AzureBastionSubnet" |
| Private endpoints fail | Network policies enabled | Disable on PE subnets |

### **📈 Monitoring Queries**
```kusto
// VNet flow logs analysis
AzureNetworkAnalytics_CL
| where SubType_s == "FlowLog"
| where TimeGenerated > ago(1h)
| summarize count() by SrcIP_s, DestIP_s, DestPort_d
| order by count_ desc
```

---

## 🔄 **Next Steps**

1. **Deploy this virtual network foundation first**
2. **Implement Private DNS Zones module** for name resolution
3. **Add Azure Firewall module** for centralized security
4. **Configure monitoring module** for network observability
5. **Integrate with AI services modules** using private endpoints

**This virtual network module provides the secure foundation for your AI enclave. All subsequent modules will build on this network infrastructure.**
