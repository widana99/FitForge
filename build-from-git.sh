#!/usr/bin/env bash
set -e
echo "========================================================"
echo "  FitForge - PLAN C: Build Langsung dari Source Git"
echo "========================================================"
docker compose -f docker-compose.lab.yml up --build -d
sleep 4
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open http://localhost:8080 >/dev/null 2>&1 &
    xdg-open http://localhost:3000 >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
    open http://localhost:8080
    open http://localhost:3000
fi
