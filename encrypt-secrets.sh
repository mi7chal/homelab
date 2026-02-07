#!/bin/bash

# Strict mode
set -euo pipefail

echo "🔒 Encrypting secrets..."

# Find all secret files
secrets=$(find "./k8s" -type f -name "*.secret.yaml" -not -path '*/.git/*')

count=0

for file in $secrets; do
    outfile="${file%.secret.yaml}.enc.yaml"
    
    # Run sops encryption
    if sops -e "$file" > "$outfile"; then
        count=$((count + 1))
    else
        echo "   ✗ Failed to encrypt $file"
        [ -f "$outfile" ] && [ ! -s "$outfile" ] && rm "$outfile"
        # Clean up empty file if created and break script execution
        exit 1
    fi
done

echo "✨ Successfully encrypted $count secrets."
