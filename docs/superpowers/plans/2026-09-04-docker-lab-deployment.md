# Dockerization & Campus Lab Deployment Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create production-grade, error-proof Docker configurations and offline lab deployment bundles for FitForge (Flutter Web & Mobile APK) and FitForge Admin (Next.js 16).

**Architecture:** Multi-stage Docker builds utilizing lightweight Nginx for Flutter Web and Next.js Standalone for the Admin Dashboard. Orchestrated via Docker Compose and driven by 1-click batch/shell scripts for offline USB deployment in university computer labs.

**Tech Stack:** Docker, Docker Compose, Nginx Alpine, Node.js 20 Alpine, Flutter 3.9+ SDK, Next.js 16, Windows Batch (.bat), POSIX Shell (.sh).

## Global Constraints
- Target 1: FitForge Web container on port 8080 (Nginx Alpine)
- Target 2: FitForge Admin container on port 3000 (Next.js Standalone)
- Target 3: Android APK exporter target for smartphone testing
- Dual-Mode: Online build (`docker compose build`) and Offline USB archive (`docker save`/`load`)
- All configurations must be zero-error on Windows and Linux lab hosts.

---

### Task 1: FitForge Containerization Configuration

**Files:**
- Create: `Dockerfile` (in `fitforge/`)
- Create: `nginx.conf` (in `fitforge/`)
- Create: `.dockerignore` (in `fitforge/`)
- Create: `docker-compose.yml` (in `fitforge/`)

- [ ] **Step 1: Create `fitforge/.dockerignore`**
Exclude caches, build artifacts, git, and local editor metadata.

- [ ] **Step 2: Create `fitforge/nginx.conf`**
Configure Nginx to serve static Flutter Web files with SPA routing fallback to `/index.html` and gzip compression.

- [ ] **Step 3: Create `fitforge/Dockerfile`**
Implement multi-stage Docker build:
- Stage 1: `ghcr.io/cirruslabs/flutter:stable` for web compilation (`flutter build web --release`).
- Stage 2: `nginx:alpine` serving web build on port 80.
- Stage 3: APK exporter stage targeting `flutter build apk --release`.

- [ ] **Step 4: Create standalone `fitforge/docker-compose.yml`**
Enable testing and running `fitforge` independently on port 8080.

- [ ] **Step 5: Verify configuration syntax and commit**
```bash
git add Dockerfile nginx.conf .dockerignore docker-compose.yml
git commit -m "feat(docker): add multi-stage Dockerfile, nginx config, and compose for fitforge"
```

---

### Task 2: FitForge Admin Containerization Configuration

**Files:**
- Modify: `../fitforge-admin/next.config.ts`
- Create: `../fitforge-admin/Dockerfile`
- Create: `../fitforge-admin/.dockerignore`
- Create: `../fitforge-admin/docker-compose.yml`

- [ ] **Step 1: Enable standalone output in `next.config.ts`**
Update `next.config.ts` in `fitforge-admin` to include `output: 'standalone'`.

- [ ] **Step 2: Create `fitforge-admin/.dockerignore`**
Exclude `node_modules`, `.next`, `.git`, `.env.local`.

- [ ] **Step 3: Create multi-stage `fitforge-admin/Dockerfile`**
- Stage 1 (deps): `node:20-alpine` runs `npm ci`.
- Stage 2 (builder): Injects Firebase environment args, copies source, runs `npm run build`.
- Stage 3 (runner): Minimal `node:20-alpine`, non-root user, runs `node server.js` on port 3000.

- [ ] **Step 4: Create standalone `fitforge-admin/docker-compose.yml`**
Enable testing and running `fitforge-admin` independently on port 3000.

---

### Task 3: Unified Root Orchestration & Port Configuration

**Files:**
- Create: `docker-compose.yml` (in workspace root)
- Create: `.env.example`

- [ ] **Step 1: Create `.env.example`**
Specify customizable ports (`FITFORGE_WEB_PORT=8080`, `FITFORGE_ADMIN_PORT=3000`).

- [ ] **Step 2: Create root `docker-compose.yml`**
Combine `fitforge-web` and `fitforge-admin` services with memory limits and health checks.

- [ ] **Step 3: Commit root orchestration files**
```bash
git add docker-compose.yml .env.example
git commit -m "feat(docker): add root docker-compose orchestrator"
```

---

### Task 4: Lab Automation Scripts (Dual-Mode: Export & Run)

**Files:**
- Create: `export-lab-bundle.bat` (Windows) & `export-lab-bundle.sh` (Linux/Mac)
- Create: `run-in-lab.bat` (Windows) & `run-in-lab.sh` (Linux/Mac)
- Create: `stop-in-lab.bat` (Windows) & `stop-in-lab.sh` (Linux/Mac)

- [ ] **Step 1: Create `export-lab-bundle.bat` & `export-lab-bundle.sh`**
Automate building images locally, building APK, running `docker save -o dist-lab/fitforge-bundle.tar`, and packaging files into `dist-lab/`.

- [ ] **Step 2: Create `run-in-lab.bat` & `run-in-lab.sh`**
Automate checking Docker status on lab machine, loading `fitforge-bundle.tar` without internet, starting containers, and launching browser.

- [ ] **Step 3: Create `stop-in-lab.bat` & `stop-in-lab.sh`**
Automate graceful teardown of containers on the lab machine.

- [ ] **Step 4: Commit scripts**
```bash
git add *.bat *.sh
git commit -m "feat(scripts): add 1-click lab bundle export, run, and stop scripts"
```

---

### Task 5: Campus Lab Deployment Guide & Troubleshooting Manual

**Files:**
- Create: `LAB_DEPLOYMENT_GUIDE.md`

- [ ] **Step 1: Write comprehensive guide covering:**
  - Prerequisites (Docker Desktop on Windows/Mac or Docker Engine on Linux).
  - Method A: Offline USB Flashdisk installation (Zero internet required).
  - Method B: Direct Git/Online build on lab machine.
  - Step-by-step troubleshooting:
    - WSL 2 Kernel update issues.
    - BIOS Virtualization (VT-x / AMD-V) disabled.
    - Port conflicts (Port 8080 / 3000 in use).
    - Windows Firewall / Defender warnings.
    - Testing APK on physical smartphone via USB debugging or direct install.

- [ ] **Step 2: Commit manual**
```bash
git add LAB_DEPLOYMENT_GUIDE.md
git commit -m "docs: add complete campus lab docker deployment guide"
```
