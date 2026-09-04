# FitForge & FitForge Admin: Dockerization & Campus Lab Deployment Design

## Overview
This document specifies the containerization architecture and offline-ready deployment pipeline for **FitForge** (Flutter Web & Android Mobile) and **FitForge Admin** (Next.js 16 Web Dashboard). The goal is to provide a robust, lightweight, and zero-error deployment flow that runs seamlessly on university computer lab machines without requiring manual installation of Flutter, Android SDK, Node.js, or relying on lab internet access.

## Architecture

### 1. `fitforge` Containerization (Flutter Multi-Target)
- **Base Builder Image:** `ghcr.io/cirruslabs/flutter:stable`
- **Target 1: Production Web Container (`fitforge-web`)**
  - Multi-stage build compiling Flutter to Web release: `flutter build web --release`.
  - Served by an ultra-lightweight `nginx:alpine` image (~25MB).
  - Web Server Port: `8080` (mapped to internal Nginx `80`).
  - Nginx Configuration: Configured with SPA rewrite rule (`try_files $uri $uri/ /index.html;`) to prevent 404s on browser reloads or client-side routing.
- **Target 2: APK Exporter (`fitforge-apk`)**
  - Standalone build target within Dockerfile compiling Android APK: `flutter build apk --release`.
  - Exported to host directory (e.g. `dist-lab/apk/app-release.apk`) using BuildKit/Docker output volume, enabling physical smartphone testing without running a heavy emulator in the lab.
- **Ignored Files (`.dockerignore`):**
  - Excludes `.dart_tool/`, `build/`, `.git/`, `.gradle/`, `.idea/`, `.vscode/`, keeping build context under 10MB.

### 2. `fitforge-admin` Containerization (Next.js 16 Standalone)
- **Next.js Configuration (`next.config.ts`):**
  - Enabled `output: 'standalone'` to produce a minimal self-contained Node server containing only the exact dependencies needed.
- **Dockerfile (Multi-stage):**
  - **Stage 1 (deps):** `node:20-alpine` with `npm ci` leveraging caching.
  - **Stage 2 (builder):** Injects `NEXT_PUBLIC_FIREBASE_*` environment variables, copies source code, and runs `npm run build`.
  - **Stage 3 (runner):** Minimal `node:20-alpine`, non-root user `nextjs:nodejs`, copies `.next/standalone` and `.next/static` to `public`.
  - Web Server Port: `3000`.
  - Size reduction: ~130MB total image size (compared to >1GB standard node image).
- **Ignored Files (`.dockerignore`):**
  - Excludes `node_modules/`, `.next/`, `.git/`, and local logs.

### 3. Unified Orchestration (`docker-compose.yml`)
- Provides a unified compose specification orchestrating:
  - `fitforge-web`: Maps `8080:80`, health check on `http://localhost:80/`
  - `fitforge-admin`: Maps `3000:3000`, health check on `http://localhost:3000/`
- Configured with memory limits (max 512MB RAM each) to protect restricted lab PCs.
- Also supports running each sub-project independently if required.

### 4. Lab Portability & Offline Bundle Pipeline
To eliminate errors caused by campus lab network restrictions, firewall proxies, and slow speeds:
- **Build & Export Pipeline (Executed on development laptop):**
  - Script: `export-lab-bundle.bat` (Windows) / `export-lab-bundle.sh` (Linux/macOS).
  - Actions:
    1. Executes `docker compose build`.
    2. Builds/exports `app-release.apk` to `dist-lab/apk/`.
    3. Runs `docker save fitforge-web:latest fitforge-admin:latest -o dist-lab/fitforge-bundle.tar`.
    4. Copies `docker-compose.yml`, `run-in-lab.bat`, `stop-in-lab.bat`, and README instructions to `dist-lab/`.
    5. The resulting `dist-lab/` directory can be copied directly to a USB Flashdisk.
- **Execution Pipeline (Executed on lab computer):**
  - Script: `run-in-lab.bat` / `run-in-lab.sh`.
  - Actions:
    1. Verifies Docker daemon status; provides clear prompts if Docker is not started.
    2. Runs `docker load -i fitforge-bundle.tar` (instant local load, zero internet required).
    3. Runs `docker compose up -d`.
    4. Automatically launches default browser opening:
       - `http://localhost:8080` (FitForge User Web)
       - `http://localhost:3000` (FitForge Admin Dashboard)
- **Teardown Pipeline:**
  - Script: `stop-in-lab.bat` (`docker compose down`).

## Error Prevention Matrix (Lab Troubleshooting)

| Common Lab Error | Root Cause | Solution Implemented |
|---|---|---|
| **No Internet / Blocked Downloads** | Campus proxy blocks NPM/Gradle/Docker Hub | Offline `.tar` bundle loaded locally via `docker load`. |
| **Port Conflict (8080 or 3000 in use)** | XAMPP/Apache or previous services running | Parameterized ports in `.env` with auto-port conflict detection. |
| **Android Virtualization Disabled (VT-x/AMD-V)** | BIOS restrictions on lab PCs | Flutter Web used for instant PC presentation; APK provided for physical phone. |
| **Flutter Web 404 on Refresh** | SPA router navigation not handled by server | Nginx `try_files` SPA rewrite rule included in `nginx.conf`. |
| **Large Node Image Freeze Lab PC** | 1GB+ Node image causes memory exhaustion | Next.js Standalone multi-stage build creates ultra-slim ~130MB container. |
