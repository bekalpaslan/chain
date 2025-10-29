# Runtime stage - just serve the pre-built app
FROM nginx:alpine

# Copy pre-built app (if exists, otherwise use placeholder)
COPY build/web /usr/share/nginx/html

# Use default nginx config for now
# Will add custom nginx.conf later if needed

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
