# Runtime stage - just serve the pre-built app
FROM nginx:alpine

# Copy pre-built app
COPY private-app/build/web /usr/share/nginx/html

# Copy nginx config
COPY private-app/nginx.conf /etc/nginx/nginx.conf

EXPOSE 3001

CMD ["nginx", "-g", "daemon off;"]
