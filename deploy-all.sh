#!/bin/bash

# Deploy all Docker Swarm stacks
# Usage: ./deploy-all.sh

set -e

echo "======================================"
echo "Deploying Docker Swarm Stacks"
echo "======================================"
echo ""

# Check if Docker Swarm is initialized
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "Error: Docker Swarm is not initialized."
    echo "Please run: docker swarm init"
    exit 1
fi

# Function to deploy a stack
deploy_stack() {
    local stack_name=$1
    local compose_file=$2
    local env_file=$3
    
    echo "Deploying $stack_name stack..."
    if docker stack deploy -c "$compose_file" --env-file "$env_file" "$stack_name"; then
        echo "✓ $stack_name stack deployed successfully"
    else
        echo "✗ Failed to deploy $stack_name stack"
        return 1
    fi
    echo ""
}

# Deploy each stack
deploy_stack "net" "net/compose.yml" "net/stack.env"
deploy_stack "servarr" "servarr/compose.yml" "servarr/stack.env"
deploy_stack "plex" "plex/compose.yml" "plex/stack.env"
deploy_stack "jellyfin" "jellyfin/compose.yml" "jellyfin/stack.env"
deploy_stack "tdarr" "tdarr/compose.yml" "tdarr/stack.env"

echo "======================================"
echo "Deployment Complete!"
echo "======================================"
echo ""
echo "View stack status with:"
echo "  docker stack ls"
echo ""
echo "View services in a stack:"
echo "  docker stack services <stack-name>"
echo ""
echo "View service logs:"
echo "  docker service logs <stack-name>_<service-name>"
