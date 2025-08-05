# =============================================================================
# Azure Key Vault Policy Deployment Script (PowerShell)
# =============================================================================
# Purpose: Deploy comprehensive Key Vault security policies for SFI-W1 compliance
# Version: 1.0.0
# Date: August 2, 2025
# =============================================================================

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$LogAnalyticsWorkspaceId,
    
    [Parameter()]
    [switch]$WhatIf
)

# Configuration
$ScriptPath = $PSScriptRoot
$PolicyDir = Split-Path (Split-Path $ScriptPath -Parent) -Parent
$ErrorActionPreference = "Stop"

# Functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Usage {
    Write-Host "Usage: .\Deploy-KeyVaultPolicies.ps1 [OPTIONS]"
    Write-Host ""
    Write-Host "Parameters:"
    Write-Host "  -SubscriptionId SUBSCRIPTION_ID       Azure subscription ID"
    Write-Host "  -LogAnalyticsWorkspaceId WORKSPACE_ID Log Analytics workspace resource ID"
    Write-Host "  -WhatIf                               Show what would be deployed without making changes"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\Deploy-KeyVaultPolicies.ps1 -SubscriptionId '12345678-1234-1234-1234-123456789012' \"
    Write-Host "                                -LogAnalyticsWorkspaceId '/subscriptions/12345678-1234-1234-1234-123456789012/resourceGroups/rg-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-audit'"
}

# Validation
if (-not $SubscriptionId) {
    Write-Error "Subscription ID is required."
    Show-Usage
    exit 1
}

if (-not $LogAnalyticsWorkspaceId) {
    Write-Error "Log Analytics workspace ID is required."
    Show-Usage
    exit 1
}

# Verify Azure PowerShell modules
Write-Info "Verifying Azure PowerShell modules..."
$RequiredModules = @('Az.Accounts', 'Az.Resources', 'Az.Profile')
foreach ($Module in $RequiredModules) {
    if (-not (Get-Module -ListAvailable -Name $Module)) {
        Write-Error "Required module '$Module' is not installed. Please install it using: Install-Module $Module"
        exit 1
    }
}

# Verify Azure connection
Write-Info "Verifying Azure authentication..."
try {
    $Context = Get-AzContext
    if (-not $Context) {
        Write-Error "Not logged in to Azure. Please run 'Connect-AzAccount' first."
        exit 1
    }
}
catch {
    Write-Error "Not logged in to Azure. Please run 'Connect-AzAccount' first."
    exit 1
}

# Set subscription context
Write-Info "Setting subscription context to: $SubscriptionId"
try {
    Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
}
catch {
    Write-Error "Failed to set subscription context: $_"
    exit 1
}

# Array of Key Vault policy definitions to deploy
$KeyVaultPolicies = @(
    "SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint",
    "SFI-W1-Def-KeyVault-DisablePublicNetworkAccess",
    "SFI-W1-Def-KeyVault-RequireRBAC",
    "SFI-W1-Def-KeyVault-RequirePurgeProtection",
    "SFI-W1-Def-KeyVault-RequireSoftDelete",
    "SFI-W1-Def-KeyVault-RequireCustomerManagedKeys",
    "SFI-W1-Def-KeyVault-RequireManagedIdentity",
    "SFI-W1-Def-Foundry-KeyVaultAISecrets",
    "SFI-W1-Def-KeyVault-RequireDiagnosticSettings"
)

Write-Info "Starting deployment of $($KeyVaultPolicies.Count) Key Vault policy definitions..."

if ($WhatIf) {
    Write-Info "WhatIf mode enabled - no actual deployments will be performed"
}

# Deploy individual policy definitions
$FailedPolicies = @()
foreach ($Policy in $KeyVaultPolicies) {
    Write-Info "Processing policy: $Policy"
    
    # Construct file path
    $PolicyFile = Join-Path $PolicyDir "definitions\key-vault\$Policy.bicep"
    
    if (-not (Test-Path $PolicyFile)) {
        Write-Error "Policy file not found: $PolicyFile"
        $FailedPolicies += $Policy
        continue
    }
    
    $DeploymentName = "deploy-$Policy-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        if ($WhatIf) {
            Write-Info "WhatIf: Would deploy $Policy from $PolicyFile"
        }
        else {
            $DeploymentResult = New-AzSubscriptionDeployment `
                -Name $DeploymentName `
                -TemplateFile $PolicyFile `
                -Location "East US" `
                -ErrorAction Stop
            
            Write-Success "Successfully deployed: $Policy"
        }
    }
    catch {
        Write-Error "Failed to deploy $Policy`: $_"
        $FailedPolicies += $Policy
    }
}

# Deploy Key Vault initiative
Write-Info "Processing Key Vault policy initiative..."
$InitiativeFile = Join-Path $PolicyDir "initiatives\key-vault\SFI-W1-Ini-KeyVault.bicep"

if (Test-Path $InitiativeFile) {
    $InitiativeDeploymentName = "deploy-keyvault-initiative-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        if ($WhatIf) {
            Write-Info "WhatIf: Would deploy Key Vault initiative from $InitiativeFile"
        }
        else {
            $InitiativeResult = New-AzSubscriptionDeployment `
                -Name $InitiativeDeploymentName `
                -TemplateFile $InitiativeFile `
                -logAnalyticsWorkspaceId $LogAnalyticsWorkspaceId `
                -Location "East US" `
                -ErrorAction Stop
            
            Write-Success "Successfully deployed Key Vault initiative"
        }
    }
    catch {
        Write-Error "Failed to deploy Key Vault initiative: $_"
        $FailedPolicies += "SFI-W1-Ini-KeyVault"
    }
}
else {
    Write-Error "Initiative file not found: $InitiativeFile"
    $FailedPolicies += "SFI-W1-Ini-KeyVault"
}

# Summary
Write-Host ""
Write-Info "=== DEPLOYMENT SUMMARY ==="
if ($FailedPolicies.Count -eq 0) {
    if ($WhatIf) {
        Write-Success "WhatIf completed successfully! All $($KeyVaultPolicies.Count) policies would be deployed."
    }
    else {
        Write-Success "All Key Vault policies deployed successfully!"
        Write-Info "Deployed $($KeyVaultPolicies.Count) policy definitions and 1 initiative"
    }
}
else {
    Write-Warning "Some policies failed to deploy:"
    foreach ($FailedPolicy in $FailedPolicies) {
        Write-Host "  - $FailedPolicy" -ForegroundColor Red
    }
    exit 1
}

if (-not $WhatIf) {
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "1. Assign the Key Vault initiative to appropriate scopes"
    Write-Host "2. Configure exemptions if needed for legacy workloads"
    Write-Host "3. Monitor compliance in Azure Policy portal"
    Write-Host ""
    Write-Info "Policy initiative deployed: SFI-W1-Ini-KeyVault"
    Write-Info "Log Analytics workspace: $LogAnalyticsWorkspaceId"
}
