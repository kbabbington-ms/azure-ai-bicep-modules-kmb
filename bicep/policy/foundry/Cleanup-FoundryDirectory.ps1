# =============================================================================
# Azure Policy Foundry Directory Cleanup Script
# =============================================================================
# Purpose: Clean up obsolete files from bicep\policy\foundry after migration
# Version: 1.0.0
# Date: August 2, 2025
# Author: Azure AI Infrastructure Team
# =============================================================================

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$WhatIf,
    
    [Parameter()]
    [switch]$Force,
    
    [Parameter()]
    [switch]$BackupFirst,
    
    [Parameter()]
    [string]$BackupPath = ".\backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')",
    
    [Parameter()]
    [switch]$Help
)

# Configuration
$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$LogFile = Join-Path $ScriptDir "cleanup-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

# Colors for output
$Colors = @{
    Header = 'Cyan'
    Success = 'Green'
    Warning = 'Yellow'
    Error = 'Red'
    Info = 'Blue'
    Progress = 'Magenta'
}

# Files categorized for deletion
$FilesToClean = @{
    # Migrated SFI-W1-Def-Foundry policies (20 files)
    MigratedPolicies = @(
        "SFI-W1-Def-Foundry-AdvancedMonitoring.bicep",
        "SFI-W1-Def-Foundry-AllowedAISku.bicep",
        "SFI-W1-Def-Foundry-ContentSafety.bicep",
        "SFI-W1-Def-Foundry-DataResidency.bicep",
        "SFI-W1-Def-Foundry-DiagnosticLoggingAI.bicep",
        "SFI-W1-Def-Foundry-EncryptionTransitAI.bicep",
        "SFI-W1-Def-Foundry-EnforceManagedIdentityUsage.bicep",
        "SFI-W1-Def-Foundry-KeyVaultAISecrets.bicep",
        "SFI-W1-Def-Foundry-LogicAppsAIWorkflows.bicep",
        "SFI-W1-Def-Foundry-LogRetentionAI.bicep",
        "SFI-W1-Def-Foundry-ManagedIdentityAI.bicep",
        "SFI-W1-Def-Foundry-ModelVersionControl.bicep",
        "SFI-W1-Def-Foundry-PrivateEndpointAI.bicep",
        "SFI-W1-Def-Foundry-RequireCreatedByTag.bicep",
        "SFI-W1-Def-Foundry-RequireDiagnosticLogging.bicep",
        "SFI-W1-Def-Foundry-RequireEncryptionAtRest.bicep",
        "SFI-W1-Def-Foundry-RequireKeyVaultPrivateEndpoint.bicep",
        "SFI-W1-Def-Foundry-RestrictPublicNetworkAccess.bicep",
        "SFI-W1-Def-Foundry-TaggingAI.bicep",
        "SFI-W1-Def-Foundry-VideoIndexer.bicep"
    )
    
    # Legacy policy definition format (6 files)
    LegacyPolicies = @(
        "policy-definition-sfi-diagnostic-logging.bicep",
        "policy-definition-sfi-encryption-at-rest.bicep",
        "policy-definition-sfi-keyvault-private-endpoint.bicep",
        "policy-definition-sfi-managed-identity.bicep",
        "policy-definition-sfi-public-network.bicep",
        "policy-definition-sfi-resource-tagging.bicep"
    )
    
    # Inconsistent naming duplicates (6 files)
    InconsistentNaming = @(
        "SFI-W1-EnforceManagedIdentityUsage.bicep",
        "SFI-W1-RequireCreatedByTag.bicep",
        "SFI-W1-RequireDiagnosticLogging.bicep",
        "SFI-W1-RequireEncryptionAtRest.bicep",
        "SFI-W1-RequireKeyVaultPrivateEndpoint.bicep",
        "SFI-W1-RestrictPublicNetworkAccess.bicep"
    )
    
    # Legacy initiative files (4 files)
    LegacyInitiatives = @(
        "policy-initiative-sfi-compliance.bicep",
        "SFI-W1-Initiative-AAIFoundry.bicep",
        "SFI-W1-Initiative-AIFoundry.bicep",
        "SFI-W1-Initiative.bicep"
    )
    
    # Migrated documentation (6 files)
    MigratedDocs = @(
        "README-AdvancedMonitoring.md",
        "README-ContentSafety.md",
        "README-LogicAppsAIWorkflows.md",
        "README-VideoIndexer.md",
        "README.md",
        "DEPLOYMENT_INSTRUCTIONS.md"
    )
    
    # Migrated deployment scripts (2 files)
    MigratedScripts = @(
        "deploy-all-policies.sh",
        "Deploy-AllPolicies.ps1"
    )
}

# Files to keep (important!)
$FilesToKeep = @(
    "SFI-W1-Ini-Foundry.bicep",
    "SFI-W1-Ini-Foundry.json",
    "SFI-W1-Def-Foundry-RequireCreatedByTag.json"  # If exists
)

# Functions
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    $color = switch ($Level) {
        "ERROR" { $Colors.Error }
        "WARNING" { $Colors.Warning }
        "SUCCESS" { $Colors.Success }
        "INFO" { $Colors.Info }
        "PROGRESS" { $Colors.Progress }
        default { 'White' }
    }
    
    Write-Host $logMessage -ForegroundColor $color
    $logMessage | Out-File -FilePath $LogFile -Append
}

function Write-Header {
    param([string]$Title)
    $separator = "=" * 70
    Write-Host $separator -ForegroundColor $Colors.Header
    Write-Host " $Title" -ForegroundColor $Colors.Header
    Write-Host $separator -ForegroundColor $Colors.Header
}

function Show-Usage {
    Write-Host @"
Azure Policy Foundry Directory Cleanup Script

PURPOSE:
    Safely remove obsolete files from bicep\policy\foundry after migration
    to the new organized AzPolicy structure.

USAGE:
    .\Cleanup-FoundryDirectory.ps1 [OPTIONS]

PARAMETERS:
    -WhatIf         Show what would be deleted without making changes
    -Force          Skip confirmation prompts (use with caution)
    -BackupFirst    Create backup before deletion
    -BackupPath     Custom backup location (default: .\backup-timestamp)
    -Help           Show this help message

EXAMPLES:
    # See what would be deleted (safe)
    .\Cleanup-FoundryDirectory.ps1 -WhatIf
    
    # Create backup and clean up with confirmation
    .\Cleanup-FoundryDirectory.ps1 -BackupFirst
    
    # Clean up without confirmation (dangerous!)
    .\Cleanup-FoundryDirectory.ps1 -Force

SAFETY FEATURES:
    - WhatIf mode to preview changes
    - Automatic backup option
    - Confirmation prompts
    - Detailed logging
    - Preserves essential files

FILES TO DELETE: 44 total
    - 20 migrated policy definitions
    - 6 legacy policy format files
    - 6 inconsistent naming duplicates
    - 4 legacy initiative files
    - 6 migrated documentation files
    - 2 migrated deployment scripts

FILES PRESERVED:
    - SFI-W1-Ini-Foundry.bicep (current initiative)
    - SFI-W1-Ini-Foundry.json (compiled initiative)
    - Any compiled JSON files

"@ -ForegroundColor White
}

function Test-NewStructureExists {
    Write-Log "Verifying new AzPolicy structure exists..."
    
    $newPolicyPath = Join-Path (Split-Path (Split-Path (Split-Path $ScriptDir -Parent) -Parent) -Parent) "AzPolicy"
    
    if (-not (Test-Path $newPolicyPath)) {
        Write-Log "ERROR: New AzPolicy structure not found at: $newPolicyPath" "ERROR"
        Write-Log "Please ensure migration was completed before running cleanup." "ERROR"
        return $false
    }
    
    # Check key directories exist
    $requiredDirs = @("definitions", "initiatives", "docs", "scripts")
    foreach ($dir in $requiredDirs) {
        $dirPath = Join-Path $newPolicyPath $dir
        if (-not (Test-Path $dirPath)) {
            Write-Log "ERROR: Required directory missing: $dirPath" "ERROR"
            return $false
        }
    }
    
    # Check if policies were migrated
    $definitionsPath = Join-Path $newPolicyPath "definitions"
    $migratedFiles = Get-ChildItem -Path $definitionsPath -Recurse -File | Measure-Object
    
    if ($migratedFiles.Count -lt 20) {
        Write-Log "WARNING: Expected at least 20 migrated files, found $($migratedFiles.Count)" "WARNING"
        Write-Log "Ensure migration was completed successfully before cleanup." "WARNING"
        return $false
    }
    
    Write-Log "New AzPolicy structure verified successfully" "SUCCESS"
    Write-Log "Found $($migratedFiles.Count) migrated policy files" "INFO"
    return $true
}

function Show-CleanupSummary {
    Write-Header "CLEANUP SUMMARY"
    
    $totalFiles = 0
    foreach ($category in $FilesToClean.Keys) {
        $count = $FilesToClean[$category].Count
        $totalFiles += $count
        Write-Log "📁 $category`: $count files" "INFO"
    }
    
    Write-Log "📊 Total files to delete: $totalFiles" "PROGRESS"
    Write-Log "🛡️  Files to preserve: $($FilesToKeep.Count)" "INFO"
    
    if ($BackupFirst) {
        Write-Log "💾 Backup location: $BackupPath" "INFO"
    }
    
    if ($WhatIf) {
        Write-Log "🔍 WhatIf mode: No files will be deleted" "WARNING"
    }
    
    Write-Host ""
}

function Invoke-BackupFiles {
    if (-not $BackupFirst) { return }
    
    Write-Log "Creating backup of all files..." "PROGRESS"
    
    try {
        if (-not (Test-Path $BackupPath)) {
            New-Item -Path $BackupPath -ItemType Directory | Out-Null
        }
        
        $allFiles = Get-ChildItem -Path $ScriptDir -File
        $backupCount = 0
        
        foreach ($file in $allFiles) {
            $destinationPath = Join-Path $BackupPath $file.Name
            if ($WhatIf) {
                Write-Log "WhatIf: Would backup $($file.Name)" "INFO"
            } else {
                Copy-Item -Path $file.FullName -Destination $destinationPath
                $backupCount++
            }
        }
        
        if (-not $WhatIf) {
            Write-Log "Backup completed: $backupCount files backed up to $BackupPath" "SUCCESS"
        }
    }
    catch {
        Write-Log "ERROR: Backup failed: $($_.Exception.Message)" "ERROR"
        if (-not $Force) {
            throw "Backup failed. Use -Force to continue without backup."
        }
    }
}

function Test-FilesExist {
    Write-Log "Checking which files exist for deletion..." "PROGRESS"
    
    $existingFiles = @{}
    $totalExisting = 0
    
    foreach ($category in $FilesToClean.Keys) {
        $existingFiles[$category] = @()
        
        foreach ($fileName in $FilesToClean[$category]) {
            $filePath = Join-Path $ScriptDir $fileName
            if (Test-Path $filePath) {
                $existingFiles[$category] += $fileName
                $totalExisting++
            }
        }
        
        if ($existingFiles[$category].Count -gt 0) {
            Write-Log "📁 $category`: $($existingFiles[$category].Count) files exist" "INFO"
        }
    }
    
    Write-Log "📊 Total existing files to delete: $totalExisting" "PROGRESS"
    return $existingFiles
}

function Confirm-Deletion {
    if ($Force -or $WhatIf) { return $true }
    
    Write-Host ""
    Write-Log "⚠️  This will permanently delete the identified obsolete files." "WARNING"
    Write-Log "📋 Essential files will be preserved automatically." "INFO"
    
    if ($BackupFirst) {
        Write-Log "💾 Backup will be created first for safety." "INFO"
    }
    
    Write-Host ""
    $response = Read-Host "❓ Do you want to proceed with the cleanup? (y/N)"
    
    if ($response -notmatch "^[Yy]$") {
        Write-Log "Cleanup cancelled by user." "WARNING"
        return $false
    }
    
    return $true
}

function Invoke-FileCleanup {
    param([hashtable]$ExistingFiles)
    
    Write-Log "Starting file cleanup..." "PROGRESS"
    
    $deletedCount = 0
    $failedCount = 0
    $skippedCount = 0
    
    foreach ($category in $ExistingFiles.Keys) {
        if ($ExistingFiles[$category].Count -eq 0) { continue }
        
        Write-Log "🗂️  Processing category: $category" "PROGRESS"
        
        foreach ($fileName in $ExistingFiles[$category]) {
            $filePath = Join-Path $ScriptDir $fileName
            
            # Safety check: Don't delete preserved files
            if ($FilesToKeep -contains $fileName) {
                Write-Log "🛡️  SKIPPED (preserved): $fileName" "WARNING"
                $skippedCount++
                continue
            }
            
            try {
                if ($WhatIf) {
                    Write-Log "🔍 WhatIf: Would delete $fileName" "INFO"
                    $deletedCount++
                } else {
                    Remove-Item -Path $filePath -Force
                    Write-Log "✅ Deleted: $fileName" "SUCCESS"
                    $deletedCount++
                }
            }
            catch {
                Write-Log "❌ Failed to delete $fileName`: $($_.Exception.Message)" "ERROR"
                $failedCount++
            }
        }
    }
    
    # Summary
    Write-Header "CLEANUP RESULTS"
    if ($WhatIf) {
        Write-Log "🔍 WhatIf Results:" "INFO"
        Write-Log "   Would delete: $deletedCount files" "INFO"
        Write-Log "   Would skip: $skippedCount files" "INFO"
    } else {
        Write-Log "✅ Successfully deleted: $deletedCount files" "SUCCESS"
        Write-Log "🛡️  Preserved: $skippedCount files" "INFO"
        if ($failedCount -gt 0) {
            Write-Log "❌ Failed to delete: $failedCount files" "ERROR"
        }
    }
}

function Show-PostCleanupInfo {
    if ($WhatIf) { return }
    
    Write-Header "POST-CLEANUP INFORMATION"
    
    Write-Log "📁 Remaining files in foundry directory:" "INFO"
    $remainingFiles = Get-ChildItem -Path $ScriptDir -File | Select-Object Name
    foreach ($file in $remainingFiles) {
        Write-Host "   - $($file.Name)" -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Log "🚀 Next Steps:" "INFO"
    Write-Log "1. Verify new AzPolicy structure is working correctly" "INFO"
    Write-Log "2. Test deployment from new organized structure" "INFO"
    Write-Log "3. Update any documentation referencing old paths" "INFO"
    Write-Log "4. Consider removing entire foundry directory once validated" "INFO"
    
    if ($BackupFirst) {
        Write-Log "💾 Backup available at: $BackupPath" "INFO"
    }
    
    Write-Log "📝 Cleanup log: $LogFile" "INFO"
}

# Main execution
function Main {
    # Show help if requested
    if ($Help) {
        Show-Usage
        exit 0
    }
    
    # Main execution flow
    try {
        Write-Header "AZURE POLICY FOUNDRY DIRECTORY CLEANUP"
        Write-Log "🧹 Starting automated cleanup process..." "PROGRESS"
        Write-Log "📂 Working directory: $ScriptDir" "INFO"
        
        # Validation
        if (-not (Test-NewStructureExists)) {
            Write-Log "❌ Pre-requisite validation failed. Cleanup aborted." "ERROR"
            exit 1
        }
        
        # Show summary
        Show-CleanupSummary
        
        # Get confirmation
        if (-not (Confirm-Deletion)) {
            Write-Log "Cleanup operation cancelled." "WARNING"
            exit 0
        }
        
        # Create backup if requested
        Invoke-BackupFiles
        
        # Check existing files
        $existingFiles = Test-FilesExist
        
        # Perform cleanup
        Invoke-FileCleanup -ExistingFiles $existingFiles
        
        # Show results
        Show-PostCleanupInfo
        
        if (-not $WhatIf) {
            Write-Header "🎉 CLEANUP COMPLETED SUCCESSFULLY"
        } else {
            Write-Header "🔍 WHATIF ANALYSIS COMPLETED"
        }
        
    }
    catch {
        Write-Log "❌ Cleanup process failed: $($_.Exception.Message)" "ERROR"
        Write-Log "📝 Check log file for details: $LogFile" "ERROR"
        exit 1
    }
}

# Execute main function
Main
