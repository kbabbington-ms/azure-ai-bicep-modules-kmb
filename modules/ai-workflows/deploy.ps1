# AI Workflows Module Deployment Script (PowerShell)
# This script deploys the AI Workflows module with comprehensive validation and monitoring

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = $env:AZURE_RESOURCE_GROUP,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = $env:AZURE_LOCATION,
    
    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = "main.parameters.json",
    
    [Parameter(Mandatory = $false)]
    [string]$Subscription = $env:AZURE_SUBSCRIPTION_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$DeploymentName,
    
    [Parameter(Mandatory = $false)]
    [hashtable]$AdditionalTags,
    
    [Parameter(Mandatory = $false)]
    [switch]$WhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$Monitor,
    
    [Parameter(Mandatory = $false)]
    [switch]$Force,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModuleName = "ai-workflows"
$TemplateFile = Join-Path $ScriptDir "main.bicep"
$DefaultParametersFile = Join-Path $ScriptDir "main.parameters.json"

if (-not $DeploymentName) {
    $Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $DeploymentName = "$ModuleName-$Timestamp"
}

# Color configuration for output
$Colors = @{
    Info    = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error   = "Red"
    Header  = "Magenta"
}

# Logging functions
function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Colors.Info
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Colors.Success
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Colors.Warning
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Colors.Error
}

function Write-LogHeader {
    param([string]$Message)
    Write-Host "[DEPLOY] $Message" -ForegroundColor $Colors.Header
}

# Help function
function Show-Help {
    @"
AI Workflows Module Deployment Script (PowerShell)

Usage: .\deploy.ps1 [PARAMETERS]

Parameters:
    -ResourceGroup          Resource group name (required)
    -Location               Azure region for deployment (optional)
    -ParametersFile         Parameters file path (default: main.parameters.json)
    -Subscription           Azure subscription ID or name (optional)
    -DeploymentName         Custom deployment name (optional)
    -AdditionalTags         Additional tags as hashtable (optional)
    -WhatIf                 Run what-if analysis without deploying
    -ValidateOnly           Validate template without deploying
    -Monitor                Monitor deployment progress
    -Force                  Skip confirmations and deploy directly
    -Help                   Show this help message

Examples:
    # Basic deployment
    .\deploy.ps1 -ResourceGroup "my-rg" -Location "eastus"

    # Deployment with custom parameters
    .\deploy.ps1 -ResourceGroup "my-rg" -ParametersFile "custom.parameters.json"

    # What-if analysis
    .\deploy.ps1 -ResourceGroup "my-rg" -WhatIf

    # Validate template
    .\deploy.ps1 -ResourceGroup "my-rg" -ValidateOnly

    # Full deployment with monitoring
    .\deploy.ps1 -ResourceGroup "my-rg" -Location "westus2" -Monitor -Force

Environment Variables:
    AZURE_RESOURCE_GROUP        Default resource group
    AZURE_LOCATION              Default location
    AZURE_SUBSCRIPTION_ID       Default subscription

"@
}

# Validate prerequisites
function Test-Prerequisites {
    Write-LogHeader "Validating Prerequisites"
    
    # Check if Azure PowerShell is installed
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-LogError "Azure PowerShell module is not installed. Please install Azure PowerShell first."
        exit 1
    }
    
    # Check Azure PowerShell login status
    try {
        $context = Get-AzContext
        if (-not $context) {
            Write-LogError "Not logged in to Azure. Please run 'Connect-AzAccount' first."
            exit 1
        }
    }
    catch {
        Write-LogError "Not logged in to Azure. Please run 'Connect-AzAccount' first."
        exit 1
    }
    
    # Check if template file exists
    if (-not (Test-Path $TemplateFile)) {
        Write-LogError "Template file not found: $TemplateFile"
        exit 1
    }
    
    # Resolve parameters file path
    if (-not [System.IO.Path]::IsPathRooted($ParametersFile)) {
        $ParametersFile = Join-Path $ScriptDir $ParametersFile
    }
    
    # Check if parameters file exists
    if (-not (Test-Path $ParametersFile)) {
        Write-LogError "Parameters file not found: $ParametersFile"
        exit 1
    }
    
    Write-LogSuccess "Prerequisites validated"
}

# Set defaults and validate required parameters
function Set-Defaults {
    if (-not $ResourceGroup) {
        Write-LogError "Resource group is required. Use -ResourceGroup parameter or set AZURE_RESOURCE_GROUP environment variable."
        exit 1
    }
}

# Set Azure subscription
function Set-AzureSubscription {
    if ($Subscription) {
        Write-LogInfo "Setting Azure subscription to: $Subscription"
        try {
            Set-AzContext -Subscription $Subscription | Out-Null
        }
        catch {
            Write-LogError "Failed to set subscription: $Subscription"
            Write-LogError $_.Exception.Message
            exit 1
        }
    }
    
    # Display current subscription
    $currentContext = Get-AzContext
    Write-LogInfo "Current subscription: $($currentContext.Subscription.Name)"
}

# Create resource group if it doesn't exist
function Ensure-ResourceGroup {
    Write-LogInfo "Checking resource group: $ResourceGroup"
    
    $rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
    
    if (-not $rg) {
        if (-not $Location) {
            Write-LogError "Resource group doesn't exist and location is not specified. Use -Location parameter."
            exit 1
        }
        
        Write-LogInfo "Creating resource group: $ResourceGroup in $Location"
        try {
            New-AzResourceGroup -Name $ResourceGroup -Location $Location | Out-Null
            Write-LogSuccess "Resource group created successfully"
        }
        catch {
            Write-LogError "Failed to create resource group"
            Write-LogError $_.Exception.Message
            exit 1
        }
    }
    else {
        Write-LogSuccess "Resource group already exists"
    }
}

# Validate Bicep template
function Test-BicepTemplate {
    Write-LogHeader "Validating Bicep Template"
    
    Write-LogInfo "Running Bicep compilation..."
    try {
        az bicep build --file $TemplateFile 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-LogSuccess "Bicep template compilation successful"
        }
        else {
            Write-LogError "Bicep template compilation failed"
            exit 1
        }
    }
    catch {
        Write-LogError "Bicep compilation failed"
        Write-LogError $_.Exception.Message
        exit 1
    }
    
    Write-LogInfo "Running deployment validation..."
    try {
        $validation = Test-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroup `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFile
        
        if ($validation.Count -eq 0) {
            Write-LogSuccess "Template validation successful"
        }
        else {
            Write-LogError "Template validation failed:"
            $validation | ForEach-Object {
                Write-LogError "- $($_.Message)"
            }
            exit 1
        }
    }
    catch {
        Write-LogError "Template validation failed"
        Write-LogError $_.Exception.Message
        exit 1
    }
}

# Run what-if analysis
function Invoke-WhatIfAnalysis {
    Write-LogHeader "Running What-If Analysis"
    
    try {
        $whatIfResult = Get-AzResourceGroupDeploymentWhatIfResult `
            -ResourceGroupName $ResourceGroup `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFile
        
        $whatIfResult | Format-Table -AutoSize
        Write-LogSuccess "What-if analysis completed"
    }
    catch {
        Write-LogError "What-if analysis failed"
        Write-LogError $_.Exception.Message
        exit 1
    }
}

# Deploy template
function Invoke-TemplateDeployment {
    Write-LogHeader "Deploying AI Workflows Module"
    
    $deploymentParams = @{
        ResourceGroupName     = $ResourceGroup
        Name                  = $DeploymentName
        TemplateFile          = $TemplateFile
        TemplateParameterFile = $ParametersFile
    }
    
    Write-LogInfo "Starting deployment: $DeploymentName"
    Write-LogInfo "Resource Group: $ResourceGroup"
    Write-LogInfo "Template: $TemplateFile"
    Write-LogInfo "Parameters: $ParametersFile"
    
    try {
        $deployment = New-AzResourceGroupDeployment @deploymentParams
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-LogSuccess "Deployment completed successfully"
            return $deployment
        }
        else {
            Write-LogError "Deployment failed with state: $($deployment.ProvisioningState)"
            return $null
        }
    }
    catch {
        Write-LogError "Deployment failed"
        Write-LogError $_.Exception.Message
        return $null
    }
}

# Monitor deployment
function Watch-DeploymentProgress {
    Write-LogHeader "Monitoring Deployment Progress"
    
    do {
        try {
            $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -Name $DeploymentName
            $status = $deployment.ProvisioningState
            
            Write-LogInfo "Deployment status: $status"
            
            switch ($status) {
                "Succeeded" {
                    Write-LogSuccess "Deployment completed successfully"
                    return $deployment
                }
                "Failed" {
                    Write-LogError "Deployment failed"
                    Show-DeploymentErrors $deployment
                    return $null
                }
                "Canceled" {
                    Write-LogWarning "Deployment was canceled"
                    return $null
                }
                default {
                    Write-LogInfo "Deployment in progress... (Status: $status)"
                    Start-Sleep -Seconds 30
                }
            }
        }
        catch {
            Write-LogError "Unable to retrieve deployment status"
            Write-LogError $_.Exception.Message
            break
        }
    } while ($status -in @("Running", "Accepted"))
}

# Show deployment errors
function Show-DeploymentErrors {
    param($Deployment)
    
    Write-LogHeader "Deployment Error Details"
    
    if ($Deployment.Error) {
        $Deployment.Error | ConvertTo-Json -Depth 10 | Write-Host
    }
    else {
        Write-LogInfo "No detailed error information available"
    }
}

# Show deployment outputs
function Show-DeploymentOutputs {
    param($Deployment)
    
    Write-LogHeader "Deployment Outputs"
    
    if ($Deployment.Outputs -and $Deployment.Outputs.Count -gt 0) {
        $Deployment.Outputs | ConvertTo-Json -Depth 5 | Write-Host
    }
    else {
        Write-LogInfo "No outputs available for this deployment"
    }
}

# Main execution function
function Invoke-Main {
    if ($Help) {
        Show-Help
        return
    }
    
    Write-LogHeader "AI Workflows Module Deployment"
    Write-Host "Starting deployment at $(Get-Date)"
    Write-Host
    
    # Validate and initialize
    Set-Defaults
    Test-Prerequisites
    Set-AzureSubscription
    Ensure-ResourceGroup
    
    # Run what-if if requested
    if ($WhatIf) {
        Invoke-WhatIfAnalysis
        return
    }
    
    # Validate template
    Test-BicepTemplate
    
    # Exit if validation only
    if ($ValidateOnly) {
        Write-LogSuccess "Template validation completed"
        return
    }
    
    # Confirm deployment if not forced
    if (-not $Force) {
        Write-Host
        Write-LogWarning "About to deploy AI Workflows module:"
        Write-LogInfo "Resource Group: $ResourceGroup"
        Write-LogInfo "Deployment Name: $DeploymentName"
        Write-LogInfo "Template: $TemplateFile"
        Write-LogInfo "Parameters: $ParametersFile"
        Write-Host
        
        $confirmation = Read-Host "Do you want to continue? (y/N)"
        if ($confirmation -notmatch '^[Yy]$') {
            Write-LogInfo "Deployment canceled by user"
            return
        }
    }
    
    # Deploy template
    $deployment = Invoke-TemplateDeployment
    
    if ($deployment) {
        # Monitor deployment if requested
        if ($Monitor) {
            $deployment = Watch-DeploymentProgress
        }
        
        if ($deployment) {
            # Show outputs
            Show-DeploymentOutputs $deployment
            
            Write-LogSuccess "AI Workflows module deployment completed successfully"
            Write-Host "Deployment Name: $DeploymentName"
            Write-Host "Resource Group: $ResourceGroup"
            Write-Host "Completed at: $(Get-Date)"
        }
    }
    else {
        Write-LogError "Deployment failed"
        exit 1
    }
}

# Execute main function
try {
    Invoke-Main
}
catch {
    Write-LogError "Unexpected error occurred:"
    Write-LogError $_.Exception.Message
    Write-LogError $_.ScriptStackTrace
    exit 1
}
