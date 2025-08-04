# =============================================================================
# Advanced Template Validation Script (PowerShell)
# =============================================================================
# Purpose: Comprehensive validation of Bicep templates, policies, and configurations
# Version: 2.0.0
# Date: August 2, 2025
# =============================================================================

param(
    [switch]$Help,
    [string]$LogPath = "",
    [switch]$Detailed
)

# Script configuration
$ErrorActionPreference = "Stop"
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent (Split-Path -Parent $ScriptRoot)
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogFile = if ($LogPath) { $LogPath } else { Join-Path $RootDir "logs\validation-$Timestamp.log" }

# Validation counters
$Global:TotalTests = 0
$Global:PassedTests = 0
$Global:FailedTests = 0
$Global:WarningTests = 0

# Create logs directory
$LogDir = Split-Path -Parent $LogFile
if (!(Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

function Write-Log {
    param([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$TimeStamp] $Message"
    Write-Host $LogMessage -ForegroundColor Blue
    Add-Content -Path $LogFile -Value $LogMessage
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
    Add-Content -Path $LogFile -Value "✅ $Message"
    $Global:PassedTests++
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
    Add-Content -Path $LogFile -Value "⚠️  $Message"
    $Global:WarningTests++
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
    Add-Content -Path $LogFile -Value "❌ $Message"
    $Global:FailedTests++
}

function Start-Test {
    param([string]$TestName)
    $Global:TotalTests++
    Write-Log "🧪 Test: $TestName"
}

function Write-Separator {
    $separator = "=" * 64
    Write-Host $separator -ForegroundColor Blue
}

# =============================================================================
# BICEP TEMPLATE VALIDATION
# =============================================================================

function Test-BicepSyntax {
    Write-Log "🔍 Validating Bicep template syntax..."
    Write-Separator
    
    $errorCount = 0
    
    # Validate module templates
    $moduleDirectories = Get-ChildItem -Path (Join-Path $RootDir "modules") -Directory
    foreach ($moduleDir in $moduleDirectories) {
        $mainBicep = Join-Path $moduleDir.FullName "main.bicep"
        if (Test-Path $mainBicep) {
            Start-Test "Bicep syntax for $($moduleDir.Name)"
            
            try {
                $tempDir = Join-Path $env:TEMP "bicep-validation"
                if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
                
                az bicep build --file $mainBicep --outdir $tempDir 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Success "Bicep syntax valid: $($moduleDir.Name)"
                } else {
                    Write-Error "Bicep syntax error: $($moduleDir.Name)"
                    $errorCount++
                }
            }
            catch {
                Write-Error "Bicep syntax error: $($moduleDir.Name) - $($_.Exception.Message)"
                $errorCount++
            }
        }
    }
    
    # Validate shared templates
    $sharedTemplates = Get-ChildItem -Path (Join-Path $RootDir "shared\templates") -Recurse -Filter "*.bicep"
    foreach ($template in $sharedTemplates) {
        Start-Test "Bicep syntax for $($template.Name)"
        
        try {
            $tempDir = Join-Path $env:TEMP "bicep-validation"
            if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
            
            az bicep build --file $template.FullName --outdir $tempDir 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Bicep syntax valid: $($template.Name)"
            } else {
                Write-Error "Bicep syntax error: $($template.Name)"
                $errorCount++
            }
        }
        catch {
            Write-Error "Bicep syntax error: $($template.Name) - $($_.Exception.Message)"
            $errorCount++
        }
    }
    
    if ($errorCount -eq 0) {
        Write-Success "All Bicep templates have valid syntax"
    } else {
        Write-Error "$errorCount Bicep syntax errors found"
    }
}

function Test-ParameterFiles {
    Write-Log "🔍 Validating parameter files..."
    Write-Separator
    
    $errorCount = 0
    
    # Validate module parameter files
    $moduleDirectories = Get-ChildItem -Path (Join-Path $RootDir "modules") -Directory
    foreach ($moduleDir in $moduleDirectories) {
        $paramFile = Join-Path $moduleDir.FullName "main.parameters.json"
        if (Test-Path $paramFile) {
            Start-Test "Parameter file for $($moduleDir.Name)"
            
            try {
                $content = Get-Content $paramFile -Raw | ConvertFrom-Json
                Write-Success "Valid JSON: $($moduleDir.Name) parameters"
            }
            catch {
                Write-Error "Invalid JSON: $($moduleDir.Name) parameters"
                $errorCount++
            }
        }
    }
    
    # Validate environment parameter files
    $envDirectories = Get-ChildItem -Path (Join-Path $RootDir "environments") -Directory
    foreach ($envDir in $envDirectories) {
        $envName = $envDir.Name
        $envFile = Join-Path $envDir.FullName "$envName.parameters.json"
        
        if (Test-Path $envFile) {
            Start-Test "Environment parameters for $envName"
            
            try {
                $content = Get-Content $envFile -Raw | ConvertFrom-Json
                Write-Success "Valid JSON: $envName environment parameters"
                
                # Validate required parameters
                $requiredParams = @("environment", "resourcePrefix", "location", "tags")
                foreach ($param in $requiredParams) {
                    if ($content.parameters.PSObject.Properties.Name -contains $param) {
                        Write-Success "Required parameter present: $param in $envName"
                    } else {
                        Write-Warning "Missing recommended parameter: $param in $envName"
                    }
                }
            }
            catch {
                Write-Error "Invalid JSON: $envName environment parameters"
                $errorCount++
            }
        }
    }
    
    if ($errorCount -eq 0) {
        Write-Success "All parameter files are valid"
    } else {
        Write-Error "$errorCount parameter file errors found"
    }
}

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

function Test-SecurityPatterns {
    Write-Log "🛡️ Validating security patterns..."
    Write-Separator
    
    $modulesPath = Join-Path $RootDir "modules"
    
    # Check for private endpoints
    Start-Test "Private endpoint configurations"
    $peCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "privateEndpoint|PrivateEndpoint" -AllMatches).Count
    if ($peCount -gt 0) {
        Write-Success "Private endpoint configurations found: $peCount references"
    } else {
        Write-Warning "Consider adding private endpoint configurations"
    }
    
    # Check for managed identity usage
    Start-Test "Managed identity configurations"
    $miCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "managedIdentity|ManagedIdentity|SystemAssigned|UserAssigned" -AllMatches).Count
    if ($miCount -gt 0) {
        Write-Success "Managed identity configurations found: $miCount references"
    } else {
        Write-Warning "Consider using managed identities for authentication"
    }
    
    # Check for diagnostic settings
    Start-Test "Diagnostic settings configurations"
    $dsCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "diagnosticSettings|Microsoft.Insights/diagnosticSettings" -AllMatches).Count
    if ($dsCount -gt 0) {
        Write-Success "Diagnostic settings found: $dsCount references"
    } else {
        Write-Warning "Consider adding diagnostic settings for monitoring"
    }
    
    # Check for encryption configurations
    Start-Test "Encryption configurations"
    $encCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "encryption|customerManagedKey|encryptionAtRest" -AllMatches).Count
    if ($encCount -gt 0) {
        Write-Success "Encryption configurations found: $encCount references"
    } else {
        Write-Warning "Consider adding customer-managed encryption"
    }
    
    # Check for network restrictions
    Start-Test "Network access restrictions"
    $netCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "networkAcls|publicNetworkAccess.*Disabled|allowedIpRanges" -AllMatches).Count
    if ($netCount -gt 0) {
        Write-Success "Network restrictions found: $netCount references"
    } else {
        Write-Warning "Consider adding network access restrictions"
    }
}

function Test-CompliancePatterns {
    Write-Log "📋 Validating compliance patterns..."
    Write-Separator
    
    $modulesPath = Join-Path $RootDir "modules"
    
    # Check for required tags
    Start-Test "Required tagging patterns"
    $tagCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "Environment|Purpose|Owner|CostCenter" -AllMatches).Count
    if ($tagCount -gt 0) {
        Write-Success "Tagging patterns found: $tagCount references"
    } else {
        Write-Warning "Consider adding standardized tags for governance"
    }
    
    # Check for audit logging
    Start-Test "Audit logging configurations"
    $auditCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "auditLogs|Category.*Audit|logAnalyticsWorkspace" -AllMatches).Count
    if ($auditCount -gt 0) {
        Write-Success "Audit logging configurations found: $auditCount references"
    } else {
        Write-Warning "Consider adding audit logging capabilities"
    }
    
    # Check for backup configurations
    Start-Test "Backup and recovery configurations"
    $backupCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "backup|recovery|retention|immutable" -AllMatches).Count
    if ($backupCount -gt 0) {
        Write-Success "Backup configurations found: $backupCount references"
    } else {
        Write-Warning "Consider adding backup and recovery configurations"
    }
}

# =============================================================================
# POLICY VALIDATION
# =============================================================================

function Test-PolicyTemplates {
    Write-Log "📋 Validating policy templates..."
    Write-Separator
    
    $errorCount = 0
    
    # Validate policy definitions
    $policyFiles = Get-ChildItem -Path (Join-Path $RootDir "policies\definitions") -Recurse -Filter "*.bicep"
    foreach ($policyFile in $policyFiles) {
        Start-Test "Policy definition: $($policyFile.Name)"
        
        try {
            $tempDir = Join-Path $env:TEMP "policy-validation"
            if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
            
            az bicep build --file $policyFile.FullName --outdir $tempDir 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Policy template valid: $($policyFile.Name)"
                
                # Check for required policy components
                $content = Get-Content $policyFile.FullName -Raw
                if ($content -match "policyRule") {
                    Write-Success "Policy rule found: $($policyFile.Name)"
                } else {
                    Write-Warning "Policy rule not found: $($policyFile.Name)"
                }
                
                if ($content -match "parameters") {
                    Write-Success "Policy parameters found: $($policyFile.Name)"
                } else {
                    Write-Warning "No parameters defined: $($policyFile.Name)"
                }
            } else {
                Write-Error "Policy template error: $($policyFile.Name)"
                $errorCount++
            }
        }
        catch {
            Write-Error "Policy template error: $($policyFile.Name) - $($_.Exception.Message)"
            $errorCount++
        }
    }
    
    # Validate policy initiatives
    $initiativeFiles = Get-ChildItem -Path (Join-Path $RootDir "policies\initiatives") -Recurse -Filter "*.bicep"
    foreach ($initiativeFile in $initiativeFiles) {
        Start-Test "Policy initiative: $($initiativeFile.Name)"
        
        try {
            $tempDir = Join-Path $env:TEMP "initiative-validation"
            if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
            
            az bicep build --file $initiativeFile.FullName --outdir $tempDir 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Success "Initiative template valid: $($initiativeFile.Name)"
            } else {
                Write-Error "Initiative template error: $($initiativeFile.Name)"
                $errorCount++
            }
        }
        catch {
            Write-Error "Initiative template error: $($initiativeFile.Name) - $($_.Exception.Message)"
            $errorCount++
        }
    }
    
    if ($errorCount -eq 0) {
        Write-Success "All policy templates are valid"
    } else {
        Write-Error "$errorCount policy template errors found"
    }
}

# =============================================================================
# DOCUMENTATION VALIDATION
# =============================================================================

function Test-Documentation {
    Write-Log "📚 Validating documentation..."
    Write-Separator
    
    # Check for module README files
    $moduleDirectories = Get-ChildItem -Path (Join-Path $RootDir "modules") -Directory
    foreach ($moduleDir in $moduleDirectories) {
        $moduleName = $moduleDir.Name
        Start-Test "README for $moduleName module"
        
        $readmePath = Join-Path $moduleDir.FullName "README.md"
        if (Test-Path $readmePath) {
            Write-Success "README found: $moduleName"
            
            # Check for required sections
            $content = Get-Content $readmePath -Raw
            if ($content -match "## Features|## Usage|## Parameters") {
                Write-Success "Required sections found: $moduleName"
            } else {
                Write-Warning "Consider adding Features, Usage, or Parameters sections: $moduleName"
            }
        } else {
            Write-Error "Missing README: $moduleName"
        }
    }
    
    # Check for root documentation
    Start-Test "Root documentation files"
    $rootDocs = @("README.md", "CONTRIBUTING.md", "SECURITY.md", "CHANGELOG.md")
    foreach ($doc in $rootDocs) {
        $docPath = Join-Path $RootDir $doc
        if (Test-Path $docPath) {
            Write-Success "Found: $doc"
        } else {
            Write-Warning "Consider adding: $doc"
        }
    }
    
    # Check for environment documentation
    Start-Test "Environment documentation"
    $envDirectories = Get-ChildItem -Path (Join-Path $RootDir "environments") -Directory
    foreach ($envDir in $envDirectories) {
        $envName = $envDir.Name
        $envReadme = Join-Path $envDir.FullName "README.md"
        if (Test-Path $envReadme) {
            Write-Success "Environment documentation found: $envName"
        } else {
            Write-Warning "Consider adding README for environment: $envName"
        }
    }
}

# =============================================================================
# STRUCTURE VALIDATION
# =============================================================================

function Test-FolderStructure {
    Write-Log "📁 Validating folder structure..."
    Write-Separator
    
    # Check for required directories
    $requiredDirs = @(
        "modules",
        "policies",
        "environments",
        "shared",
        "scripts",
        "docs",
        ".github\workflows"
    )
    
    foreach ($dir in $requiredDirs) {
        Start-Test "Required directory: $dir"
        $dirPath = Join-Path $RootDir $dir
        if (Test-Path $dirPath) {
            Write-Success "Directory exists: $dir"
        } else {
            Write-Error "Missing required directory: $dir"
        }
    }
    
    # Check for naming conventions
    Start-Test "Naming convention compliance"
    $namingIssues = 0
    
    # Check module naming (should be kebab-case)
    $moduleDirectories = Get-ChildItem -Path (Join-Path $RootDir "modules") -Directory
    foreach ($moduleDir in $moduleDirectories) {
        $moduleName = $moduleDir.Name
        if ($moduleName -match "^[a-z][a-z0-9-]*[a-z0-9]$") {
            Write-Success "Naming convention valid: $moduleName"
        } else {
            Write-Warning "Naming convention issue: $moduleName (should be kebab-case)"
            $namingIssues++
        }
    }
    
    if ($namingIssues -eq 0) {
        Write-Success "All names follow conventions"
    } else {
        Write-Warning "$namingIssues naming convention issues found"
    }
}

# =============================================================================
# PERFORMANCE VALIDATION
# =============================================================================

function Test-PerformancePatterns {
    Write-Log "⚡ Validating performance patterns..."
    Write-Separator
    
    $modulesPath = Join-Path $RootDir "modules"
    
    # Check for resource optimization patterns
    Start-Test "Resource optimization patterns"
    $optCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "sku|tier|capacity|autoscale" -AllMatches).Count
    if ($optCount -gt 0) {
        Write-Success "Resource optimization patterns found: $optCount references"
    } else {
        Write-Warning "Consider adding resource optimization configurations"
    }
    
    # Check for monitoring configurations
    Start-Test "Monitoring and alerting patterns"
    $monCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "alert|metric|monitor|Application.*Insights" -AllMatches).Count
    if ($monCount -gt 0) {
        Write-Success "Monitoring patterns found: $monCount references"
    } else {
        Write-Warning "Consider adding monitoring and alerting capabilities"
    }
    
    # Check for caching patterns
    Start-Test "Caching optimization patterns"
    $cacheCount = (Select-String -Path "$modulesPath\*\*.bicep" -Pattern "cache|redis|cdn" -AllMatches).Count
    if ($cacheCount -gt 0) {
        Write-Success "Caching patterns found: $cacheCount references"
    } else {
        Write-Warning "Consider adding caching for performance optimization"
    }
}

# =============================================================================
# MAIN VALIDATION WORKFLOW
# =============================================================================

function Start-AllValidations {
    Write-Separator
    Write-Log "🚀 Starting Comprehensive Template Validation"
    Write-Separator
    
    # Core validations
    Test-BicepSyntax
    Test-ParameterFiles
    Test-PolicyTemplates
    
    # Security validations
    Test-SecurityPatterns
    Test-CompliancePatterns
    
    # Structure validations
    Test-FolderStructure
    Test-Documentation
    
    # Performance validations
    Test-PerformancePatterns
}

function Show-ValidationSummary {
    Write-Separator
    Write-Log "📊 Validation Summary"
    Write-Separator
    
    Write-Host "🧪 Total Tests: $Global:TotalTests"
    Write-Host "✅ Passed: $Global:PassedTests"
    Write-Host "❌ Failed: $Global:FailedTests"
    Write-Host "⚠️  Warnings: $Global:WarningTests"
    Write-Host ""
    
    $successRate = [math]::Round(($Global:PassedTests * 100 / $Global:TotalTests), 0)
    Write-Host "📈 Success Rate: $successRate%"
    Write-Host "📝 Log File: $LogFile"
    Write-Host "⏱️ Completed: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Host ""
    
    if ($Global:FailedTests -eq 0) {
        if ($Global:WarningTests -eq 0) {
            Write-Success "🏆 Perfect validation! All tests passed with no warnings."
            Write-Host "🎯 Repository Quality Score: 10/10" -ForegroundColor Green
        } else {
            Write-Success "✅ Validation passed with $Global:WarningTests recommendations."
            Write-Host "🎯 Repository Quality Score: 9/10" -ForegroundColor Green
        }
    } else {
        Write-Error "❌ Validation failed with $Global:FailedTests errors."
        Write-Host "🎯 Repository Quality Score: $([math]::Round($successRate/10, 0))/10" -ForegroundColor Red
    }
    
    Write-Separator
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

function Show-Help {
    @"
🧪 Advanced Template Validation Script

PURPOSE:
    Comprehensive validation of Azure infrastructure templates, policies, and configurations.

USAGE:
    .\validate-templates.ps1 [OPTIONS]

OPTIONS:
    -Help           Show this help message
    -LogPath        Specify custom log file path
    -Detailed       Show detailed validation output

VALIDATION CATEGORIES:
    🔍 Bicep Syntax        - Template compilation and syntax validation
    📋 Parameters          - JSON syntax and required parameter validation
    🛡️ Security            - Security pattern and best practice validation
    📚 Documentation       - README and documentation completeness
    📁 Structure           - Folder organization and naming conventions
    ⚡ Performance         - Optimization and monitoring pattern validation
    📋 Policies            - Azure Policy template validation

OUTPUT:
    - Detailed validation results with pass/fail status
    - Security and compliance recommendations
    - Performance optimization suggestions
    - Overall quality score (0-10)

"@
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

try {
    # Create temporary directories for validation
    $tempPaths = @(
        (Join-Path $env:TEMP "bicep-validation"),
        (Join-Path $env:TEMP "policy-validation"),
        (Join-Path $env:TEMP "initiative-validation")
    )
    
    foreach ($tempPath in $tempPaths) {
        if (!(Test-Path $tempPath)) {
            New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
        }
    }
    
    # Run all validations
    Start-AllValidations
    
    # Show summary
    Show-ValidationSummary
    
    # Clean up
    foreach ($tempPath in $tempPaths) {
        Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Exit with appropriate code
    if ($Global:FailedTests -gt 0) {
        exit 1
    } else {
        exit 0
    }
}
catch {
    Write-Error "Validation script failed: $($_.Exception.Message)"
    exit 1
}
