import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:the_chain/core/providers/chain_provider.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _loadStats();
    _animationController.forward();
  }

  Future<void> _loadStats() async {
    await ref.read(chainStatsProvider.notifier).loadChainStats();
  }

  Future<void> _refresh() async {
    await ref.read(chainStatsProvider.notifier).refresh();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final chainState = ref.watch(chainStatsProvider);
    final stats = chainState.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chain Statistics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: chainState.isLoading ? null : _refresh,
          ),
        ],
      ),
      body: chainState.isLoading && stats == null
          ? const Center(child: CircularProgressIndicator())
          : chainState.error != null && stats == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${chainState.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStats,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Main Stats Grid
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            childAspectRatio: 1.5,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: [
                              _AnimatedStatCard(
                                icon: Icons.people,
                                title: 'Total Members',
                                value: stats?.totalUsers ?? 0,
                                color: Colors.blue,
                                delay: 100,
                              ),
                              _AnimatedStatCard(
                                icon: Icons.confirmation_number,
                                title: 'Active Tickets',
                                value: stats?.activeTickets ?? 0,
                                color: Colors.green,
                                delay: 200,
                              ),
                              _AnimatedStatCard(
                                icon: Icons.public,
                                title: 'Countries',
                                value: stats?.countriesRepresented ?? 0,
                                color: Colors.purple,
                                delay: 300,
                              ),
                              _AnimatedStatCard(
                                icon: Icons.percent,
                                title: 'Usage Rate',
                                value: ((stats?.ticketUsageRate ?? 0) * 100).round(),
                                suffix: '%',
                                color: Colors.orange,
                                delay: 400,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Ticket Statistics Section
                        Text(
                          'Ticket Statistics',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _TicketStatRow(
                                  label: 'Total Generated',
                                  value: stats?.totalTicketsGenerated ?? 0,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 12),
                                _TicketStatRow(
                                  label: 'Successfully Used',
                                  value: stats?.totalTicketsUsed ?? 0,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _TicketStatRow(
                                  label: 'Expired/Wasted',
                                  value: stats?.totalTicketsExpired ?? 0,
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Chain Health Indicator
                        _ChainHealthCard(
                          usageRate: stats?.ticketUsageRate ?? 0,
                          activeTickets: stats?.activeTickets ?? 0,
                        ),

                        const SizedBox(height: 24),

                        // Fun Facts
                        Card(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.lightbulb,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chain Insights',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (stats != null) ...[
                                  Text('• ${stats.totalUsers} people connected globally'),
                                  const SizedBox(height: 4),
                                  Text('• ${stats.countriesRepresented} countries represented'),
                                  const SizedBox(height: 4),
                                  Text('• ${((stats.ticketUsageRate) * 100).toStringAsFixed(1)}% success rate'),
                                  const SizedBox(height: 4),
                                  if (stats.activeTickets > 0)
                                    Text('• ${stats.activeTickets} invitations waiting to be claimed'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

// Animated Stat Card Widget
class _AnimatedStatCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final int value;
  final String? suffix;
  final Color color;
  final int delay;

  const _AnimatedStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.delay,
    this.suffix,
  });

  @override
  State<_AnimatedStatCard> createState() => _AnimatedStatCardState();
}

class _AnimatedStatCardState extends State<_AnimatedStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatValue(int value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        elevation: 4,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withValues(alpha: 0.1),
                  widget.color.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: widget.color, size: 32),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatValue(widget.value),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: widget.color,
                          ),
                    ),
                    if (widget.suffix != null)
                      Text(
                        widget.suffix!,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: widget.color,
                            ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Ticket Statistics Row
class _TicketStatRow extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _TicketStatRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
        Text(
          formatter.format(value),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

// Chain Health Card
class _ChainHealthCard extends StatelessWidget {
  final double usageRate;
  final int activeTickets;

  const _ChainHealthCard({
    required this.usageRate,
    required this.activeTickets,
  });

  String _getHealthStatus() {
    if (usageRate >= 0.8) return 'Excellent';
    if (usageRate >= 0.6) return 'Good';
    if (usageRate >= 0.4) return 'Fair';
    return 'Needs Attention';
  }

  Color _getHealthColor() {
    if (usageRate >= 0.8) return Colors.green;
    if (usageRate >= 0.6) return Colors.lightGreen;
    if (usageRate >= 0.4) return Colors.orange;
    return Colors.red;
  }

  IconData _getHealthIcon() {
    if (usageRate >= 0.8) return Icons.mood;
    if (usageRate >= 0.6) return Icons.sentiment_satisfied;
    if (usageRate >= 0.4) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  @override
  Widget build(BuildContext context) {
    final healthColor = _getHealthColor();
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              healthColor.withValues(alpha: 0.2),
              healthColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getHealthIcon(), color: healthColor, size: 40),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Chain Health',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      _getHealthStatus(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: healthColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: usageRate,
                minHeight: 12,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(healthColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(usageRate * 100).toStringAsFixed(1)}% tickets successfully used',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}