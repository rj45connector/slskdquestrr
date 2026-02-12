#!/bin/bash
set -e

cd ~/Projects/slskdquestrr

# ── Git push ─────────────────────────────────
MSG="${1:-update index.html}"
git add .
git commit -m "$MSG"
git push origin main

# ── Docker build + push ─────────────────────
docker build -t myusername/slskdquestrr:latest .
docker push myusername/slskdquestrr:latest

echo "✓ pushed to GitHub + Docker Hub"
