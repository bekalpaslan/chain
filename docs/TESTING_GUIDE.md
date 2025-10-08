# The Chain - Complete Testing Guide

## Prerequisites

### 1. Install Flutter
```bash
# Download Flutter SDK from: https://flutter.dev/docs/get-started/install/windows
# Or use winget:
winget install --id=Google.Flutter -e

# Verify installation:
flutter doctor
```

### 2. Start Backend Services
```bash
# Make sure Docker containers are running:
docker-compose ps

# If not running, start them:
docker-compose up -d

# Verify backend health:
curl http://localhost:8080/api/v1/actuator/health
```

## Testing Workflow

### Phase 1: Setup & Initial Run

#### Step 1: Get Flutter Dependencies
```bash
cd mobile
flutter pub get
```

#### Step 2: Check for Connected Devices
```bash
flutter devices
```

**Options:**
- Android Emulator (recommended)
- iOS Simulator (Mac only)
- Chrome (web testing)
- Physical device via USB

#### Step 3: Start Android Emulator (if using)
```bash
# List available emulators
flutter emulators

# Start an emulator
flutter emulators --launch <emulator_id>
```

#### Step 4: Run the App
```bash
# Run in debug mode
flutter run

# Or specify device
flutter run -d <device_id>

# For web
flutter run -d chrome
```

---

### Phase 2: Complete Flow Testing

## Test Case 1: Splash Screen
**Goal:** Verify app initialization

✅ **Expected Behavior:**
- App shows splash screen for ~1 second
- Navigates to scan screen (if not logged in)
- OR navigates to home screen (if logged in)

📝 **Test:**
1. Launch app
2. Observe splash screen
3. Check navigation

---

## Test Case 2: QR Scanning Flow
**Goal:** Test QR code scanning

✅ **Expected Behavior:**
- Camera permission requested
- QR scanner opens
- Can scan QR code
- Navigates to registration

📝 **Test:**
1. Tap "Allow" for camera permission
2. Point camera at QR code
3. Verify navigation to register screen

**Test QR Code:**
Use the ticket we generated earlier or create a new one:
```bash
curl -X POST http://localhost:8080/api/v1/tickets/generate \
  -H "X-User-Id: a0000000-0000-0000-0000-000000000001" \
  | python -m json.tool
```

---

## Test Case 3: User Registration
**Goal:** Test new user registration

✅ **Expected Behavior:**
- Form displays with fields
- Location permission requested
- Can enter username
- Registration succeeds
- Navigates to home screen

📝 **Test:**
1. Enter username: "TestUser"
2. Enable location sharing (optional)
3. Tap "Register"
4. Verify success and navigation

**Expected API Call:**
```json
POST /api/v1/auth/register
{
  "ticketId": "...",
  "ticketSignature": "...",
  "displayName": "TestUser",
  "deviceId": "...",
  "deviceFingerprint": "...",
  "shareLocation": true,
  "latitude": 52.52,
  "longitude": 13.405
}
```

---

## Test Case 4: Home Screen
**Goal:** Verify user dashboard

✅ **Expected Behavior:**
- Shows user's position number
- Displays chain key
- Shows username
- Location displayed (if shared)
- "Generate Invitation" button works
- "View Stats" button works

📝 **Test:**
1. Verify position number matches backend
2. Check username is correct
3. Tap "Generate Invitation" → navigates to ticket screen
4. Tap "View Chain Stats" → navigates to stats screen
5. Pull to refresh → updates data

---

## Test Case 5: Generate Ticket
**Goal:** Test ticket generation

✅ **Expected Behavior:**
- QR code displays
- Shows expiration time
- Countdown timer works
- Can copy link
- Share functionality works

📝 **Test:**
1. Tap "Generate Invitation" from home
2. Verify QR code appears
3. Check expiration countdown
4. Tap "Copy Link" → clipboard contains link
5. Verify ticket status shows "ACTIVE"

---

## Test Case 6: Stats Screen
**Goal:** Verify chain statistics

✅ **Expected Behavior:**
- Total members count displayed
- Active tickets shown
- Countries count
- Usage rate percentage
- Ticket statistics breakdown
- Chain health indicator
- Pull-to-refresh works

📝 **Test:**
1. Navigate to stats screen
2. Verify all cards have animations
3. Check numbers match backend:
   ```bash
   curl http://localhost:8080/api/v1/chain/stats
   ```
4. Pull to refresh
5. Verify data updates

---

## Test Case 7: Profile Screen
**Goal:** Test user profile

✅ **Expected Behavior:**
- Avatar with first letter
- Username displayed
- Position number correct
- Chain key copyable
- Join date shown
- Parent/child info (if exists)
- Ticket activity stats
- Location section (if shared)
- Logout works

📝 **Test:**
1. Navigate to profile
2. Verify all user data correct
3. Tap chain key → copies to clipboard
4. Check ticket activity numbers
5. Tap "Logout" → shows confirmation
6. Confirm logout → returns to splash/scan screen

---

### Phase 3: Backend Integration Testing

## Test Backend Endpoints

### 1. Health Check
```bash
curl http://localhost:8080/api/v1/actuator/health
# Expected: {"status":"UP"}
```

### 2. Chain Stats
```bash
curl http://localhost:8080/api/v1/chain/stats
# Should return full statistics
```

### 3. Ticket Generation
```bash
curl -X POST http://localhost:8080/api/v1/tickets/generate \
  -H "X-User-Id: a0000000-0000-0000-0000-000000000001"
```

### 4. Check Database
```bash
docker exec chain-postgres psql -U chain_user -d chaindb \
  -c "SELECT chain_key, display_name, position FROM users ORDER BY position;"
```

---

### Phase 4: Error Handling Testing

## Test Error Scenarios

### 1. No Internet Connection
📝 **Test:**
- Turn off WiFi
- Try to load stats
- Verify error message displays
- Verify retry button works

### 2. Invalid Ticket
📝 **Test:**
- Use expired ticket
- Verify error message
- App handles gracefully

### 3. Backend Down
📝 **Test:**
```bash
docker-compose stop backend
```
- Try to register
- Verify error handling
```bash
docker-compose start backend
```

---

### Phase 5: UI/UX Testing

## Visual & Animation Testing

✅ **Check:**
- [ ] All animations smooth
- [ ] No lag when scrolling
- [ ] Cards have proper shadows
- [ ] Colors match theme
- [ ] Icons display correctly
- [ ] Text is readable
- [ ] Loading indicators show
- [ ] Error messages clear
- [ ] Buttons have feedback
- [ ] Pull-to-refresh works

---

## Known Issues & Limitations

### Current Limitations:
1. WebSocket not implemented (no real-time updates)
2. Push notifications not implemented
3. Settings menu is placeholder
4. Help & Support is placeholder
5. No offline mode

### Deprecated Warnings:
- `withOpacity` warnings (cosmetic, non-blocking)

---

## Debugging Tips

### View Flutter Logs
```bash
flutter logs
```

### Debug Backend
```bash
docker-compose logs -f backend
```

### Check Database State
```bash
docker exec chain-postgres psql -U chain_user -d chaindb -c "\dt"
```

### Clear App Data
```bash
flutter clean
flutter pub get
```

---

## Success Criteria

✅ **MVP is successful if:**
- [ ] Can scan QR code
- [ ] Can register new user
- [ ] Home screen shows correct data
- [ ] Can generate invitation ticket
- [ ] Stats screen displays chain data
- [ ] Profile shows user information
- [ ] Can logout successfully
- [ ] App handles errors gracefully
- [ ] UI is smooth and responsive
- [ ] Backend integration works

---

## Next Steps After Testing

1. **Document Bugs** - Create GitHub issues
2. **Fix Critical Bugs** - Block release
3. **Improve UX** - Based on testing feedback
4. **Optimize Performance** - If needed
5. **Prepare for Deployment** - Production setup

---

## Quick Test Script

Run this to verify backend is ready:
```bash
#!/bin/bash

echo "🔍 Testing The Chain Backend..."

# Health check
echo "1. Health Check:"
curl -s http://localhost:8080/api/v1/actuator/health | python -m json.tool

# Stats
echo -e "\n2. Chain Stats:"
curl -s http://localhost:8080/api/v1/chain/stats | python -m json.tool

# Database check
echo -e "\n3. Database Users:"
docker exec chain-postgres psql -U chain_user -d chaindb \
  -c "SELECT chain_key, display_name, position FROM users ORDER BY position;"

echo -e "\n✅ Backend is ready for testing!"
```

Save as `test-backend.sh` and run with `bash test-backend.sh`

---

## Contact

For issues or questions about testing:
- Check logs: `docker-compose logs`
- Review API: `http://localhost:8080/api/v1`
- Database: `docker exec -it chain-postgres psql -U chain_user -d chaindb`

Good luck with testing! 🚀
