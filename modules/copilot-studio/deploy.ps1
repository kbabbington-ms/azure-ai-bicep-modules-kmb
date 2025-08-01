# Azure Copilot Studio Module Deployment Script
# This script deploys the Copilot Studio module with enterprise-grade configuration

param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $true)]
    [string]$CopilotStudioName,
    
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId = "",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory = $false)]
    [string]$PowerPlatformRegion = "unitedstates",
    
    [Parameter(Mandatory = $false)]
    [string]$DeploymentName = "copilot-studio-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    
    [Parameter(Mandatory = $false)]
    [string]$TemplateFile = "main.bicep",
    
    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = "main.parameters.json",
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Function to write colored output
function Write-ColoredOutput {
    param(
        [string]$Message,
        [string]$Type = "INFO"
    )
    
    switch ($Type) {
        "INFO" { Write-Host "[INFO] $Message" -ForegroundColor Blue }
        "SUCCESS" { Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
        "WARNING" { Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "[ERROR] $Message" -ForegroundColor Red }
    }
}

# Function to show usage
function Show-Usage {
    Write-Host @"
Azure Copilot Studio Module Deployment Script

SYNOPSIS
    Deploy Azure Copilot Studio Module with enterprise-grade configuration

SYNTAX
    .\deploy.ps1 -ResourceGroupName <String> -CopilotStudioName <String> [<CommonParameters>]

PARAMETERS
    -ResourceGroupName <String>
        Name of the resource group (Required)
        
    -CopilotStudioName <String>
        Name for the Copilot Studio environment (Required)
        
    -SubscriptionId <String>
        Azure subscription ID (Optional)
        
    -Location <String>
        Azure region (Default: eastus)
        
    -PowerPlatformRegion <String>
        Power Platform region (Default: unitedstates)
        
    -DeploymentName <String>
        Deployment name (Default: auto-generated)
        
    -TemplateFile <String>
        Bicep template file (Default: main.bicep)
        
    -ParametersFile <String>
        Parameters file (Default: main.parameters.json)
        
    -ValidateOnly
        Only validate the template without deploying
        
    -Help
        Show this help message

EXAMPLES
    .\deploy.ps1 -ResourceGroupName "myResourceGroup" -CopilotStudioName "mycopilot"
    
    .\deploy.ps1 -ResourceGroupName "myResourceGroup" -CopilotStudioName "mycopilot" -Location "westus2" -PowerPlatformRegion "unitedstates"
    
    .\deploy.ps1 -ResourceGroupName "myResourceGroup" -CopilotStudioName "mycopilot" -ValidateOnly
"@
}

# Show help if requested
if ($Help) {
    Show-Usage
    return
}

# Validate required parameters
if (-not $ResourceGroupName) {
    Write-ColoredOutput "Resource group name is required" "ERROR"
    Show-Usage
    return
}

if (-not $CopilotStudioName) {
    Write-ColoredOutput "Copilot Studio name is required" "ERROR"
    Show-Usage
    return
}

# Check if Azure PowerShell module is installed
if (-not (Get-Module -ListAvailable -Name Az)) {
    Write-ColoredOutput "Azure PowerShell module is not installed. Please install it first." "ERROR"
    Write-ColoredOutput "Run: Install-Module -Name Az -AllowClobber -Scope CurrentUser" "INFO"
    return
}

# Import required modules
Import-Module Az.Accounts -Force
Import-Module Az.Resources -Force

# Check if logged in to Azure
try {
    $context = Get-AzContext -ErrorAction Stop
    if (-not $context) {
        throw "Not logged in"
    }
}
catch {
    Write-ColoredOutput "Not logged in to Azure. Please run 'Connect-AzAccount' first." "ERROR"
    return
}

# Set subscription if provided
if ($SubscriptionId) {
    Write-ColoredOutput "Setting subscription to $SubscriptionId" "INFO"
    try {
        Set-AzContext -SubscriptionId $SubscriptionId -ErrorAction Stop
    }
    catch {
        Write-ColoredOutput "Failed to set subscription: $($_.Exception.Message)" "ERROR"
        return
    }
}

# Get current subscription info
$currentContext = Get-AzContext
$subscriptionName = $currentContext.Subscription.Name
$subscriptionId = $currentContext.Subscription.Id
Write-ColoredOutput "Using subscription: $subscriptionName ($subscriptionId)" "INFO"

# Check if resource group exists
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $resourceGroup) {
    Write-ColoredOutput "Resource group '$ResourceGroupName' does not exist." "WARNING"
    $createRg = Read-Host "Create resource group '$ResourceGroupName' in location '$Location'? (y/N)"
    if ($createRg -eq 'y' -or $createRg -eq 'Y') {
        Write-ColoredOutput "Creating resource group '$ResourceGroupName'" "INFO"
        try {
            New-AzResourceGroup -Name $ResourceGroupName -Location $Location -ErrorAction Stop
            Write-ColoredOutput "Resource group created successfully" "SUCCESS"
        }
        catch {
            Write-ColoredOutput "Failed to create resource group: $($_.Exception.Message)" "ERROR"
            return
        }
    }
    else {
        Write-ColoredOutput "Deployment cancelled" "ERROR"
        return
    }
}

# Check if template files exist
if (-not (Test-Path $TemplateFile)) {
    Write-ColoredOutput "Template file '$TemplateFile' not found" "ERROR"
    return
}

if (-not (Test-Path $ParametersFile)) {
    Write-ColoredOutput "Parameters file '$ParametersFile' not found" "ERROR"
    return
}

# Validate Power Platform region
$validRegions = @("unitedstates", "europe", "asia", "australia", "india", "japan", "canada", "southamerica", "unitedkingdom", "france", "germany", "switzerland", "norway", "korea", "southafrica")
if ($PowerPlatformRegion -notin $validRegions) {
    Write-ColoredOutput "Invalid Power Platform region: $PowerPlatformRegion" "ERROR"
    Write-ColoredOutput "Valid regions: $($validRegions -join ', ')" "ERROR"
    return
}

Write-ColoredOutput "Starting deployment with the following configuration:" "INFO"
Write-Host "  Resource Group: $ResourceGroupName"
Write-Host "  Location: $Location"
Write-Host "  Copilot Studio Name: $CopilotStudioName"
Write-Host "  Power Platform Region: $PowerPlatformRegion"
Write-Host "  Deployment Name: $DeploymentName"
Write-Host "  Template File: $TemplateFile"
Write-Host "  Parameters File: $ParametersFile"
Write-Host "  Validate Only: $ValidateOnly"

# Confirm deployment
if (-not $ValidateOnly) {
    Write-Host ""
    $proceed = Read-Host "Proceed with deployment? (y/N)"
    if ($proceed -ne 'y' -and $proceed -ne 'Y') {
        Write-ColoredOutput "Deployment cancelled" "ERROR"
        return
    }
}

# Prepare deployment parameters
$deploymentParameters = @{
    copilotStudioName = $CopilotStudioName
    location = $Location
    powerPlatformRegion = $PowerPlatformRegion
}

# Validate template
Write-ColoredOutput "Validating Bicep template..." "INFO"
try {
    $validationResult = Test-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile `
        -TemplateParameterObject $deploymentParameters `
        -ErrorAction Stop
    
    if ($validationResult) {
        Write-ColoredOutput "Template validation failed:" "ERROR"
        $validationResult | ForEach-Object { Write-ColoredOutput "  $($_.Message)" "ERROR" }
        return
    }
    else {
        Write-ColoredOutput "Template validation passed" "SUCCESS"
    }
}
catch {
    Write-ColoredOutput "Template validation failed: $($_.Exception.Message)" "ERROR"
    return
}

# Exit if validate-only mode
if ($ValidateOnly) {
    Write-ColoredOutput "Validation completed successfully" "SUCCESS"
    return
}

# Deploy template
Write-ColoredOutput "Deploying Copilot Studio module..." "INFO"
try {
    $deployment = New-AzResourceGroupDeployment `
        -ResourceGroupName $ResourceGroupName `
        -Name $DeploymentName `
        -TemplateFile $TemplateFile `
        -TemplateParameterFile $ParametersFile `
        -TemplateParameterObject $deploymentParameters `
        -ErrorAction Stop `
        -Verbose
    
    Write-ColoredOutput "Deployment completed successfully!" "SUCCESS"
    
    # Show outputs
    if ($deployment.Outputs) {
        Write-ColoredOutput "Deployment outputs:" "INFO"
        $deployment.Outputs | ConvertTo-Json -Depth 10 | Write-Host
    }
    
    # Show important information
    Write-ColoredOutput "Important Information:" "INFO"
    Write-Host "  Deployment Name: $DeploymentName"
    Write-Host "  Resource Group: $ResourceGroupName"
    Write-Host "  Copilot Studio Name: $CopilotStudioName"
    
    Write-ColoredOutput "Next Steps:" "INFO"
    Write-Host "1. Navigate to Power Platform Admin Center"
    Write-Host "2. Configure your Copilot Studio environment"
    Write-Host "3. Set up authentication and security policies"
    Write-Host "4. Configure bot channels as needed"
    Write-Host "5. Monitor deployment in Azure portal"
}
catch {
    Write-ColoredOutput "Deployment failed: $($_.Exception.Message)" "ERROR"
    return
}

Write-ColoredOutput "Copilot Studio module deployment completed!" "SUCCESS"
