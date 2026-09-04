#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  FitForge - Campus Lab 1-Click Runner (Linux/macOS)"
echo "========================================================"
echo ""

# 1. Verify Docker Daemon
if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running on this machine!"
    echo "Please start Docker Desktop or Docker engine service ('sudo systemctl start docker')."
    exit 1
fi

# 2. Load Offline Images if tarball exists
if [ -f "fitforge-images.tar" ]; then
    echo "[1/3] Found 'fitforge-images.tar'. Loading Docker images..."
    docker load -i fitforge-images.tar
    echo "[OK] Docker images loaded successfully without internet!"
else
    echo "[1/3] 'fitforge-images.tar' not found, proceeding with local/compose images..."
fi

# 3. Start Containers
echo "[2/3] Starting FitForge Web & Admin containers..."
docker compose up -d

# 4. Open in default browser
echo "[3/3] Waiting for services to initialize..."
sleep 4

echo ""
echo "========================================================"
echo "  [SUCCESS] FitForge Services are Running!"
echo "  - FitForge User App (Flutter Web): http://localhost:8080"
echo "  - FitForge Admin Dashboard       : http://localhost:3000"
echo "========================================================"
echo ""

# Attempt to open browser across OS platforms
if command -v xdg-open >/dev/null 2>&1; then
    xdg-open http://localhost:8080 >/dev/null 2>&1 &
    xdg-open http://localhost:3000 >/dev/null 2>&1 &
elif command -v open >/dev/null 2>&1; then
    open http://localhost:8080
    open http://localhost:3000
fi

echo "To stop the containers after your demo, run: ./stop-in-lab.sh"
