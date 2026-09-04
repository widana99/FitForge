#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  FitForge - PLAN B: Push Docker Images ke Docker Hub"
echo "========================================================"
echo ""

if ! docker info >/dev/null 2>&1; then
    echo "[ERROR] Docker is not running!"
    exit 1
fi

read -p "Masukkan Username Docker Hub Anda: " DOCKERHUB_USER
if [ -z "$DOCKERHUB_USER" ]; then
    echo "[ERROR] Username tidak boleh kosong!"
    exit 1
fi

docker login
docker compose -f docker-compose.lab.yml build

docker tag fitforge-web:latest "$DOCKERHUB_USER/fitforge-web:latest"
docker tag fitforge-admin:latest "$DOCKERHUB_USER/fitforge-admin:latest"

docker push "$DOCKERHUB_USER/fitforge-web:latest"
docker push "$DOCKERHUB_USER/fitforge-admin:latest"

echo ""
echo "========================================================"
echo "  [SUKSES] Image Berhasil Diunggah ke Docker Hub!"
echo "  - $DOCKERHUB_USER/fitforge-web:latest"
echo "  - $DOCKERHUB_USER/fitforge-admin:latest"
echo "========================================================"
