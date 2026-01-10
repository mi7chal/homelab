#!/bin/bash
set -e

echo "================================"
echo "Homelab k3s Deployment Script"
echo "================================"
echo ""

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if k3s is running
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: Cannot connect to Kubernetes cluster"
    echo "Please ensure k3s is installed and running"
    exit 1
fi

echo "✓ kubectl is available"
echo "✓ Connected to Kubernetes cluster"
echo ""

# Function to deploy a stack
deploy_stack() {
    local stack=$1
    local stack_dir="k8s/${stack}"
    
    if [ ! -d "$stack_dir" ]; then
        echo "Warning: Directory $stack_dir does not exist, skipping..."
        return
    fi
    
    echo "Deploying ${stack}..."
    kubectl apply -f "$stack_dir/"
    echo "✓ ${stack} deployed"
    echo ""
}

# Create namespace first
echo "Creating namespace..."
kubectl apply -f k8s/base/namespace.yaml
echo "✓ Namespace created"
echo ""

# Deploy stacks in order
echo "Deploying stacks..."
echo ""

deploy_stack "net"
deploy_stack "servarr"
deploy_stack "plex"
deploy_stack "jellyfin"
deploy_stack "tdarr"

echo "================================"
echo "Deployment Complete!"
echo "================================"
echo ""
echo "Check status with:"
echo "  kubectl get pods -n homelab"
echo ""
echo "View logs with:"
echo "  kubectl logs -n homelab <pod-name>"
echo ""
echo "Services available at:"
echo "  http://qbittorrent.home"
echo "  http://sonarr.home"
echo "  http://radarr.home"
echo "  http://prowlarr.home"
echo "  http://bazarr.home"
echo "  http://overseerr.home"
echo "  http://plex.home"
echo "  http://tautulli.home"
echo "  http://jellyfin.home"
echo "  http://tdarr.home"
echo "  http://adguard.home"
echo ""
