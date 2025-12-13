import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/models/chain_stats.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/utils/storage_helper.dart';
import '../theme/app_theme.dart';

/// Public landing page for The Chain
/// Displays chain statistics without requiring authentication.
/// Users can log in if they already have an account (invitation-only system).
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen>
    with TickerProviderStateMixin {
  // State
  ChainStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _orbController;
  late Animation<double> _fadeAnimation;
  final List<_OrbAnimation> _orbs = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOrbs();
    _checkExistingSession();
    _loadStats();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    final random = math.Random();
    for (int i = 0; i < 5; i++) {
      _orbs.add(_OrbAnimation(
        size: 100 + random.nextDouble() * 200,
        left: random.nextDouble(),
        top: random.nextDouble(),
        delay: random.nextDouble() * 5,
      ));
    }
  }

  Future<void> _checkExistingSession() async {
    final accessToken = await StorageHelper.getAccessToken();
    final userId = await StorageHelper.getUserId();

    if (accessToken != null && userId != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
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
          _errorMessage = 'Unable to load chain stats';
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
    final theme = AppTheme.darkMystique;

    return Scaffold(
      backgroundColor: theme.deepVoid,
      body: Stack(
        children: [
          // Floating animated orbs (background)
          ..._buildFloatingOrbs(size),

          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const SizedBox(height: 48),
                        _buildStatsCard(),
                        const SizedBox(height: 32),
                        _buildLoginSection(),
                        const SizedBox(height: 24),
                        _buildViewStatsButton(),
                        const SizedBox(height: 32),
                        _buildFooter(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingOrbs(Size screenSize) {
    final theme = AppTheme.darkMystique;

    return _orbs.map((orb) {
      return AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          final progress = (_orbController.value + orb.delay / 5) % 1.0;
          final x =
              orb.left * screenSize.width + math.sin(progress * 2 * math.pi) * 50;
          final y =
              orb.top * screenSize.height + math.cos(progress * 2 * math.pi) * 50;

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
                    theme.mysticViolet.withOpacity(0.15),
                    theme.mysticViolet.withOpacity(0.05),
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

  Widget _buildHeader() {
    final theme = AppTheme.darkMystique;

    return Column(
      children: [
        // Animated logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.mysticViolet,
                theme.mysticViolet.withOpacity(0.7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.mysticViolet.withOpacity(0.5),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.link,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'The Chain',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                color: theme.mysticViolet.withOpacity(0.5),
                blurRadius: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A viral invitation network',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final theme = AppTheme.darkMystique;

    if (_isLoading) {
      return MystiqueCard(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: CircularProgressIndicator(
              color: theme.mysticViolet,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return MystiqueCard(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off,
                size: 48,
                color: theme.errorRed.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _loadStats,
                child: Text(
                  'Retry',
                  style: TextStyle(color: theme.mysticViolet),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Text(
              'Live Chain Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.mysticViolet, theme.ghostCyan],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 28),

            // Stats grid
            Wrap(
              spacing: 24,
              runSpacing: 24,
              alignment: WrapAlignment.center,
              children: [
                _buildStatItem(
                  icon: Icons.people_outline,
                  value: _stats?.totalUsers.toString() ?? '—',
                  label: 'Members',
                  color: theme.mysticViolet,
                ),
                _buildStatItem(
                  icon: Icons.confirmation_number_outlined,
                  value: _stats?.activeTickets.toString() ?? '—',
                  label: 'Active Tickets',
                  color: theme.ghostCyan,
                ),
                _buildStatItem(
                  icon: Icons.public,
                  value: _stats?.countries.toString() ?? '—',
                  label: 'Countries',
                  color: theme.amber,
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value: _stats != null
                      ? '${(_stats!.averageGrowthRate * 100).toStringAsFixed(1)}%'
                      : '—',
                  label: 'Growth Rate',
                  color: theme.emerald,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Last updated
            if (_stats != null)
              Text(
                'Updated ${_formatTimeAgo(_stats!.lastUpdate)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginSection() {
    return Column(
      children: [
        Text(
          'Already a member?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 16),
        MystiqueButton(
          text: 'Sign In',
          onPressed: () => Navigator.pushNamed(context, '/login'),
        ),
      ],
    );
  }

  Widget _buildViewStatsButton() {
    final theme = AppTheme.darkMystique;

    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/stats'),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics_outlined,
            color: theme.ghostCyan,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'View Detailed Statistics',
            style: TextStyle(
              color: theme.ghostCyan,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward,
            color: theme.ghostCyan,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 8),
              Text(
                'Membership by invitation only',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          '© 2025 The Chain. All rights reserved.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.3),
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
