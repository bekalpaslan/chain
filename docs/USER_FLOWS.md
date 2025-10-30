# User Flows

## Overview

This document outlines the detailed user journeys through The Chain application, covering all primary and edge case scenarios.

---

## Flow 1: First-Time User Registration (via Ticket)

### Preconditions
- User has received a QR code or deep link from existing Chain member
- User has installed the app or visiting web version

### Steps

1. **Receive Invitation**
   - Friend shows QR code or shares deep link
   - User scans QR with device camera OR clicks deep link

2. **Open App**
   - If app not installed: Redirect to App Store/Play Store
   - If app installed: Deep link opens app directly
   - Web version: Opens in browser

3. **Ticket Validation Screen**
   ```
   [Loading spinner]
   "Validating your invitation..."
   ```
   - App sends `GET /tickets/{ticketId}` to validate
   - **Success:** Shows ticket details
   - **Error cases:**
     - Ticket expired: Show error + "This ticket expired. Ask your friend for a new one."
     - Ticket used: Show error + "This ticket was already used."
     - Invalid ticket: Show error + "Invalid invitation link."

4. **Ticket Details Screen** (if valid)
   ```
   "You've been invited by [Alice] (#42 in the chain)"

   [Profile icon]

   "Time remaining: 18h 24m"
   [Progress bar]

   "Join The Chain and become part of a global social experiment"

   [Join Now button]
   [Learn More link]
   ```

5. **Registration Form**
   ```
   "Choose your display name"
   [Text input] (optional, defaults to "Anonymous #[position]")

   "Share your location? (optional)"
   [Toggle: Off by default]
   [Info icon: "We only store your city/country, not exact location"]

   [Terms checkbox] "I agree to Terms of Service"

   [Create My Chain Key button]
   ```

6. **Processing**
   - App sends `POST /auth/register` with ticket data
   - Server validates ticket signature
   - Creates user account
   - Issues Chain Key and JWT tokens

7. **Welcome Screen**
   ```
   "🎉 Welcome to The Chain!"

   "You're now #[position] in the global chain"

   "Your Chain Key: [ABCD1234EFGH]"
   [Copy button]

   "You're connected through [Alice] (#42)"

   [Continue to Home button]
   ```

8. **Home Screen** (first visit)
   - Shows onboarding tutorial overlay
   - Points to "View Ticket" FAB button (floating action button, bottom-right)
   - Shows chain stats
   - **Active ticket banner** displayed at top if user has no child yet

### Postconditions
- User registered and authenticated
- Parent-child relationship established
- **User automatically has an active ticket** (created on registration)

---

## Flow 2: View and Share Active Invitation Ticket

### Preconditions
- User is authenticated
- User has NOT already attached a child (no activeChildId)
- **User automatically has an active ticket** (system auto-creates on registration/expiration)

### Steps

1. **Access Ticket**
   - Tap "View Ticket" FAB button (bottom-right) OR
   - Tap active ticket banner at top of dashboard

2. **Ticket View Screen** (full-screen)
   - App sends `GET /tickets/me/active` (auto-fetches user's active ticket)

3. **Ticket Display Screen**
   ```
   "Your Invitation Ticket"

   [Large QR Code]

   "Expires in: 23h 58m"
   [Countdown timer - updates every second]

   "Share with ONE person"
   [Share button] → Opens system share sheet
   [Copy Link button]
   [Cancel Ticket button] (secondary action)

   "What happens next?"
   - Your friend scans this code
   - They join the chain through you
   - You both become permanently connected
   - Your ticket expires after 24 hours if unused
   ```

4. **Real-time Updates**
   - WebSocket connection monitors ticket status
   - If ticket expires:
     ```
     [Banner notification]
     "Your ticket expired without being used"
     "Strike 1/3"
     "A new ticket has been created automatically"
     [View New Ticket button]
     ```
   - If ticket is claimed:
     ```
     [Full-screen celebration animation]
     "🎉 [Bob] joined through you!"
     "They're now #[position] in the chain"
     [View Their Profile button]
     ```

### Edge Cases

**Already has child:**
```
"You've already attached someone!"
"[Bob] (#43) joined through you on [date]"
[View Chain button]
```

**Active ticket exists:**
```
"You already have an active ticket"
[Shows existing ticket with timer]
[Cancel & Create New button]
```

**Rate limited:**
```
"You recently cancelled a ticket"
"You can generate a new ticket in 8 minutes"
[Timer countdown]
```

---

## Flow 3: Returning User Login

### Preconditions
- User previously registered
- App installed on same device OR user has credentials

### Steps

1. **Open App**
   - App checks for stored refresh token in secure storage

2. **Auto-login**
   - If valid token exists:
     - App sends `POST /auth/refresh`
     - Silently logs in user
     - Shows home screen

3. **Manual login** (if token expired/cleared)
   ```
   "Welcome back to The Chain"

   [Device-based authentication]
   "Tap to continue on this device"
   [Login button]

   [Lost access? link]
   ```
   - App sends `POST /auth/login` with device fingerprint
   - **Success:** Home screen
   - **Error:** Device not recognized → Contact support

### Postconditions
- User authenticated and sees current chain status
- WebSocket reconnects for real-time updates

---

## Flow 4: View Chain Statistics

### Preconditions
- User is authenticated

### Steps

1. **Navigate to Stats Tab**
   - Bottom navigation: [Home] [Invite] [Chain] [Profile]

2. **Global Stats View**
   ```
   "The Chain"

   📊 Total Members: 123,456
   🔗 Active Tickets: 8,901
   ⏰ Wasted Tickets: 4,567 (3.7%)
   🌍 Countries: 89
   📈 Growth Rate: +245/day

   [Last updated: 2 seconds ago]
   ```

3. **Live Feed**
   ```
   "Recent Joins"
   [Scrollable list with real-time updates]

   • Anonymous #123456 (🇺🇸) - just now
   • Bob #123455 (🇩🇪) - 3s ago
   • Alice #123454 (🇬🇧) - 12s ago
   ...
   ```

4. **Geographic Heatmap**
   ```
   [Interactive world map]
   [Hotspots showing concentration of users]

   "Top Countries"
   1. 🇺🇸 United States - 45,678 (37%)
   2. 🇬🇧 United Kingdom - 23,456 (19%)
   3. 🇩🇪 Germany - 12,345 (10%)
   ...
   ```

5. **Explore Chain Tree** (tap to expand)
   ```
   "Chain Tree View"

   #1 The Seeder 🌱
     └─ #2 Alice
         └─ #3 Bob
             └─ #4 Charlie
                 └─ #5 Dave
                     └─ ...

   [Search by position or name]
   [Your position: #42] (highlighted)
   ```

---

## Flow 5: View Personal Chain Lineage

### Preconditions
- User is authenticated

### Steps

1. **Navigate to Profile Tab**

2. **Personal Stats**
   ```
   "Your Chain Profile"

   [Chain Key: ABCD1234EFGH]
   [Copy icon]

   Position: #42
   Joined: Oct 5, 2025
   Days in chain: 3

   🎟️ Total Tickets: 3 (auto-renewed)
   ❌ Wasted Tickets (Strikes): 2/3
   ✅ Successful Invitation: Yes
   ```

3. **Your Lineage**
   ```
   "Your Path"

   🌱 The Seeder (#1)
      ↓
   ... (ancestors)
      ↓
   👤 Alice (#41) ← Your parent
      ↓
   🫵 YOU (#42)
      ↓
   👤 Bob (#43) ← Your child
      ↓
   ... (descendants)
   ```

4. **Tap on any user** → User Detail Modal
   ```
   [Modal popup]

   "Alice"
   Position: #41
   Chain Key: PREV1234KEYS
   Joined: Oct 4, 2025
   Country: 🇺🇸

   Wasted Tickets: 0
   Successful Attachment: ✅

   [View in Chain Tree button]
   ```

---

## Flow 6: Update Profile

### Preconditions
- User is authenticated

### Steps

1. **Navigate to Profile → Settings**

2. **Settings Screen**
   ```
   "Settings"

   Display Name
   [Text input: "Alice"]

   Location Sharing
   [Toggle: On]
   "Share my city with the chain"

   Notifications
   [Toggle: On] New attachments
   [Toggle: On] Ticket expiring
   [Toggle: Off] Chain milestones

   [Save button]
   ```

3. **Save Changes**
   - App sends `PUT /users/me`
   - Shows success toast: "Profile updated"

---

## Flow 7: Ticket Expiration Handling

### Preconditions
- User has active ticket
- 24 hours elapsed since ticket generation

### Automated Flow

1. **Server-side Expiration Job**
   - Cron job checks Redis sorted set `tickets:expiring`
   - Marks ticket as `expired` in database
   - Creates entry in `wasted_tickets` table
   - Publishes WebSocket event

2. **Client Receives Update**
   - WebSocket message: `user.ticket.expired`
   - App shows notification:
     ```
     [Push notification or in-app banner]
     "Your ticket expired without being used"
     ```

3. **If App is Open**
   ```
   [Modal overlay on ticket screen]

   "⏰ Ticket Expired"

   "Your invitation wasn't used within 24 hours."
   "This counts as a wasted ticket (strike)."

   "Strikes: 3/3"
   "You have been removed from the chain"

   [View Chain button]
   ```

4. **Record in History**
   - User's profile shows updated wasted ticket count
   - Visible in chain tree view
   - Included in transparency statistics

---

## Flow 8: Cancel Active Ticket

### Preconditions
- User has active ticket
- Ticket not yet used

### Steps

1. **On Ticket Display Screen**
   - Tap "Cancel Ticket" button (secondary action)

2. **Confirmation Dialog**
   ```
   "Cancel Ticket?"

   "This will count as a wasted ticket (strike 1/3).
   A new ticket will be created automatically."

   [Cancel] [Yes, Cancel Ticket]
   ```

3. **If Confirmed**
   - App sends `DELETE /tickets/my`
   - Ticket marked as `cancelled`
   - Strike counter increments
   - **New ticket automatically created immediately**

4. **New Ticket Screen**
   ```
   "Ticket Cancelled"

   "Strike 1/3"
   "A new ticket has been created"

   [View New Ticket button]
   [View Chain button]
   ```

---

## Flow 9: Error Handling & Edge Cases

### Network Errors

**Offline on Critical Action:**
```
[Banner notification]
"No internet connection"
"Your ticket is saved and will sync when online"
```

**Timeout:**
```
"Taking longer than expected..."
[Retry button]
```

### Abuse Detection

**Multiple Accounts Detected:**
```
"Account Verification Required"

"We detected unusual activity from this device.
Please contact support."

[Contact Support button]
```

**Suspended Account:**
```
"Account Suspended"

"Your account was suspended for violating
our Terms of Service."

[Learn More] [Appeal]
```

### Deleted User View

**Viewing deleted user in chain:**
```
[Position #42]
"[Deleted User]"
Joined: Oct 5, 2025
Status: Left the chain
```

---

## Flow 10: Delete Account

### Preconditions
- User is authenticated

### Steps

1. **Settings → Account → Delete Account**

2. **Warning Screen**
   ```
   "⚠️ Delete Account?"

   "This will:"
   • Remove your display name and data
   • Keep your position in the chain
   • Show as '[Deleted User]' to others
   • Cannot be undone

   "Your parent and child will remain connected."

   [Cancel] [Delete Account]
   ```

3. **Final Confirmation**
   ```
   "Type DELETE to confirm"
   [Text input]

   [Confirm Deletion button]
   ```

4. **Processing**
   - App sends `DELETE /users/me`
   - Account soft-deleted (deleted_at timestamp)
   - Tokens revoked
   - Local data cleared

5. **Completion**
   - App logs out user
   - Shows farewell message
   - Redirects to landing page

---

## Flow 11: First User (The Seeder)

### Special Case: System Admin Creates Seed

This is NOT a user flow, but an administrative action:

1. **Admin runs initialization script**
   ```bash
   ./scripts/init-chain.sh
   ```

2. **Script creates seed user**
   - Inserts first user with position #1
   - Display name: "The Seeder"
   - No parent_id (NULL)
   - **System automatically creates first ticket** for seed user

3. **Admin shares seed ticket**
   - Via official social media channels
   - First person to claim becomes #2

4. **Seed account monitoring**
   - Admin monitors if seed ticket is claimed
   - If not claimed within 24h, **system auto-creates new ticket** (no strike for seed)
   - Process repeats until first attachment succeeds

---

## Flow 12: Search for User in Chain

### Preconditions
- User is authenticated
- On Chain Tree View screen

### Steps

1. **Tap Search Icon**
   ```
   "Search the Chain"
   [Search input: "Search by name, position, or Chain Key"]
   ```

2. **Enter Query**
   - Type position number: "42"
   - Type name: "Alice"
   - Type Chain Key: "ABCD1234"

3. **Results Display**
   ```
   "Results for '42'"

   👤 Alice (#42)
   Chain Key: ABCD1234EFGH
   Joined: Oct 5, 2025

   [View Profile button]
   ```

4. **View in Tree**
   - Chain tree view scrolls to user's position
   - User node highlighted
   - Shows parent and child connections

---

## Navigation Map

```
Landing/Login
    ↓
Home Screen ───────────┬──→ View Active Ticket (FAB) → Share → [Wait for claim]
    │                  │
    ├─→ Stats Tab ─────┼──→ Global Stats
    │                  │
    ├─→ Chain Tab ─────┼──→ Chain Tree View
    │                  │    └──→ Search
    │                  │    └──→ User Detail
    │                  │
    └─→ Profile Tab ───┼──→ Personal Stats
                       │    └──→ Lineage View
                       │    └──→ Settings
                       │         └──→ Update Profile
                       │         └──→ Delete Account
                       │
                       └──→ Notifications
```

---

## Accessibility Considerations

- All interactive elements have accessible labels
- QR codes have alt text and deep link fallback
- Color-blind friendly palette (avoid red/green only indicators)
- Font size respects system settings
- Voice-over compatible navigation
- Keyboard navigation for web version
