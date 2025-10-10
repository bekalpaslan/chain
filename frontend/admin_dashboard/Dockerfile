# Multi-stage build for The Chain Admin Dashboard
# Stage 1: Use pre-built web assets (built locally)
# For production, we'll use the already built web assets from local build

# Stage 2: Serve with nginx
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy custom nginx config
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/default.conf /etc/nginx/conf.d/default.conf

# Copy pre-built web app from local build
COPY build/web /usr/share/nginx/html

# Add security headers script
COPY docker/security-headers.conf /etc/nginx/security-headers.conf

# Create non-root user
RUN adduser -D -u 1001 appuser && \
    chown -R appuser:appuser /usr/share/nginx/html && \
    chown -R appuser:appuser /var/cache/nginx && \
    chown -R appuser:appuser /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown appuser:appuser /var/run/nginx.pid

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

# Switch to non-root user
USER appuser

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]