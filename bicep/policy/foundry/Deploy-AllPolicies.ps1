# ================================================================
# SFI-W1 Policy Initiative Deployment Script (PowerShell)
# ================================================================
# Purpose: Deploy all Azure Policy definitions and initiative for Azure AI Foundry
# Author: AI Infrastructure Team
# Version: 2.0
# Last Updated: August 1, 2025
# ================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$Location,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipConfirmation,
    
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
$LogFile = Join-Path $ScriptDir "policy-deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Policy definition files in dependency order
$PolicyDefinitions = @(
    "SFI-W1-Def-Foundry-RequireCreatedByTag.bicep",
    "SFI-W1-Def-Foundry-RestrictPublicNetworkAccess.bicep",
    "SFI-W1-Def-Foundry-RequireDiagnosticLogging.bicep",
    "SFI-W1-Def-Foundry-EnforceManagedIdentityUsage.bicep",
    "SFI-W1-Def-Foundry-RequireEncryptionAtRest.bicep",
    "SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint.bicep",
    "SFI-W1-Def-Foundry-AllowedAISku.bicep",
    "SFI-W1-Def-Foundry-ModelVersionControl.bicep",
    "SFI-W1-Def-Foundry-DataResidency.bicep",
    "SFI-W1-Def-Foundry-PrivateEndpointAI.bicep",
    "SFI-W1-Def-Foundry-DiagnosticLoggingAI.bicep",
    "SFI-W1-Def-Foundry-KeyVaultAISecrets.bicep",
    "SFI-W1-Def-Foundry-TaggingAI.bicep",
    "SFI-W1-Def-Foundry-ManagedIdentityAI.bicep",
    "SFI-W1-Def-Foundry-EncryptionTransitAI.bicep",
    "SFI-W1-Def-Foundry-LogRetentionAI.bicep",
    "SFI-W1-Def-Foundry-ContentSafety.bicep",
    "SFI-W1-Def-Foundry-VideoIndexer.bicep",
    "SFI-W1-Def-Foundry-LogicAppsAIWorkflows.bicep",
    "SFI-W1-Def-Foundry-AdvancedMonitoring.bicep"
)

$InitiativeFile = "SFI-W1-Ini-Foundry.bicep"

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
        "PROGRESS" { Write-Host $logMessage -ForegroundColor Magenta }
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

function Write-Info {
    param([string]$Message)
    Write-Log "ℹ️  $Message" "INFO"
}

function Write-Separator {
    $separator = "=" * 64
    Write-Host $separator -ForegroundColor Blue
}

function Write-ProgressBar {
    param(
        [int]$Current,
        [int]$Total,
        [string]$Activity = "Processing"
    )
    
    $percentage = [math]::Round(($Current / $Total) * 100)
    Write-Progress -Activity $Activity -Status "$Current of $Total" -PercentComplete $percentage
}

function Show-Usage {
    Write-Host @"
SFI-W1 Policy Initiative Deployment Script

USAGE:
    .\Deploy-AllPolicies.ps1 -Location <region> [OPTIONS]

PARAMETERS:
    -SubscriptionId     Subscription ID (optional, uses current subscription)
    -Location           Azure region for deployment (required)
    -SkipConfirmation   Skip confirmation prompts
    -SkipValidation     Skip post-deployment validation
    -Help               Show this help message

EXAMPLES:
    .\Deploy-AllPolicies.ps1 -Location "eastus"
    .\Deploy-AllPolicies.ps1 -Location "westus2" -SkipConfirmation
    .\Deploy-AllPolicies.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -Location "eastus"

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
        
        $script:CurrentSub = $context.Subscription.Id
        $script:CurrentSubName = $context.Subscription.Name
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
    
    Write-Success "Prerequisites check completed"
    Write-Info "Current subscription: $CurrentSubName ($CurrentSub)"
}

function Test-Files {
    Write-Log "Validating Bicep files..."
    
    $missingFiles = @()
    
    # Check policy definition files
    foreach ($file in $PolicyDefinitions) {
        $filePath = Join-Path $ScriptDir $file
        if (-not (Test-Path $filePath)) {
            $missingFiles += $file
        }
    }
    
    # Check initiative file
    $initiativeFilePath = Join-Path $ScriptDir $InitiativeFile
    if (-not (Test-Path $initiativeFilePath)) {
        $missingFiles += $InitiativeFile
    }
    
    if ($missingFiles.Count -gt 0) {
        Write-Error "Missing required files:"
        foreach ($file in $missingFiles) {
            Write-Host "  - $file" -ForegroundColor Red
        }
        exit 1
    }
    
    Write-Success "All required files found"
}

function Test-BicepFiles {
    Write-Log "Linting Bicep files..."
    
    $lintErrors = 0
    
    # Lint policy definitions
    foreach ($file in $PolicyDefinitions) {
        $filePath = Join-Path $ScriptDir $file
        try {
            $result = az bicep build --file $filePath --outfile ([System.IO.Path]::GetTempFileName()) 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Lint error in $file"
                $lintErrors++
            }
        }
        catch {
            Write-Error "Lint error in $file : $($_.Exception.Message)"
            $lintErrors++
        }
    }
    
    # Lint initiative
    $initiativeFilePath = Join-Path $ScriptDir $InitiativeFile
    try {
        $result = az bicep build --file $initiativeFilePath --outfile ([System.IO.Path]::GetTempFileName()) 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Lint error in $InitiativeFile"
            $lintErrors++
        }
    }
    catch {
        Write-Error "Lint error in $InitiativeFile : $($_.Exception.Message)"
        $lintErrors++
    }
    
    if ($lintErrors -gt 0) {
        Write-Error "$lintErrors Bicep lint errors found. Please fix before proceeding."
        exit 1
    }
    
    Write-Success "All Bicep files passed lint validation"
}

# ================================================================
# DEPLOYMENT FUNCTIONS
# ================================================================

function Show-DeploymentSummary {
    Write-Host ""
    Write-Separator
    Write-Log "🚀 SFI-W1 Policy Initiative Deployment Summary"
    Write-Separator
    
    Write-Host "📋 Subscription: $CurrentSubName ($CurrentSub)" -ForegroundColor White
    Write-Host "📁 Location: $Location" -ForegroundColor White
    Write-Host "📄 Policy Definitions: $($PolicyDefinitions.Count)" -ForegroundColor White
    Write-Host "📋 Initiative: $InitiativeFile" -ForegroundColor White
    Write-Host "📝 Log File: $LogFile" -ForegroundColor White
    Write-Host ""
    
    if (-not $SkipConfirmation) {
        $response = Read-Host "🤔 Do you want to proceed with the deployment? (y/N)"
        if ($response -notmatch "^[Yy]$") {
            Write-Log "Deployment cancelled by user"
            exit 0
        }
    }
}

function Invoke-PolicyDefinitionsDeployment {
    Write-Log "Deploying policy definitions..."
    Write-Separator
    
    $failedDeployments = @()
    $successfulDeployments = 0
    $totalDefinitions = $PolicyDefinitions.Count
    
    for ($i = 0; $i -lt $PolicyDefinitions.Count; $i++) {
        $file = $PolicyDefinitions[$i]
        $current = $i + 1
        $filePath = Join-Path $ScriptDir $file
        
        Write-ProgressBar -Current $current -Total $totalDefinitions -Activity "Deploying Policy Definitions"
        Write-Info "Deploying: $file"
        
        $deploymentName = "policy-def-$(Get-Date -Format 'yyyyMMdd-HHmmss')-$current"
        
        try {
            $deployment = New-AzSubscriptionDeployment -Location $Location -TemplateFile $filePath -Name $deploymentName
            
            if ($deployment.ProvisioningState -eq "Succeeded") {
                Write-Success "✅ $file deployed successfully"
                $successfulDeployments++
            } else {
                Write-Error "❌ Failed to deploy $file - State: $($deployment.ProvisioningState)"
                $failedDeployments += $file
            }
        }
        catch {
            Write-Error "❌ Failed to deploy $file : $($_.Exception.Message)"
            $failedDeployments += $file
        }
    }
    
    Write-Progress -Activity "Deploying Policy Definitions" -Completed
    
    if ($failedDeployments.Count -gt 0) {
        Write-Error "Failed to deploy $($failedDeployments.Count) policy definitions:"
        foreach ($file in $failedDeployments) {
            Write-Host "  - $file" -ForegroundColor Red
        }
        exit 1
    }
    
    Write-Success "All $successfulDeployments policy definitions deployed successfully!"
}

function Invoke-PolicyInitiativeDeployment {
    Write-Log "Deploying policy initiative..."
    
    $initiativeFilePath = Join-Path $ScriptDir $InitiativeFile
    $deploymentName = "policy-initiative-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        $deployment = New-AzSubscriptionDeployment -Location $Location -TemplateFile $initiativeFilePath -Name $deploymentName
        
        if ($deployment.ProvisioningState -eq "Succeeded") {
            Write-Success "Policy initiative deployed successfully!"
            
            # Display outputs if any
            if ($deployment.Outputs) {
                Write-Log "Deployment outputs:"
                $deployment.Outputs | Format-Table -AutoSize
            }
        } else {
            Write-Error "Failed to deploy policy initiative - State: $($deployment.ProvisioningState)"
            exit 1
        }
    }
    catch {
        Write-Error "Failed to deploy policy initiative: $($_.Exception.Message)"
        exit 1
    }
}

# ================================================================
# POST-DEPLOYMENT ACTIONS
# ================================================================

function Test-Deployment {
    Write-Log "Validating deployment..."
    
    # Check policy definitions
    try {
        $deployedPolicies = Get-AzPolicyDefinition | Where-Object { $_.Name -like "SFI-W1-Def-Foundry*" }
        $expectedPolicies = $PolicyDefinitions.Count
        
        if ($deployedPolicies.Count -ge $expectedPolicies) {
            Write-Success "All policy definitions are deployed ($($deployedPolicies.Count) found)"
        } else {
            Write-Warning "Expected $expectedPolicies policies, found $($deployedPolicies.Count)"
        }
    }
    catch {
        Write-Warning "Could not verify policy definitions: $($_.Exception.Message)"
    }
    
    # Check initiative
    try {
        $initiative = Get-AzPolicySetDefinition -Name "SFI-W1-Ini-Foundry"
        if ($initiative) {
            Write-Success "Policy initiative is deployed and accessible"
        } else {
            Write-Error "Policy initiative not found"
            exit 1
        }
    }
    catch {
        Write-Error "Policy initiative not found or not accessible: $($_.Exception.Message)"
        exit 1
    }
}

function Show-NextSteps {
    Write-Host ""
    Write-Separator
    Write-Log "🎯 Next Steps"
    Write-Separator
    
    Write-Host "1. 📋 Assign the policy initiative to subscription or resource group:" -ForegroundColor White
    Write-Host "   New-AzPolicyAssignment ``" -ForegroundColor Cyan
    Write-Host "     -Name 'SFI-W1-AI-Foundry-Assignment' ``" -ForegroundColor Cyan
    Write-Host "     -PolicySetDefinition 'SFI-W1-Ini-Foundry' ``" -ForegroundColor Cyan
    Write-Host "     -Scope '/subscriptions/$CurrentSub'" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "2. 📊 Monitor compliance:" -ForegroundColor White
    Write-Host "   Get-AzPolicyState | Where-Object { `$_.PolicySetDefinitionName -eq 'SFI-W1-Ini-Foundry' }" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "3. 📈 Generate compliance report:" -ForegroundColor White
    Write-Host "   Get-AzPolicyStateSummary -PolicySetDefinitionName 'SFI-W1-Ini-Foundry'" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "4. 🔍 View deployed policies:" -ForegroundColor White
    Write-Host "   Get-AzPolicyDefinition | Where-Object { `$_.Name -like 'SFI-W1-Def-Foundry*' }" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Info "Policy deployment completed successfully!"
    Write-Info "Review the logs at: $LogFile"
}

# ================================================================
# ERROR HANDLING
# ================================================================

function Invoke-CleanupOnError {
    Write-Error "Deployment failed. Check the logs for details."
    Write-Warning "You may need to manually clean up partially deployed policies."
    Write-Info "Log file: $LogFile"
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
    if (-not $Location) {
        Write-Error "Location is required. Use -Location parameter."
        Show-Usage
        exit 1
    }
    
    # Set subscription if provided
    if ($SubscriptionId) {
        Write-Log "Setting subscription to: $SubscriptionId"
        try {
            Set-AzContext -SubscriptionId $SubscriptionId
            $script:CurrentSub = $SubscriptionId
            $context = Get-AzContext
            $script:CurrentSubName = $context.Subscription.Name
        }
        catch {
            Write-Error "Failed to set subscription: $($_.Exception.Message)"
            exit 1
        }
    }
    
    # Main execution flow
    Write-Host ""
    Write-Separator
    Write-Log "🛡️ SFI-W1 Policy Initiative Deployment Script"
    Write-Separator
    
    try {
        # Execute deployment steps
        Test-Prerequisites
        Test-Files
        Test-BicepFiles
        Show-DeploymentSummary
        Invoke-PolicyDefinitionsDeployment
        Invoke-PolicyInitiativeDeployment
        
        if (-not $SkipValidation) {
            Test-Deployment
        }
        
        Show-NextSteps
        
        Write-Host ""
        Write-Separator
        Write-Success "🎉 Policy deployment completed successfully!"
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
