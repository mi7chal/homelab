#!/bin/bash
set -e

echo "================================"
echo "Homelab k3s Cleanup Script"
echo "================================"
echo ""
echo "WARNING: This will delete all homelab resources from the cluster!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "Deleting homelab resources..."
echo ""

# Delete all resources in homelab namespace
kubectl delete all --all -n homelab 2>/dev/null || true
kubectl delete ingress --all -n homelab 2>/dev/null || true
kubectl delete pvc --all -n homelab 2>/dev/null || true
kubectl delete configmap --all -n homelab 2>/dev/null || true
kubectl delete secret --all -n homelab 2>/dev/null || true

echo ""
echo "Deleting namespace..."
kubectl delete namespace homelab 2>/dev/null || true

echo ""
echo "================================"
echo "Cleanup Complete!"
echo "================================"
