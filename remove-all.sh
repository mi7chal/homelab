#!/bin/bash

# Remove all Docker Swarm stacks
# Usage: ./remove-all.sh

set -e

echo "======================================"
echo "Removing Docker Swarm Stacks"
echo "======================================"
echo ""

# Check if Docker Swarm is initialized
if ! docker info 2>/dev/null | grep -q "Swarm: active"; then
    echo "Error: Docker Swarm is not initialized."
    exit 1
fi

# Get list of existing stacks
echo "Checking existing stacks..."
EXISTING_STACKS=$(docker stack ls --format "{{.Name}}")
echo ""

# Function to remove a stack
remove_stack() {
    local stack_name=$1
    
    if echo "$EXISTING_STACKS" | grep -q "^${stack_name}$"; then
        echo "Removing $stack_name stack..."
        if docker stack rm "$stack_name"; then
            echo "✓ $stack_name stack removed successfully"
        else
            echo "✗ Failed to remove $stack_name stack"
            return 1
        fi
    else
        echo "Stack $stack_name not found, skipping..."
    fi
    echo ""
}

# Remove each stack
remove_stack "tdarr"
remove_stack "jellyfin"
remove_stack "plex"
remove_stack "servarr"
remove_stack "net"

echo "======================================"
echo "Removal Complete!"
echo "======================================"
echo ""
echo "Note: Networks and volumes may take a few moments to be removed."
