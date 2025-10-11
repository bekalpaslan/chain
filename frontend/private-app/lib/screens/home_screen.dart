import 'package:flutter/material.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/user.dart';
import 'package:thechain_shared/utils/storage_helper.dart';
import '../widgets/person_card.dart';
import 'login_screen.dart';

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

  /// Generate mock chain data with the current user in the middle (position 3)
  List<ChainMember> _getMockChainData(User currentUser) {
    return [
      // Grandparent (2 levels up)
      ChainMember(
        displayName: 'Sarah Johnson',
        chainKey: 'CHAIN0000001',
        position: currentUser.position - 2,
        status: 'seed',
        isCurrentUser: false,
      ),
      // Parent (1 level up)
      ChainMember(
        displayName: 'Michael Chen',
        chainKey: 'CHAIN0000045',
        position: currentUser.position - 1,
        status: 'active',
        isCurrentUser: false,
      ),
      // Current user (middle - position 3)
      ChainMember(
        displayName: currentUser.displayName,
        chainKey: currentUser.chainKey,
        position: currentUser.position,
        status: currentUser.status,
        isCurrentUser: true,
      ),
      // Child (1 level down)
      ChainMember(
        displayName: 'Emma Rodriguez',
        chainKey: 'CHAIN0000127',
        position: currentUser.position + 1,
        status: 'active',
        isCurrentUser: false,
      ),
      // Grandchild (2 levels down)
      ChainMember(
        displayName: 'James Wilson',
        chainKey: 'CHAIN0000231',
        position: currentUser.position + 2,
        status: 'active',
        isCurrentUser: false,
      ),
    ];
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

  /// Build chain members with connecting arrows
  List<Widget> _buildChainWithArrows() {
    final List<Widget> widgets = [];

    for (int i = 0; i < _chainMembers.length; i++) {
      final member = _chainMembers[i];

      // Add person card
      widgets.add(
        PersonCard(
          displayName: member.displayName,
          chainKey: member.chainKey,
          position: member.position,
          isCurrentUser: member.isCurrentUser,
          status: member.status,
        ),
      );

      // Add arrow between cards (except after the last one)
      if (i < _chainMembers.length - 1) {
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
