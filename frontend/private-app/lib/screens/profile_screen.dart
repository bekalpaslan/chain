import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/models/user.dart';
import '../providers/dashboard_providers.dart';
import '../models/dashboard_models.dart';

/// Profile screen showing user's chain position and stats
/// Uses Dark Mystique theme with glass morphism effects
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();

    // Load dashboard data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardDataProvider.notifier).loadDashboardData();
    });
  }

  void _initAnimations() {
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: DarkMystiqueTheme.shadowPurple.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DarkMystiqueTheme.etherealPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: DarkMystiqueTheme.etherealPurple),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: dashboardState.when(
        loading: () => const Center(
          child: MystiqueLoadingIndicator(message: 'Loading profile...'),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: DarkMystiqueTheme.errorPulse, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load profile',
                style: TextStyle(color: DarkMystiqueTheme.textSecondary),
              ),
              const SizedBox(height: 16),
              MystiqueButton(
                text: 'Retry',
                onPressed: () => ref.read(dashboardDataProvider.notifier).loadDashboardData(),
                variant: MystiqueButtonVariant.secondary,
              ),
            ],
          ),
        ),
        data: (data) => _buildProfileContent(data),
      ),
    );
  }

  Widget _buildProfileContent(DashboardData data) {
    final user = data.user;
    final stats = data.stats;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Avatar and basic info card
          _buildProfileHeader(user),

          const SizedBox(height: 24),

          // Chain position highlight
          _buildChainPositionCard(stats.position),

          const SizedBox(height: 24),

          // Stats grid
          _buildStatsSection(stats, user),

          const SizedBox(height: 24),

          // Membership status
          _buildMembershipCard(user),

          const SizedBox(height: 24),

          // Achievements preview
          _buildAchievementsPreview(data.achievements),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return MystiqueCard(
      child: Column(
        children: [
          // Avatar with glow
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: DarkMystiqueTheme.mysticGradient,
                  boxShadow: [
                    BoxShadow(
                      color: DarkMystiqueTheme.mysticViolet
                          .withOpacity(_glowAnimation.value),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _getInitials(user.displayName),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Display name
          Text(
            user.displayName,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: DarkMystiqueTheme.textPrimary,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 8),

          // Chain key
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.link,
                  size: 16,
                  color: DarkMystiqueTheme.etherealPurple,
                ),
                const SizedBox(width: 8),
                Text(
                  user.chainKey,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DarkMystiqueTheme.etherealPurple,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Member since
          Text(
            'Member since ${_formatDate(user.createdAt)}',
            style: const TextStyle(
              fontSize: 13,
              color: DarkMystiqueTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChainPositionCard(int position) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DarkMystiqueTheme.ghostCyan.withOpacity(0.2),
                DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: DarkMystiqueTheme.ghostCyan.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: DarkMystiqueTheme.ghostCyan.withOpacity(_glowAnimation.value * 0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.tag,
                    color: DarkMystiqueTheme.ghostCyan,
                    size: 28,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Chain Position',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: DarkMystiqueTheme.textSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [DarkMystiqueTheme.ghostCyan, DarkMystiqueTheme.astralCyan],
                ).createShader(bounds),
                child: Text(
                  '#$position',
                  style: const TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getPositionDescription(position),
                style: const TextStyle(
                  fontSize: 13,
                  color: DarkMystiqueTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(DashboardStats stats, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Statistics', Icons.bar_chart),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.people_outline,
                value: stats.totalInvited.toString(),
                label: 'Invited',
                color: DarkMystiqueTheme.successGlow,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.percent,
                value: stats.formattedSuccessRate,
                label: 'Success Rate',
                color: DarkMystiqueTheme.ghostCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.delete_outline,
                value: user.wastedTicketsCount.toString(),
                label: 'Wasted Tickets',
                color: user.wastedTicketsCount > 0
                    ? DarkMystiqueTheme.warningAura
                    : DarkMystiqueTheme.textMuted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.favorite_outline,
                value: stats.formattedChainHealth,
                label: 'Chain Health',
                color: _getHealthColor(stats.chainHealth),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: DarkMystiqueTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(User user) {
    final status = user.status.toUpperCase();
    final isActive = status == 'ACTIVE';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Membership', Icons.card_membership),
        const SizedBox(height: 12),
        MystiqueCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? DarkMystiqueTheme.successGlow.withOpacity(0.1)
                      : DarkMystiqueTheme.errorPulse.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isActive ? Icons.verified : Icons.cancel_outlined,
                  color: isActive
                      ? DarkMystiqueTheme.successGlow
                      : DarkMystiqueTheme.errorPulse,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive ? 'Active Member' : status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? DarkMystiqueTheme.successGlow
                            : DarkMystiqueTheme.errorPulse,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? 'Your account is in good standing'
                          : 'Contact support for assistance',
                      style: const TextStyle(
                        fontSize: 13,
                        color: DarkMystiqueTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementsPreview(List<Achievement> achievements) {
    final earnedAchievements = achievements.where((a) => a.isEarned).toList();
    final inProgressAchievements =
        achievements.where((a) => a.isInProgress && !a.isEarned).take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionHeader('Achievements', Icons.military_tech),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/achievements'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: DarkMystiqueTheme.etherealPurple,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: DarkMystiqueTheme.etherealPurple,
                    size: 14,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MystiqueCard(
          child: Column(
            children: [
              // Earned count
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: DarkMystiqueTheme.warningAura.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: DarkMystiqueTheme.warningAura,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${earnedAchievements.length} / ${achievements.length}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DarkMystiqueTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Achievements Earned',
                    style: TextStyle(
                      fontSize: 14,
                      color: DarkMystiqueTheme.textSecondary,
                    ),
                  ),
                ],
              ),

              if (inProgressAchievements.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
                ),
                const SizedBox(height: 16),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'In Progress',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: DarkMystiqueTheme.textMuted,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...inProgressAchievements.map((achievement) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildAchievementProgressItem(achievement),
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementProgressItem(Achievement achievement) {
    return Row(
      children: [
        Text(
          achievement.icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                achievement.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DarkMystiqueTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: achievement.progress,
                  backgroundColor: DarkMystiqueTheme.twilightGray,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    achievement.rarity.color,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          achievement.progressPercentage,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: achievement.rarity.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: DarkMystiqueTheme.etherealPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.etherealPurple,
          ),
        ),
      ],
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Edit profile coming soon!'),
        backgroundColor: DarkMystiqueTheme.mysticViolet,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getPositionDescription(int position) {
    if (position == 1) return 'Genesis - The First Link';
    if (position <= 10) return 'Early Adopter';
    if (position <= 100) return 'Pioneer Member';
    if (position <= 1000) return 'Established Member';
    return 'Growing the Chain';
  }

  Color _getHealthColor(double health) {
    if (health >= 0.8) return DarkMystiqueTheme.successGlow;
    if (health >= 0.5) return DarkMystiqueTheme.warningAura;
    return DarkMystiqueTheme.errorPulse;
  }
}
