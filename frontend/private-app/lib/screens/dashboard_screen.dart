import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/models/user.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard/hero_welcome_section.dart';
import '../widgets/dashboard/critical_actions_area.dart';
import '../widgets/dashboard/smart_stats_grid.dart';
import '../widgets/dashboard/interactive_chain_widget.dart';
import '../widgets/dashboard/activity_feed_section.dart';
import '../widgets/dashboard/achievements_section.dart';
import '../widgets/dashboard/seed_node_widget.dart';
import '../widgets/dashboard/child_candidate_node_widget.dart';
import '../widgets/dashboard/paginated_chain_widget.dart';
import '../widgets/dashboard/system_notification_panel.dart';
import '../widgets/dashboard/notification_popup_bar.dart';
import '../widgets/bottom_panel/chain_stats_panel.dart';
import '../widgets/bottom_panel/map_button_panel.dart';
import '../widgets/bottom_panel/activity_button_panel.dart';
import '../providers/dashboard_providers.dart';
import '../theme/app_theme.dart';
import 'package:thechain_shared/utils/storage_helper.dart';

/// Unified Dashboard Screen for The Chain Private App
/// Central hub for all user interactions and information
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _fadeInController;
  late AnimationController _slideUpController;

  // Scroll Controller
  late ScrollController _scrollController;

  // Navigation
  int _selectedIndex = 0;

  // Chain drag offset
  double _chainVerticalOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeScrollController();

    // Load dashboard data
    Future.microtask(() {
      ref.read(dashboardDataProvider.notifier).loadDashboardData();
    });
  }

  void _initializeAnimations() {
    _fadeInController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _slideUpController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  void _initializeScrollController() {
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _fadeInController.dispose();
    _slideUpController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardDataProvider);
    final theme = AppTheme.darkMystique;

    return Scaffold(
      backgroundColor: theme.deepVoid,
      body: dashboardState.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
        data: (data) => _buildDashboard(data),
      ),
      bottomNavigationBar: dashboardState.valueOrNull != null
          ? _buildBottomPanel(dashboardState.value!)
          : null,
    );
  }

  Widget _buildDashboard(DashboardData data) {
    return Stack(
      children: [
        // Background gradient
        _buildBackgroundGradient(),

        // Main content
        CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ====================================================================
            // CONTENT AREA - Building from scratch
            // ====================================================================

            // Notification popup bar at the very top
            SliverToBoxAdapter(
              child: NotificationPopupBar(
                notifications: _getSampleNotifications(),
                onDismiss: () {
                  // Handle notification dismissal if needed
                },
              ),
            ),

            // Small padding after notification bar
            const SliverPadding(
              padding: EdgeInsets.only(top: 12),
            ),

            // Chain visualization - shows all visible chain members (draggable)
            SliverToBoxAdapter(
              child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _chainVerticalOffset += details.delta.dy;
                    // Clamp the offset to reasonable bounds
                    _chainVerticalOffset = _chainVerticalOffset.clamp(-200.0, 200.0);
                  });
                },
                onVerticalDragEnd: (details) {
                  // Animate back to center if dragged too far
                  if (_chainVerticalOffset.abs() > 150) {
                    setState(() {
                      _chainVerticalOffset = 0.0;
                    });
                  }
                },
                child: Transform.translate(
                  offset: Offset(0, _chainVerticalOffset),
                  child: AnimatedContainer(
                    duration: _chainVerticalOffset == 0.0
                        ? const Duration(milliseconds: 300)
                        : Duration.zero,
                    curve: Curves.easeOutCubic,
                    height: 500, // Fixed height for the chain visualization
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Stack(
                      children: [
                        // Drag indicator when dragging
                        if (_chainVerticalOffset != 0)
                          Positioned(
                            top: 10,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.darkMystique.shadowDark.withOpacity(0.8),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppTheme.darkMystique.gold.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _chainVerticalOffset > 0 ? '↓ Dragging Down ↓' : '↑ Dragging Up ↑',
                                  style: TextStyle(
                                    color: AppTheme.darkMystique.gold,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        // The smart paginated chain visualization
                        PaginatedChainWidget(
                          initialMembers: data.chainMembers, // Pass all members from backend (now returns 50 for admin)
                          onLoadMore: (offset, limit) async {
                            // Load more members using the provider
                            final notifier = ref.read(dashboardDataProvider.notifier);
                            return notifier.loadMoreChainMembers(offset, limit);
                          },
                          onGenerateTicket: _generateNewTicket,
                          bufferSize: 10, // Buffer 10 items above and below viewport
                          pageSize: 20, // Load 20 items at a time
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // COMMENTED OUT - Will rebuild component by component
            /*
            // Hero welcome section
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeInController,
                child: HeroWelcomeSection(
                  user: data.user,
                  lastActivity: data.lastActivity,
                ),
              ),
            ),

            // Critical actions (if any)
            if (data.criticalActions.isNotEmpty)
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideUpController,
                    curve: Curves.easeOutBack,
                  )),
                  child: CriticalActionsArea(
                    actions: data.criticalActions,
                  ),
                ),
              ),

            // Stats grid
            SliverToBoxAdapter(
              child: SmartStatsGrid(
                stats: data.stats,
                onStatTap: _handleStatTap,
              ),
            ),

            // Interactive chain visualization
            SliverToBoxAdapter(
              child: InteractiveChainWidget(
                members: data.chainMembers,
                currentUserPosition: data.user.position,
                onMemberTap: _handleMemberTap,
              ),
            ),

            // Activity feed
            SliverToBoxAdapter(
              child: ActivityFeedSection(
                activities: data.recentActivities,
                onLoadMore: _loadMoreActivities,
              ),
            ),

            // Achievements section
            if (data.achievements.isNotEmpty)
              SliverToBoxAdapter(
                child: AchievementsSection(
                  achievements: data.achievements,
                  progress: data.achievementProgress,
                ),
              ),
            */

            // Bottom padding
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 24),
            ),
          ],
        ),

        // Notification badge overlay
        _buildNotificationBadge(data.unreadNotifications),

        // Floating logout button in bottom-left corner
        Positioned(
          bottom: 24,
          left: 24,
          child: _buildFloatingLogoutButton(),
        ),
      ],
    );
  }

  Widget _buildCustomAppBar(User user) {
    final theme = AppTheme.darkMystique;

    return SliverAppBar(
      toolbarHeight: 70, // Fixed smaller height
      floating: false,
      pinned: true,
      backgroundColor: theme.shadowDark.withOpacity(0.95),
      elevation: 4,
      leadingWidth: 70, // Space for avatar with equal margins
      leading: Padding(
        padding: const EdgeInsets.all(12.0), // Equal margin on three edges
        child: CircleAvatar(
          backgroundColor: theme.mysticViolet,
          child: Text(
            user.displayName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      // Position in the center
      title: Text(
        '#${user.position}',
        style: TextStyle(
          color: theme.amber, // Yellow color
          fontSize: 24, // Bigger size
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        // Notifications
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined),
              if ((ref.watch(dashboardDataProvider).valueOrNull?.unreadNotifications ?? 0) > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${ref.watch(dashboardDataProvider).valueOrNull?.unreadNotifications}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          onPressed: _openNotifications,
        ),
        // Settings
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: _openSettings,
        ),
      ],
    );
  }

  Widget _buildBackgroundGradient() {
    final theme = AppTheme.darkMystique;
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.5, -0.5),
          radius: 1.5,
          colors: [
            theme.mysticViolet.withOpacity(0.05),
            theme.deepVoid,
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = AppTheme.darkMystique;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.mysticViolet,
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

  Widget _buildErrorState(String error) {
    final theme = AppTheme.darkMystique;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.errorRed.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(dashboardDataProvider.notifier).loadDashboardData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.mysticViolet,
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


  Widget _buildBottomPanel(DashboardData data) {
    final theme = AppTheme.darkMystique;

    return Container(
      height: 120, // Match seed node height
      padding: const EdgeInsets.all(4), // Minimal gap around components
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: theme.gray700.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Left: Chain length statistics (unclickable)
          Expanded(
            flex: 1,
            child: ChainStatsPanel(
              chainLength: data.stats.totalChainLength,
            ),
          ),
          const SizedBox(width: 4), // Minimal gap between components

          // Center: Map button
          Expanded(
            flex: 1,
            child: MapButtonPanel(
              onTap: _showMapPopup,
            ),
          ),
          const SizedBox(width: 4), // Minimal gap between components

          // Right: Activity button
          Expanded(
            flex: 1,
            child: ActivityButtonPanel(
              onTap: _showActivityPopup,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final theme = AppTheme.darkMystique;
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedIndex = index);
        _handleNavigation(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.mysticViolet : Colors.white.withOpacity(0.5),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.mysticViolet : Colors.white.withOpacity(0.5),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationBadge(int count) {
    if (count == 0) return const SizedBox.shrink();

    return Positioned(
      top: 100,
      right: 16,
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            '$count new',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // Navigation handlers
  void _handleNavigation(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        // Navigate to chain view
        Navigator.pushNamed(context, '/chain');
        break;
      case 2:
        // Navigate to achievements
        Navigator.pushNamed(context, '/achievements');
        break;
      case 3:
        // Navigate to profile
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  void _handleStatTap(String statType) {
    // Handle stat tap - show detailed view
    HapticFeedback.lightImpact();
    // Implementation depends on stat type
  }

  void _handleMemberTap(ChainMember member) {
    // Show member detail sheet
    HapticFeedback.lightImpact();
    // Show bottom sheet with member details
  }

  void _loadMoreActivities() {
    // Load more activities
    ref.read(dashboardDataProvider.notifier).loadMoreActivities();
  }

  void _openNotifications() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/notifications');
  }

  void _openSettings() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/settings');
  }

  void _generateNewTicket() {
    HapticFeedback.mediumImpact();
    Navigator.pushNamed(context, '/generate-ticket');
  }

  void _viewActiveTicket() {
    HapticFeedback.lightImpact();
    Navigator.pushNamed(context, '/active-ticket');
  }

  void _showMapPopup() {
    HapticFeedback.lightImpact();
    final theme = AppTheme.darkMystique;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Map',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(bottom: 120),
              decoration: BoxDecoration(
                color: theme.deepVoid.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: theme.mysticViolet.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: theme.mysticViolet,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Chain Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.gray600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.gray700.withOpacity(0.3), height: 1),

                  // Content
                  Expanded(
                    child: Center(
                      child: Text(
                        'Map visualization coming soon...',
                        style: TextStyle(
                          color: theme.gray600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActivityPopup() {
    HapticFeedback.lightImpact();
    final theme = AppTheme.darkMystique;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Activity',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              width: MediaQuery.of(context).size.width * 0.8,
              margin: const EdgeInsets.only(bottom: 120),
              decoration: BoxDecoration(
                color: theme.deepVoid.withOpacity(0.9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border.all(
                  color: theme.mysticViolet.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Icon(
                          Icons.history,
                          color: theme.mysticViolet,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close, color: theme.gray600),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: theme.gray700.withOpacity(0.3), height: 1),

                  // Content
                  Expanded(
                    child: Center(
                      child: Text(
                        'Activity feed coming soon...',
                        style: TextStyle(
                          color: theme.gray600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout() async {
    HapticFeedback.mediumImpact();

    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = AppTheme.darkMystique;
        return AlertDialog(
          backgroundColor: theme.shadowDark,
          title: Text(
            'Logout',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: theme.gray400),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Logout',
                style: TextStyle(color: theme.errorRed),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      // Clear all stored tokens and data
      await StorageHelper.clearAuthData();

      // Navigate back to login and clear navigation stack
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      }
    }
  }

  List<SystemNotification> _getSampleNotifications() {
    // Sample notifications for demonstration
    // In production, these would come from the backend
    return [
      SystemNotification(
        id: '1',
        title: 'Chain Rule Update',
        message: 'New cooldown period reduced to 8 minutes. Effective immediately.',
        type: 'rule_change',
        priority: NotificationPriority.critical,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      SystemNotification(
        id: '2',
        title: 'System Maintenance',
        message: 'Scheduled maintenance on Sunday 2 AM - 4 AM EST',
        type: 'maintenance',
        priority: NotificationPriority.high,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      SystemNotification(
        id: '3',
        title: 'New Achievement Unlocked',
        message: 'Chain reached 100 members! All participants receive bonus points.',
        type: 'chain_update',
        priority: NotificationPriority.medium,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];
  }

  Widget _buildFloatingLogoutButton() {
    final theme = AppTheme.darkMystique;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.shadowDark,
              theme.shadowDark.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.errorRed.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: _handleLogout,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout,
                  color: theme.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'LOGOUT',
                  style: TextStyle(
                    color: theme.errorRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}