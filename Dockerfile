# ==========================================
# STAGE 1: Flutter Web Builder
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS web-builder

WORKDIR /app

# Enable web support and install dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter config --enable-web \
    && flutter pub get

# Copy all source files
COPY . .

# Build optimized Flutter Web bundle
RUN flutter build web --release --pwa-strategy=none

# ==========================================
# STAGE 2: Production Web Server (Nginx Alpine)
# ==========================================
FROM nginx:alpine AS runner

# Custom Nginx configuration with SPA fallback
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy compiled Web output from web-builder
COPY --from=web-builder /app/build/web /usr/share/nginx/html

# Port exposed internally
EXPOSE 80

# Container healthcheck
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]

# ==========================================
# STAGE 3: Android APK Builder (Optional Target)
# ==========================================
FROM ghcr.io/cirruslabs/flutter:stable AS apk-builder

WORKDIR /app

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .

# Build Release APK
RUN flutter build apk --release

# Exporter stage to output APK to host:
# docker build --target apk-exporter --output type=local,dest=./dist-lab/apk .
FROM scratch AS apk-exporter
COPY --from=apk-builder /app/build/app/outputs/flutter-apk/app-release.apk /app-release.apk
