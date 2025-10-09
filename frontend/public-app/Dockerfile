# Build stage - compile Flutter app
FROM debian:bullseye-slim AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable --depth 1 /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter dependencies
RUN flutter doctor -v
RUN flutter precache --web

# Set working directory
WORKDIR /app

# Copy shared library first (for better layer caching)
COPY shared /app/shared

# Copy public-app files
COPY public-app/pubspec.* /app/public-app/
WORKDIR /app/public-app

# Get dependencies (cached if pubspec hasn't changed)
RUN flutter pub get

# Copy source code
COPY public-app /app/public-app

# Build web app
RUN flutter build web --release --no-tree-shake-icons

# Runtime stage - serve with nginx
FROM nginx:alpine

# Install security updates
RUN apk --no-cache upgrade

# Create non-root user
RUN addgroup -g 101 -S nginx && \
    adduser -S -D -H -u 101 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx || true

# Copy built app from build stage
COPY --from=build /app/public-app/build/web /usr/share/nginx/html

# Copy nginx config
COPY public-app/nginx.conf /etc/nginx/nginx.conf

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
