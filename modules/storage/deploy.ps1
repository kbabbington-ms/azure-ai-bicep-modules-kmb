# =============================================================================
# Azure Storage Account Deployment Script (PowerShell)
# =============================================================================
# This script deploys a secure Azure Storage Account using the Bicep module
# with different configuration scenarios.
# =============================================================================

param(
    [string]$ResourceGroupName = "rg-storage-test",
    [string]$Location = "East US 2",
    [string]$SubscriptionId = "",
    [switch]$BasicOnly,
    [switch]$SecureOnly,
    [switch]$DataLakeOnly,
    [switch]$NoCleanup,
    [switch]$Help
)

# =============================================================================
# CONFIGURATION
# =============================================================================

$ErrorActionPreference = "Stop"
$StorageAccountName = "stgtest$(Get-Date -Format 'yyyyMMddHHmmss')"

# =============================================================================
# FUNCTIONS
# =============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host "=============================================================" -ForegroundColor Blue
    Write-Host $Message -ForegroundColor Blue
    Write-Host "=============================================================" -ForegroundColor Blue
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Help {
    @"
Azure Storage Account Deployment Script (PowerShell)

Usage: .\deploy.ps1 [PARAMETERS]

PARAMETERS:
    -ResourceGroupName      Resource group name (default: $ResourceGroupName)
    -Location              Azure location (default: $Location)
    -SubscriptionId        Azure subscription ID
    -BasicOnly             Deploy basic storage account only
    -SecureOnly            Deploy secure storage account only
    -DataLakeOnly          Deploy data lake storage account only
    -NoCleanup             Skip cleanup prompt
    -Help                  Show this help message

EXAMPLES:
    .\deploy.ps1                                    # Deploy all scenarios
    .\deploy.ps1 -BasicOnly                         # Deploy only basic storage
    .\deploy.ps1 -SecureOnly -NoCleanup            # Deploy secure storage without cleanup
    .\deploy.ps1 -ResourceGroupName "my-rg" -Location "West US 2"  # Custom settings

SECURITY FEATURES DEMONSTRATED:
    - HTTPS-only traffic enforcement
    - Minimum TLS version configuration
    - Shared key access controls
    - Public blob access restrictions
    - Network access controls
    - Customer-managed encryption options
    - Managed identity integration
    - SAS policy enforcement
    - Cross-tenant replication controls
"@
}

function Test-Prerequisites {
    Write-Header "Checking Prerequisites"
    
    # Check if Azure PowerShell is installed
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-Error "Azure PowerShell module 'Az.Accounts' is not installed. Please install it first using: Install-Module -Name Az"
        exit 1
    }
    
    # Check if logged in to Azure
    try {
        $context = Get-AzContext
        if (-not $context) {
            Write-Error "Not logged in to Azure. Please run 'Connect-AzAccount' first."
            exit 1
        }
    }
    catch {
        Write-Error "Not logged in to Azure. Please run 'Connect-AzAccount' first."
        exit 1
    }
    
    # Check if Bicep is available
    try {
        $bicepVersion = az bicep version 2>$null
        if (-not $bicepVersion) {
            Write-Info "Installing Bicep CLI..."
            az bicep install
        }
    }
    catch {
        Write-Warning "Could not verify Bicep installation. Ensure Azure CLI with Bicep is available."
    }
    
    Write-Info "Prerequisites check completed successfully"
}

function New-ResourceGroupIfNotExists {
    Write-Header "Creating Resource Group"
    
    try {
        $rg = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction Stop
        Write-Warning "Resource group '$ResourceGroupName' already exists"
    }
    catch {
        Write-Info "Creating resource group '$ResourceGroupName' in '$Location'"
        $tags = @{
            Purpose = "Storage Testing"
            Environment = "Development"
            CreatedBy = (Get-AzContext).Account.Id
            CreatedDate = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        }
        
        New-AzResourceGroup -Name $ResourceGroupName -Location $Location -Tag $tags | Out-Null
    }
}

function Test-BicepTemplate {
    Write-Header "Validating Bicep Template"
    
    Write-Info "Validating storage account template..."
    
    $templateParams = @{
        storageAccountName = $StorageAccountName
        location = $Location
        skuName = "Standard_LRS"
        kind = "StorageV2"
    }
    
    try {
        Test-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile "modules\storage\storage-account.bicep" -TemplateParameterObject $templateParams | Out-Null
        Write-Info "Template validation completed successfully"
    }
    catch {
        Write-Error "Template validation failed: $($_.Exception.Message)"
        exit 1
    }
}

function Deploy-BasicStorage {
    Write-Header "Deploying Basic Storage Account"
    
    $deploymentName = "basic-storage-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    Write-Info "Deploying basic storage account: $StorageAccountName"
    
    $templateParams = @{
        storageAccountName = $StorageAccountName
        location = $Location
        skuName = "Standard_LRS"
        kind = "StorageV2"
        accessTier = "Hot"
        tags = @{
            Environment = "Development"
            Purpose = "Testing"
            DeploymentType = "Basic"
        }
    }
    
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -TemplateFile "modules\storage\storage-account.bicep" -TemplateParameterObject $templateParams | Out-Null
        Write-Info "Basic storage account deployment completed"
    }
    catch {
        Write-Error "Basic storage deployment failed: $($_.Exception.Message)"
        exit 1
    }
}

function Deploy-SecureStorage {
    Write-Header "Deploying Secure Storage Account"
    
    $secureStorageName = "stgsec$(Get-Date -Format 'yyyyMMddHHmmss')"
    $deploymentName = "secure-storage-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    Write-Info "Deploying secure storage account: $secureStorageName"
    
    $templateParams = @{
        storageAccountName = $secureStorageName
        location = $Location
        skuName = "Standard_ZRS"
        kind = "StorageV2"
        accessTier = "Hot"
        supportsHttpsTrafficOnly = $true
        minimumTlsVersion = "TLS1_2"
        allowSharedKeyAccess = $false
        allowBlobPublicAccess = $false
        allowCrossTenantReplication = $false
        defaultToOAuthAuthentication = $true
        publicNetworkAccess = "Disabled"
        allowedCopyScope = "AAD"
        networkAclsDefaultAction = "Deny"
        networkAclsBypass = "AzureServices"
        encryptionKeySource = "Microsoft.Storage"
        requireInfrastructureEncryption = $true
        managedIdentityType = "SystemAssigned"
        sasExpirationPeriod = "01.00:00:00"
        sasExpirationAction = "Block"
        keyExpirationPeriodInDays = 90
        tags = @{
            Environment = "Production"
            Purpose = "Secure Testing"
            DeploymentType = "Secure"
            DataClassification = "Confidential"
        }
    }
    
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -TemplateFile "modules\storage\storage-account.bicep" -TemplateParameterObject $templateParams | Out-Null
        Write-Info "Secure storage account deployment completed"
    }
    catch {
        Write-Error "Secure storage deployment failed: $($_.Exception.Message)"
        exit 1
    }
}

function Deploy-DataLakeStorage {
    Write-Header "Deploying Data Lake Storage Account"
    
    $dataLakeStorageName = "stgdl$(Get-Date -Format 'yyyyMMddHHmmss')"
    $deploymentName = "datalake-storage-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    Write-Info "Deploying Data Lake storage account: $dataLakeStorageName"
    
    $templateParams = @{
        storageAccountName = $dataLakeStorageName
        location = $Location
        skuName = "Standard_ZRS"
        kind = "StorageV2"
        accessTier = "Hot"
        isHnsEnabled = $true
        supportsHttpsTrafficOnly = $true
        minimumTlsVersion = "TLS1_2"
        allowSharedKeyAccess = $false
        allowBlobPublicAccess = $false
        defaultToOAuthAuthentication = $true
        publicNetworkAccess = "Disabled"
        networkAclsDefaultAction = "Deny"
        networkAclsBypass = "AzureServices"
        managedIdentityType = "SystemAssigned"
        tags = @{
            Environment = "Development"
            Purpose = "Data Lake"
            DeploymentType = "Analytics"
            DataProcessing = "BigData"
        }
    }
    
    try {
        New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -Name $deploymentName -TemplateFile "modules\storage\storage-account.bicep" -TemplateParameterObject $templateParams | Out-Null
        Write-Info "Data Lake storage account deployment completed"
    }
    catch {
        Write-Error "Data Lake storage deployment failed: $($_.Exception.Message)"
        exit 1
    }
}

function Test-Deployment {
    Write-Header "Verifying Deployment"
    
    Write-Info "Listing storage accounts in resource group..."
    
    $storageAccounts = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName
    
    $storageAccounts | Format-Table -Property StorageAccountName, Location, Kind, @{Name='Sku';Expression={$_.Sku.Name}}, CreationTime -AutoSize
    
    Write-Info "Checking storage account security settings..."
    
    foreach ($storageAccount in $storageAccounts) {
        Write-Host "`nStorage Account: $($storageAccount.StorageAccountName)" -ForegroundColor Blue
        
        $securitySettings = [PSCustomObject]@{
            HttpsOnly = $storageAccount.EnableHttpsTrafficOnly
            MinTls = $storageAccount.MinimumTlsVersion
            PublicAccess = $storageAccount.AllowBlobPublicAccess
            SharedKey = $storageAccount.AllowSharedKeyAccess
            NetworkAccess = $storageAccount.PublicNetworkAccess
        }
        
        $securitySettings | Format-List
    }
}

function Remove-TestResources {
    Write-Header "Cleanup Resources"
    
    if (-not $NoCleanup) {
        $response = Read-Host "Do you want to delete the test resource group '$ResourceGroupName'? (y/N)"
        if ($response -eq 'y' -or $response -eq 'Y') {
            Write-Info "Deleting resource group '$ResourceGroupName'..."
            Remove-AzResourceGroup -Name $ResourceGroupName -Force -AsJob | Out-Null
            Write-Info "Resource group deletion initiated (running in background)"
        }
        else {
            Write-Info "Resource group '$ResourceGroupName' preserved"
            Write-Warning "Remember to clean up resources manually to avoid charges"
        }
    }
    else {
        Write-Warning "Resources are still running in resource group: $ResourceGroupName"
        Write-Warning "Remember to clean up manually to avoid charges"
    }
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

function Main {
    if ($Help) {
        Show-Help
        return
    }
    
    # Determine what to deploy
    $deployBasic = -not ($SecureOnly -or $DataLakeOnly)
    $deploySecure = -not ($BasicOnly -or $DataLakeOnly)
    $deployDataLake = -not ($BasicOnly -or $SecureOnly)
    
    if ($BasicOnly) { $deployBasic = $true; $deploySecure = $false; $deployDataLake = $false }
    if ($SecureOnly) { $deployBasic = $false; $deploySecure = $true; $deployDataLake = $false }
    if ($DataLakeOnly) { $deployBasic = $false; $deploySecure = $false; $deployDataLake = $true }
    
    Write-Header "Azure Storage Account Deployment"
    Write-Info "Resource Group: $ResourceGroupName"
    Write-Info "Location: $Location"
    Write-Info "Timestamp: $(Get-Date)"
    
    # Set subscription if provided
    if ($SubscriptionId -and $SubscriptionId -ne "") {
        Write-Info "Setting Azure subscription: $SubscriptionId"
        Set-AzContext -SubscriptionId $SubscriptionId | Out-Null
    }
    
    try {
        # Execute deployment steps
        Test-Prerequisites
        New-ResourceGroupIfNotExists
        Test-BicepTemplate
        
        if ($deployBasic) {
            Deploy-BasicStorage
        }
        
        if ($deploySecure) {
            Deploy-SecureStorage
        }
        
        if ($deployDataLake) {
            Deploy-DataLakeStorage
        }
        
        Test-Deployment
        Remove-TestResources
        
        Write-Header "Deployment Completed Successfully"
        Write-Info "All storage accounts have been deployed and verified"
    }
    catch {
        Write-Error "Deployment failed: $($_.Exception.Message)"
        Write-Error "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Run main function
Main
