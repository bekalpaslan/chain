import 'package:flutter/material.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/user.dart';
import 'package:thechain_shared/utils/storage_helper.dart';
import '../widgets/chain_member_card.dart';
import '../widgets/chain_ellipsis_link.dart';
import 'login_screen.dart';
import 'dart:math' as math;

/// Home screen showing the user's chain with 5 members displayed vertically
/// with connecting arrows. Uses Dark Mystique theme.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiClient _apiClient = ApiClient();
  User? _currentUser;
  bool _loading = true;
  String? _error;

  // Mock chain data - Replace with real API data later
  List<ChainMember> _chainMembers = [];
  int _totalChainLength = 0;
  int _hiddenMembersAbove = 0;
  int _hiddenMembersBelow = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final profile = await _apiClient.getUserProfile();

      setState(() {
        _currentUser = profile;
        _chainMembers = _getMockChainData(profile);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  /// Generate adaptive chain data: Genesis + 3-member window + TIP
  /// Shows: Position 1 ... Parent-YOU-Child ... Position N
  List<ChainMember> _getMockChainData(User currentUser) {
    // Simulate different chain lengths for testing
    // In production, this would come from the API
    _totalChainLength = 100; // Simulate a chain with 100 members

    // For demo, let's test with user at position 37 as requested
    final userPosition = 37; // currentUser.position;

    List<ChainMember> visibleMembers = [];

    // Always add Genesis (Position 1) if chain has multiple members
    if (_totalChainLength > 1 && userPosition > 1) {
      visibleMembers.add(ChainMember(
        displayName: 'Genesis',
        chainKey: 'CHAIN0000001',
        position: 1,
        status: 'seed',
        isCurrentUser: false,
      ));
    }

    // Calculate if we need ellipsis above
    final parentPosition = math.max(1, userPosition - 1);
    _hiddenMembersAbove = math.max(0, parentPosition - 2); // -2 because we show position 1 separately

    // Add parent (if exists and not already shown as Genesis)
    if (userPosition > 1 && parentPosition != 1) {
      visibleMembers.add(ChainMember(
        displayName: 'Member #$parentPosition',
        chainKey: 'CHAIN${parentPosition.toString().padLeft(7, '0')}',
        position: parentPosition,
        status: 'active',
        isCurrentUser: false,
      ));
    }

    // Add current user
    visibleMembers.add(ChainMember(
      displayName: currentUser.displayName,
      chainKey: currentUser.chainKey,
      position: userPosition,
      status: userPosition == _totalChainLength ? 'tip' : currentUser.status,
      isCurrentUser: true,
    ));

    // Add child (if exists and not the TIP)
    final childPosition = userPosition + 1;
    if (childPosition <= _totalChainLength && childPosition != _totalChainLength) {
      visibleMembers.add(ChainMember(
        displayName: 'Member #$childPosition',
        chainKey: 'CHAIN${childPosition.toString().padLeft(7, '0')}',
        position: childPosition,
        status: 'active',
        isCurrentUser: false,
      ));
    }

    // Calculate if we need ellipsis below
    _hiddenMembersBelow = math.max(0, _totalChainLength - childPosition - 1); // -1 because we show TIP separately

    // Always add the TIP if it's not the user or child
    if (_totalChainLength > userPosition + 1) {
      visibleMembers.add(ChainMember(
        displayName: 'Current TIP',
        chainKey: 'CHAIN${_totalChainLength.toString().padLeft(7, '0')}',
        position: _totalChainLength,
        status: 'tip',
        isCurrentUser: false,
      ));
    }

    // Add ghost slot if user is near the tip
    if (userPosition >= _totalChainLength - 1) {
      visibleMembers.add(ChainMember(
        displayName: 'Waiting for invitation...',
        chainKey: '---',
        position: _totalChainLength + 1,
        status: 'ghost',
        isCurrentUser: false,
      ));
    }

    return visibleMembers;
  }

  /// Calculate which members should be visible in the 5-member window
  Map<String, int> _calculateVisibleWindow(int userPosition, int totalLength) {
    const int WINDOW_SIZE = 5;

    int startPos, endPos;
    int hiddenAbove = 0;
    int hiddenBelow = 0;

    // Special cases for small chains
    if (totalLength <= WINDOW_SIZE) {
      startPos = 1;
      endPos = totalLength;

      // Add ghost slot if chain is small
      if (totalLength < WINDOW_SIZE) {
        endPos = totalLength + 1; // Include ghost position
      }
    } else {
      // Calculate optimal window for larger chains

      // Try to center user (position 3 of 5)
      int idealStart = userPosition - 2;
      int idealEnd = userPosition + 2;

      // Adjust for boundaries
      if (idealStart < 1) {
        // User near beginning
        startPos = 1;
        endPos = WINDOW_SIZE;
      } else if (idealEnd > totalLength) {
        // User near end
        startPos = math.max(1, totalLength - WINDOW_SIZE + 1);
        endPos = totalLength;

        // Include ghost if user is very close to the tip
        if (userPosition >= totalLength - 1) {
          endPos = totalLength + 1; // Show ghost slot
          startPos = math.max(1, endPos - WINDOW_SIZE + 1);
        }
      } else {
        // User in middle - perfect centering
        startPos = idealStart;
        endPos = idealEnd;
      }

      // Calculate hidden members
      hiddenAbove = math.max(0, startPos - 1);
      hiddenBelow = math.max(0, totalLength - endPos);
    }

    return {
      'startPos': startPos,
      'endPos': endPos,
      'hiddenAbove': hiddenAbove,
      'hiddenBelow': hiddenBelow,
    };
  }

  Future<void> _logout() async {
    // Clear stored tokens
    await StorageHelper.clearAuthData();

    // Navigate back to login
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Dark Mystique background
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827).withOpacity(0.8),
        elevation: 0,
        title: const Text(
          'The Chain',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 1.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF1F2937),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    'Are you sure you want to logout?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF7C3AED),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading your chain...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return _buildChainView();
  }

  Widget _buildChainView() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            // Title
            Text(
              'Your Chain',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connected members in your network',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 48),

            // Chain members with arrows
            ..._buildChainWithArrows(),
          ],
        ),
      ),
    );
  }

  /// Build chain members with connecting arrows and ellipsis for hidden sections
  List<Widget> _buildChainWithArrows() {
    final List<Widget> widgets = [];

    // Build visible chain members with ellipsis inserted at the right position
    for (int i = 0; i < _chainMembers.length; i++) {
      final member = _chainMembers[i];

      // Determine the card type based on status and properties
      ChainCardType cardType = _determineCardType(member);

      // Add the unified ChainMemberCard
      widgets.add(
        ChainMemberCard(
          type: cardType,
          displayName: member.displayName,
          chainKey: member.chainKey,
          position: member.position,
          isCurrentUser: member.isCurrentUser,
          pendingTimeRemaining: member.status == 'pending'
              ? const Duration(hours: 23) // Mock countdown
              : null,
          milestoneNumber: _isMilestonePosition(member.position)
              ? member.position
              : null,
          onTap: () {
            _handleCardTap(member);
          },
        ),
      );

      // Add arrow or ellipsis between cards
      if (i < _chainMembers.length - 1) {
        final nextMember = _chainMembers[i + 1];

        // Check if we need ellipsis after Genesis (position 1) and before next member
        if (member.position == 1 && _hiddenMembersAbove > 0) {
          widgets.add(_buildArrow()); // Arrow after Genesis

          final int startOfHidden = 2; // Start after Genesis
          final int endOfHidden = nextMember.position - 1; // End before next member

          widgets.add(
            ChainEllipsisLink(
              memberCount: _hiddenMembersAbove,
              isAbove: true,
              startPosition: startOfHidden,
              endPosition: endOfHidden,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_hiddenMembersAbove members (#$startOfHidden - #$endOfHidden)'),
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                );
              },
            ),
          );
        }
        // Check if we need ellipsis between current member and TIP
        else if (_hiddenMembersBelow > 0 && nextMember.status == 'tip') {
          widgets.add(_buildArrow()); // Arrow after current member

          final int startOfHidden = member.position + 1;
          final int endOfHidden = nextMember.position - 1;

          widgets.add(
            ChainEllipsisLink(
              memberCount: _hiddenMembersBelow,
              isAbove: false,
              startPosition: startOfHidden,
              endPosition: endOfHidden,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$_hiddenMembersBelow members (#$startOfHidden - #$endOfHidden)'),
                    backgroundColor: const Color(0xFF7C3AED),
                  ),
                );
              },
            ),
          );
        }

        widgets.add(_buildArrow());
      }
    }

    return widgets;
  }

  /// Build connecting arrow between cards
  Widget _buildArrow() {
    return Container(
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vertical line
          Container(
            width: 2,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF7C3AED).withOpacity(0.3),
                  const Color(0xFF7C3AED).withOpacity(0.6),
                  const Color(0xFF7C3AED).withOpacity(0.3),
                ],
              ),
            ),
          ),
          // Arrow icon
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: const Color(0xFF7C3AED),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determine the appropriate card type based on member status and properties
  ChainCardType _determineCardType(ChainMember member) {
    // Check for special positions first
    if (member.position == 1 || member.status == 'seed') {
      return ChainCardType.genesis;
    }

    // Check for milestone positions (100, 1000, 10000)
    if (_isMilestonePosition(member.position)) {
      return ChainCardType.milestone;
    }

    // Current user gets special treatment
    if (member.isCurrentUser) {
      return ChainCardType.currentUser;
    }

    // Check status-based types
    switch (member.status) {
      case 'tip':
        return ChainCardType.tip;
      case 'pending':
        return ChainCardType.pending;
      case 'ghost':
        return ChainCardType.ghost;
      case 'wasted':
        return ChainCardType.wasted;
      case 'active':
      default:
        return ChainCardType.active;
    }
  }

  /// Check if a position is a milestone (100, 1000, 10000, etc.)
  bool _isMilestonePosition(int position) {
    return position == 100 ||
           position == 1000 ||
           position == 10000 ||
           position == 100000;
  }

  /// Handle tap events on chain member cards
  void _handleCardTap(ChainMember member) {
    String message;
    Color snackBarColor;

    switch (member.status) {
      case 'tip':
        message = 'This is the chain TIP - they can invite the next member';
        snackBarColor = const Color(0xFF10B981);
        break;
      case 'pending':
        message = 'Invitation pending for position #${member.position}';
        snackBarColor = const Color(0xFFF59E0B);
        break;
      case 'ghost':
        message = 'Waiting for the TIP to send an invitation';
        snackBarColor = const Color(0xFF6B7280);
        break;
      case 'wasted':
        message = 'Invitation expired at position #${member.position}';
        snackBarColor = const Color(0xFFEF4444);
        break;
      case 'seed':
        message = 'Genesis member - the beginning of The Chain';
        snackBarColor = const Color(0xFFFFD700);
        break;
      default:
        if (member.isCurrentUser) {
          message = 'This is you! Position #${member.position} in The Chain';
          snackBarColor = const Color(0xFF7C3AED);
        } else {
          message = 'Member #${member.position} - ${member.displayName}';
          snackBarColor = const Color(0xFF374151);
        }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: snackBarColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Data class for chain members
class ChainMember {
  final String displayName;
  final String chainKey;
  final int position;
  final String status;
  final bool isCurrentUser;

  ChainMember({
    required this.displayName,
    required this.chainKey,
    required this.position,
    required this.status,
    required this.isCurrentUser,
  });
}
