#!/bin/bash
set -e

cd ~/Projects/slskdquestrr

MSG="${1:-update}"
git add .
git commit -m "$MSG"
git push origin main

docker build -t ghcr.io/rj45connector/slskdquestrr:latest .
docker push ghcr.io/rj45connector/slskdquestrr:latest

echo "✓ pushed to GitHub + GHCR"
