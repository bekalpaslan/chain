#!/bin/bash

# The Chain - Admin Dashboard Production Deployment Script
# Usage: ./deploy-admin-dashboard.sh [staging|production]

set -euo pipefail

# Configuration
ENVIRONMENT=${1:-staging}
NAMESPACE="thechain-${ENVIRONMENT}"
APP_NAME="admin-dashboard"
DOCKER_REGISTRY="ghcr.io"
IMAGE_NAME="${DOCKER_REGISTRY}/thechain/${APP_NAME}"
CLUSTER_NAME="thechain-${ENVIRONMENT}"
AWS_REGION="us-east-1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    exit 1
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check for required tools
    command -v docker >/dev/null 2>&1 || log_error "Docker is required but not installed"
    command -v kubectl >/dev/null 2>&1 || log_error "kubectl is required but not installed"
    command -v aws >/dev/null 2>&1 || log_error "AWS CLI is required but not installed"
    command -v flutter >/dev/null 2>&1 || log_warning "Flutter is not installed, skipping local build"

    # Check AWS credentials
    aws sts get-caller-identity >/dev/null 2>&1 || log_error "AWS credentials not configured"

    log_success "All prerequisites met"
}

# Build Flutter app
build_flutter_app() {
    log_info "Building Flutter web application..."

    if [ ! -d "frontend/admin_dashboard" ]; then
        log_error "Admin dashboard directory not found"
    fi

    cd frontend/admin_dashboard

    # Get dependencies
    flutter pub get

    # Build for production
    flutter build web \
        --release \
        --web-renderer canvaskit \
        --dart-define=PRODUCTION=true \
        --dart-define=API_URL=https://api.thechain.com

    cd ../..

    log_success "Flutter build completed"
}

# Build Docker image
build_docker_image() {
    log_info "Building Docker image..."

    VERSION=$(date +'%Y%m%d')-$(git rev-parse --short HEAD)

    docker build \
        -t ${IMAGE_NAME}:${VERSION} \
        -t ${IMAGE_NAME}:latest \
        -f frontend/admin_dashboard/Dockerfile \
        frontend/admin_dashboard

    log_success "Docker image built: ${IMAGE_NAME}:${VERSION}"
}

# Push Docker image
push_docker_image() {
    log_info "Pushing Docker image to registry..."

    VERSION=$(date +'%Y%m%d')-$(git rev-parse --short HEAD)

    # Login to GitHub Container Registry
    echo $GITHUB_TOKEN | docker login ${DOCKER_REGISTRY} -u $GITHUB_USER --password-stdin

    docker push ${IMAGE_NAME}:${VERSION}
    docker push ${IMAGE_NAME}:latest

    log_success "Docker image pushed to registry"
}

# Configure kubectl
configure_kubectl() {
    log_info "Configuring kubectl for ${ENVIRONMENT}..."

    aws eks update-kubeconfig \
        --name ${CLUSTER_NAME} \
        --region ${AWS_REGION}

    # Verify connection
    kubectl get nodes >/dev/null 2>&1 || log_error "Cannot connect to Kubernetes cluster"

    log_success "kubectl configured for ${CLUSTER_NAME}"
}

# Create namespace if not exists
create_namespace() {
    log_info "Ensuring namespace exists..."

    kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

    log_success "Namespace ${NAMESPACE} ready"
}

# Deploy to Kubernetes
deploy_to_kubernetes() {
    log_info "Deploying to Kubernetes..."

    VERSION=$(date +'%Y%m%d')-$(git rev-parse --short HEAD)

    # Apply all manifests
    kubectl apply -f k8s/admin-dashboard/ -n ${NAMESPACE}

    # Update image
    kubectl set image deployment/${APP_NAME} \
        ${APP_NAME}=${IMAGE_NAME}:${VERSION} \
        -n ${NAMESPACE} \
        --record

    # Wait for rollout
    kubectl rollout status deployment/${APP_NAME} \
        -n ${NAMESPACE} \
        --timeout=300s

    log_success "Deployment completed successfully"
}

# Verify deployment
verify_deployment() {
    log_info "Verifying deployment..."

    # Check pod status
    READY_PODS=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -o "True" | wc -l)
    TOTAL_PODS=$(kubectl get pods -n ${NAMESPACE} -l app=${APP_NAME} --no-headers | wc -l)

    if [ "$READY_PODS" -ne "$TOTAL_PODS" ]; then
        log_warning "Not all pods are ready: ${READY_PODS}/${TOTAL_PODS}"
    else
        log_success "All pods are ready: ${READY_PODS}/${TOTAL_PODS}"
    fi

    # Get service endpoint
    if [ "$ENVIRONMENT" == "production" ]; then
        ENDPOINT="https://admin.thechain.com"
    else
        ENDPOINT="https://admin-staging.thechain.com"
    fi

    # Test endpoint
    log_info "Testing endpoint: ${ENDPOINT}"

    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" ${ENDPOINT}/health || echo "000")

    if [ "$HTTP_CODE" == "200" ]; then
        log_success "Health check passed"
    else
        log_warning "Health check returned HTTP ${HTTP_CODE}"
    fi

    # Show deployment info
    echo ""
    log_info "Deployment Summary:"
    echo "Environment: ${ENVIRONMENT}"
    echo "Namespace: ${NAMESPACE}"
    echo "Application: ${APP_NAME}"
    echo "Endpoint: ${ENDPOINT}"
    echo ""

    kubectl get deployment,service,ingress -n ${NAMESPACE} -l app=${APP_NAME}
}

# Rollback deployment
rollback_deployment() {
    log_warning "Rolling back deployment..."

    kubectl rollout undo deployment/${APP_NAME} -n ${NAMESPACE}
    kubectl rollout status deployment/${APP_NAME} -n ${NAMESPACE} --timeout=300s

    log_success "Rollback completed"
}

# Main execution
main() {
    log_info "Starting deployment of Admin Dashboard to ${ENVIRONMENT}"

    # Validate environment
    if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
        log_error "Invalid environment: ${ENVIRONMENT}. Use 'staging' or 'production'"
    fi

    # Production safeguard
    if [ "$ENVIRONMENT" == "production" ]; then
        log_warning "You are about to deploy to PRODUCTION!"
        read -p "Are you sure? (yes/no): " confirm
        if [ "$confirm" != "yes" ]; then
            log_info "Deployment cancelled"
            exit 0
        fi
    fi

    # Run deployment steps
    check_prerequisites

    # Build steps (optional, can be skipped if using CI/CD)
    if [ "${BUILD_LOCAL:-false}" == "true" ]; then
        build_flutter_app
        build_docker_image
        push_docker_image
    fi

    # Deploy steps
    configure_kubectl
    create_namespace
    deploy_to_kubernetes
    verify_deployment

    log_success "Deployment completed successfully!"
}

# Handle errors
trap 'log_error "Deployment failed at line $LINENO"' ERR

# Run main function
main "$@"