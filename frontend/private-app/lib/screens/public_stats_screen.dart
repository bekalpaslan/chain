import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/chain_stats.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';

/// Public statistics page showing detailed chain metrics
/// No authentication required - anyone can view these stats
class PublicStatsScreen extends StatefulWidget {
  const PublicStatsScreen({super.key});

  @override
  State<PublicStatsScreen> createState() => _PublicStatsScreenState();
}

class _PublicStatsScreenState extends State<PublicStatsScreen>
    with TickerProviderStateMixin {
  ChainStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _fadeController;
  late AnimationController _orbController;
  late Animation<double> _fadeAnimation;
  final List<_OrbAnimation> _orbs = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOrbs();
    _loadStats();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  void _initializeOrbs() {
    _orbController = AnimationController(
      duration: const Duration(seconds: 25),
      vsync: this,
    )..repeat();

    final random = math.Random();
    for (int i = 0; i < 4; i++) {
      _orbs.add(_OrbAnimation(
        size: 80 + random.nextDouble() * 150,
        left: random.nextDouble(),
        top: random.nextDouble(),
        delay: random.nextDouble() * 5,
      ));
    }
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await ApiClient().getChainStats();
      if (mounted) {
        setState(() {
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Unable to load chain statistics';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: DarkMystiqueTheme.shadowPurple.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DarkMystiqueTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: ShaderMask(
          shaderCallback: (bounds) => DarkMystiqueTheme.mysticGradient.createShader(bounds),
          child: const Text(
            'Chain Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: DarkMystiqueTheme.ghostCyan),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background orbs
          ..._buildFloatingOrbs(size),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(Size screenSize) {
    return _orbs.map((orb) {
      return AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final progress = (_orbController.value + orb.delay / 5) % 1.0;
          final x =
              orb.left * screenSize.width + math.sin(progress * 2 * math.pi) * 40;
          final y =
              orb.top * screenSize.height + math.cos(progress * 2 * math.pi) * 40;

          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: orb.size,
              height: orb.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
                    DarkMystiqueTheme.mysticViolet.withOpacity(0.03),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return _buildStatsContent();
  }

  Widget _buildLoadingState() {
    return Center(
      child: MystiqueLoadingIndicator(
        message: 'Loading statistics...',
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
              Icons.cloud_off,
              size: 64,
              color: DarkMystiqueTheme.errorPulse.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: DarkMystiqueTheme.textPrimary,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            MystiqueButton(
              text: 'Retry',
              onPressed: _loadStats,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Primary stats
          _buildPrimaryStatsSection(),
          const SizedBox(height: 24),

          // Chain health metrics
          _buildChainHealthSection(),
          const SizedBox(height: 24),

          // Recent activity
          _buildRecentActivitySection(),
          const SizedBox(height: 24),

          // Chain info
          _buildChainInfoSection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPrimaryStatsSection() {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Chain Overview', Icons.link),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildLargeStatCard(
                    value: _stats?.totalUsers.toString() ?? '—',
                    label: 'Total Members',
                    icon: Icons.people,
                    color: DarkMystiqueTheme.mysticViolet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLargeStatCard(
                    value: _stats?.activeTickets.toString() ?? '—',
                    label: 'Active Invitations',
                    icon: Icons.confirmation_number,
                    color: DarkMystiqueTheme.ghostCyan,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChainHealthSection() {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Chain Health', Icons.monitor_heart_outlined),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    label: 'Growth Rate',
                    value: _stats != null
                        ? '${(_stats!.averageGrowthRate * 100).toStringAsFixed(1)}%'
                        : '—',
                    icon: Icons.trending_up,
                    color: DarkMystiqueTheme.successGlow,
                    subtitle: 'per day',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    label: 'Waste Rate',
                    value: _stats != null
                        ? '${(_stats!.wasteRate * 100).toStringAsFixed(1)}%'
                        : '—',
                    icon: Icons.warning_amber_outlined,
                    color: DarkMystiqueTheme.warningAura,
                    subtitle: 'expired tickets',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatTile(
                    label: 'Countries',
                    value: _stats?.countries.toString() ?? '—',
                    icon: Icons.public,
                    color: DarkMystiqueTheme.ghostCyan,
                    subtitle: 'worldwide',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatTile(
                    label: 'Wasted',
                    value: _stats?.totalWastedTickets.toString() ?? '—',
                    icon: Icons.delete_outline,
                    color: DarkMystiqueTheme.errorPulse,
                    subtitle: 'total tickets',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final attachments = _stats?.recentAttachments ?? [];

    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Recent Joins', Icons.person_add_outlined),
            const SizedBox(height: 16),
            if (attachments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No recent activity',
                    style: TextStyle(
                      color: DarkMystiqueTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...attachments.take(5).map((attachment) => _buildActivityItem(
                    position: attachment.childPosition,
                    name: attachment.displayName,
                    country: attachment.country,
                    time: _formatTimeAgo(attachment.timestamp),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildChainInfoSection() {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Chain Info', Icons.info_outline),
            const SizedBox(height: 16),
            _buildInfoRow(
              label: 'Chain Started',
              value: _stats != null
                  ? _formatDate(_stats!.chainStartDate)
                  : '—',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              label: 'Last Updated',
              value: _stats != null
                  ? _formatTimeAgo(_stats!.lastUpdate)
                  : '—',
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 18,
                    color: DarkMystiqueTheme.etherealPurple,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This is an invitation-only chain. Members can only join through valid invitation tickets.',
                      style: TextStyle(
                        fontSize: 13,
                        color: DarkMystiqueTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: DarkMystiqueTheme.mysticViolet, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLargeStatCard({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: DarkMystiqueTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: DarkMystiqueTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: DarkMystiqueTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: DarkMystiqueTheme.textMuted,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required int position,
    required String name,
    required String country,
    required String time,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.twilightGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '#$position',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: DarkMystiqueTheme.mysticViolet,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: DarkMystiqueTheme.textPrimary,
                  ),
                ),
                Text(
                  country,
                  style: TextStyle(
                    fontSize: 12,
                    color: DarkMystiqueTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: DarkMystiqueTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: DarkMystiqueTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _OrbAnimation {
  final double size;
  final double left;
  final double top;
  final double delay;

  _OrbAnimation({
    required this.size,
    required this.left,
    required this.top,
    required this.delay,
  });
}
