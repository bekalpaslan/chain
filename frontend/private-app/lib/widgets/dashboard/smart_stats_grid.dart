import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';
import 'dart:math' as math;

/// Smart stats grid widget
/// Displays key statistics in an adaptive grid layout
class SmartStatsGrid extends StatefulWidget {
  final DashboardStats stats;
  final Function(String) onStatTap;

  const SmartStatsGrid({
    super.key,
    required this.stats,
    required this.onStatTap,
  });

  @override
  State<SmartStatsGrid> createState() => _SmartStatsGridState();
}

class _SmartStatsGridState extends State<SmartStatsGrid>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationControllers = List.generate(
      6, // Number of stat cards
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 100)),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();

    // Start animations
    for (final controller in _animationControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 400;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_outlined,
                  color: theme.mysticViolet,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Your Stats',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => widget.onStatTap('all'),
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: theme.mysticViolet,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stats grid
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = isCompact ? 2 : 3;
              final aspectRatio = isCompact ? 1.2 : 1.3;

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: AppTheme.spacingM,
                crossAxisSpacing: AppTheme.spacingM,
                childAspectRatio: aspectRatio,
                children: [
                  _buildStatCard(
                    index: 0,
                    icon: Icons.timeline,
                    label: 'Position',
                    value: '#${widget.stats.position}',
                    trend: TrendDirection.up,
                    trendValue: '+5',
                    gradient: [theme.mysticViolet, theme.ghostCyan],
                    onTap: () => widget.onStatTap('position'),
                  ),
                  _buildStatCard(
                    index: 1,
                    icon: Icons.people_outline,
                    label: 'Total Invited',
                    value: '${widget.stats.totalInvited}',
                    subValue: '${widget.stats.activeInvites} active',
                    gradient: [theme.emerald, theme.ghostCyan],
                    onTap: () => widget.onStatTap('invited'),
                  ),
                  _buildStatCard(
                    index: 2,
                    icon: Icons.trending_up,
                    label: 'Success Rate',
                    value: widget.stats.formattedSuccessRate,
                    progress: widget.stats.successRate,
                    gradient: [theme.amber, theme.emerald],
                    onTap: () => widget.onStatTap('success'),
                  ),
                  _buildStatCard(
                    index: 3,
                    icon: Icons.favorite_outline,
                    label: 'Chain Health',
                    value: widget.stats.formattedChainHealth,
                    progress: widget.stats.chainHealth,
                    gradient: [theme.errorRed, theme.mysticViolet],
                    onTap: () => widget.onStatTap('health'),
                  ),
                  _buildStatCard(
                    index: 4,
                    icon: Icons.link,
                    label: 'Chain Length',
                    value: '${widget.stats.totalChainLength}',
                    subValue: 'members',
                    gradient: [theme.ghostCyan, theme.mysticViolet],
                    onTap: () => widget.onStatTap('length'),
                  ),
                  _buildStatCard(
                    index: 5,
                    icon: Icons.timer_off,
                    label: 'Wasted',
                    value: '${widget.stats.wastedTickets}',
                    subValue: 'tickets',
                    gradient: [theme.gray600, theme.gray700],
                    isNegative: true,
                    onTap: () => widget.onStatTap('wasted'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required int index,
    required IconData icon,
    required String label,
    required String value,
    String? subValue,
    double? progress,
    TrendDirection? trend,
    String? trendValue,
    required List<Color> gradient,
    bool isNegative = false,
    required VoidCallback onTap,
  }) {
    return AnimatedBuilder(
      animation: _scaleAnimations[index],
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimations[index].value,
          child: _StatCard(
            icon: icon,
            label: label,
            value: value,
            subValue: subValue,
            progress: progress,
            trend: trend,
            trendValue: trendValue,
            gradient: gradient,
            isNegative: isNegative,
            onTap: onTap,
          ),
        );
      },
    );
  }
}

/// Individual stat card widget
class _StatCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final double? progress;
  final TrendDirection? trend;
  final String? trendValue;
  final List<Color> gradient;
  final bool isNegative;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.progress,
    this.trend,
    this.trendValue,
    required this.gradient,
    this.isNegative = false,
    required this.onTap,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient.map((c) => c.withOpacity(0.1)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
          border: Border.all(
            color: widget.gradient[0].withOpacity(0.3),
            width: 1,
          ),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.gradient[0].withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and trend
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    widget.icon,
                    color: widget.gradient[0],
                    size: 24,
                  ),
                  if (widget.trend != null && widget.trendValue != null)
                    _buildTrend(),
                ],
              ),

              // Value and label
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    textBaseline: TextBaseline.alphabetic,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    children: [
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: widget.isNegative
                              ? Colors.white.withOpacity(0.6)
                              : widget.gradient[0],
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.subValue != null) ...[
                        const SizedBox(width: 4),
                        Text(
                          widget.subValue!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              // Progress bar (if applicable)
              if (widget.progress != null) _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrend() {
    final isUp = widget.trend == TrendDirection.up;
    final color = isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUp ? Icons.arrow_upward : Icons.arrow_downward,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            widget.trendValue!,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widget.progress,
            backgroundColor: Colors.white.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(widget.gradient[0]),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}

enum TrendDirection { up, down }