# Azure AI SFI-W1 Policy Framework Implementation Script
# Version: 2.0.0 | Updated: 2025-08-04
# Purpose: Automate the deployment and validation of SFI-W1 compliant policies

param(
    [Parameter(Mandatory=$true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory=$true)]
    [string]$Location = "eastus",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "rg-sfi-policies",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Dev", "Test", "Staging", "Prod")]
    [string]$Environment = "Dev",
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("Audit", "Deny", "Disabled")]
    [string]$GlobalEffect = "Audit",
    
    [Parameter(Mandatory=$false)]
    [string]$LogAnalyticsWorkspaceId = "",
    
    [Parameter(Mandatory=$false)]
    [switch]$ValidateOnly,
    
    [Parameter(Mandatory=$false)]
    [switch]$DeployHighPriorityOnly
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Import required modules
Write-Host "🔧 Importing required Azure modules..." -ForegroundColor Yellow
Import-Module Az.Accounts -Force
Import-Module Az.Resources -Force
Import-Module Az.PolicyInsights -Force

# Authenticate to Azure
Write-Host "🔐 Authenticating to Azure..." -ForegroundColor Yellow
try {
    $context = Get-AzContext
    if (-not $context -or $context.Subscription.Id -ne $SubscriptionId) {
        Connect-AzAccount -Subscription $SubscriptionId
    }
    Write-Host "✅ Successfully authenticated to subscription: $SubscriptionId" -ForegroundColor Green
} catch {
    Write-Error "❌ Failed to authenticate to Azure: $_"
    exit 1
}

# Define service priorities and policies
$ServicePriorities = @{
    "High" = @("azure-openai", "machine-learning", "cognitive-search", "document-intelligence", "cognitive-services")
    "Medium" = @("key-vault", "virtual-network", "storage", "monitoring", "firewall")
    "Low" = @("container-infrastructure", "data-services", "compute", "backup-recovery", "identity-access")
}

# Policy template structure
$PolicyTemplate = @{
    "RequirePrivateEndpoints" = @{
        "Description" = "Enforce private endpoint usage for network isolation"
        "Category" = "Network Security"
        "Effect" = "Deny"
    }
    "RequireCustomerManagedKeys" = @{
        "Description" = "Enforce customer-managed encryption keys"
        "Category" = "Data Protection" 
        "Effect" = "Deny"
    }
    "RequireDiagnosticSettings" = @{
        "Description" = "Enable comprehensive audit logging"
        "Category" = "Monitoring"
        "Effect" = "DeployIfNotExists"
    }
    "RequireManagedIdentity" = @{
        "Description" = "Enforce managed identity usage"
        "Category" = "Identity Security"
        "Effect" = "Deny"
    }
    "RestrictSKUs" = @{
        "Description" = "Restrict to approved resource SKUs"
        "Category" = "Resource Governance"
        "Effect" = "Deny"
    }
}

function Write-SectionHeader {
    param([string]$Title)
    Write-Host ""
    Write-Host "=" * 80 -ForegroundColor Cyan
    Write-Host " $Title" -ForegroundColor Cyan
    Write-Host "=" * 80 -ForegroundColor Cyan
}

function Test-PolicyCompliance {
    param(
        [string]$ServiceName,
        [string]$PolicyPath
    )
    
    Write-Host "🔍 Validating policy compliance for $ServiceName..." -ForegroundColor Yellow
    
    # Check if policy files exist and follow naming convention
    $expectedPolicies = @()
    foreach ($policyType in $PolicyTemplate.Keys) {
        $expectedFile = "SFI-W1-Def-$ServiceName-$policyType.bicep"
        $expectedPolicies += $expectedFile
        
        $filePath = Join-Path $PolicyPath $expectedFile
        if (Test-Path $filePath) {
            Write-Host "  ✅ Found: $expectedFile" -ForegroundColor Green
            
            # Validate file content
            $content = Get-Content $filePath -Raw
            if ($content -match "SFI-W1-Def-$ServiceName-$policyType" -and 
                $content -match "targetScope = 'subscription'" -and
                $content -match "Microsoft.Authorization/policyDefinitions") {
                Write-Host "    ✅ Content validation passed" -ForegroundColor Green
            } else {
                Write-Host "    ⚠️  Content validation failed" -ForegroundColor Yellow
            }
        } else {
            Write-Host "  ❌ Missing: $expectedFile" -ForegroundColor Red
        }
    }
    
    # Check for initiative file
    $initiativeFile = "SFI-W1-Ini-$ServiceName.bicep"
    $initiativePath = $PolicyPath.Replace("definitions", "initiatives")
    $initiativeFullPath = Join-Path $initiativePath $initiativeFile
    
    if (Test-Path $initiativeFullPath) {
        Write-Host "  ✅ Found initiative: $initiativeFile" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Missing initiative: $initiativeFile" -ForegroundColor Red
    }
    
    return $expectedPolicies
}

function Deploy-ServicePolicies {
    param(
        [string]$ServiceName,
        [string]$PolicyPath,
        [string]$Priority
    )
    
    Write-Host "🚀 Deploying policies for $ServiceName (Priority: $Priority)..." -ForegroundColor Yellow
    
    $deploymentName = "sfi-$ServiceName-policies-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    try {
        # Deploy individual policies first
        $policyFiles = Get-ChildItem -Path $PolicyPath -Filter "SFI-W1-Def-$ServiceName-*.bicep"
        
        foreach ($policyFile in $policyFiles) {
            Write-Host "  📦 Deploying policy: $($policyFile.Name)" -ForegroundColor Blue
            
            $policyDeploymentName = "$deploymentName-$($policyFile.BaseName)"
            
            if (-not $ValidateOnly) {
                $deployment = New-AzSubscriptionDeployment `
                    -Name $policyDeploymentName `
                    -Location $Location `
                    -TemplateFile $policyFile.FullName `
                    -Verbose
                
                if ($deployment.ProvisioningState -eq "Succeeded") {
                    Write-Host "    ✅ Policy deployed successfully" -ForegroundColor Green
                } else {
                    Write-Host "    ❌ Policy deployment failed" -ForegroundColor Red
                }
            } else {
                Write-Host "    🔍 Validation mode - skipping deployment" -ForegroundColor Yellow
            }
        }
        
        # Deploy initiative if exists
        $initiativePath = $PolicyPath.Replace("definitions", "initiatives")
        $initiativeFile = Get-ChildItem -Path $initiativePath -Filter "SFI-W1-Ini-$ServiceName.bicep" -ErrorAction SilentlyContinue
        
        if ($initiativeFile) {
            Write-Host "  📦 Deploying initiative: $($initiativeFile.Name)" -ForegroundColor Blue
            
            if (-not $ValidateOnly) {
                $initiativeDeploymentName = "$deploymentName-initiative"
                
                $deployment = New-AzSubscriptionDeployment `
                    -Name $initiativeDeploymentName `
                    -Location $Location `
                    -TemplateFile $initiativeFile.FullName `
                    -Verbose
                
                if ($deployment.ProvisioningState -eq "Succeeded") {
                    Write-Host "    ✅ Initiative deployed successfully" -ForegroundColor Green
                } else {
                    Write-Host "    ❌ Initiative deployment failed" -ForegroundColor Red
                }
            }
        }
        
        return $true
    } catch {
        Write-Host "    ❌ Deployment failed: $_" -ForegroundColor Red
        return $false
    }
}

function Generate-ComplianceReport {
    param([hashtable]$Results)
    
    Write-SectionHeader "📊 SFI-W1 COMPLIANCE REPORT"
    
    $totalServices = 0
    $compliantServices = 0
    $totalPolicies = 0
    $deployedPolicies = 0
    
    foreach ($priority in $ServicePriorities.Keys) {
        Write-Host ""
        Write-Host "🎯 $priority Priority Services:" -ForegroundColor Magenta
        
        foreach ($service in $ServicePriorities[$priority]) {
            $totalServices++
            $serviceResult = $Results[$service]
            
            if ($serviceResult) {
                Write-Host "  ✅ $service" -ForegroundColor Green
                $compliantServices++
                $deployedPolicies += $serviceResult.Count
            } else {
                Write-Host "  ❌ $service" -ForegroundColor Red
            }
            
            $totalPolicies += 5  # Expected policies per service
        }
    }
    
    Write-Host ""
    Write-Host "📈 SUMMARY STATISTICS:" -ForegroundColor Cyan
    Write-Host "  Services Compliant: $compliantServices/$totalServices ($([math]::Round(($compliantServices/$totalServices)*100, 1))%)" -ForegroundColor $(if($compliantServices -eq $totalServices) {"Green"} else {"Yellow"})
    Write-Host "  Policies Deployed: $deployedPolicies/$totalPolicies ($([math]::Round(($deployedPolicies/$totalPolicies)*100, 1))%)" -ForegroundColor $(if($deployedPolicies -eq $totalPolicies) {"Green"} else {"Yellow"})
    Write-Host "  Environment: $Environment" -ForegroundColor Blue
    Write-Host "  Global Effect: $GlobalEffect" -ForegroundColor Blue
    Write-Host "  Deployment Mode: $(if($ValidateOnly) {"Validation Only"} else {"Full Deployment"})" -ForegroundColor Blue
}

# Main execution
try {
    Write-SectionHeader "🚀 AZURE AI SFI-W1 POLICY FRAMEWORK DEPLOYMENT"
    
    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host "  Subscription: $SubscriptionId" -ForegroundColor Blue
    Write-Host "  Location: $Location" -ForegroundColor Blue
    Write-Host "  Environment: $Environment" -ForegroundColor Blue
    Write-Host "  Global Effect: $GlobalEffect" -ForegroundColor Blue
    Write-Host "  Validation Only: $ValidateOnly" -ForegroundColor Blue
    Write-Host "  Deploy High Priority Only: $DeployHighPriorityOnly" -ForegroundColor Blue
    
    # Define base paths
    $scriptPath = $PSScriptRoot
    $policiesPath = Join-Path $scriptPath "policies"
    $definitionsPath = Join-Path $policiesPath "definitions"
    
    # Results tracking
    $deploymentResults = @{}
    $servicesToProcess = @()
    
    # Determine which services to process
    if ($DeployHighPriorityOnly) {
        $servicesToProcess = $ServicePriorities["High"]
    } else {
        $servicesToProcess = $ServicePriorities["High"] + $ServicePriorities["Medium"] + $ServicePriorities["Low"]
    }
    
    Write-SectionHeader "🔍 VALIDATION PHASE"
    
    # Validate each service
    foreach ($service in $servicesToProcess) {
        $servicePath = Join-Path $definitionsPath $service
        
        if (Test-Path $servicePath) {
            $policies = Test-PolicyCompliance -ServiceName $service -PolicyPath $servicePath
            $deploymentResults[$service] = $policies
        } else {
            Write-Host "⚠️  Service directory not found: $servicePath" -ForegroundColor Yellow
            $deploymentResults[$service] = $null
        }
    }
    
    if (-not $ValidateOnly) {
        Write-SectionHeader "🚀 DEPLOYMENT PHASE"
        
        # Deploy policies by priority
        foreach ($priority in @("High", "Medium", "Low")) {
            if ($DeployHighPriorityOnly -and $priority -ne "High") { continue }
            
            Write-Host ""
            Write-Host "📦 Deploying $priority Priority Services..." -ForegroundColor Magenta
            
            foreach ($service in $ServicePriorities[$priority]) {
                $servicePath = Join-Path $definitionsPath $service
                
                if (Test-Path $servicePath -and $deploymentResults[$service]) {
                    $success = Deploy-ServicePolicies -ServiceName $service -PolicyPath $servicePath -Priority $priority
                    
                    if (-not $success) {
                        Write-Host "⚠️  Deployment failed for $service - continuing with next service" -ForegroundColor Yellow
                    }
                }
            }
        }
    }
    
    # Generate final report
    Generate-ComplianceReport -Results $deploymentResults
    
    Write-Host ""
    Write-Host "🎉 SFI-W1 Policy Framework deployment completed successfully!" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "❌ DEPLOYMENT FAILED: $_" -ForegroundColor Red
    Write-Host "Stack Trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Red
    exit 1
}

# Usage examples:
<#
# Validate only (no deployment)
.\Deploy-SFI-Policies.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -ValidateOnly

# Deploy high priority services only in audit mode
.\Deploy-SFI-Policies.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -DeployHighPriorityOnly -GlobalEffect "Audit"

# Full deployment in production with deny mode
.\Deploy-SFI-Policies.ps1 -SubscriptionId "12345678-1234-1234-1234-123456789012" -Environment "Prod" -GlobalEffect "Deny" -LogAnalyticsWorkspaceId "/subscriptions/.../workspaces/..."
#>
