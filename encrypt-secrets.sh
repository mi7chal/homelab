#!/bin/bash

# Strict mode
set -euo pipefail

echo "🔒 Encrypting secrets..."

count=0

while IFS= read -r -d '' file; do
    outfile="${file%.secret.yaml}-secret.enc.yaml"

    # Run sops encryption
    if sops -e "$file" > "$outfile"; then
        count=$((count + 1))
    else
        echo "   ✗ Failed to encrypt $file"
        [ -f "$outfile" ] && [ ! -s "$outfile" ] && rm "$outfile"
        # Clean up empty file if created and break script execution
        exit 1
    fi
done < <(find "./k8s" -type f -name "*.secret.yaml" -not -path '*/.git/*' -print0)

echo "✨ Successfully encrypted $count secrets."
