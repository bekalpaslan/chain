# Simple runtime stage - serve pre-built Flutter web app
FROM nginx:alpine

# Create app directory
RUN mkdir -p /usr/share/nginx/html

# Copy pre-built app if it exists, otherwise create placeholder
COPY build/web /usr/share/nginx/html

# Use default nginx config
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]