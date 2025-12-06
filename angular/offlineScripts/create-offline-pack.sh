#!/bin/bash
set -e

echo "[1/3] Installing project dependencies..."
npm ci

echo "[2/3] Building dep list..."
npm ls --all --parseable > deps.txt

echo "[3/3] Packing tarballs..."
mkdir -p offline-pack

while IFS= read -r dep; do
    if [ -f "$dep/package.json" ]; then
        echo "Packing $dep"
        (
            cd "$dep"
            npm pack --silent
            mv *.tgz ../../offline-pack 2>/dev/null || true
        )
    fi
done < deps.txt

echo "Done. Tarballs stored in offline-pack/"
