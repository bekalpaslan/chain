# Build stage
FROM debian:latest AS build-env

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl git wget unzip libgconf-2-4 gdb libstdc++6 \
    libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 \
    sed ca-certificates

# Clone Flutter
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:${PATH}"

# Enable Flutter web
RUN flutter channel stable
RUN flutter upgrade
RUN flutter config --enable-web

# Copy shared package first
WORKDIR /shared
COPY shared/ /shared/
RUN flutter pub get

# Copy public app
WORKDIR /app
COPY public-app/pubspec.yaml public-app/pubspec.lock ./
RUN flutter pub get

# Copy public app source code
COPY public-app/ .

# Build web app
RUN flutter build web --release --web-renderer canvaskit

# Runtime stage
FROM nginx:alpine

# Copy built app
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Copy nginx config
COPY public-app/nginx.conf /etc/nginx/nginx.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
