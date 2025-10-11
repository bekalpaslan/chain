# The Chain - Private App Home Screen Design

## 🎨 Design Overview

The home screen is the primary dashboard for authenticated Chain members, providing immediate access to their position, invitations, and chain statistics.

## 📐 Layout Structure

```
┌─────────────────────────────────────┐
│          Header Section             │
│  ┌─────────────────────────────┐   │
│  │   Welcome & User Avatar     │   │
│  └─────────────────────────────┘   │
├─────────────────────────────────────┤
│       Stats Overview Cards          │
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Chain │ │Active│ │Total │       │
│  │Pos.  │ │Invit.│ │Sent  │       │
│  └──────┘ └──────┘ └──────┘       │
├─────────────────────────────────────┤
│       Quick Actions Section         │
│  ┌────────────┐ ┌────────────┐     │
│  │Generate QR │ │View Chain  │     │
│  └────────────┘ └────────────┘     │
├─────────────────────────────────────┤
│     Chain Visualization             │
│         (Interactive)               │
├─────────────────────────────────────┤
│      Recent Activity Feed           │
└─────────────────────────────────────┘
```

## 🎨 Visual Design Specifications

### Color Palette (Dark Mystique Theme)
- **Background**: `#0A0A0F` (Deep Void)
- **Primary**: `#7C3AED` (Mystic Violet)
- **Secondary**: `#00D4FF` (Ghost Cyan)
- **Surface**: `#111827` (Shadow Dark)
- **Success**: `#10B981` (Emerald)
- **Warning**: `#F59E0B` (Amber)
- **Error**: `#EF4444` (Error Pulse)

### Typography
- **Headlines**: Roboto Bold, 24-28px
- **Subheadings**: Roboto Medium, 18-20px
- **Body**: Roboto Regular, 14-16px
- **Captions**: Roboto Light, 12px

## 📱 Component Specifications

### 1. Header Section
```dart
Container(
  height: 180,
  gradient: LinearGradient(
    colors: [#111827, #0A0A0F],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  ),
  child: Column(
    - Avatar with glow effect (if user in top 100)
    - Welcome message: "Welcome back, {displayName}"
    - Chain Key: "CHAIN{formattedKey}"
    - Last active: "Active 2 hours ago"
  ),
)
```

### 2. Stats Overview Cards
Three animated cards showing key metrics:

#### Card 1: Chain Position
- **Icon**: `Icons.timeline`
- **Value**: `#${user.position}`
- **Label**: "Your Position"
- **Color**: Gradient from violet to cyan
- **Tap Action**: Navigate to full chain view

#### Card 2: Active Invitations
- **Icon**: `Icons.qr_code_2`
- **Value**: `${activeTickets.count}`
- **Label**: "Active Invites"
- **Color**: Green if > 0, gray if 0
- **Tap Action**: Navigate to invitations page

#### Card 3: Total Invites Sent
- **Icon**: `Icons.people_outline`
- **Value**: `${totalInvitesSent}`
- **Label**: "People Invited"
- **Color**: Blue gradient
- **Tap Action**: Show invitation history

### 3. Quick Actions Section
Two primary action buttons with glassmorphism effect:

```dart
GlassmorphicContainer(
  blur: 10,
  opacity: 0.1,
  border: 1,
  borderGradient: LinearGradient([violet, cyan]),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: [
      ActionButton(
        icon: Icons.qr_code_scanner,
        label: "Generate Invitation",
        onTap: () => generateNewTicket(),
      ),
      ActionButton(
        icon: Icons.account_tree,
        label: "View My Chain",
        onTap: () => navigateToChainView(),
      ),
    ],
  ),
)
```

### 4. Chain Visualization (Enhanced)
Interactive chain display with 5 members:

```dart
class EnhancedChainView extends StatefulWidget {
  // Features:
  - Animated entrance (staggered fade-in)
  - Tap to view member details
  - Swipe horizontally to see extended chain
  - Particle effects connecting members
  - Highlight current user with pulse animation
  - Show "ghost" slots for unfilled positions
}
```

#### Member Card Design:
```dart
Container(
  width: 320,
  height: 100,
  decoration: BoxDecoration(
    gradient: isCurrentUser
      ? LinearGradient([violet, cyan])
      : LinearGradient([gray800, gray900]),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isCurrentUser ? cyan : gray700,
      width: isCurrentUser ? 2 : 1,
    ),
    boxShadow: [
      if (isCurrentUser) BoxShadow(
        color: violet.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 5,
      ),
    ],
  ),
  child: Row(
    - CircleAvatar with position number
    - Column with name and chain key
    - Status indicator (active/inactive)
    - Arrow pointing to next member
  ),
)
```

### 5. Recent Activity Feed
Scrollable list of recent chain events:

```dart
ListView.builder(
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  itemBuilder: (context, index) => ActivityTile(
    icon: getActivityIcon(activity.type),
    title: activity.title,
    subtitle: activity.description,
    time: timeago.format(activity.timestamp),
    color: getActivityColor(activity.type),
  ),
)
```

Activity Types:
- **New Member Joined**: "Emma joined through your invitation"
- **Invitation Expired**: "Your invitation to Alex expired"
- **Chain Growth**: "Your chain grew by 5 members today"
- **Milestone**: "You reached position #1000!"

## 🎯 Interactive Features

### 1. Pull-to-Refresh
- Custom animation with chain links forming
- Updates all stats and activity feed
- Haptic feedback on completion

### 2. Floating Action Button
```dart
FloatingActionButton.extended(
  icon: AnimatedIcon(Icons.add_to_queue),
  label: Text("Quick Invite"),
  gradient: LinearGradient([violet, cyan]),
  onPressed: () => showQuickInviteBottomSheet(),
)
```

### 3. Bottom Navigation
```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  backgroundColor: #111827,
  items: [
    BottomNavigationBarItem(
      icon: Icons.home,
      label: "Home",
      activeColor: violet,
    ),
    BottomNavigationBarItem(
      icon: Icons.qr_code,
      label: "Invites",
    ),
    BottomNavigationBarItem(
      icon: Icons.timeline,
      label: "Chain",
    ),
    BottomNavigationBarItem(
      icon: Icons.person,
      label: "Profile",
    ),
  ],
)
```

## 🎭 Animations & Transitions

### Entry Animations
1. **Header**: Fade in with slight scale (0.95 → 1.0)
2. **Stats Cards**: Staggered slide up (50ms delay each)
3. **Chain Members**: Cascade fade-in from top to bottom
4. **Activity Feed**: Slide in from bottom

### Micro-interactions
- **Card Tap**: Scale down to 0.97 with haptic
- **Button Press**: Ripple effect with glow
- **Chain Connection**: Animated particles flowing
- **Position Counter**: Animated number counting

## 📊 Data Requirements

### API Calls on Load
```dart
Future<HomeScreenData> loadHomeData() async {
  final results = await Future.wait([
    apiClient.getUserProfile(),
    apiClient.getActiveTickets(),
    apiClient.getChainMembers(limit: 5),
    apiClient.getRecentActivity(limit: 10),
    apiClient.getChainStats(),
  ]);

  return HomeScreenData(
    user: results[0],
    activeTickets: results[1],
    chainMembers: results[2],
    activities: results[3],
    stats: results[4],
  );
}
```

## 🎨 Responsive Design

### Mobile (< 600px)
- Single column layout
- Stack stats cards vertically
- Simplified chain view (3 members visible)

### Tablet (600-1200px)
- Two column grid for stats
- Extended chain view (7 members)
- Side-by-side quick actions

### Desktop (> 1200px)
- Three column layout
- Full chain visualization
- Sidebar with extended stats

## ♿ Accessibility

### WCAG 2.1 Compliance
- **Color Contrast**: Minimum 4.5:1 for text
- **Touch Targets**: Minimum 44x44 pixels
- **Screen Reader**: Semantic labels for all interactive elements
- **Keyboard Navigation**: Tab order follows visual hierarchy

### Semantic Structure
```dart
Semantics(
  label: "Chain position ${user.position}",
  hint: "Tap to view full chain",
  button: true,
  child: ChainPositionCard(),
)
```

## 🚀 Performance Optimizations

### Image Loading
- Lazy load member avatars
- Use cached network images
- Progressive JPEG for backgrounds

### Data Management
- Cache user profile locally
- Debounce refresh requests
- Paginate activity feed

### Animation Performance
- Use RepaintBoundary for complex widgets
- Limit concurrent animations to 3
- Disable animations on low-end devices

## 📝 Implementation Notes

### State Management
Use Riverpod for:
- User profile state
- Chain members cache
- Activity feed pagination
- Real-time updates via WebSocket

### Error States
Each section should have:
- Loading skeleton
- Error message with retry
- Empty state illustration

### Testing Considerations
- Widget tests for all cards
- Integration tests for data flow
- Golden tests for visual regression
- Performance profiling for animations

## 🎯 Success Metrics

Track these metrics to measure home screen effectiveness:
1. **Time to First Meaningful Paint**: < 1.5s
2. **Invitation Generation Rate**: > 30% daily active users
3. **Chain View Engagement**: > 50% tap through rate
4. **Activity Feed Scroll Depth**: > 60% average
5. **Error Rate**: < 0.1% of page loads

## 🔄 Future Enhancements

### Phase 2 (Next Sprint)
- Real-time chain updates via WebSocket
- Invitation templates
- Chain achievements/badges display
- Social sharing of position

### Phase 3 (Future)
- AR chain visualization
- Voice commands for quick invite
- AI-suggested invitation targets
- Gamification elements (streaks, challenges)