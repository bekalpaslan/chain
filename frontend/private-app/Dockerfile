# Runtime stage - just serve the pre-built app
FROM nginx:alpine

# Copy pre-built app (if exists, otherwise use placeholder)
COPY build/web /usr/share/nginx/html

# Copy custom nginx configuration with Flutter routing support
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
