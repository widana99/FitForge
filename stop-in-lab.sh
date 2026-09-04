#!/usr/bin/env bash
echo "========================================================"
echo "  FitForge - Stopping Lab Containers"
echo "========================================================"
echo ""

docker compose down

echo ""
echo "[OK] All FitForge containers stopped cleanly."
