# Nginx Production Deployment Guide

## Overview

This guide explains how to deploy **The Chain** Flutter web application using **Nginx** as a production web server.

## Current Status

✅ **Flutter web build completed**: `mobile/build/web/`
✅ **Nginx configuration created**: `nginx.conf`
⏳ **Nginx installation needed**: Follow steps below

## Architecture

```
┌─────────────┐
│   Browser   │
└──────┬──────┘
       │ HTTP :80
       │
┌──────▼──────────────┐
│      Nginx          │
│   (Port 80/443)     │
└─────────┬───────────┘
          │
          ├─────────────────┐
          │                 │
┌─────────▼─────────┐  ┌────▼────────────┐
│  Flutter Web App  │  │  Backend API    │
│  (Static Files)   │  │  (Port 8080)    │
│  /index.html      │  │  /api/v1/*      │
└───────────────────┘  └─────────────────┘
```

## Features

### Nginx Configuration Includes:

1. ✅ **Serves Flutter web app** from `mobile/build/web/`
2. ✅ **Reverse proxy** for backend API (`/api/*` → `localhost:8080`)
3. ✅ **WebSocket support** for real-time updates (`/api/v1/ws/*`)
4. ✅ **Gzip compression** for better performance
5. ✅ **Cache headers** for static assets (1 year)
6. ✅ **Security headers** (X-Frame-Options, X-XSS-Protection, etc.)
7. ✅ **SPA routing** (all routes serve `index.html`)
8. ✅ **Health check endpoint** (`/health`)
9. 🔒 **HTTPS ready** (SSL configuration included, commented out)

## Installation Steps

### Step 1: Install Nginx

#### On Windows:

1. **Download Nginx**:
   ```
   https://nginx.org/en/download.html
   ```
   Download the Windows version (mainline or stable)

2. **Extract** to `C:\nginx` or your preferred location

3. **Test installation**:
   ```bash
   cd C:\nginx
   nginx -v
   ```

#### On Linux:

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nginx

# CentOS/RHEL
sudo yum install nginx

# Verify
nginx -v
```

#### On macOS:

```bash
# Using Homebrew
brew install nginx

# Verify
nginx -v
```

### Step 2: Configure Nginx

#### Option A: Replace Default Config (Recommended for Development)

**Windows**:
```bash
# Backup original config
copy C:\nginx\conf\nginx.conf C:\nginx\conf\nginx.conf.backup

# Copy our config
copy nginx.conf C:\nginx\conf\nginx.conf
```

**Linux/macOS**:
```bash
# Backup original config
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.backup

# Copy our config to sites-available
sudo cp nginx.conf /etc/nginx/sites-available/thechain

# Enable site
sudo ln -s /etc/nginx/sites-available/thechain /etc/nginx/sites-enabled/

# Remove default site (optional)
sudo rm /etc/nginx/sites-enabled/default
```

#### Option B: Add as Virtual Host

**Windows** (`C:\nginx\conf\nginx.conf`):
```nginx
http {
    # ... other configs ...

    # Include our site config
    include C:/Users/alpas/IdeaProjects/ticketz/nginx.conf;
}
```

**Linux/macOS** (`/etc/nginx/nginx.conf`):
```nginx
http {
    # ... other configs ...

    # Include sites
    include /etc/nginx/sites-enabled/*;
}
```

### Step 3: Verify Configuration

**Test the configuration**:

```bash
# Windows
C:\nginx\nginx.exe -t

# Linux/macOS
sudo nginx -t
```

Expected output:
```
nginx: the configuration file C:/nginx/conf/nginx.conf syntax is ok
nginx: configuration file C:/nginx/conf/nginx.conf test is successful
```

### Step 4: Start Nginx

#### Windows:

```bash
# Start Nginx
cd C:\nginx
start nginx

# Or run as service (if installed as service)
net start nginx
```

#### Linux:

```bash
# Start Nginx
sudo systemctl start nginx

# Enable on boot
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx
```

#### macOS:

```bash
# Start Nginx
brew services start nginx

# Or manually
sudo nginx
```

### Step 5: Verify It's Working

1. **Check Nginx is running**:
   ```bash
   # Check if port 80 is listening
   # Windows
   netstat -an | findstr :80

   # Linux/macOS
   sudo netstat -tuln | grep :80
   ```

2. **Access the application**:
   - Open browser: `http://localhost`
   - Should see The Chain Flutter web app!

3. **Test API proxy**:
   ```bash
   curl http://localhost/api/v1/chain/stats
   ```

4. **Check health endpoint**:
   ```bash
   curl http://localhost/health
   ```

## Managing Nginx

### Check Status

```bash
# Windows
tasklist /fi "imagename eq nginx.exe"

# Linux
sudo systemctl status nginx

# macOS
brew services list | grep nginx
```

### Reload Configuration (after changes)

```bash
# Windows
cd C:\nginx
nginx -s reload

# Linux/macOS
sudo nginx -s reload
# Or
sudo systemctl reload nginx
```

### Stop Nginx

```bash
# Windows
cd C:\nginx
nginx -s stop

# Linux
sudo systemctl stop nginx

# macOS
brew services stop nginx
```

### Restart Nginx

```bash
# Windows
nginx -s stop && start nginx

# Linux
sudo systemctl restart nginx

# macOS
brew services restart nginx
```

### View Logs

```bash
# Windows
# Access logs: C:\nginx\logs\thechain-access.log
# Error logs: C:\nginx\logs\thechain-error.log
type C:\nginx\logs\thechain-error.log

# Linux
sudo tail -f /var/log/nginx/thechain-error.log
sudo tail -f /var/log/nginx/thechain-access.log

# macOS
tail -f /usr/local/var/log/nginx/thechain-error.log
```

## File Structure

After deployment, your structure should be:

```
ticketz/
├── mobile/
│   └── build/
│       └── web/                    # Flutter production build
│           ├── index.html          # Main HTML file
│           ├── main.dart.js        # Compiled Dart code (2.8MB)
│           ├── flutter.js          # Flutter engine
│           ├── assets/             # App assets
│           ├── canvaskit/          # Canvas rendering
│           └── icons/              # App icons
├── nginx.conf                      # Nginx configuration
└── NGINX_DEPLOYMENT.md            # This file
```

## Configuration Details

### Static File Serving

```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```
- Serves Flutter web app
- Falls back to `index.html` for SPA routing

### API Reverse Proxy

```nginx
location /api/ {
    proxy_pass http://localhost:8080;
    # ... proxy headers ...
}
```
- Forwards `/api/*` requests to Spring Boot backend
- Adds proper headers for proxy

### WebSocket Support

```nginx
location /api/v1/ws/ {
    proxy_pass http://localhost:8080;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
}
```
- Enables WebSocket connections for real-time updates

### Caching Strategy

- **Static assets** (JS, CSS, images): 1 year cache
- **index.html**: No cache (always fresh)
- **API responses**: No cache by Nginx (handled by backend)

## Performance Optimizations

### 1. Gzip Compression
Already enabled in config:
```nginx
gzip on;
gzip_types text/plain text/css application/javascript application/json;
```

### 2. HTTP/2 (When SSL enabled)
```nginx
listen 443 ssl http2;
```

### 3. Browser Caching
Static assets cached for 1 year:
```nginx
expires 1y;
add_header Cache-Control "public, immutable";
```

### 4. Buffer Sizes
Optimized proxy buffers for API requests

## Security

### Headers Added

```nginx
X-Frame-Options: SAMEORIGIN           # Prevent clickjacking
X-Content-Type-Options: nosniff       # Prevent MIME sniffing
X-XSS-Protection: 1; mode=block       # XSS protection
```

### SSL/HTTPS (Production)

To enable HTTPS:

1. **Get SSL certificate**:
   - Let's Encrypt (free): https://letsencrypt.org/
   - Or use self-signed for testing

2. **Uncomment HTTPS server block** in `nginx.conf`

3. **Update certificate paths**:
   ```nginx
   ssl_certificate /path/to/fullchain.pem;
   ssl_certificate_key /path/to/privkey.pem;
   ```

4. **Reload Nginx**:
   ```bash
   nginx -s reload
   ```

## Troubleshooting

### Nginx won't start

1. **Check configuration**:
   ```bash
   nginx -t
   ```

2. **Check port 80 availability**:
   ```bash
   # Windows
   netstat -ano | findstr :80

   # Linux/macOS
   sudo lsof -i :80
   ```

3. **Check error logs**:
   ```bash
   # Windows
   type C:\nginx\logs\error.log

   # Linux/macOS
   tail -f /var/log/nginx/error.log
   ```

### Can't access the app

1. **Verify Nginx is running**:
   ```bash
   # Windows
   tasklist | findstr nginx

   # Linux
   ps aux | grep nginx
   ```

2. **Check firewall**:
   - Windows: Allow port 80 in Windows Firewall
   - Linux: `sudo ufw allow 80`

3. **Verify backend is running**:
   ```bash
   curl http://localhost:8080/api/v1/chain/stats
   ```

### 404 errors on refresh

Make sure this is in config:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

### API calls failing

1. **Check backend is running** on port 8080
2. **Verify proxy configuration**:
   ```nginx
   location /api/ {
       proxy_pass http://localhost:8080;
   }
   ```
3. **Check Nginx error logs**

## URLs After Deployment

| Service | URL | Notes |
|---------|-----|-------|
| **Web App** | `http://localhost` | Served by Nginx |
| **API (proxied)** | `http://localhost/api/v1/*` | Proxied to :8080 |
| **API (direct)** | `http://localhost:8080/api/v1/*` | Direct backend access |
| **Health Check** | `http://localhost/health` | Nginx health endpoint |
| **WebSocket** | `ws://localhost/api/v1/ws/*` | Real-time updates |

## Benefits of Nginx Deployment

### Performance
- ⚡ **Faster**: Static file serving optimized
- 📦 **Compressed**: Gzip reduces bandwidth
- 🚀 **Cached**: Browser caching for assets
- 🔄 **HTTP/2**: Multiplexed connections

### Production Ready
- 🔒 **SSL/HTTPS**: Easy to configure
- 📊 **Logging**: Access and error logs
- 🛡️ **Security**: Headers and protections
- 🏥 **Health Checks**: Monitor uptime

### Architecture
- 🌐 **Single Domain**: Frontend and backend on same domain (no CORS!)
- 🔗 **Reverse Proxy**: Backend hidden from public
- 📱 **WebSocket**: Real-time updates supported
- 🎯 **Load Balancing**: Can add multiple backend servers

## Next Steps

1. ✅ Install Nginx
2. ✅ Copy configuration
3. ✅ Start Nginx
4. ✅ Test at `http://localhost`
5. 🔒 Add SSL certificate (production)
6. 🌍 Configure domain name (production)
7. 📊 Set up monitoring
8. 🚀 Deploy to cloud (AWS, DigitalOcean, etc.)

## Summary

✅ **Flutter web built** for production (2.8MB optimized)
✅ **Nginx configuration** ready with all features
✅ **Reverse proxy** configured for backend API
✅ **WebSocket support** for real-time updates
✅ **Caching strategy** for optimal performance
✅ **Security headers** configured
✅ **Production-ready** architecture

Your application is ready to deploy with Nginx! 🎉
