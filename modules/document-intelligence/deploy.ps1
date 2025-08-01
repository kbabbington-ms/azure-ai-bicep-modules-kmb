# Azure AI Document Intelligence Module - PowerShell Deployment Script
# This script deploys the Document Intelligence service with comprehensive security and processing capabilities
# Version: 1.0.0 | Date: 2025-08-01

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ResourceGroup = $env:RESOURCE_GROUP,
    
    [Parameter(Mandatory = $false)]
    [string]$DocumentIntelligenceName = $env:DOC_INTEL_NAME,
    
    [Parameter(Mandatory = $false)]
    [string]$Location = $env:LOCATION,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet('F0', 'S0')]
    [string]$DocumentIntelligenceSku = $env:DOC_INTEL_SKU,
    
    [Parameter(Mandatory = $false)]
    [bool]$EnablePrivateEndpoint = [bool]::Parse($env:ENABLE_PRIVATE_ENDPOINT ?? $false),
    
    [Parameter(Mandatory = $false)]
    [string]$SubnetId = $env:SUBNET_ID,
    
    [Parameter(Mandatory = $false)]
    [bool]$EnableCustomerManagedKey = [bool]::Parse($env:ENABLE_CUSTOMER_MANAGED_KEY ?? $false),
    
    [Parameter(Mandatory = $false)]
    [string]$KeyVaultId = $env:KEY_VAULT_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$KeyName = $env:KEY_NAME,
    
    [Parameter(Mandatory = $false)]
    [string]$LogAnalyticsWorkspaceId = $env:LOG_ANALYTICS_WORKSPACE_ID,
    
    [Parameter(Mandatory = $false)]
    [string]$ResourceTags = $env:RESOURCE_TAGS,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipWhatIf = [bool]::Parse($env:SKIP_WHATIF ?? $false),
    
    [Parameter(Mandatory = $false)]
    [switch]$Help
)

# Script configuration
$ScriptName = "Azure AI Document Intelligence Deployment"
$ScriptVersion = "1.0.0"
$DeploymentName = "document-intelligence-$(Get-Date -Format 'yyyyMMdd-HHmmss')"

# Function to write colored output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    
    $originalColor = $Host.UI.RawUI.ForegroundColor
    $Host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $Host.UI.RawUI.ForegroundColor = $originalColor
}

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-ColorOutput "[INFO] $Message" "Cyan"
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[WARNING] $Message" "Yellow"
}

function Write-ErrorMsg {
    param([string]$Message)
    Write-ColorOutput "[ERROR] $Message" "Red"
}

# Function to display script header
function Show-Header {
    Write-Output "======================================"
    Write-Output $ScriptName
    Write-Output "Version: $ScriptVersion"
    Write-Output "Date: $(Get-Date)"
    Write-Output "======================================"
    Write-Output ""
}

# Function to display usage
function Show-Usage {
    Write-Output "Usage: .\deploy.ps1 [parameters]"
    Write-Output ""
    Write-Output "Parameters:"
    Write-Output "  -ResourceGroup                   Required: Target resource group"
    Write-Output "  -DocumentIntelligenceName        Required: Document Intelligence service name"
    Write-Output "  -Location                        Optional: Azure region (default: eastus)"
    Write-Output "  -DocumentIntelligenceSku         Optional: Service SKU (F0/S0)"
    Write-Output "  -EnablePrivateEndpoint           Optional: Enable private endpoint"
    Write-Output "  -SubnetId                        Optional: Subnet ID for private endpoint"
    Write-Output "  -EnableCustomerManagedKey        Optional: Enable customer-managed keys"
    Write-Output "  -KeyVaultId                      Optional: Key Vault resource ID"
    Write-Output "  -KeyName                         Optional: Key name for encryption"
    Write-Output "  -LogAnalyticsWorkspaceId         Optional: Log Analytics workspace ID"
    Write-Output "  -ResourceTags                    Optional: Resource tags (JSON format)"
    Write-Output "  -SkipWhatIf                      Optional: Skip what-if analysis"
    Write-Output "  -Help                            Show this help message"
    Write-Output ""
    Write-Output "Environment Variables (alternative to parameters):"
    Write-Output "  RESOURCE_GROUP, DOC_INTEL_NAME, LOCATION, DOC_INTEL_SKU,"
    Write-Output "  ENABLE_PRIVATE_ENDPOINT, SUBNET_ID, ENABLE_CUSTOMER_MANAGED_KEY,"
    Write-Output "  KEY_VAULT_ID, KEY_NAME, LOG_ANALYTICS_WORKSPACE_ID, RESOURCE_TAGS, SKIP_WHATIF"
    Write-Output ""
    Write-Output "Examples:"
    Write-Output "  # Basic deployment"
    Write-Output "  .\deploy.ps1 -ResourceGroup 'my-rg' -DocumentIntelligenceName 'mydocintel'"
    Write-Output ""
    Write-Output "  # Production deployment with private endpoint"
    Write-Output "  .\deploy.ps1 -ResourceGroup 'my-prod-rg' -DocumentIntelligenceName 'mydocintel-prod' \"
    Write-Output "               -DocumentIntelligenceSku 'S0' -EnablePrivateEndpoint `$true \"
    Write-Output "               -SubnetId '/subscriptions/.../subnets/mysubnet'"
}

# Function to check prerequisites
function Test-Prerequisites {
    Write-Info "Checking prerequisites..."
    
    # Check if Azure PowerShell is installed
    if (-not (Get-Module -ListAvailable -Name Az.Accounts)) {
        Write-ErrorMsg "Azure PowerShell Az module is not installed. Please install it first:"
        Write-Output "Install-Module -Name Az -Repository PSGallery -Force"
        exit 1
    }
    
    # Check if user is logged in
    try {
        $context = Get-AzContext
        if (-not $context) {
            throw "Not authenticated"
        }
    }
    catch {
        Write-ErrorMsg "Not logged in to Azure PowerShell. Please run 'Connect-AzAccount' first."
        exit 1
    }
    
    # Check if Bicep is available
    try {
        az bicep version | Out-Null
    }
    catch {
        Write-Warning "Bicep CLI not found. Installing Bicep..."
        az bicep install
    }
    
    Write-Success "Prerequisites check completed"
}

# Function to validate parameters
function Test-Parameters {
    Write-Info "Validating deployment parameters..."
    
    if (-not $ResourceGroup) {
        Write-ErrorMsg "ResourceGroup parameter is required"
        exit 1
    }
    
    if (-not $DocumentIntelligenceName) {
        Write-ErrorMsg "DocumentIntelligenceName parameter is required"
        exit 1
    }
    
    if (-not $Location) {
        Write-Warning "Location not specified, using default: eastus"
        $script:Location = "eastus"
    }
    
    # Validate Document Intelligence name
    if ($DocumentIntelligenceName.Length -lt 2 -or $DocumentIntelligenceName.Length -gt 24) {
        Write-ErrorMsg "Document Intelligence name must be between 2 and 24 characters"
        exit 1
    }
    
    # Validate private endpoint configuration
    if ($EnablePrivateEndpoint -and -not $SubnetId) {
        Write-ErrorMsg "SubnetId is required when EnablePrivateEndpoint is true"
        exit 1
    }
    
    # Validate customer-managed key configuration
    if ($EnableCustomerManagedKey -and (-not $KeyVaultId -or -not $KeyName)) {
        Write-ErrorMsg "KeyVaultId and KeyName are required when EnableCustomerManagedKey is true"
        exit 1
    }
    
    Write-Success "Parameter validation completed"
}

# Function to check resource group
function Test-ResourceGroup {
    Write-Info "Checking resource group: $ResourceGroup"
    
    $rg = Get-AzResourceGroup -Name $ResourceGroup -ErrorAction SilentlyContinue
    
    if (-not $rg) {
        Write-Warning "Resource group '$ResourceGroup' does not exist"
        $createRg = Read-Host "Do you want to create it? (y/N)"
        
        if ($createRg -eq 'y' -or $createRg -eq 'Y') {
            Write-Info "Creating resource group: $ResourceGroup"
            New-AzResourceGroup -Name $ResourceGroup -Location $Location
            Write-Success "Resource group created successfully"
        }
        else {
            Write-ErrorMsg "Resource group is required for deployment"
            exit 1
        }
    }
    else {
        Write-Success "Resource group exists"
    }
}

# Function to validate Bicep template
function Test-Template {
    Write-Info "Validating Bicep template..."
    
    if (-not (Test-Path "main.bicep")) {
        Write-ErrorMsg "main.bicep file not found in current directory"
        exit 1
    }
    
    # Build Bicep template to check for errors
    try {
        az bicep build --file main.bicep --outfile temp-template.json
        Remove-Item temp-template.json -ErrorAction SilentlyContinue
    }
    catch {
        Write-ErrorMsg "Bicep template validation failed"
        exit 1
    }
    
    Write-Success "Bicep template validation completed"
}

# Function to perform what-if analysis
function Invoke-WhatIf {
    if ($SkipWhatIf) {
        Write-Info "Skipping what-if analysis (SkipWhatIf specified)"
        return
    }
    
    Write-Info "Performing what-if analysis..."
    
    # Build parameters hashtable
    $deploymentParams = @{
        documentIntelligenceName = $DocumentIntelligenceName
        location = $Location
    }
    
    # Add optional parameters if specified
    if ($DocumentIntelligenceSku) {
        $deploymentParams.documentIntelligenceSku = $DocumentIntelligenceSku
    }
    
    if ($EnablePrivateEndpoint) {
        $deploymentParams.enablePrivateEndpoint = $EnablePrivateEndpoint
        if ($SubnetId) {
            $deploymentParams.subnetId = $SubnetId
        }
    }
    
    if ($EnableCustomerManagedKey) {
        $deploymentParams.enableCustomerManagedKey = $EnableCustomerManagedKey
        if ($KeyVaultId) {
            $deploymentParams.keyVaultId = $KeyVaultId
        }
        if ($KeyName) {
            $deploymentParams.keyName = $KeyName
        }
    }
    
    if ($LogAnalyticsWorkspaceId) {
        $deploymentParams.logAnalyticsWorkspaceId = $LogAnalyticsWorkspaceId
    }
    
    if ($ResourceTags) {
        try {
            $tagsObject = $ResourceTags | ConvertFrom-Json
            $deploymentParams.tags = $tagsObject
        }
        catch {
            Write-Warning "Failed to parse ResourceTags JSON, ignoring tags"
        }
    }
    
    # Perform what-if analysis
    try {
        $whatIfParams = @{
            ResourceGroupName = $ResourceGroup
            Name = $DeploymentName
            TemplateFile = "main.bicep"
            TemplateParameterObject = $deploymentParams
        }
        
        # Add parameters file if it exists
        if (Test-Path "main.parameters.json") {
            $whatIfParams.TemplateParameterFile = "main.parameters.json"
        }
        
        Get-AzResourceGroupDeploymentWhatIfResult @whatIfParams
        
        Write-Output ""
        $proceed = Read-Host "Do you want to proceed with the deployment? (y/N)"
        
        if ($proceed -ne 'y' -and $proceed -ne 'Y') {
            Write-Info "Deployment cancelled by user"
            exit 0
        }
    }
    catch {
        Write-ErrorMsg "What-if analysis failed: $($_.Exception.Message)"
        exit 1
    }
}

# Function to deploy the template
function Invoke-Deployment {
    Write-Info "Starting Document Intelligence deployment..."
    
    # Build parameters hashtable
    $deploymentParams = @{
        documentIntelligenceName = $DocumentIntelligenceName
        location = $Location
    }
    
    # Add optional parameters if specified
    if ($DocumentIntelligenceSku) {
        $deploymentParams.documentIntelligenceSku = $DocumentIntelligenceSku
    }
    
    if ($EnablePrivateEndpoint) {
        $deploymentParams.enablePrivateEndpoint = $EnablePrivateEndpoint
        if ($SubnetId) {
            $deploymentParams.subnetId = $SubnetId
        }
    }
    
    if ($EnableCustomerManagedKey) {
        $deploymentParams.enableCustomerManagedKey = $EnableCustomerManagedKey
        if ($KeyVaultId) {
            $deploymentParams.keyVaultId = $KeyVaultId
        }
        if ($KeyName) {
            $deploymentParams.keyName = $KeyName
        }
    }
    
    if ($LogAnalyticsWorkspaceId) {
        $deploymentParams.logAnalyticsWorkspaceId = $LogAnalyticsWorkspaceId
    }
    
    if ($ResourceTags) {
        try {
            $tagsObject = $ResourceTags | ConvertFrom-Json
            $deploymentParams.tags = $tagsObject
        }
        catch {
            Write-Warning "Failed to parse ResourceTags JSON, ignoring tags"
        }
    }
    
    # Deploy the template
    $startTime = Get-Date
    
    try {
        $deployParams = @{
            ResourceGroupName = $ResourceGroup
            Name = $DeploymentName
            TemplateFile = "main.bicep"
            TemplateParameterObject = $deploymentParams
        }
        
        # Add parameters file if it exists
        if (Test-Path "main.parameters.json") {
            $deployParams.TemplateParameterFile = "main.parameters.json"
        }
        
        $deployment = New-AzResourceGroupDeployment @deployParams
        
        $endTime = Get-Date
        $duration = ($endTime - $startTime).TotalSeconds
        
        Write-Success "Deployment completed in $([math]::Round($duration, 2)) seconds"
        return $deployment
    }
    catch {
        Write-ErrorMsg "Deployment failed: $($_.Exception.Message)"
        exit 1
    }
}

# Function to get deployment outputs
function Get-DeploymentOutputs {
    param([object]$Deployment)
    
    Write-Info "Retrieving deployment outputs..."
    
    if ($Deployment.Outputs -and $Deployment.Outputs.Count -gt 0) {
        Write-Output "Deployment Outputs:"
        Write-Output "=================="
        
        $outputs = $Deployment.Outputs
        $outputs | ConvertTo-Json -Depth 10 | Write-Output
        
        # Extract key information
        $docIntelConfig = $outputs.documentIntelligenceConfig
        if ($docIntelConfig) {
            $endpoint = $docIntelConfig.Value.endpoint
            $serviceName = $docIntelConfig.Value.name
            
            if ($endpoint) {
                Write-Output ""
                Write-Success "Document Intelligence service deployed successfully!"
                Write-Output "Service Name: $serviceName"
                Write-Output "Endpoint: $endpoint"
                Write-Output ""
                Write-Output "Next Steps:"
                Write-Output "1. Configure custom models for your document types"
                Write-Output "2. Set up batch processing workflows"
                Write-Output "3. Integrate with your applications"
                Write-Output "4. Configure monitoring and alerting"
                Write-Output "5. Test document processing capabilities"
            }
        }
    }
    else {
        Write-Warning "No deployment outputs available"
    }
}

# Function to perform post-deployment verification
function Test-Deployment {
    Write-Info "Performing post-deployment verification..."
    
    try {
        # Check if the service exists and is accessible
        $service = Get-AzCognitiveServicesAccount -ResourceGroupName $ResourceGroup -Name $DocumentIntelligenceName -ErrorAction SilentlyContinue
        
        if ($service) {
            Write-Success "Document Intelligence service is accessible"
            
            Write-Output "Service Details:"
            Write-Output "- SKU: $($service.Sku.Name)"
            Write-Output "- Location: $($service.Location)"
            Write-Output "- Provisioning State: $($service.Properties.ProvisioningState)"
            
            if ($service.Properties.ProvisioningState -eq "Succeeded") {
                Write-Success "Service is successfully provisioned"
            }
            else {
                Write-Warning "Service provisioning state: $($service.Properties.ProvisioningState)"
            }
        }
        else {
            Write-ErrorMsg "Document Intelligence service verification failed"
            return $false
        }
    }
    catch {
        Write-ErrorMsg "Service verification failed: $($_.Exception.Message)"
        return $false
    }
    
    return $true
}

# Main execution function
function Invoke-Main {
    try {
        # Show help if requested
        if ($Help) {
            Show-Usage
            return
        }
        
        Show-Header
        
        Test-Prerequisites
        Test-Parameters
        Test-ResourceGroup
        Test-Template
        Invoke-WhatIf
        $deployment = Invoke-Deployment
        Get-DeploymentOutputs -Deployment $deployment
        $verified = Test-Deployment
        
        Write-Output ""
        if ($verified) {
            Write-Success "Document Intelligence deployment completed successfully!"
            Write-Output "Deployment Name: $DeploymentName"
            Write-Output "Resource Group: $ResourceGroup"
            Write-Output "Service Name: $DocumentIntelligenceName"
        }
        else {
            Write-Warning "Deployment completed but verification failed"
        }
        Write-Output ""
        Write-Output "For more information, see the README.md file"
    }
    catch {
        Write-ErrorMsg "Script execution failed: $($_.Exception.Message)"
        Write-ErrorMsg "Stack trace: $($_.ScriptStackTrace)"
        exit 1
    }
}

# Execute main function
Invoke-Main
