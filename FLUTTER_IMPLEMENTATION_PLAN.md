# 🎨 Flutter Frontend Implementation Plan
## Candidate/Permanent Member System UI Updates

### 📋 Overview
The Flutter app needs updates to display the new membership tier system. This document outlines the specific changes required.

---

## 1️⃣ **Update Shared Models** (30 mins)

### File: `frontend/shared/lib/models/user.dart`

Add new fields to User model:
```dart
class User {
  // ... existing fields ...

  // New fields for membership system
  final String? membershipTier;  // 'candidate' or 'permanent'
  final DateTime? promotedToPermanentAt;
  final int inviteeDepth;
  final bool isPermanent;
  final int? nextTicketDurationHours;

  // Add to constructor
  User({
    // ... existing parameters ...
    this.membershipTier,
    this.promotedToPermanentAt,
    this.inviteeDepth = 0,
    this.isPermanent = false,
    this.nextTicketDurationHours,
  });

  // Helper getters
  bool get isCandidate => membershipTier == 'candidate';
  bool get isPermanentMember => membershipTier == 'permanent';

  String get membershipBadge {
    if (isPermanentMember) return '👑';
    if (isCandidate) return '🎯';
    return '';
  }

  Color get membershipColor {
    if (isPermanentMember) return Colors.amber;
    if (isCandidate) return Colors.blue;
    return Colors.grey;
  }
}
```

---

## 2️⃣ **Update Ticket Models** (20 mins)

### File: `frontend/private-app/lib/models/ticket_models.dart`

Add attempt tracking:
```dart
class TicketData {
  // ... existing fields ...

  // New fields
  final int attemptNumber;      // 1, 2, or 3
  final int durationHours;      // Current ticket duration
  final int strikeCount;        // Number of wasted tickets
  final int? nextAttemptDurationHours;  // Next duration if this fails

  String get attemptDisplay => 'Attempt $attemptNumber/3';

  String get durationDisplay => '${durationHours}h remaining';

  Color get urgencyColor {
    switch (attemptNumber) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.grey;
    }
  }
}
```

---

## 3️⃣ **Update Hero Welcome Section** (45 mins)

### File: `frontend/private-app/lib/widgets/dashboard/hero_welcome_section.dart`

Add membership badge next to name:
```dart
Widget _buildNameWithBadge(User user) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      // Animated name with shimmer
      ShimmerText(user.displayName),

      SizedBox(width: 8),

      // Membership badge
      if (user.membershipTier != null)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: user.membershipColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: user.membershipColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Text(
                user.membershipBadge,
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(width: 4),
              Text(
                user.isPermanentMember ? 'PERMANENT' : 'CANDIDATE',
                style: TextStyle(
                  color: user.membershipColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}

// Add progression indicator for candidates
Widget _buildProgressionIndicator(User user) {
  if (user.isPermanentMember) return SizedBox.shrink();

  return Card(
    color: Colors.blue.withOpacity(0.1),
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Path to Permanent Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: user.inviteeDepth / 2.0,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(Colors.blue),
          ),
          SizedBox(height: 8),
          Text(
            user.inviteeDepth == 0
              ? 'Step 1: Invite someone'
              : user.inviteeDepth == 1
                ? 'Step 2: Your invitee needs to invite someone'
                : 'Promotion achieved!',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    ),
  );
}
```

---

## 4️⃣ **Update Ticket Banner** (45 mins)

### File: `frontend/private-app/lib/widgets/ticket/active_ticket_banner.dart`

Display attempt number and variable duration:
```dart
Widget _buildTicketHeader(TicketData ticket) {
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          ticket.urgencyColor.withOpacity(0.8),
          ticket.urgencyColor.withOpacity(0.3),
        ],
      ),
    ),
    child: Column(
      children: [
        // Attempt indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Chip(
              label: Text(
                ticket.attemptDisplay,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: ticket.urgencyColor,
            ),

            // Strike indicator
            Row(
              children: List.generate(3, (index) {
                return Icon(
                  index < ticket.strikeCount
                    ? Icons.cancel
                    : Icons.radio_button_unchecked,
                  color: index < ticket.strikeCount
                    ? Colors.red
                    : Colors.grey,
                  size: 20,
                );
              }),
            ),
          ],
        ),

        // Time remaining with urgency
        Text(
          ticket.durationDisplay,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Warning for last attempt
        if (ticket.attemptNumber == 3)
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'FINAL ATTEMPT - Use it or lose your spot!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

        // Next duration warning
        if (ticket.nextAttemptDurationHours != null)
          Text(
            'If this expires: Next attempt only ${ticket.nextAttemptDurationHours}h',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
      ],
    ),
  );
}
```

---

## 5️⃣ **Update Chain Member Cards** (30 mins)

### File: `frontend/private-app/lib/widgets/chain_member_card.dart`

Add membership tier indicator:
```dart
Widget _buildMemberCard(ChainMember member) {
  return Card(
    elevation: member.isYou ? 8 : 2,
    color: member.isYou ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
    child: ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            backgroundColor: _getMemberColor(member),
            child: Text(
              member.position.toString(),
              style: TextStyle(color: Colors.white),
            ),
          ),

          // Membership badge overlay
          if (member.membershipTier != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: member.membershipColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    member.membershipBadge,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),

      title: Row(
        children: [
          Text(member.displayName),
          if (member.isYou)
            Container(
              margin: EdgeInsets.only(left: 8),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),

      subtitle: Text(
        '${member.chainKey} • ${member.membershipTier ?? 'Unknown'}',
        style: TextStyle(fontSize: 12),
      ),

      trailing: _buildStatusIndicator(member),
    ),
  );
}
```

---

## 6️⃣ **Add Promotion Celebration** (1 hour)

### File: `frontend/private-app/lib/widgets/dashboard/promotion_celebration.dart` (NEW)

Create celebration overlay:
```dart
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class PromotionCelebration extends StatefulWidget {
  final VoidCallback onComplete;

  @override
  _PromotionCelebrationState createState() => _PromotionCelebrationState();
}

class _PromotionCelebrationState extends State<PromotionCelebration>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    _confettiController.play();
    _animationController.forward();

    Future.delayed(Duration(seconds: 5), widget.onComplete);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        Container(
          color: Colors.black.withOpacity(0.7),
        ),

        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3.14 / 2,
            colors: [Colors.amber, Colors.orange, Colors.yellow],
            gravity: 0.1,
          ),
        ),

        // Celebration message
        Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _animationController,
              curve: Curves.elasticOut,
            ),
            child: Card(
              elevation: 20,
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '👑',
                      style: TextStyle(fontSize: 80),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'CONGRATULATIONS!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You are now a',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'PERMANENT MEMBER',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Your chain is secure!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
```

---

## 7️⃣ **Testing Checklist**

- [ ] User model properly deserializes with new fields
- [ ] Membership badge displays correctly (👑/🎯)
- [ ] Ticket banner shows attempt number (1/3, 2/3, 3/3)
- [ ] Time duration displays correctly (24h, 12h, 6h)
- [ ] Strike indicators work
- [ ] Progression indicator shows for candidates
- [ ] Promotion celebration triggers on status change
- [ ] Chain member cards show membership status
- [ ] Colors and urgency indicators work correctly

---

## 📱 Files to Modify Summary

1. `frontend/shared/lib/models/user.dart` - Add membership fields
2. `frontend/private-app/lib/models/ticket_models.dart` - Add attempt tracking
3. `frontend/private-app/lib/widgets/dashboard/hero_welcome_section.dart` - Add badge
4. `frontend/private-app/lib/widgets/ticket/active_ticket_banner.dart` - Show attempts
5. `frontend/private-app/lib/widgets/chain_member_card.dart` - Show tier
6. `frontend/private-app/lib/widgets/dashboard/promotion_celebration.dart` - NEW file

---

## 🚀 Implementation Order

1. **Start with models** (User and Ticket)
2. **Update hero section** (most visible change)
3. **Update ticket banner** (critical for user awareness)
4. **Add celebration** (reward for achievement)
5. **Update other components** (polish)

**Estimated Total Time: 4-5 hours**

---

## 🎨 Design Tokens

### Colors
- **Permanent Member**: `Colors.amber` (#FFC107)
- **Candidate**: `Colors.blue` (#2196F3)
- **Attempt 1**: `Colors.green` (#4CAF50)
- **Attempt 2**: `Colors.orange` (#FF9800)
- **Attempt 3**: `Colors.red` (#F44336)

### Icons
- **Permanent Badge**: 👑
- **Candidate Badge**: 🎯
- **Strike Icon**: ❌
- **Warning Icon**: ⚠️

---

## 📦 Dependencies to Add

Add to `pubspec.yaml` if not already present:
```yaml
dependencies:
  confetti: ^0.7.0  # For celebration animation
  shimmer: ^3.0.0   # For shimmer effects
```

Run: `flutter pub get`