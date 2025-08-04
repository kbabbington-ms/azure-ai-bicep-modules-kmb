# Compute Infrastructure Module

This module deploys compute infrastructure for the AI Enclave including Virtual Machine Scale Sets and Azure Functions.

## Resources Deployed

- **Virtual Machine Scale Set (VMSS)**
  - Windows Server 2022 Datacenter Azure Edition
  - Auto-scaling based on CPU metrics
  - Premium SSD storage
  - Trusted Launch security
  - Azure AD authentication
  - Azure Monitor Agent

- **Azure Function App**
  - Elastic Premium plan
  - VNet integration
  - Private endpoints ready
  - System-assigned managed identity
  - Secure storage account backend

- **App Service Plan**
  - Elastic Premium tier
  - Auto-scaling enabled
  - Zone redundancy support

- **Storage Account**
  - Premium LRS
  - TLS 1.2 minimum
  - Infrastructure encryption
  - Private network access only

## Features

- **Security**: Trusted Launch VMs, Azure AD authentication, private network access
- **Monitoring**: Diagnostic settings for all resources
- **Scaling**: Auto-scaling for both VMSS and Function Apps
- **Compliance**: Enterprise security standards
- **High Availability**: Zone redundancy support

## Parameters

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| location | string | Azure region | resourceGroup().location |
| environment | string | Environment name | 'dev' |
| projectName | string | Project name | 'ai-enclave' |
| subnetId | string | Subnet resource ID | Required |
| logAnalyticsWorkspaceId | string | Log Analytics workspace ID | '' |
| vmAdminUsername | string | VM admin username | 'azureuser' |
| vmAdminPassword | securestring | VM admin password | Required |
| vmSize | string | VM size | 'Standard_D4s_v3' |
| instanceCount | int | Initial instance count | 2 |

## Outputs

| Output | Description |
|--------|-------------|
| vmssId | Virtual Machine Scale Set resource ID |
| vmssName | Virtual Machine Scale Set name |
| functionAppId | Function App resource ID |
| functionAppName | Function App name |
| functionAppDefaultHostName | Function App hostname |
| appServicePlanId | App Service Plan resource ID |
| storageAccountId | Storage Account resource ID |
| storageAccountName | Storage Account name |

## Usage

```bash
# Deploy with Azure CLI
az deployment group create \
  --resource-group myResourceGroup \
  --template-file main.bicep \
  --parameters main.parameters.json

# Deploy with PowerShell
New-AzResourceGroupDeployment \
  -ResourceGroupName "myResourceGroup" \
  -TemplateFile "main.bicep" \
  -TemplateParameterFile "main.parameters.json"
```

## Dependencies

- Virtual Network with compute subnet
- Log Analytics workspace (optional)
- Azure AD integration

## Security Considerations

- VMs use Trusted Launch security type
- Function Apps have private network access only
- Storage accounts deny public access
- All resources have diagnostic settings enabled
- Azure AD authentication for VMs
