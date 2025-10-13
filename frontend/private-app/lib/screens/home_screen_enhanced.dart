import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/user.dart';
import 'package:thechain_shared/utils/storage_helper.dart';
import 'dart:async';
import 'dart:math' as math;

/// Enhanced Home Screen for The Chain Private App
/// Provides comprehensive dashboard for authenticated users
class HomeScreenEnhanced extends ConsumerStatefulWidget {
  const HomeScreenEnhanced({super.key});

  @override
  ConsumerState<HomeScreenEnhanced> createState() => _HomeScreenEnhancedState();
}

class _HomeScreenEnhancedState extends ConsumerState<HomeScreenEnhanced>
    with TickerProviderStateMixin {
  // API and Data
  final ApiClient _apiClient = ApiClient();
  User? _currentUser;
  List<ChainMember> _chainMembers = [];
  List<Activity> _recentActivities = [];
  final ChainStats _stats = ChainStats.empty();

  // Loading States
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;

  // Animation Controllers
  late AnimationController _headerAnimController;
  late AnimationController _statsAnimController;
  late AnimationController _chainAnimController;
  late AnimationController _pulseAnimController;

  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<double> _headerScaleAnimation;
  late Animation<Offset> _statsSlideAnimation;
  late Animation<double> _chainFadeAnimation;

  // Navigation
  int _selectedIndex = 0;

  // Colors (Dark Mystique Theme)
  static const Color _deepVoid = Color(0xFF0A0A0F);
  static const Color _mysticViolet = Color(0xFF7C3AED);
  static const Color _ghostCyan = Color(0xFF00D4FF);
  static const Color _shadowDark = Color(0xFF111827);
  static const Color _emerald = Color(0xFF10B981);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _errorRed = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadHomeData();
  }

  void _initializeAnimations() {
    // Header animations
    _headerAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.easeOut,
    ));
    _headerScaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimController,
      curve: Curves.elasticOut,
    ));

    // Stats cards animation
    _statsAnimController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _statsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _statsAnimController,
      curve: Curves.easeOutBack,
    ));

    // Chain animation
    _chainAnimController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _chainFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chainAnimController,
      curve: Curves.easeIn,
    ));

    // Pulse animation for current user
    _pulseAnimController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  Future<void> _loadHomeData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Parallel API calls
      final results = await Future.wait([
        _apiClient.getUserProfile(),
        _apiClient.getChainStats(),
        // Add more API calls as implemented
      ]);

      final user = results[0] as User;
      final stats = results[1] as dynamic; // Replace with actual ChainStats

      setState(() {
        _currentUser = user;
        _chainMembers = _generateChainMembers(user);
        _recentActivities = _generateMockActivities();
        _isLoading = false;
      });

      // Start animations
      _headerAnimController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _statsAnimController.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _chainAnimController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await _loadHomeData();

    setState(() => _isRefreshing = false);
    HapticFeedback.lightImpact();
  }

  List<ChainMember> _generateChainMembers(User user) {
    return [
      ChainMember(
        displayName: 'Sarah Johnson',
        chainKey: 'CHAIN0000001',
        position: math.max(1, user.position - 2),
        status: 'active',
        isCurrentUser: false,
      ),
      ChainMember(
        displayName: 'Michael Chen',
        chainKey: 'CHAIN0000045',
        position: math.max(1, user.position - 1),
        status: 'active',
        isCurrentUser: false,
      ),
      ChainMember(
        displayName: user.displayName,
        chainKey: user.chainKey,
        position: user.position,
        status: user.status,
        isCurrentUser: true,
      ),
      ChainMember(
        displayName: 'Emma Rodriguez',
        chainKey: 'CHAIN0000127',
        position: user.position + 1,
        status: 'active',
        isCurrentUser: false,
      ),
      ChainMember(
        displayName: 'Pending...',
        chainKey: '---',
        position: user.position + 2,
        status: 'ghost',
        isCurrentUser: false,
      ),
    ];
  }

  List<Activity> _generateMockActivities() {
    return [
      Activity(
        type: ActivityType.newMember,
        title: 'New Member Joined',
        description: 'Emma joined through your invitation',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Activity(
        type: ActivityType.inviteExpired,
        title: 'Invitation Expired',
        description: 'Your invitation to Alex expired',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      Activity(
        type: ActivityType.chainGrowth,
        title: 'Chain Growth',
        description: 'Your chain grew by 5 members today',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Activity(
        type: ActivityType.milestone,
        title: 'Milestone Reached!',
        description: 'You reached position #1000!',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  void dispose() {
    _headerAnimController.dispose();
    _statsAnimController.dispose();
    _chainAnimController.dispose();
    _pulseAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _deepVoid,
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
              ? _buildErrorState()
              : _buildMainContent(),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: _mysticViolet,
            strokeWidth: 2,
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your chain...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: _errorRed.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadHomeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _mysticViolet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: _mysticViolet,
      backgroundColor: _shadowDark,
      child: CustomScrollView(
        slivers: [
          _buildHeader(),
          _buildStatsSection(),
          _buildQuickActions(),
          _buildChainVisualization(),
          _buildActivityFeed(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _headerAnimController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _headerFadeAnimation,
            child: ScaleTransition(
              scale: _headerScaleAnimation,
              child: Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_shadowDark, _deepVoid],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildAvatar(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _currentUser?.displayName ?? 'User',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.notifications_outlined),
                              color: Colors.white,
                              onPressed: () {
                                // Navigate to notifications
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _buildChainKeyChip(),
                            const Spacer(),
                            Text(
                              'Active 2 hours ago',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatar() {
    final isTopUser = (_currentUser?.position ?? 999999) <= 100;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isTopUser
            ? const LinearGradient(
                colors: [_mysticViolet, _ghostCyan],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        boxShadow: isTopUser
            ? [
                BoxShadow(
                  color: _mysticViolet.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ]
            : null,
      ),
      child: CircleAvatar(
        radius: 30,
        backgroundColor: _shadowDark,
        child: Text(
          _currentUser?.displayName.substring(0, 1).toUpperCase() ?? 'U',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChainKeyChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _mysticViolet.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _mysticViolet.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.link,
            size: 16,
            color: _mysticViolet,
          ),
          const SizedBox(width: 6),
          Text(
            _currentUser?.chainKey ?? 'CHAIN000000',
            style: const TextStyle(
              color: _mysticViolet,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _statsAnimController,
        builder: (context, child) {
          return SlideTransition(
            position: _statsSlideAnimation,
            child: FadeTransition(
              opacity: _statsAnimController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Stats',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.timeline,
                            value: '#${_currentUser?.position ?? 0}',
                            label: 'Chain Position',
                            gradient: const [_mysticViolet, _ghostCyan],
                            delay: 0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.qr_code_2,
                            value: '3',
                            label: 'Active Invites',
                            gradient: const [_emerald, _ghostCyan],
                            delay: 100,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.people,
                            value: '12',
                            label: 'Total Invited',
                            gradient: const [_amber, _errorRed],
                            delay: 200,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required List<Color> gradient,
    required int delay,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient.map((c) => c.withOpacity(0.1)).toList(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: gradient[0].withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: gradient[0], size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: gradient[0],
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.qr_code_scanner,
                label: 'Generate Invite',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Generate new invitation
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.account_tree,
                label: 'View Chain',
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Navigate to chain view
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _shadowDark.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _mysticViolet.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: _mysticViolet, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainVisualization() {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _chainAnimController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _chainFadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Chain',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ..._buildChainMembers(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildChainMembers() {
    final List<Widget> widgets = [];
    for (int i = 0; i < _chainMembers.length; i++) {
      final member = _chainMembers[i];
      final delay = i * 100.0;

      widgets.add(
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 600 + delay.toInt()),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: _buildChainMemberCard(member),
              ),
            );
          },
        ),
      );

      if (i < _chainMembers.length - 1) {
        widgets.add(_buildChainConnector(member.isCurrentUser));
      }
    }
    return widgets;
  }

  Widget _buildChainMemberCard(ChainMember member) {
    final isGhost = member.status == 'ghost';
    final isCurrent = member.isCurrentUser;

    return AnimatedBuilder(
      animation: isCurrent ? _pulseAnimController : const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        final pulseValue = isCurrent
            ? math.sin(_pulseAnimController.value * math.pi) * 0.1 + 1.0
            : 1.0;

        return Transform.scale(
          scale: pulseValue,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCurrent
                    ? [_mysticViolet, _ghostCyan]
                    : isGhost
                        ? [Colors.grey.withOpacity(0.2), Colors.grey.withOpacity(0.1)]
                        : [_shadowDark, _deepVoid],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isCurrent
                    ? _ghostCyan
                    : isGhost
                        ? Colors.grey.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                width: isCurrent ? 2 : 1,
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: _mysticViolet.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isCurrent
                      ? Colors.white
                      : isGhost
                          ? Colors.grey.withOpacity(0.3)
                          : _mysticViolet.withOpacity(0.2),
                  child: Text(
                    isGhost ? '?' : '#${member.position}',
                    style: TextStyle(
                      color: isCurrent
                          ? _mysticViolet
                          : isGhost
                              ? Colors.grey
                              : _mysticViolet,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.displayName,
                        style: TextStyle(
                          color: isGhost ? Colors.grey : Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        member.chainKey,
                        style: TextStyle(
                          color: isGhost
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'YOU',
                      style: TextStyle(
                        color: _mysticViolet,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildChainConnector(bool fromCurrentUser) {
    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 2,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: fromCurrentUser
                    ? [_mysticViolet, _ghostCyan.withOpacity(0.3)]
                    : [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
              ),
            ),
          ),
          Icon(
            Icons.arrow_downward,
            size: 16,
            color: fromCurrentUser ? _mysticViolet : Colors.white.withOpacity(0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityFeed() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._recentActivities.map((activity) => _buildActivityTile(activity)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile(Activity activity) {
    final icon = _getActivityIcon(activity.type);
    final color = _getActivityColor(activity.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  activity.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _getTimeAgo(activity.timestamp),
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.newMember:
        return Icons.person_add;
      case ActivityType.inviteExpired:
        return Icons.timer_off;
      case ActivityType.chainGrowth:
        return Icons.trending_up;
      case ActivityType.milestone:
        return Icons.emoji_events;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.newMember:
        return _emerald;
      case ActivityType.inviteExpired:
        return _errorRed;
      case ActivityType.chainGrowth:
        return _ghostCyan;
      case ActivityType.milestone:
        return _amber;
    }
  }

  String _getTimeAgo(DateTime timestamp) {
    final difference = DateTime.now().difference(timestamp);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  Widget? _buildFAB() {
    if (_isLoading || _error != null) return null;

    return FloatingActionButton.extended(
      onPressed: () {
        HapticFeedback.mediumImpact();
        // Show quick invite bottom sheet
      },
      backgroundColor: _mysticViolet,
      icon: const Icon(Icons.add),
      label: const Text('Quick Invite'),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: _shadowDark,
      selectedItemColor: _mysticViolet,
      unselectedItemColor: Colors.white.withOpacity(0.5),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.qr_code),
          label: 'Invites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'Chain',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}

// Data Models
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

class ChainStats {
  final int totalUsers;
  final int activeTickets;
  final int totalInvited;

  ChainStats({
    required this.totalUsers,
    required this.activeTickets,
    required this.totalInvited,
  });

  factory ChainStats.empty() => ChainStats(
        totalUsers: 0,
        activeTickets: 0,
        totalInvited: 0,
      );
}

enum ActivityType {
  newMember,
  inviteExpired,
  chainGrowth,
  milestone,
}

class Activity {
  final ActivityType type;
  final String title;
  final String description;
  final DateTime timestamp;

  Activity({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}