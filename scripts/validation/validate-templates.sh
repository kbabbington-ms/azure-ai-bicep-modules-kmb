#!/bin/bash

# =============================================================================
# Advanced Template Validation Script
# =============================================================================
# Purpose: Comprehensive validation of Bicep templates, policies, and configurations
# Version: 2.0.0
# Date: August 2, 2025
# =============================================================================

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$ROOT_DIR/logs/validation-$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Validation counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
WARNING_TESTS=0

# Create logs directory
mkdir -p "$ROOT_DIR/logs"

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

success() {
    echo -e "${GREEN}✅ $1${NC}" | tee -a "$LOG_FILE"
    ((PASSED_TESTS++))
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
    ((WARNING_TESTS++))
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
    ((FAILED_TESTS++))
}

test_start() {
    ((TOTAL_TESTS++))
    log "🧪 Test: $1"
}

separator() {
    echo -e "${BLUE}================================================================${NC}"
}

# =============================================================================
# BICEP TEMPLATE VALIDATION
# =============================================================================

validate_bicep_syntax() {
    log "🔍 Validating Bicep template syntax..."
    separator
    
    local error_count=0
    
    # Validate module templates
    for module_dir in "$ROOT_DIR"/modules/*/; do
        if [ -f "$module_dir/main.bicep" ]; then
            test_start "Bicep syntax for $(basename "$module_dir")"
            
            if az bicep build --file "$module_dir/main.bicep" --outdir /tmp/bicep-validation/ > /dev/null 2>&1; then
                success "Bicep syntax valid: $(basename "$module_dir")"
            else
                error "Bicep syntax error: $(basename "$module_dir")"
                ((error_count++))
            fi
        fi
    done
    
    # Validate shared templates
    for template_file in "$ROOT_DIR"/shared/templates/*/*.bicep; do
        if [ -f "$template_file" ]; then
            test_start "Bicep syntax for $(basename "$template_file")"
            
            if az bicep build --file "$template_file" --outdir /tmp/bicep-validation/ > /dev/null 2>&1; then
                success "Bicep syntax valid: $(basename "$template_file")"
            else
                error "Bicep syntax error: $(basename "$template_file")"
                ((error_count++))
            fi
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        success "All Bicep templates have valid syntax"
    else
        error "$error_count Bicep syntax errors found"
    fi
}

validate_parameter_files() {
    log "🔍 Validating parameter files..."
    separator
    
    local error_count=0
    
    # Validate module parameter files
    for module_dir in "$ROOT_DIR"/modules/*/; do
        local param_file="$module_dir/main.parameters.json"
        if [ -f "$param_file" ]; then
            test_start "Parameter file for $(basename "$module_dir")"
            
            if jq . "$param_file" > /dev/null 2>&1; then
                success "Valid JSON: $(basename "$module_dir") parameters"
            else
                error "Invalid JSON: $(basename "$module_dir") parameters"
                ((error_count++))
            fi
        fi
    done
    
    # Validate environment parameter files
    for env_dir in "$ROOT_DIR"/environments/*/; do
        if [ -d "$env_dir" ]; then
            local env_name=$(basename "$env_dir")
            local env_file="$env_dir/$env_name.parameters.json"
            
            if [ -f "$env_file" ]; then
                test_start "Environment parameters for $env_name"
                
                if jq . "$env_file" > /dev/null 2>&1; then
                    success "Valid JSON: $env_name environment parameters"
                    
                    # Validate required parameters
                    local required_params=("environment" "resourcePrefix" "location" "tags")
                    for param in "${required_params[@]}"; do
                        if jq -e ".parameters.$param" "$env_file" > /dev/null 2>&1; then
                            success "Required parameter present: $param in $env_name"
                        else
                            warning "Missing recommended parameter: $param in $env_name"
                        fi
                    done
                else
                    error "Invalid JSON: $env_name environment parameters"
                    ((error_count++))
                fi
            fi
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        success "All parameter files are valid"
    else
        error "$error_count parameter file errors found"
    fi
}

# =============================================================================
# SECURITY VALIDATION
# =============================================================================

validate_security_patterns() {
    log "🛡️ Validating security patterns..."
    separator
    
    # Check for private endpoints
    test_start "Private endpoint configurations"
    local pe_count=$(grep -r "privateEndpoint\|PrivateEndpoint" "$ROOT_DIR/modules/" | wc -l)
    if [ $pe_count -gt 0 ]; then
        success "Private endpoint configurations found: $pe_count references"
    else
        warning "Consider adding private endpoint configurations"
    fi
    
    # Check for managed identity usage
    test_start "Managed identity configurations"
    local mi_count=$(grep -r "managedIdentity\|ManagedIdentity\|SystemAssigned\|UserAssigned" "$ROOT_DIR/modules/" | wc -l)
    if [ $mi_count -gt 0 ]; then
        success "Managed identity configurations found: $mi_count references"
    else
        warning "Consider using managed identities for authentication"
    fi
    
    # Check for diagnostic settings
    test_start "Diagnostic settings configurations"
    local ds_count=$(grep -r "diagnosticSettings\|Microsoft.Insights/diagnosticSettings" "$ROOT_DIR/modules/" | wc -l)
    if [ $ds_count -gt 0 ]; then
        success "Diagnostic settings found: $ds_count references"
    else
        warning "Consider adding diagnostic settings for monitoring"
    fi
    
    # Check for encryption configurations
    test_start "Encryption configurations"
    local enc_count=$(grep -r "encryption\|customerManagedKey\|encryptionAtRest" "$ROOT_DIR/modules/" | wc -l)
    if [ $enc_count -gt 0 ]; then
        success "Encryption configurations found: $enc_count references"
    else
        warning "Consider adding customer-managed encryption"
    fi
    
    # Check for network restrictions
    test_start "Network access restrictions"
    local net_count=$(grep -r "networkAcls\|publicNetworkAccess.*Disabled\|allowedIpRanges" "$ROOT_DIR/modules/" | wc -l)
    if [ $net_count -gt 0 ]; then
        success "Network restrictions found: $net_count references"
    else
        warning "Consider adding network access restrictions"
    fi
}

validate_compliance_patterns() {
    log "📋 Validating compliance patterns..."
    separator
    
    # Check for required tags
    test_start "Required tagging patterns"
    local tag_count=$(grep -r "Environment\|Purpose\|Owner\|CostCenter" "$ROOT_DIR/modules/" | wc -l)
    if [ $tag_count -gt 0 ]; then
        success "Tagging patterns found: $tag_count references"
    else
        warning "Consider adding standardized tags for governance"
    fi
    
    # Check for audit logging
    test_start "Audit logging configurations"
    local audit_count=$(grep -r "auditLogs\|Category.*Audit\|logAnalyticsWorkspace" "$ROOT_DIR/modules/" | wc -l)
    if [ $audit_count -gt 0 ]; then
        success "Audit logging configurations found: $audit_count references"
    else
        warning "Consider adding audit logging capabilities"
    fi
    
    # Check for backup configurations
    test_start "Backup and recovery configurations"
    local backup_count=$(grep -r "backup\|recovery\|retention\|immutable" "$ROOT_DIR/modules/" | wc -l)
    if [ $backup_count -gt 0 ]; then
        success "Backup configurations found: $backup_count references"
    else
        warning "Consider adding backup and recovery configurations"
    fi
}

# =============================================================================
# POLICY VALIDATION
# =============================================================================

validate_policy_templates() {
    log "📋 Validating policy templates..."
    separator
    
    local error_count=0
    
    # Validate policy definitions
    for policy_file in "$ROOT_DIR"/policies/definitions/*/*.bicep; do
        if [ -f "$policy_file" ]; then
            test_start "Policy definition: $(basename "$policy_file")"
            
            if az bicep build --file "$policy_file" --outdir /tmp/policy-validation/ > /dev/null 2>&1; then
                success "Policy template valid: $(basename "$policy_file")"
                
                # Check for required policy components
                if grep -q "policyRule" "$policy_file"; then
                    success "Policy rule found: $(basename "$policy_file")"
                else
                    warning "Policy rule not found: $(basename "$policy_file")"
                fi
                
                if grep -q "parameters" "$policy_file"; then
                    success "Policy parameters found: $(basename "$policy_file")"
                else
                    warning "No parameters defined: $(basename "$policy_file")"
                fi
                
            else
                error "Policy template error: $(basename "$policy_file")"
                ((error_count++))
            fi
        fi
    done
    
    # Validate policy initiatives
    for initiative_file in "$ROOT_DIR"/policies/initiatives/*/*.bicep; do
        if [ -f "$initiative_file" ]; then
            test_start "Policy initiative: $(basename "$initiative_file")"
            
            if az bicep build --file "$initiative_file" --outdir /tmp/initiative-validation/ > /dev/null 2>&1; then
                success "Initiative template valid: $(basename "$initiative_file")"
            else
                error "Initiative template error: $(basename "$initiative_file")"
                ((error_count++))
            fi
        fi
    done
    
    if [ $error_count -eq 0 ]; then
        success "All policy templates are valid"
    else
        error "$error_count policy template errors found"
    fi
}

# =============================================================================
# DOCUMENTATION VALIDATION
# =============================================================================

validate_documentation() {
    log "📚 Validating documentation..."
    separator
    
    # Check for module README files
    for module_dir in "$ROOT_DIR"/modules/*/; do
        if [ -d "$module_dir" ]; then
            local module_name=$(basename "$module_dir")
            test_start "README for $module_name module"
            
            if [ -f "$module_dir/README.md" ]; then
                success "README found: $module_name"
                
                # Check for required sections
                local readme_file="$module_dir/README.md"
                if grep -q "## Features\|## Usage\|## Parameters" "$readme_file"; then
                    success "Required sections found: $module_name"
                else
                    warning "Consider adding Features, Usage, or Parameters sections: $module_name"
                fi
                
            else
                error "Missing README: $module_name"
            fi
        fi
    done
    
    # Check for root documentation
    test_start "Root documentation files"
    local root_docs=("README.md" "CONTRIBUTING.md" "SECURITY.md" "CHANGELOG.md")
    for doc in "${root_docs[@]}"; do
        if [ -f "$ROOT_DIR/$doc" ]; then
            success "Found: $doc"
        else
            warning "Consider adding: $doc"
        fi
    done
    
    # Check for environment documentation
    test_start "Environment documentation"
    for env_dir in "$ROOT_DIR"/environments/*/; do
        if [ -d "$env_dir" ]; then
            local env_name=$(basename "$env_dir")
            if [ -f "$env_dir/README.md" ]; then
                success "Environment documentation found: $env_name"
            else
                warning "Consider adding README for environment: $env_name"
            fi
        fi
    done
}

# =============================================================================
# STRUCTURE VALIDATION
# =============================================================================

validate_folder_structure() {
    log "📁 Validating folder structure..."
    separator
    
    # Check for required directories
    local required_dirs=(
        "modules"
        "policies"
        "environments"
        "shared"
        "scripts"
        "docs"
        ".github/workflows"
    )
    
    for dir in "${required_dirs[@]}"; do
        test_start "Required directory: $dir"
        if [ -d "$ROOT_DIR/$dir" ]; then
            success "Directory exists: $dir"
        else
            error "Missing required directory: $dir"
        fi
    done
    
    # Check for naming conventions
    test_start "Naming convention compliance"
    local naming_issues=0
    
    # Check module naming (should be kebab-case)
    for module_dir in "$ROOT_DIR"/modules/*/; do
        if [ -d "$module_dir" ]; then
            local module_name=$(basename "$module_dir")
            if [[ $module_name =~ ^[a-z][a-z0-9-]*[a-z0-9]$ ]]; then
                success "Naming convention valid: $module_name"
            else
                warning "Naming convention issue: $module_name (should be kebab-case)"
                ((naming_issues++))
            fi
        fi
    done
    
    if [ $naming_issues -eq 0 ]; then
        success "All names follow conventions"
    else
        warning "$naming_issues naming convention issues found"
    fi
}

# =============================================================================
# PERFORMANCE VALIDATION
# =============================================================================

validate_performance_patterns() {
    log "⚡ Validating performance patterns..."
    separator
    
    # Check for resource optimization patterns
    test_start "Resource optimization patterns"
    local opt_count=$(grep -r "sku\|tier\|capacity\|autoscale" "$ROOT_DIR/modules/" | wc -l)
    if [ $opt_count -gt 0 ]; then
        success "Resource optimization patterns found: $opt_count references"
    else
        warning "Consider adding resource optimization configurations"
    fi
    
    # Check for monitoring configurations
    test_start "Monitoring and alerting patterns"
    local mon_count=$(grep -r "alert\|metric\|monitor\|Application.*Insights" "$ROOT_DIR/modules/" | wc -l)
    if [ $mon_count -gt 0 ]; then
        success "Monitoring patterns found: $mon_count references"
    else
        warning "Consider adding monitoring and alerting capabilities"
    fi
    
    # Check for caching patterns
    test_start "Caching optimization patterns"
    local cache_count=$(grep -r "cache\|redis\|cdn" "$ROOT_DIR/modules/" | wc -l)
    if [ $cache_count -gt 0 ]; then
        success "Caching patterns found: $cache_count references"
    else
        warning "Consider adding caching for performance optimization"
    fi
}

# =============================================================================
# MAIN VALIDATION WORKFLOW
# =============================================================================

run_all_validations() {
    separator
    log "🚀 Starting Comprehensive Template Validation"
    separator
    
    # Core validations
    validate_bicep_syntax
    validate_parameter_files
    validate_policy_templates
    
    # Security validations
    validate_security_patterns
    validate_compliance_patterns
    
    # Structure validations
    validate_folder_structure
    validate_documentation
    
    # Performance validations
    validate_performance_patterns
}

show_validation_summary() {
    separator
    log "📊 Validation Summary"
    separator
    
    echo "🧪 Total Tests: $TOTAL_TESTS"
    echo "✅ Passed: $PASSED_TESTS"
    echo "❌ Failed: $FAILED_TESTS"
    echo "⚠️  Warnings: $WARNING_TESTS"
    echo ""
    
    local success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    echo "📈 Success Rate: $success_rate%"
    echo "📝 Log File: $LOG_FILE"
    echo "⏱️ Completed: $(date +'%Y-%m-%d %H:%M:%S')"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        if [ $WARNING_TESTS -eq 0 ]; then
            success "🏆 Perfect validation! All tests passed with no warnings."
            echo "🎯 Repository Quality Score: 10/10"
        else
            success "✅ Validation passed with $WARNING_TESTS recommendations."
            echo "🎯 Repository Quality Score: 9/10"
        fi
    else
        error "❌ Validation failed with $FAILED_TESTS errors."
        echo "🎯 Repository Quality Score: $((success_rate/10))/10"
    fi
    
    separator
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Show usage if help requested
    if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
        cat << EOF
🧪 Advanced Template Validation Script

PURPOSE:
    Comprehensive validation of Azure infrastructure templates, policies, and configurations.

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --help, -h    Show this help message

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

EOF
        exit 0
    fi
    
    # Create temporary directories for validation
    mkdir -p /tmp/bicep-validation
    mkdir -p /tmp/policy-validation
    mkdir -p /tmp/initiative-validation
    
    # Run all validations
    run_all_validations
    
    # Show summary
    show_validation_summary
    
    # Clean up
    rm -rf /tmp/bicep-validation
    rm -rf /tmp/policy-validation
    rm -rf /tmp/initiative-validation
    
    # Exit with appropriate code
    if [ $FAILED_TESTS -gt 0 ]; then
        exit 1
    else
        exit 0
    fi
}

# Execute main function
main "$@"
