# =============================================================================
# Azure Cognitive Services Bicep Module Deployment Script (PowerShell)
# =============================================================================
# This script deploys the Azure Cognitive Services Bicep module with 
# comprehensive validation and error handling for Windows environments.
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Target resource group name")]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false, HelpMessage = "Azure region for deployment")]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory = $false, HelpMessage = "Parameters file path")]
    [string]$ParametersFile = "cognitive-services.parameters.json",
    
    [Parameter(Mandatory = $false, HelpMessage = "Deployment name")]
    [string]$DeploymentName = "cognitive-services-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    
    [Parameter(Mandatory = $false, HelpMessage = "Azure subscription ID")]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $false, HelpMessage = "Only validate template, don't deploy")]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show what would be deployed without deploying")]
    [switch]$DryRun,
    
    [Parameter(Mandatory = $false, HelpMessage = "Skip template validation")]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory = $false, HelpMessage = "Enable preview features")]
    [switch]$EnablePreview,
    
    [Parameter(Mandatory = $false, HelpMessage = "Cleanup resources on deployment failure")]
    [switch]$CleanupOnFailure,
    
    [Parameter(Mandatory = $false, HelpMessage = "Show verbose output")]
    [switch]$Verbose
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$TemplateFile = Join-Path $ScriptDir "cognitive-services.bicep"
$ParametersFilePath = Join-Path $ScriptDir $ParametersFile

# =============================================================================
# FUNCTIONS
# =============================================================================

function Write-LogInfo {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-LogSuccess {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-LogWarning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-LogError {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Usage {
    @"
Azure Cognitive Services Bicep Module Deployment Script

DESCRIPTION:
    Deploy Azure Cognitive Services using Bicep template with comprehensive
    validation and error handling.

PARAMETERS:
    -ResourceGroupName      Target resource group name (required)
    -Location              Azure region for deployment (default: eastus)
    -ParametersFile        Parameters file path (default: cognitive-services.parameters.json)
    -DeploymentName        Deployment name (default: auto-generated)
    -SubscriptionId        Azure subscription ID (optional)
    -ValidateOnly          Only validate template, don't deploy
    -DryRun               Show what would be deployed without deploying
    -SkipValidation       Skip template validation
    -EnablePreview        Enable preview features
    -CleanupOnFailure     Cleanup resources on deployment failure
    -Verbose              Show verbose output

EXAMPLES:
    # Basic deployment
    .\deploy.ps1 -ResourceGroupName "myai-rg"

    # Deploy with custom parameters
    .\deploy.ps1 -ResourceGroupName "myai-rg" -ParametersFile "custom-parameters.json"

    # Validate only
    .\deploy.ps1 -ResourceGroupName "myai-rg" -ValidateOnly

    # Deploy to specific subscription
    .\deploy.ps1 -ResourceGroupName "myai-rg" -SubscriptionId "12345678-1234-1234-1234-123456789012"

    # Dry run to see planned changes
    .\deploy.ps1 -ResourceGroupName "myai-rg" -DryRun

"@
}

function Test-Prerequisites {
    Write-LogInfo "Checking prerequisites..."
    
    # Check if Azure PowerShell module is installed
    try {
        Import-Module Az -Force -ErrorAction Stop
        Write-LogSuccess "Azure PowerShell module loaded"
    }
    catch {
        Write-LogError "Azure PowerShell module is not installed. Please install it with: Install-Module -Name Az"
        throw
    }
    
    # Check if user is logged into Azure
    try {
        $context = Get-AzContext -ErrorAction Stop
        if (-not $context) {
            throw "No Azure context found"
        }
        Write-LogSuccess "Azure authentication confirmed for account: $($context.Account.Id)"
    }
    catch {
        Write-LogError "Not logged into Azure. Please run 'Connect-AzAccount' first."
        throw
    }
    
    # Check if template file exists
    if (-not (Test-Path $TemplateFile)) {
        Write-LogError "Template file not found: $TemplateFile"
        throw "Template file not found"
    }
    
    # Check if parameters file exists
    if (-not (Test-Path $ParametersFilePath)) {
        Write-LogError "Parameters file not found: $ParametersFilePath"
        throw "Parameters file not found"
    }
    
    Write-LogSuccess "Prerequisites check completed"
}

function Test-BicepTemplate {
    Write-LogInfo "Validating Bicep template..."
    
    try {
        $validationResult = Test-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFilePath `
            -ErrorAction Stop
        
        if ($validationResult.Count -eq 0) {
            Write-LogSuccess "Template validation passed"
            return $true
        }
        else {
            Write-LogError "Template validation failed:"
            $validationResult | ForEach-Object {
                Write-Host "  - $($_.Code): $($_.Message)" -ForegroundColor Red
            }
            return $false
        }
    }
    catch {
        Write-LogError "Template validation failed with exception: $($_.Exception.Message)"
        return $false
    }
}

function Show-DeploymentPlan {
    Write-LogInfo "Generating deployment plan..."
    
    try {
        # Note: What-If is available in newer versions of Azure PowerShell
        $whatIfResult = Get-AzResourceGroupDeploymentWhatIfResult `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFilePath `
            -ErrorAction Stop
        
        Write-LogSuccess "Deployment plan generated"
        Write-Host $whatIfResult -ForegroundColor Cyan
        return $true
    }
    catch {
        Write-LogWarning "Could not generate deployment plan (What-If might not be supported): $($_.Exception.Message)"
        return $false
    }
}

function Invoke-TemplateDeployment {
    Write-LogInfo "Starting deployment: $DeploymentName"
    Write-LogInfo "Resource Group: $ResourceGroupName"
    Write-LogInfo "Location: $Location"
    Write-LogInfo "Template: $TemplateFile"
    Write-LogInfo "Parameters: $ParametersFilePath"
    
    try {
        $deploymentResult = New-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFilePath `
            -Name $DeploymentName `
            -Force `
            -Verbose:$Verbose `
            -ErrorAction Stop
        
        Write-LogSuccess "Deployment completed successfully"
        
        # Display key outputs
        if ($deploymentResult.Outputs) {
            Write-LogInfo "Deployment outputs:"
            $deploymentResult.Outputs.GetEnumerator() | ForEach-Object {
                Write-Host "  $($_.Key): $($_.Value.Value)" -ForegroundColor Cyan
            }
            
            # Extract Cognitive Service details
            $serviceName = $deploymentResult.Outputs["cognitiveServiceName"]?.Value ?? "N/A"
            $serviceEndpoint = $deploymentResult.Outputs["endpoint"]?.Value ?? "N/A"
            $serviceId = $deploymentResult.Outputs["cognitiveServiceId"]?.Value ?? "N/A"
            
            Write-Host ""
            Write-LogSuccess "Cognitive Services Account Details:"
            Write-Host "  Name: $serviceName" -ForegroundColor Cyan
            Write-Host "  Endpoint: $serviceEndpoint" -ForegroundColor Cyan
            Write-Host "  Resource ID: $serviceId" -ForegroundColor Cyan
        }
        
        return $deploymentResult
    }
    catch {
        Write-LogError "Deployment failed: $($_.Exception.Message)"
        
        # Show deployment error details if available
        try {
            $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName -ErrorAction SilentlyContinue
            if ($deployment -and $deployment.ProvisioningState -eq "Failed") {
                Write-LogError "Deployment error details:"
                $deployment | Format-List ProvisioningState, StatusCode, StatusMessage | Out-String | Write-Host -ForegroundColor Red
            }
        }
        catch {
            # Ignore errors when trying to get deployment details
        }
        
        throw
    }
}

function Test-DeploymentStatus {
    Write-LogInfo "Checking deployment status..."
    
    try {
        $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName -ErrorAction Stop
        
        switch ($deployment.ProvisioningState) {
            "Succeeded" {
                Write-LogSuccess "Deployment status: $($deployment.ProvisioningState)"
                break
            }
            "Failed" {
                Write-LogError "Deployment status: $($deployment.ProvisioningState)"
                if ($deployment.StatusMessage) {
                    Write-Host $deployment.StatusMessage -ForegroundColor Red
                }
                break
            }
            { $_ -in @("Running", "Accepted") } {
                Write-LogInfo "Deployment status: $($deployment.ProvisioningState)"
                break
            }
            default {
                Write-LogWarning "Deployment status: $($deployment.ProvisioningState)"
                break
            }
        }
        
        return $deployment
    }
    catch {
        Write-LogError "Could not retrieve deployment status: $($_.Exception.Message)"
        return $null
    }
}

function Remove-FailedDeployment {
    if ($CleanupOnFailure) {
        Write-LogWarning "Cleaning up failed deployment..."
        try {
            Remove-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName -Force -ErrorAction SilentlyContinue
            Write-LogInfo "Cleanup completed"
        }
        catch {
            Write-LogWarning "Could not cleanup deployment: $($_.Exception.Message)"
        }
    }
}

# =============================================================================
# MAIN SCRIPT
# =============================================================================

try {
    Write-LogInfo "Starting Azure Cognitive Services deployment process"
    
    # Set subscription if provided
    if ($SubscriptionId) {
        Write-LogInfo "Setting Azure subscription context: $SubscriptionId"
        Set-AzContext -SubscriptionId $SubscriptionId
    }
    
    # Enable preview features if requested
    if ($EnablePreview) {
        Write-LogInfo "Preview features enabled"
        # Add any preview feature enablement here
    }
    
    # Check prerequisites
    Test-Prerequisites
    
    # Create resource group if it doesn't exist
    $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $resourceGroup) {
        Write-LogInfo "Creating resource group: $ResourceGroupName"
        $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
        Write-LogSuccess "Resource group created"
    }
    else {
        Write-LogInfo "Using existing resource group: $ResourceGroupName"
    }
    
    # Validation
    if (-not $SkipValidation) {
        $validationPassed = Test-BicepTemplate
        if (-not $validationPassed) {
            throw "Template validation failed"
        }
    }
    
    # Handle different execution modes
    if ($ValidateOnly) {
        Write-LogSuccess "Validation completed. Exiting without deployment."
        exit 0
    }
    elseif ($DryRun) {
        Show-DeploymentPlan
        Write-LogInfo "Dry run completed. No resources were deployed."
        exit 0
    }
    else {
        # Proceed with deployment
        $deploymentResult = Invoke-TemplateDeployment
        $deploymentStatus = Test-DeploymentStatus
        
        Write-LogSuccess "Cognitive Services deployment process completed"
        Write-LogInfo "Deployment name: $DeploymentName"
        Write-LogInfo "Resource group: $ResourceGroupName"
        
        # Return deployment result for potential script chaining
        return $deploymentResult
    }
}
catch {
    Write-LogError "Deployment process failed: $($_.Exception.Message)"
    Remove-FailedDeployment
    
    if ($Verbose) {
        Write-Host $_.Exception.StackTrace -ForegroundColor Red
    }
    
    exit 1
}
finally {
    Write-LogInfo "Deployment script execution completed"
}
