# Admin Dashboard - Production Deployment Guide

## Overview

This guide provides step-by-step instructions for deploying The Chain Admin Dashboard to production.

## Architecture

The admin dashboard is a Flutter Web application deployed as a containerized service on Kubernetes with:
- **Frontend**: Flutter 3.19.2 with Dark Mystique UI theme
- **Web Server**: Nginx Alpine with security headers
- **Container**: Multi-stage Docker build
- **Orchestration**: Kubernetes with HPA
- **CI/CD**: GitHub Actions with blue-green deployment
- **Monitoring**: Prometheus metrics and health checks

## Prerequisites

### Required Tools
- Docker 20.10+
- kubectl 1.28+
- AWS CLI 2.0+
- GitHub CLI (gh)
- Flutter 3.19.2 (for local builds)

### Access Requirements
- AWS account with EKS permissions
- GitHub repository write access
- Docker registry (GHCR) access
- Kubernetes cluster access

## Deployment Methods

### Method 1: Automated CI/CD (Recommended)

The easiest way to deploy is through GitHub Actions:

1. **Trigger Production Deployment**
   ```bash
   # From main branch
   gh workflow run admin-dashboard-deploy.yml \
     -f environment=production
   ```

2. **Monitor Deployment**
   ```bash
   # Watch workflow progress
   gh run watch

   # View logs
   gh run view --log
   ```

### Method 2: Manual Deployment Script

Use the deployment script for more control:

```bash
# Deploy to staging
./scripts/deploy-admin-dashboard.sh staging

# Deploy to production (requires confirmation)
./scripts/deploy-admin-dashboard.sh production

# Build locally and deploy
BUILD_LOCAL=true ./scripts/deploy-admin-dashboard.sh production
```

### Method 3: Step-by-Step Manual Deployment

For complete control over each step:

#### Step 1: Build Flutter App
```bash
cd frontend/admin_dashboard
flutter pub get
flutter build web --release --web-renderer canvaskit
```

#### Step 2: Build Docker Image
```bash
# Build image
docker build -t ghcr.io/thechain/admin-dashboard:latest \
  -f Dockerfile .

# Tag with version
VERSION=$(date +'%Y%m%d')-$(git rev-parse --short HEAD)
docker tag ghcr.io/thechain/admin-dashboard:latest \
  ghcr.io/thechain/admin-dashboard:${VERSION}
```

#### Step 3: Push to Registry
```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u $GITHUB_USER --password-stdin

# Push images
docker push ghcr.io/thechain/admin-dashboard:latest
docker push ghcr.io/thechain/admin-dashboard:${VERSION}
```

#### Step 4: Deploy to Kubernetes
```bash
# Configure kubectl
aws eks update-kubeconfig --name thechain-production --region us-east-1

# Apply manifests
kubectl apply -f k8s/admin-dashboard/ -n thechain-production

# Update image
kubectl set image deployment/admin-dashboard \
  admin-dashboard=ghcr.io/thechain/admin-dashboard:${VERSION} \
  -n thechain-production \
  --record

# Wait for rollout
kubectl rollout status deployment/admin-dashboard \
  -n thechain-production \
  --timeout=300s
```

## Configuration

### Environment Variables

Required environment variables for deployment:

```bash
# AWS Configuration
export AWS_ACCESS_KEY_ID="your-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_REGION="us-east-1"

# GitHub Configuration
export GITHUB_TOKEN="your-github-token"
export GITHUB_USER="your-github-username"

# Application Configuration
export API_URL="https://api.thechain.com"
export WS_URL="wss://api.thechain.com/ws"
```

### Kubernetes Secrets

Create required secrets:

```bash
# Create Docker registry secret
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=$GITHUB_USER \
  --docker-password=$GITHUB_TOKEN \
  --docker-email=your-email@example.com \
  -n thechain-production

# Create TLS certificate (managed by cert-manager)
# This is automatic with the ingress annotation
```

### Application Configuration

Update `k8s/admin-dashboard/configmap.yaml` for environment-specific settings:

```yaml
data:
  app-config.json: |
    {
      "environment": "production",
      "apiUrl": "https://api.thechain.com",
      "wsUrl": "wss://api.thechain.com/ws"
    }
```

## Monitoring & Health Checks

### Health Check Endpoints

- **Health**: `https://admin.thechain.com/health`
- **Metrics**: `https://admin.thechain.com/metrics` (Prometheus format)

### Verify Deployment

```bash
# Check pod status
kubectl get pods -n thechain-production -l app=admin-dashboard

# View logs
kubectl logs -n thechain-production -l app=admin-dashboard --tail=100

# Check service
kubectl get svc admin-dashboard -n thechain-production

# Test health endpoint
curl https://admin.thechain.com/health
```

### Monitor Resources

```bash
# CPU and Memory usage
kubectl top pods -n thechain-production -l app=admin-dashboard

# HPA status
kubectl get hpa admin-dashboard -n thechain-production

# Events
kubectl get events -n thechain-production --sort-by='.lastTimestamp'
```

## Rollback Procedures

### Automatic Rollback

The CI/CD pipeline includes automatic rollback on failure.

### Manual Rollback

```bash
# Rollback to previous version
kubectl rollout undo deployment/admin-dashboard -n thechain-production

# Rollback to specific revision
kubectl rollout undo deployment/admin-dashboard \
  -n thechain-production \
  --to-revision=2

# Check rollout history
kubectl rollout history deployment/admin-dashboard -n thechain-production
```

## Troubleshooting

### Common Issues

#### Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name> -n thechain-production

# Check logs
kubectl logs <pod-name> -n thechain-production --previous
```

#### Image Pull Errors
```bash
# Verify secret
kubectl get secret ghcr-secret -n thechain-production

# Re-create secret
kubectl delete secret ghcr-secret -n thechain-production
kubectl create secret docker-registry ghcr-secret ...
```

#### Ingress Not Working
```bash
# Check ingress status
kubectl describe ingress admin-dashboard -n thechain-production

# Verify certificate
kubectl get certificate admin-dashboard-tls -n thechain-production
```

### Debug Commands

```bash
# Execute into pod
kubectl exec -it <pod-name> -n thechain-production -- /bin/sh

# Port forward for local testing
kubectl port-forward deployment/admin-dashboard 8080:8080 -n thechain-production

# View configuration
kubectl get configmap admin-dashboard-config -n thechain-production -o yaml
```

## Security Checklist

- [ ] All secrets stored in Kubernetes secrets or AWS Secrets Manager
- [ ] TLS enabled with valid certificate
- [ ] Security headers configured in nginx
- [ ] Container running as non-root user
- [ ] Network policies applied
- [ ] RBAC configured for service accounts
- [ ] Image vulnerability scanning enabled
- [ ] Rate limiting configured

## Performance Optimization

### Scaling Configuration

The HPA is configured with:
- Min replicas: 3
- Max replicas: 10
- CPU target: 70%
- Memory target: 80%

### Manual Scaling

```bash
# Scale manually
kubectl scale deployment/admin-dashboard --replicas=5 -n thechain-production

# Disable HPA temporarily
kubectl patch hpa admin-dashboard -n thechain-production -p '{"spec":{"minReplicas":5,"maxReplicas":5}}'
```

## Maintenance

### Update Dependencies

```bash
# Update Flutter dependencies
cd frontend/admin_dashboard
flutter pub upgrade
flutter pub outdated

# Update Docker base image
docker pull nginx:alpine
```

### Certificate Renewal

Certificates are auto-renewed by cert-manager. To manually renew:

```bash
kubectl delete certificate admin-dashboard-tls -n thechain-production
# cert-manager will recreate it
```

## Support

For issues or questions:
- Check logs: `kubectl logs -n thechain-production -l app=admin-dashboard`
- View metrics: Grafana dashboard
- Alert channel: #thechain-alerts in Slack
- On-call: Check PagerDuty schedule

## Quick Start Commands

```bash
# Deploy to production (one command)
gh workflow run admin-dashboard-deploy.yml -f environment=production

# Check status
kubectl get all -n thechain-production -l app=admin-dashboard

# View live logs
kubectl logs -n thechain-production -l app=admin-dashboard -f

# Access locally
kubectl port-forward svc/admin-dashboard 8080:80 -n thechain-production
# Then open http://localhost:8080
```