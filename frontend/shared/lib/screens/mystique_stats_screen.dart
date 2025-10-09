import 'package:flutter/material.dart';
import '../theme/dark_mystique_theme.dart';
import '../widgets/mystique_components.dart';
import '../api/api_client.dart';
import '../models/chain_stats.dart';

/// Dark Mystique Chain Stats Screen
///
/// Features:
/// - Cosmic data visualization
/// - Animated stat cards with glows
/// - Star field background effect
/// - Chain network visualization
class MystiqueStatsScreen extends StatefulWidget {
  const MystiqueStatsScreen({super.key});

  @override
  State<MystiqueStatsScreen> createState() => _MystiqueStatsScreenState();
}

class _MystiqueStatsScreenState extends State<MystiqueStatsScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  ChainStats? _stats;
  bool _loading = true;
  String? _error;
  late AnimationController _starfieldController;

  @override
  void initState() {
    super.initState();
    _starfieldController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    _loadStats();
  }

  @override
  void dispose() {
    _starfieldController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final stats = await _apiClient.getChainStats();

      setState(() {
        _stats = stats;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: DarkMystiqueTheme.voidGradient,
        ),
        child: Stack(
          children: [
            // Animated starfield background
            AnimatedBuilder(
              animation: _starfieldController,
              builder: (context, child) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _StarfieldPainter(
                    animation: _starfieldController.value,
                  ),
                );
              },
            ),
            // Chain link decorations
            Positioned(
              top: 50,
              right: 20,
              child: Opacity(
                opacity: 0.05,
                child: ChainLinkDecoration(
                  size: 180,
                  color: DarkMystiqueTheme.mysticViolet,
                  opacity: 1.0,
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 30,
              child: Opacity(
                opacity: 0.05,
                child: ChainLinkDecoration(
                  size: 200,
                  color: DarkMystiqueTheme.ghostCyan,
                  opacity: 1.0,
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: _loading
                  ? const Center(
                      child: MystiqueLoadingIndicator(
                        message: 'Connecting to The Chain...',
                      ),
                    )
                  : _error != null
                      ? _buildError()
                      : _buildStatsContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 64,
              color: DarkMystiqueTheme.errorPulse,
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Lost',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: DarkMystiqueTheme.textPrimary,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                fontSize: 14,
                color: DarkMystiqueTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            MystiqueButton(
              text: 'RECONNECT',
              onPressed: _loadStats,
              icon: Icons.refresh,
              variant: MystiqueButtonVariant.secondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsContent() {
    if (_stats == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildStatsGrid(),
          const SizedBox(height: 32),
          _buildNetworkVisualization(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Chain icon with mystical glow
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                DarkMystiqueTheme.mysticViolet.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
            boxShadow: DarkMystiqueTheme.purpleGlow,
          ),
          child: const Icon(
            Icons.hub_outlined,
            size: 56,
            color: DarkMystiqueTheme.etherealPurple,
          ),
        ),
        const SizedBox(height: 24),
        // Title
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              DarkMystiqueTheme.etherealPurple,
              DarkMystiqueTheme.astralCyan,
            ],
          ).createShader(bounds),
          child: const Text(
            'THE CHAIN',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              letterSpacing: 10.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Network Statistics',
          style: TextStyle(
            fontSize: 14,
            color: DarkMystiqueTheme.textMuted,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        alignment: WrapAlignment.center,
        children: [
          MystiqueStatCard(
            title: 'TOTAL MEMBERS',
            value: _stats!.totalUsers.toString(),
            icon: Icons.people_outline,
            accentColor: DarkMystiqueTheme.mysticViolet,
            subtitle: 'In the network',
          ),
          MystiqueStatCard(
            title: 'ACTIVE INVITES',
            value: _stats!.activeTickets.toString(),
            icon: Icons.confirmation_number_outlined,
            accentColor: DarkMystiqueTheme.ghostCyan,
            subtitle: 'Pending activation',
          ),
          MystiqueStatCard(
            title: 'EXPIRED TICKETS',
            value: _stats!.totalWastedTickets.toString(),
            icon: Icons.hourglass_empty,
            accentColor: DarkMystiqueTheme.errorPulse,
            subtitle: 'Lost connections',
          ),
          MystiqueStatCard(
            title: 'GLOBAL REACH',
            value: _stats!.countries.toString(),
            icon: Icons.public,
            accentColor: DarkMystiqueTheme.successGlow,
            subtitle: 'Countries',
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkVisualization() {
    return MystiqueCard(
      elevated: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      DarkMystiqueTheme.ghostCyan.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.insights,
                  color: DarkMystiqueTheme.ghostCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Network Health',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                  color: DarkMystiqueTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildNetworkMetric(
            'Active Connection Rate',
            _calculateActiveRate(),
            DarkMystiqueTheme.successGlow,
          ),
          const SizedBox(height: 16),
          _buildNetworkMetric(
            'Invitation Utilization',
            _calculateUtilizationRate(),
            DarkMystiqueTheme.mysticViolet,
          ),
          const SizedBox(height: 16),
          _buildNetworkMetric(
            'Network Density',
            _calculateDensity(),
            DarkMystiqueTheme.ghostCyan,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkMetric(String label, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: DarkMystiqueTheme.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              '${(value * 100).toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.75,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.twilightGray,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, color.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateActiveRate() {
    if (_stats == null) return 0.0;
    final total = _stats!.totalUsers;
    if (total == 0) return 0.0;
    return (_stats!.activeTickets / (total * 3)).clamp(0.0, 1.0);
  }

  double _calculateUtilizationRate() {
    if (_stats == null) return 0.0;
    final totalTickets = _stats!.activeTickets + _stats!.totalWastedTickets;
    if (totalTickets == 0) return 0.0;
    return (_stats!.activeTickets / totalTickets).clamp(0.0, 1.0);
  }

  double _calculateDensity() {
    if (_stats == null) return 0.0;
    if (_stats!.countries == 0) return 0.0;
    return (_stats!.totalUsers / (_stats!.countries * 100)).clamp(0.0, 1.0);
  }
}

/// Custom painter for starfield effect
class _StarfieldPainter extends CustomPainter {
  final double animation;

  _StarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DarkMystiqueTheme.textPrimary.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Generate consistent star positions using seed-based random
    final stars = List.generate(50, (index) {
      final seed = index * 1000;
      final x = ((seed * 17) % 1000) / 1000 * size.width;
      final y = ((seed * 31) % 1000) / 1000 * size.height;
      final starSize = ((seed * 7) % 3) + 1.0;
      final speed = ((seed * 13) % 100) / 100;
      return {'x': x, 'y': y, 'size': starSize, 'speed': speed};
    });

    for (final star in stars) {
      final x = star['x'] as double;
      final y = star['y'] as double;
      final starSize = star['size'] as double;
      final speed = star['speed'] as double;

      // Twinkle effect
      final opacity = (0.3 + 0.7 * ((animation * speed * 10) % 1.0).abs());
      paint.color =
          DarkMystiqueTheme.textPrimary.withValues(alpha: opacity * 0.3);

      canvas.drawCircle(Offset(x, y), starSize, paint);
    }

    // Draw some purple/cyan nebula spots
    final nebulaPoints = [
      {
        'x': size.width * 0.2,
        'y': size.height * 0.3,
        'color': DarkMystiqueTheme.mysticViolet
      },
      {
        'x': size.width * 0.7,
        'y': size.height * 0.6,
        'color': DarkMystiqueTheme.ghostCyan
      },
      {
        'x': size.width * 0.5,
        'y': size.height * 0.8,
        'color': DarkMystiqueTheme.etherealPurple
      },
    ];

    for (final nebula in nebulaPoints) {
      final gradient = RadialGradient(
        colors: [
          (nebula['color'] as Color).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 1.0],
      );

      final rect = Rect.fromCircle(
        center: Offset(nebula['x'] as double, nebula['y'] as double),
        radius: 150,
      );

      paint.shader = gradient.createShader(rect);
      canvas.drawCircle(
        Offset(nebula['x'] as double, nebula['y'] as double),
        150,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarfieldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
