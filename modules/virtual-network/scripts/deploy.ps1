# Set deployment parameters
$resourceGroupName = "rg-ai-enclave-network-dev"
$location = "East US 2"
$templateFile = ".\main.bicep"
$parametersFile = ".\main.parameters.json"

# Check if resource group exists, create if it doesn't
$resourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-Host "Creating resource group: $resourceGroupName" -ForegroundColor Green
    New-AzResourceGroup -Name $resourceGroupName -Location $location
}

# Deploy the virtual network module
Write-Host "Deploying Virtual Network module..." -ForegroundColor Green
$deployment = New-AzResourceGroupDeployment `
    -ResourceGroupName $resourceGroupName `
    -TemplateFile $templateFile `
    -TemplateParameterFile $parametersFile `
    -Verbose

# Display deployment results
if ($deployment.ProvisioningState -eq "Succeeded") {
    Write-Host "Virtual Network deployment completed successfully!" -ForegroundColor Green
    Write-Host "Hub VNet ID: $($deployment.Outputs.hubVNetId.Value)" -ForegroundColor Yellow
    Write-Host "Bastion FQDN: $($deployment.Outputs.bastionFqdn.Value)" -ForegroundColor Yellow
} else {
    Write-Host "Deployment failed with state: $($deployment.ProvisioningState)" -ForegroundColor Red
}
