import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/user.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard/hero_welcome_section.dart';
import '../widgets/dashboard/critical_actions_area.dart';
import '../widgets/dashboard/smart_stats_grid.dart';
import '../widgets/dashboard/interactive_chain_widget.dart';
import '../widgets/dashboard/activity_feed_section.dart';
import '../widgets/dashboard/achievements_section.dart';
import '../providers/dashboard_providers.dart';
import '../theme/app_theme.dart';

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

  // Scroll Controller for custom app bar effects
  late ScrollController _scrollController;
  double _scrollOffset = 0.0;

  // Navigation
  int _selectedIndex = 0;

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
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      });
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
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigation(),
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
            // Custom app bar with parallax effect
            _buildCustomAppBar(data.user),

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

            // Bottom padding for FAB
            const SliverPadding(
              padding: EdgeInsets.only(bottom: 100),
            ),
          ],
        ),

        // Notification badge overlay
        _buildNotificationBadge(data.unreadNotifications),
      ],
    );
  }

  Widget _buildCustomAppBar(User user) {
    final theme = AppTheme.darkMystique;
    final opacity = (1 - (_scrollOffset / 150).clamp(0, 1)).toDouble();
    final scale = (1 - (_scrollOffset / 500).clamp(0, 0.2)).toDouble();

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: theme.shadowDark.withOpacity(0.95),
      elevation: _scrollOffset > 10 ? 8 : 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.mysticViolet.withOpacity(0.2),
                theme.ghostCyan.withOpacity(0.1),
              ],
            ),
          ),
        ),
        title: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.mysticViolet,
                  child: Text(
                    user.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Chain position
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.mysticViolet.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.mysticViolet.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    '#${user.position}',
                    style: TextStyle(
                      color: theme.mysticViolet,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        centerTitle: true,
      ),
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

  Widget? _buildFAB() {
    final theme = AppTheme.darkMystique;
    final hasActiveTicket = ref.watch(dashboardDataProvider).valueOrNull?.hasActiveTicket ?? false;

    return FloatingActionButton.extended(
      onPressed: hasActiveTicket ? _viewActiveTicket : _generateNewTicket,
      backgroundColor: theme.mysticViolet,
      icon: Icon(hasActiveTicket ? Icons.qr_code : Icons.add),
      label: Text(hasActiveTicket ? 'View Ticket' : 'Generate Ticket'),
      elevation: 8,
    );
  }

  Widget _buildBottomNavigation() {
    final theme = AppTheme.darkMystique;

    return BottomAppBar(
      color: theme.shadowDark,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.home, 'Home', 0),
            _buildNavItem(Icons.timeline, 'Chain', 1),
            const SizedBox(width: 80), // Space for FAB
            _buildNavItem(Icons.emoji_events, 'Badges', 2),
            _buildNavItem(Icons.person, 'Profile', 3),
          ],
        ),
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
}