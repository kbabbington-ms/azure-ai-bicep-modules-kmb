# ================================================================
# Key Vault Module Deployment Script (PowerShell)
# ================================================================
# Purpose: Deploy Azure Key Vault using Bicep template with comprehensive validation
# Author: AI Infrastructure Team
# Version: 1.0
# Last Updated: August 1, 2025
# ================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroup,
    
    [Parameter(Mandatory = $false)]
    [string]$ParametersFile = "key-vault.parameters.json",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConfirmation,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipWhatIf,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipValidation,
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# ================================================================
# CONFIGURATION VARIABLES
# ================================================================
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TemplateFile = Join-Path $ScriptDir "key-vault.bicep"
$DefaultParametersFile = Join-Path $ScriptDir "key-vault.parameters.json"
$LogFile = Join-Path $ScriptDir "deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# ================================================================
# UTILITY FUNCTIONS
# ================================================================

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    switch ($Level) {
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "INFO" { Write-Host $logMessage -ForegroundColor Cyan }
        default { Write-Host $logMessage }
    }
    
    $logMessage | Out-File -FilePath $LogFile -Append
}

function Write-Success {
    param([string]$Message)
    Write-Log "✅ $Message" "SUCCESS"
}

function Write-Warning {
    param([string]$Message)
    Write-Log "⚠️  $Message" "WARNING"
}

function Write-Error {
    param([string]$Message)
    Write-Log "❌ $Message" "ERROR"
}

function Write-Separator {
    $separator = "=" * 64
    Write-Host $separator -ForegroundColor Blue
}

function Show-Usage {
    Write-Host @"
Azure Key Vault Deployment Script

USAGE:
    .\deploy.ps1 -ResourceGroup <name> [OPTIONS]

PARAMETERS:
    -ResourceGroup      Resource group name (required)
    -ParametersFile     Parameters file path (default: key-vault.parameters.json)
    -SkipConfirmation   Skip confirmation prompts
    -SkipWhatIf         Skip What-If analysis
    -SkipValidation     Skip post-deployment validation
    -Help               Show this help message

EXAMPLES:
    .\deploy.ps1 -ResourceGroup "my-resource-group"
    .\deploy.ps1 -ResourceGroup "my-rg" -ParametersFile "custom-parameters.json" -SkipConfirmation
    .\deploy.ps1 -ResourceGroup "my-rg" -SkipWhatIf

"@ -ForegroundColor White
}

# ================================================================
# VALIDATION FUNCTIONS
# ================================================================

function Test-Prerequisites {
    Write-Log "Checking prerequisites..."
    
    # Check if Azure PowerShell is installed
    try {
        $azModule = Get-Module -Name Az -ListAvailable
        if (-not $azModule) {
            Write-Error "Azure PowerShell module is not installed. Please install it with: Install-Module -Name Az"
            exit 1
        }
    }
    catch {
        Write-Error "Error checking Azure PowerShell module: $($_.Exception.Message)"
        exit 1
    }
    
    # Check if user is logged in
    try {
        $context = Get-AzContext
        if (-not $context) {
            Write-Error "Not logged into Azure. Please run 'Connect-AzAccount' first."
            exit 1
        }
    }
    catch {
        Write-Error "Error checking Azure context: $($_.Exception.Message)"
        exit 1
    }
    
    # Check if Bicep is available
    try {
        $bicepVersion = az bicep version 2>$null
        if (-not $bicepVersion) {
            Write-Warning "Bicep CLI not found. Installing..."
            az bicep install
        }
    }
    catch {
        Write-Warning "Could not check Bicep version. Continuing..."
    }
    
    # Check if template file exists
    if (-not (Test-Path $TemplateFile)) {
        Write-Error "Template file not found: $TemplateFile"
        exit 1
    }
    
    Write-Success "Prerequisites check completed"
}

function Test-Template {
    Write-Log "Validating Bicep template..."
    
    # Lint the Bicep template
    try {
        $tempFile = [System.IO.Path]::GetTempFileName() + ".json"
        $result = az bicep build --file $TemplateFile --outfile $tempFile 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Bicep template lint validation passed"
            Remove-Item $tempFile -ErrorAction SilentlyContinue
        } else {
            Write-Error "Bicep template lint validation failed: $result"
            exit 1
        }
    }
    catch {
        Write-Error "Error during Bicep validation: $($_.Exception.Message)"
        exit 1
    }
    
    # ARM template validation
    try {
        $validation = Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile
        
        if ($validation) {
            Write-Error "ARM template validation failed:"
            $validation | ForEach-Object { Write-Error $_.Message }
            exit 1
        } else {
            Write-Success "ARM template validation passed"
        }
    }
    catch {
        Write-Error "Error during ARM template validation: $($_.Exception.Message)"
        exit 1
    }
}

# ================================================================
# DEPLOYMENT FUNCTIONS
# ================================================================

function Get-DeploymentInfo {
    Write-Host ""
    Write-Separator
    Write-Log "🔍 Deployment Information"
    Write-Separator
    
    # Get current subscription
    $context = Get-AzContext
    $subscription = Get-AzSubscription -SubscriptionId $context.Subscription.Id
    
    Write-Host "📋 Current Subscription: $($subscription.Name) ($($subscription.Id))" -ForegroundColor White
    Write-Host "📁 Resource Group: $ResourceGroup" -ForegroundColor White
    Write-Host "📄 Template: $TemplateFile" -ForegroundColor White
    Write-Host "⚙️  Parameters: $ParametersFile" -ForegroundColor White
    Write-Host "📝 Log File: $LogFile" -ForegroundColor White
    Write-Host ""
}

function Confirm-Deployment {
    if (-not $SkipConfirmation) {
        $response = Read-Host "🤔 Do you want to proceed with the deployment? (y/N)"
        if ($response -notmatch "^[Yy]$") {
            Write-Log "Deployment cancelled by user"
            exit 0
        }
    }
}

function Invoke-WhatIfAnalysis {
    if (-not $SkipWhatIf) {
        Write-Log "Running What-If analysis..."
        Write-Separator
        
        try {
            $whatIfResult = Get-AzResourceGroupDeploymentWhatIfResult -ResourceGroupName $ResourceGroup -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile
            $whatIfResult | Format-Table -AutoSize
        }
        catch {
            Write-Warning "What-If analysis failed: $($_.Exception.Message)"
            Write-Log "Continuing with deployment..."
        }
        
        Write-Separator
        Write-Success "What-If analysis completed"
        Write-Host ""
        
        if (-not $SkipConfirmation) {
            $response = Read-Host "🤔 Continue with deployment? (y/N)"
            if ($response -notmatch "^[Yy]$") {
                Write-Log "Deployment cancelled after What-If analysis"
                exit 0
            }
        }
    }
}

function Invoke-Deployment {
    Write-Log "Starting deployment..."
    
    $deploymentName = "keyvault-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        $deployment = New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -TemplateFile $TemplateFile -TemplateParameterFile $ParametersFile -Name $deploymentName -Verbose
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Success "Deployment completed successfully!"
            
            # Display deployment outputs
            if ($deployment.Outputs) {
                Write-Log "Deployment outputs:"
                $deployment.Outputs | Format-Table -AutoSize
            }
        } else {
            Write-Error "Deployment failed with state: $($deployment.ProvisioningState)"
            exit 1
        }
    }
    catch {
        Write-Error "Deployment failed: $($_.Exception.Message)"
        
        # Get deployment details for troubleshooting
        try {
            $failedDeployment = Get-AzResourceGroupDeployment -ResourceGroupName $ResourceGroup -Name $deploymentName
            Write-Log "Deployment details for troubleshooting:"
            $failedDeployment | Format-List
        }
        catch {
            Write-Warning "Could not retrieve deployment details"
        }
        
        exit 1
    }
}

# ================================================================
# POST-DEPLOYMENT VALIDATION
# ================================================================

function Test-Deployment {
    Write-Log "Validating deployment..."
    
    # Get the Key Vault name from parameters
    try {
        $parametersContent = Get-Content $ParametersFile | ConvertFrom-Json
        $vaultName = $parametersContent.parameters.keyVaultName.value
        
        if (-not $vaultName) {
            Write-Warning "Could not retrieve Key Vault name from parameters file"
            return
        }
    }
    catch {
        Write-Warning "Error reading parameters file: $($_.Exception.Message)"
        return
    }
    
    # Check if Key Vault exists and is accessible
    try {
        $vault = Get-AzKeyVault -VaultName $vaultName -ResourceGroupName $ResourceGroup
        
        if ($vault) {
            Write-Success "Key Vault '$vaultName' is accessible"
            
            # Display Key Vault properties
            Write-Host "  📊 SKU: $($vault.Sku)" -ForegroundColor White
            Write-Host "  🗑️  Soft Delete: $($vault.EnableSoftDelete)" -ForegroundColor White
            Write-Host "  🛡️  Purge Protection: $($vault.EnablePurgeProtection)" -ForegroundColor White
        } else {
            Write-Error "Key Vault '$vaultName' not found"
        }
    }
    catch {
        Write-Error "Key Vault '$vaultName' is not accessible: $($_.Exception.Message)"
    }
    
    # Check diagnostic settings if enabled
    Write-Log "Checking diagnostic settings..."
    try {
        $context = Get-AzContext
        $resourceId = "/subscriptions/$($context.Subscription.Id)/resourceGroups/$ResourceGroup/providers/Microsoft.KeyVault/vaults/$vaultName"
        $diagSettings = Get-AzDiagnosticSetting -ResourceId $resourceId
        
        if ($diagSettings) {
            Write-Success "Diagnostic settings configured ($($diagSettings.Count) settings)"
        } else {
            Write-Warning "No diagnostic settings found"
        }
    }
    catch {
        Write-Warning "Could not check diagnostic settings: $($_.Exception.Message)"
    }
}

# ================================================================
# ERROR HANDLING & CLEANUP
# ================================================================

function Invoke-CleanupOnError {
    Write-Error "Deployment failed. Cleaning up resources..."
    
    # Add cleanup logic here if needed
    # For Key Vault, we typically don't auto-delete due to purge protection
    
    Write-Warning "Please review the deployment logs and clean up manually if necessary"
}

# ================================================================
# MAIN SCRIPT
# ================================================================

function Main {
    # Show help if requested
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    # Validate required parameters
    if (-not $ResourceGroup) {
        Write-Error "Resource group is required. Use -ResourceGroup parameter."
        Show-Usage
        exit 1
    }
    
    # Set parameters file path
    if ($ParametersFile -and (Test-Path $ParametersFile)) {
        $script:ParametersFile = $ParametersFile
    } else {
        $script:ParametersFile = $DefaultParametersFile
    }
    
    if (-not (Test-Path $script:ParametersFile)) {
        Write-Error "Parameters file not found: $script:ParametersFile"
        exit 1
    }
    
    # Main execution flow
    Write-Host ""
    Write-Separator
    Write-Log "🚀 Azure Key Vault Deployment Script"
    Write-Separator
    
    try {
        # Execute deployment steps
        Test-Prerequisites
        Get-DeploymentInfo
        Confirm-Deployment
        Test-Template
        Invoke-WhatIfAnalysis
        Invoke-Deployment
        
        if (-not $SkipValidation) {
            Test-Deployment
        }
        
        Write-Host ""
        Write-Separator
        Write-Success "✅ Deployment process completed successfully!"
        Write-Log "📝 Deployment logs saved to: $LogFile"
        Write-Separator
        Write-Host ""
    }
    catch {
        Write-Error "Deployment process failed: $($_.Exception.Message)"
        Invoke-CleanupOnError
        exit 1
    }
}

# Execute main function
Main
