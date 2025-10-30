# ✅ Phase 1 Implementation Checklist

**Goal:** Remove public-app service and make private-app dashboard accessible to unauthenticated users

**Status:** Not Started
**Started:** _____
**Completed:** _____

---

## 📋 Pre-Implementation

- [ ] Read [CLAUDE_START_HERE.md](CLAUDE_START_HERE.md)
- [ ] Read [KNOWN_ISSUES.md](KNOWN_ISSUES.md)
- [ ] Read [NEXT_STEPS_ROADMAP.md](NEXT_STEPS_ROADMAP.md) - Phase 1 section
- [ ] Verify system is running: `docker-compose ps`
- [ ] Verify backend healthy: `curl http://localhost:8080/api/v1/actuator/health`

---

## 🗑️ Task 1.1: Docker Configuration Cleanup

- [ ] Open `docker-compose.yml`
- [ ] Locate `public-app` service definition
- [ ] Remove entire `public-app` service block
- [ ] Save file
- [ ] Verify syntax: `docker-compose config`

**Files modified:** `docker-compose.yml`

---

## 🔧 Task 1.2: Update Nginx Configuration

- [ ] Open `frontend/private-app/nginx.conf`
- [ ] Add SPA routing configuration (see NEXT_STEPS_ROADMAP.md)
- [ ] Add cache headers for static assets
- [ ] Save file

**Files modified:** `frontend/private-app/nginx.conf`

---

## 🚪 Task 1.3: Remove Forced Authentication

- [ ] Open `frontend/private-app/lib/main.dart`
- [ ] Change `home: const AuthCheckPage()` → `home: const DashboardScreen()`
- [ ] Update route for `/` to point to DashboardScreen
- [ ] Save file

**Files modified:** `frontend/private-app/lib/main.dart`

---

## 👁️ Task 1.4: Implement Dashboard Dual-Mode

### Step 1: Update Dashboard Screen

- [ ] Open `frontend/private-app/lib/screens/dashboard_screen.dart`
- [ ] Add auth state detection at top of build method
- [ ] Create `_buildPublicDashboard()` method
- [ ] Create `_buildPublicWelcome()` method
- [ ] Update build method to switch based on auth state
- [ ] Hide FAB when not authenticated
- [ ] Hide ticket banner when not authenticated
- [ ] Show "Join The Chain" CTA when not authenticated
- [ ] Save file

### Step 2: Test Dashboard Rendering

- [ ] Build Flutter web: `cd frontend/private-app && flutter build web --release`
- [ ] Check for build errors
- [ ] Fix any errors
- [ ] Rebuild until successful

**Files modified:** `frontend/private-app/lib/screens/dashboard_screen.dart`

---

## 🛣️ Task 1.5: Update App Routes

- [ ] Open `frontend/private-app/lib/main.dart`
- [ ] Verify `/login` route exists
- [ ] Add `/register` route (if not exists)
- [ ] Make `/dashboard` accessible to all (remove AuthGuard)
- [ ] Make `/` route point to DashboardScreen
- [ ] Keep `/ticket` protected with AuthGuard
- [ ] Keep `/settings` protected with AuthGuard
- [ ] Save file

**Files modified:** `frontend/private-app/lib/main.dart`

---

## 🏗️ Task 1.6: Build & Deploy

### Step 1: Delete Public App

- [ ] Delete entire `frontend/public-app/` directory
- [ ] Verify it's deleted: `ls frontend/`
- [ ] Update `.gitignore` if needed

### Step 2: Rebuild Flutter App

- [ ] Navigate to private-app: `cd frontend/private-app`
- [ ] Clean previous builds: `flutter clean`
- [ ] Get dependencies: `flutter pub get`
- [ ] Build for web: `flutter build web --release`
- [ ] Verify build succeeded (check for errors)

### Step 3: Rebuild Docker Containers

- [ ] Navigate to root: `cd ../..`
- [ ] Stop all services: `docker-compose down`
- [ ] Rebuild private-app: `docker-compose build private-app`
- [ ] Start all services: `docker-compose up -d`
- [ ] Check status: `docker-compose ps`
- [ ] Verify all services healthy

**Directories deleted:** `frontend/public-app/`
**Containers rebuilt:** `chain-private-app`

---

## 🧪 Task 1.7: Testing

### Test 1: Unauthenticated Access

- [ ] Open browser in incognito/private mode
- [ ] Navigate to http://localhost:3001
- [ ] Dashboard loads without redirect to login
- [ ] See chain statistics
- [ ] See "Join The Chain" CTA button
- [ ] See "Sign In" link
- [ ] NO FAB button visible
- [ ] NO ticket banner visible
- [ ] NO settings icon visible

### Test 2: CTA Navigation

- [ ] Click "Join The Chain" button
- [ ] Should navigate to `/register` (or show coming soon)
- [ ] Go back to dashboard
- [ ] Click "Sign In" link
- [ ] Should navigate to `/login`

### Test 3: Authenticated Access

- [ ] Login with test user: `testuser_50@test.com` / `password123`
  - If password fails, use set-password endpoint (see KNOWN_ISSUES.md)
- [ ] After login, should see full dashboard
- [ ] FAB button visible (bottom-right)
- [ ] Ticket banner visible (if has active ticket)
- [ ] Settings icon visible
- [ ] All features working

### Test 4: FAB Navigation

- [ ] Click FAB button
- [ ] Should navigate to `/ticket`
- [ ] Ticket view screen loads
- [ ] See ticket QR code
- [ ] See countdown timer
- [ ] See share buttons
- [ ] Can navigate back to dashboard

### Test 5: Logout & Return

- [ ] Logout (if logout button exists)
- [ ] Should see public dashboard view
- [ ] FAB hidden
- [ ] Ticket banner hidden
- [ ] CTA visible

---

## ✅ Success Criteria

Phase 1 is complete when ALL of these are true:

- [ ] ✅ `frontend/public-app/` directory deleted
- [ ] ✅ `docker-compose.yml` has no `public-app` service
- [ ] ✅ http://localhost:3001 loads without authentication
- [ ] ✅ Unauthenticated users see stats + CTA (no FAB)
- [ ] ✅ Authenticated users see full dashboard (with FAB)
- [ ] ✅ "Join The Chain" navigates to registration (or shows coming soon)
- [ ] ✅ "Sign In" navigates to login
- [ ] ✅ Login works correctly
- [ ] ✅ After login, FAB appears
- [ ] ✅ After login, ticket banner appears (if has active ticket)
- [ ] ✅ No console errors in browser
- [ ] ✅ No broken links
- [ ] ✅ All Docker containers running and healthy

---

## 🐛 Troubleshooting

### Issue: Password login fails
→ See [KNOWN_ISSUES.md](KNOWN_ISSUES.md) #1 - Use `/set-password` endpoint

### Issue: Flutter build fails
```bash
cd frontend/private-app
flutter clean
flutter pub get
flutter build web --release
```

### Issue: Docker container won't start
```bash
docker-compose down
docker-compose build --no-cache private-app
docker-compose up -d
docker logs chain-private-app -f
```

### Issue: Dashboard shows blank page
- Check browser console for errors
- Verify nginx.conf has SPA routing
- Check Flutter build completed successfully

### Issue: Routes not working (404)
- Verify nginx.conf has `try_files $uri $uri/ /index.html`
- Rebuild Docker container after nginx config changes

---

## 📝 Notes

**After completing Phase 1:**
1. Update this checklist with completion date
2. Create a summary of any issues encountered
3. Move on to [NEXT_STEPS_ROADMAP.md](NEXT_STEPS_ROADMAP.md) Phase 2

**If you get stuck:**
1. Re-read the relevant section in NEXT_STEPS_ROADMAP.md
2. Check KNOWN_ISSUES.md for similar problems
3. Look at existing code for examples
4. Test incrementally (don't change everything at once)

---

**Good luck!** 🚀

This phase should take approximately 2-3 hours to complete.
