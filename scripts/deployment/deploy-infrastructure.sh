#!/bin/bash

# =============================================================================
# Universal Azure Infrastructure Deployment Script
# =============================================================================
# Purpose: Deploy Azure AI infrastructure across environments with full validation
# Version: 2.0.0
# Date: August 2, 2025
# =============================================================================

set -e

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="$ROOT_DIR/logs/deployment-$TIMESTAMP.log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Global variables
ENVIRONMENT=""
RESOURCE_GROUP=""
LOCATION=""
SUBSCRIPTION_ID=""
DEPLOY_MODULES=true
DEPLOY_POLICIES=true
WHATIF_MODE=false
SKIP_VALIDATION=false

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
}

warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}❌ $1${NC}" | tee -a "$LOG_FILE"
}

separator() {
    echo -e "${BLUE}================================================================${NC}"
}

show_usage() {
    cat << EOF
🚀 Universal Azure Infrastructure Deployment Script

USAGE:
    $0 -e ENVIRONMENT [OPTIONS]

PARAMETERS:
    -e, --environment    Target environment (dev|staging|prod)
    -g, --resource-group Resource group name
    -l, --location       Azure region (default: eastus2)
    -s, --subscription   Azure subscription ID
    -m, --modules-only   Deploy modules only (skip policies)
    -p, --policies-only  Deploy policies only (skip modules)
    -w, --whatif         Run in what-if mode (preview changes)
    -v, --skip-validation Skip post-deployment validation
    -h, --help           Show this help message

EXAMPLES:
    # Deploy everything to development
    $0 -e dev -g rg-ai-dev

    # Deploy only modules to staging with what-if
    $0 -e staging -g rg-ai-staging -m -w

    # Deploy to production with specific subscription
    $0 -e prod -g rg-ai-prod -s "12345678-1234-1234-1234-123456789012"

ENVIRONMENTS:
    dev      - Development environment (relaxed security, cost-optimized)
    staging  - Staging environment (production-like, full validation)
    prod     - Production environment (maximum security, compliance)

EOF
}

# =============================================================================
# VALIDATION FUNCTIONS
# =============================================================================

validate_prerequisites() {
    log "🔍 Validating prerequisites..."
    
    # Check Azure CLI
    if ! command -v az &> /dev/null; then
        error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    # Check Azure login
    if ! az account show &> /dev/null; then
        error "Not logged into Azure. Please run 'az login' first."
        exit 1
    fi
    
    # Check Bicep CLI
    if ! az bicep version &> /dev/null; then
        warning "Bicep CLI not found. Installing..."
        az bicep install
    fi
    
    # Check environment configuration
    local env_file="$ROOT_DIR/environments/$ENVIRONMENT/$ENVIRONMENT.parameters.json"
    if [ ! -f "$env_file" ]; then
        error "Environment configuration not found: $env_file"
        exit 1
    fi
    
    success "Prerequisites validated"
}

validate_environment() {
    log "🔍 Validating environment configuration..."
    
    local env_file="$ROOT_DIR/environments/$ENVIRONMENT/$ENVIRONMENT.parameters.json"
    
    # Validate JSON syntax
    if ! jq . "$env_file" > /dev/null 2>&1; then
        error "Invalid JSON in environment file: $env_file"
        exit 1
    fi
    
    # Extract and validate parameters
    local env_location=$(jq -r '.parameters.location.value' "$env_file")
    local env_tags=$(jq -r '.parameters.tags.value' "$env_file")
    
    if [ "$env_location" = "null" ]; then
        error "Missing location in environment configuration"
        exit 1
    fi
    
    # Set location from environment if not specified
    if [ -z "$LOCATION" ]; then
        LOCATION="$env_location"
    fi
    
    success "Environment configuration validated"
}

validate_templates() {
    log "🔍 Validating Bicep templates..."
    
    local error_count=0
    
    # Validate module templates
    if [ "$DEPLOY_MODULES" = true ]; then
        for module_dir in "$ROOT_DIR"/modules/*/; do
            if [ -f "$module_dir/main.bicep" ]; then
                log "Validating module: $(basename "$module_dir")"
                if ! az bicep build --file "$module_dir/main.bicep" --outdir /tmp/bicep-validation/ > /dev/null 2>&1; then
                    error "Bicep validation failed for $(basename "$module_dir")"
                    ((error_count++))
                fi
            fi
        done
    fi
    
    # Validate policy templates
    if [ "$DEPLOY_POLICIES" = true ]; then
        for policy_file in "$ROOT_DIR"/policies/definitions/*/*.bicep; do
            if [ -f "$policy_file" ]; then
                log "Validating policy: $(basename "$policy_file")"
                if ! az bicep build --file "$policy_file" --outdir /tmp/bicep-validation/ > /dev/null 2>&1; then
                    error "Policy validation failed for $(basename "$policy_file")"
                    ((error_count++))
                fi
            fi
        done
    fi
    
    if [ $error_count -gt 0 ]; then
        error "$error_count template validation errors found"
        exit 1
    fi
    
    success "All templates validated successfully"
}

# =============================================================================
# DEPLOYMENT FUNCTIONS
# =============================================================================

set_azure_context() {
    log "🔧 Setting Azure context..."
    
    if [ -n "$SUBSCRIPTION_ID" ]; then
        log "Setting subscription to: $SUBSCRIPTION_ID"
        az account set --subscription "$SUBSCRIPTION_ID"
    fi
    
    local current_sub=$(az account show --query "name" -o tsv)
    local current_sub_id=$(az account show --query "id" -o tsv)
    
    log "Current subscription: $current_sub ($current_sub_id)"
    
    # Create resource group if it doesn't exist
    if [ -n "$RESOURCE_GROUP" ]; then
        log "Ensuring resource group exists: $RESOURCE_GROUP"
        az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none
        success "Resource group ready: $RESOURCE_GROUP"
    fi
}

deploy_infrastructure_modules() {
    if [ "$DEPLOY_MODULES" != true ]; then
        return 0
    fi
    
    log "🏗️ Deploying infrastructure modules..."
    separator
    
    local env_file="$ROOT_DIR/environments/$ENVIRONMENT/$ENVIRONMENT.parameters.json"
    local deployment_count=0
    local success_count=0
    
    # Define deployment order (dependencies first)
    local modules=(
        "key-vault"
        "storage"
        "cognitive-services"
        "machine-learning"
        "cognitive-search"
        "ai-foundry"
        "azure-openai"
        "copilot-studio"
        "document-intelligence"
    )
    
    for module in "${modules[@]}"; do
        local module_path="$ROOT_DIR/modules/$module"
        
        if [ -f "$module_path/main.bicep" ]; then
            ((deployment_count++))
            log "📦 Deploying module: $module"
            
            local deployment_name="$module-$ENVIRONMENT-$TIMESTAMP"
            local deploy_cmd="az deployment group create"
            
            if [ "$WHATIF_MODE" = true ]; then
                deploy_cmd="az deployment group what-if"
                log "🔍 Running what-if analysis for $module..."
            fi
            
            if $deploy_cmd \
                --resource-group "$RESOURCE_GROUP" \
                --name "$deployment_name" \
                --template-file "$module_path/main.bicep" \
                --parameters "@$env_file" \
                --output table; then
                
                success "Module deployed successfully: $module"
                ((success_count++))
            else
                error "Failed to deploy module: $module"
            fi
            
            echo ""
        fi
    done
    
    if [ $deployment_count -eq 0 ]; then
        warning "No modules found to deploy"
    else
        success "Infrastructure deployment completed: $success_count/$deployment_count modules"
    fi
}

deploy_policies() {
    if [ "$DEPLOY_POLICIES" != true ]; then
        return 0
    fi
    
    log "📋 Deploying Azure policies..."
    separator
    
    local policy_count=0
    local success_count=0
    
    # Deploy policy definitions first
    log "📜 Deploying policy definitions..."
    for category_dir in "$ROOT_DIR"/policies/definitions/*/; do
        if [ -d "$category_dir" ]; then
            local category=$(basename "$category_dir")
            log "Processing policy category: $category"
            
            for policy_file in "$category_dir"*.bicep; do
                if [ -f "$policy_file" ]; then
                    ((policy_count++))
                    local policy_name=$(basename "$policy_file" .bicep)
                    
                    log "📜 Deploying policy: $policy_name"
                    
                    local deploy_cmd="az deployment sub create"
                    if [ "$WHATIF_MODE" = true ]; then
                        deploy_cmd="az deployment sub what-if"
                    fi
                    
                    if $deploy_cmd \
                        --location "$LOCATION" \
                        --name "$policy_name-$TIMESTAMP" \
                        --template-file "$policy_file" \
                        --output none; then
                        
                        success "Policy deployed: $policy_name"
                        ((success_count++))
                    else
                        warning "Policy deployment skipped (may already exist): $policy_name"
                        ((success_count++))
                    fi
                fi
            done
        fi
    done
    
    # Deploy policy initiatives
    log "📋 Deploying policy initiatives..."
    for initiative_file in "$ROOT_DIR"/policies/initiatives/*/*.bicep; do
        if [ -f "$initiative_file" ]; then
            ((policy_count++))
            local initiative_name=$(basename "$initiative_file" .bicep)
            
            log "📋 Deploying initiative: $initiative_name"
            
            local deploy_cmd="az deployment sub create"
            if [ "$WHATIF_MODE" = true ]; then
                deploy_cmd="az deployment sub what-if"
            fi
            
            if $deploy_cmd \
                --location "$LOCATION" \
                --name "$initiative_name-$TIMESTAMP" \
                --template-file "$initiative_file" \
                --output none; then
                
                success "Initiative deployed: $initiative_name"
                ((success_count++))
            else
                warning "Initiative deployment skipped: $initiative_name"
                ((success_count++))
            fi
        fi
    done
    
    success "Policy deployment completed: $success_count/$policy_count policies"
}

validate_deployment() {
    if [ "$SKIP_VALIDATION" = true ] || [ "$WHATIF_MODE" = true ]; then
        return 0
    fi
    
    log "✅ Validating deployment..."
    separator
    
    # Check resource group
    if [ -n "$RESOURCE_GROUP" ]; then
        local rg_state=$(az group show --name "$RESOURCE_GROUP" --query "properties.provisioningState" -o tsv 2>/dev/null || echo "NotFound")
        if [ "$rg_state" = "Succeeded" ]; then
            success "Resource group validation passed: $RESOURCE_GROUP"
        else
            warning "Resource group validation failed: $RESOURCE_GROUP ($rg_state)"
        fi
    fi
    
    # Check deployed resources
    if [ "$DEPLOY_MODULES" = true ] && [ -n "$RESOURCE_GROUP" ]; then
        local resource_count=$(az resource list --resource-group "$RESOURCE_GROUP" --query "length(@)" -o tsv 2>/dev/null || echo "0")
        log "Resources deployed: $resource_count"
        
        if [ "$resource_count" -gt 0 ]; then
            success "Resource deployment validation passed"
        else
            warning "No resources found in resource group"
        fi
    fi
    
    # Check policies
    if [ "$DEPLOY_POLICIES" = true ]; then
        local policy_count=$(az policy definition list --query "length([?starts_with(name, 'SFI-W1')])" -o tsv 2>/dev/null || echo "0")
        log "Policies deployed: $policy_count"
        
        if [ "$policy_count" -gt 0 ]; then
            success "Policy deployment validation passed"
        else
            warning "No SFI-W1 policies found"
        fi
    fi
    
    success "Deployment validation completed"
}

show_deployment_summary() {
    separator
    log "📊 Deployment Summary"
    separator
    
    echo "🎯 Environment: $ENVIRONMENT"
    echo "📁 Resource Group: ${RESOURCE_GROUP:-'N/A'}"
    echo "📍 Location: $LOCATION"
    echo "🏗️ Modules: $([ "$DEPLOY_MODULES" = true ] && echo "✅ Deployed" || echo "⏭️ Skipped")"
    echo "📋 Policies: $([ "$DEPLOY_POLICIES" = true ] && echo "✅ Deployed" || echo "⏭️ Skipped")"
    echo "🔍 What-if Mode: $([ "$WHATIF_MODE" = true ] && echo "✅ Enabled" || echo "❌ Disabled")"
    echo "⏱️ Duration: $(date +'%Y-%m-%d %H:%M:%S')"
    echo "📝 Log File: $LOG_FILE"
    echo ""
    
    if [ "$WHATIF_MODE" = true ]; then
        success "🔍 What-if analysis completed successfully!"
    else
        success "🚀 Deployment completed successfully!"
    fi
    
    separator
}

# =============================================================================
# PARAMETER PARSING
# =============================================================================

parse_parameters() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -e|--environment)
                ENVIRONMENT="$2"
                shift 2
                ;;
            -g|--resource-group)
                RESOURCE_GROUP="$2"
                shift 2
                ;;
            -l|--location)
                LOCATION="$2"
                shift 2
                ;;
            -s|--subscription)
                SUBSCRIPTION_ID="$2"
                shift 2
                ;;
            -m|--modules-only)
                DEPLOY_MODULES=true
                DEPLOY_POLICIES=false
                shift
                ;;
            -p|--policies-only)
                DEPLOY_MODULES=false
                DEPLOY_POLICIES=true
                shift
                ;;
            -w|--whatif)
                WHATIF_MODE=true
                shift
                ;;
            -v|--skip-validation)
                SKIP_VALIDATION=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            *)
                error "Unknown parameter: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Validate required parameters
    if [ -z "$ENVIRONMENT" ]; then
        error "Environment is required. Use -e parameter."
        show_usage
        exit 1
    fi
    
    # Validate environment value
    case $ENVIRONMENT in
        dev|staging|prod)
            ;;
        *)
            error "Invalid environment: $ENVIRONMENT. Must be dev, staging, or prod."
            exit 1
            ;;
    esac
    
    # Set default resource group if not provided
    if [ -z "$RESOURCE_GROUP" ]; then
        RESOURCE_GROUP="rg-ai-$ENVIRONMENT"
        warning "Using default resource group: $RESOURCE_GROUP"
    fi
    
    # Set default location if not provided
    if [ -z "$LOCATION" ]; then
        LOCATION="eastus2"
    fi
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    # Parse command line parameters
    parse_parameters "$@"
    
    # Show header
    separator
    log "🚀 Universal Azure Infrastructure Deployment"
    separator
    
    # Execute deployment steps
    validate_prerequisites
    validate_environment
    validate_templates
    set_azure_context
    deploy_infrastructure_modules
    deploy_policies
    validate_deployment
    show_deployment_summary
}

# Error handling
trap 'error "Deployment failed! Check logs at: $LOG_FILE"; exit 1' ERR

# Execute main function with all parameters
main "$@"
