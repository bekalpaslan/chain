# Simple runtime stage - serve pre-built Flutter web app
FROM nginx:alpine

# Create app directory
RUN mkdir -p /usr/share/nginx/html

# Copy pre-built app if it exists, otherwise create placeholder
COPY build/web /usr/share/nginx/html

# Copy custom nginx configuration with Flutter routing support
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]