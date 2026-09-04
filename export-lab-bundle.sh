#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  FitForge - Export Docker Lab Bundle (Portable USB)"
echo "========================================================"
echo ""

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running. Please start Docker Desktop or Docker engine."
    exit 1
fi

echo "[1/5] Creating dist-lab output directories..."
mkdir -p dist-lab/apk

echo "[2/5] Building Docker images for FitForge Web & Admin..."
docker compose -f docker-compose.lab.yml build

echo "[3/5] (Optional) Building Android APK to dist-lab/apk..."
docker build --target apk-exporter --output type=local,dest=dist-lab/apk . 2>/dev/null || true

echo "[4/5] Exporting Docker images to tarball (fitforge-images.tar)..."
docker save fitforge-web:latest fitforge-admin:latest -o dist-lab/fitforge-images.tar

echo "[5/5] Copying lab runner scripts..."
cp run-in-lab.bat dist-lab/run-in-lab.bat 2>/dev/null || true
cp run-in-lab.sh dist-lab/run-in-lab.sh
chmod +x dist-lab/run-in-lab.sh
cp stop-in-lab.bat dist-lab/stop-in-lab.bat 2>/dev/null || true
cp stop-in-lab.sh dist-lab/stop-in-lab.sh
chmod +x dist-lab/stop-in-lab.sh
cp .env.example dist-lab/.env

cat << 'EOF' > dist-lab/docker-compose.yml
services:
  fitforge-web:
    image: fitforge-web:latest
    container_name: fitforge-web
    ports:
      - "${FITFORGE_WEB_PORT:-8080}:80"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:80/"]
      interval: 30s
      timeout: 5s
      retries: 3

  fitforge-admin:
    image: fitforge-admin:latest
    container_name: fitforge-admin
    ports:
      - "${FITFORGE_ADMIN_PORT:-3000}:3000"
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 512M
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost:3000/"]
      interval: 30s
      timeout: 5s
      retries: 3
EOF

echo ""
echo "========================================================"
echo "  [SUCCESS] Lab Bundle ready in folder: $(pwd)/dist-lab"
echo "  Copy 'dist-lab' folder to your USB drive!"
echo "========================================================"
