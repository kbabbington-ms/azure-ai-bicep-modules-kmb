# Azure OpenAI Service Deployment Script
# This PowerShell script deploys the Azure OpenAI module with comprehensive validation and monitoring

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory = $false)]
    [string]$TemplateFile = "main.bicep",
    
    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = "main.parameters.json",
    
    [Parameter(Mandatory = $false)]
    [string]$DeploymentName = "openai-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    
    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun,
    
    [Parameter(Mandatory = $false)]
    [switch]$Monitor,
    
    [Parameter(Mandatory = $false)]
    [int]$TimeoutSeconds = 1800,
    
    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Import required modules
Import-Module Az.Accounts -Force -ErrorAction SilentlyContinue
Import-Module Az.Resources -Force -ErrorAction SilentlyContinue
Import-Module Az.CognitiveServices -Force -ErrorAction SilentlyContinue

# Logging functions
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

# Check prerequisites
function Test-Prerequisites {
    Write-LogInfo "Checking prerequisites..."
    
    # Check if Azure PowerShell is installed
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-LogError "Azure PowerShell module 'Az.Accounts' is not installed. Please install it first."
        throw "Missing required module"
    }
    
    # Check if logged in to Azure
    try {
        $context = Get-AzContext
        if (-not $context) {
            Write-LogError "Not logged in to Azure. Run 'Connect-AzAccount' first."
            throw "Not authenticated"
        }
        Write-LogInfo "Connected to Azure as: $($context.Account.Id)"
    }
    catch {
        Write-LogError "Not logged in to Azure. Run 'Connect-AzAccount' first."
        throw "Not authenticated"
    }
    
    # Check if Bicep is available
    try {
        az bicep version | Out-Null
    }
    catch {
        Write-LogWarning "Bicep CLI not found. Installing..."
        az bicep install
    }
    
    Write-LogSuccess "Prerequisites check completed"
}

# Validate template
function Test-Template {
    Write-LogInfo "Validating Bicep template..."
    
    # Check if template file exists
    if (-not (Test-Path $TemplateFile)) {
        Write-LogError "Template file not found: $TemplateFile"
        throw "Template file not found"
    }
    
    # Check if parameters file exists
    if (-not (Test-Path $ParametersFile)) {
        Write-LogError "Parameters file not found: $ParametersFile"
        throw "Parameters file not found"
    }
    
    # Validate template syntax
    try {
        az bicep build --file $TemplateFile --stdout | Out-Null
    }
    catch {
        Write-LogError "Template validation failed"
        throw "Template validation failed"
    }
    
    # Validate deployment
    try {
        $validationResult = Test-AzResourceGroupDeployment `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFile
        
        if ($validationResult) {
            Write-LogError "Template validation failed:"
            $validationResult | Format-List
            throw "Template validation failed"
        }
    }
    catch {
        Write-LogError "Template validation failed: $($_.Exception.Message)"
        throw "Template validation failed"
    }
    
    Write-LogSuccess "Template validation passed"
}

# Show what would be deployed (dry run)
function Show-DryRun {
    Write-LogInfo "Showing deployment preview (dry-run)..."
    
    try {
        $whatIfResult = Get-AzResourceGroupDeploymentWhatIfResult `
            -ResourceGroupName $ResourceGroupName `
            -TemplateFile $TemplateFile `
            -TemplateParameterFile $ParametersFile
        
        $whatIfResult | Format-List
        
        Write-LogInfo "Dry-run completed. No resources were deployed."
    }
    catch {
        Write-LogError "Dry-run failed: $($_.Exception.Message)"
        throw "Dry-run failed"
    }
}

# Deploy the template
function Start-Deployment {
    Write-LogInfo "Starting Azure OpenAI deployment..."
    Write-LogInfo "Resource Group: $ResourceGroupName"
    Write-LogInfo "Location: $Location"
    Write-LogInfo "Deployment Name: $DeploymentName"
    
    try {
        if ($Monitor) {
            # Start deployment without waiting
            $deployment = New-AzResourceGroupDeployment `
                -ResourceGroupName $ResourceGroupName `
                -TemplateFile $TemplateFile `
                -TemplateParameterFile $ParametersFile `
                -Name $DeploymentName `
                -AsJob
            
            Write-LogInfo "Deployment started. Monitoring progress..."
            Watch-Deployment -Job $deployment
        }
        else {
            # Deploy and wait for completion
            $deployment = New-AzResourceGroupDeployment `
                -ResourceGroupName $ResourceGroupName `
                -TemplateFile $TemplateFile `
                -TemplateParameterFile $ParametersFile `
                -Name $DeploymentName `
                -Verbose:$Verbose
            
            Write-LogSuccess "Deployment completed successfully"
            Show-DeploymentOutputs
        }
    }
    catch {
        Write-LogError "Deployment failed: $($_.Exception.Message)"
        Show-DeploymentErrors
        throw "Deployment failed"
    }
}

# Monitor deployment progress
function Watch-Deployment {
    param([Microsoft.Azure.Commands.Profile.Models.PSAzureJob]$Job)
    
    $startTime = Get-Date
    $spinnerChars = @('|', '/', '-', '\')
    $spinnerIndex = 0
    
    Write-LogInfo "Monitoring deployment progress (timeout: $TimeoutSeconds seconds)..."
    
    while ($Job.State -eq "Running") {
        $elapsed = (Get-Date) - $startTime
        
        # Check timeout
        if ($elapsed.TotalSeconds -gt $TimeoutSeconds) {
            $Job | Stop-Job
            Write-LogError "Deployment timed out after $TimeoutSeconds seconds"
            throw "Deployment timeout"
        }
        
        # Get deployment status
        try {
            $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName -ErrorAction SilentlyContinue
            $status = if ($deployment) { $deployment.ProvisioningState } else { "Starting" }
        }
        catch {
            $status = "Unknown"
        }
        
        # Show spinner
        $spinner = $spinnerChars[$spinnerIndex % 4]
        Write-Host "`r[INFO] Deployment status: $status $spinner (elapsed: $([int]$elapsed.TotalSeconds)s)" -NoNewline -ForegroundColor Blue
        $spinnerIndex++
        
        Start-Sleep -Seconds 5
    }
    
    Write-Host ""  # New line after spinner
    
    # Check final job state
    $result = Receive-Job -Job $Job
    
    if ($Job.State -eq "Completed") {
        Write-LogSuccess "Deployment completed successfully"
        Show-DeploymentOutputs
    }
    else {
        Write-LogError "Deployment failed with state: $($Job.State)"
        Show-DeploymentErrors
        throw "Deployment failed"
    }
}

# Show deployment outputs
function Show-DeploymentOutputs {
    Write-LogInfo "Deployment outputs:"
    
    try {
        $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName
        
        if ($deployment.Outputs) {
            $deployment.Outputs | Format-Table -AutoSize
        }
        
        Write-Host ""
        Write-LogInfo "Getting OpenAI service details..."
        
        # Get OpenAI account details
        $openAIName = $deployment.Outputs["openAIName"].Value
        
        if ($openAIName) {
            Write-Host ""
            Write-LogInfo "Azure OpenAI Service Details:"
            
            $openAIAccount = Get-AzCognitiveServicesAccount -ResourceGroupName $ResourceGroupName -Name $openAIName
            $openAIAccount | Format-Table -Property Name, Location, Kind, SkuName, ProvisioningState -AutoSize
            
            Write-Host ""
            Write-LogInfo "Model Deployments:"
            
            try {
                $deployments = az cognitiveservices account deployment list `
                    --resource-group $ResourceGroupName `
                    --account-name $openAIName `
                    --output json | ConvertFrom-Json
                
                $deployments | Format-Table -Property name, @{Name='Model';Expression={$_.properties.model.name}}, @{Name='Version';Expression={$_.properties.model.version}}, @{Name='Capacity';Expression={$_.sku.capacity}} -AutoSize
            }
            catch {
                Write-LogWarning "Could not retrieve model deployments. Use Azure CLI: az cognitiveservices account deployment list"
            }
        }
    }
    catch {
        Write-LogWarning "Could not retrieve deployment outputs: $($_.Exception.Message)"
    }
}

# Show deployment errors
function Show-DeploymentErrors {
    Write-LogError "Deployment errors:"
    
    try {
        $deployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $DeploymentName -ErrorAction SilentlyContinue
        
        if ($deployment -and $deployment.Error) {
            $deployment.Error | Format-List
        }
        
        # Show operation details
        Write-LogInfo "Deployment operations:"
        $operations = Get-AzResourceGroupDeploymentOperation -ResourceGroupName $ResourceGroupName -DeploymentName $DeploymentName
        $failedOperations = $operations | Where-Object { $_.ProvisioningState -eq "Failed" }
        
        if ($failedOperations) {
            $failedOperations | Format-Table -Property OperationId, ProvisioningState, StatusMessage -AutoSize
        }
    }
    catch {
        Write-LogWarning "Could not retrieve deployment error details: $($_.Exception.Message)"
    }
}

# Main execution
function Main {
    Write-LogInfo "Azure OpenAI Service Deployment Script"
    Write-LogInfo "======================================="
    
    try {
        Test-Prerequisites
        
        # Create resource group if it doesn't exist
        $resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
        if (-not $resourceGroup) {
            Write-LogInfo "Creating resource group: $ResourceGroupName"
            $resourceGroup = New-AzResourceGroup -Name $ResourceGroupName -Location $Location
            Write-LogSuccess "Resource group created"
        }
        
        Test-Template
        
        if ($ValidateOnly) {
            Write-LogSuccess "Validation completed. Exiting without deployment."
            return
        }
        
        if ($DryRun) {
            Show-DryRun
            return
        }
        
        Start-Deployment
        
        Write-LogSuccess "Azure OpenAI deployment script completed successfully!"
    }
    catch {
        Write-LogError "Script execution failed: $($_.Exception.Message)"
        if ($Verbose) {
            Write-LogError "Full error details:"
            $_ | Format-List * -Force
        }
        exit 1
    }
}

# Run main function
Main
