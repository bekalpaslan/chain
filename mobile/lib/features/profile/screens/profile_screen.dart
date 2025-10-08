import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:the_chain/core/providers/auth_provider.dart';
import 'package:the_chain/core/providers/chain_provider.dart';
import 'package:the_chain/core/providers/ticket_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeController.forward();
    _slideController.forward();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Load user's chain info if needed
    await ref.read(chainStatsProvider.notifier).loadMyChainInfo();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _copyChainKey(String chainKey) async {
    await Clipboard.setData(ClipboardData(text: chainKey));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chain key copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout? You\'ll need your device to log back in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await ref.read(authProvider.notifier).logout();
      context.go('/');
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final chainState = ref.watch(chainStatsProvider);
    final ticketState = ref.watch(ticketProvider);

    final user = authState.user;
    final myChainInfo = chainState.myChainInfo;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: const Center(
          child: Text('Not logged in'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserData,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Card
              _ProfileCard(
                user: user,
                myChainInfo: myChainInfo,
                onCopyChainKey: () => _copyChainKey(user.chainKey),
              ),

              const SizedBox(height: 24),

              // Chain Statistics
              _ChainStatsSection(
                user: user,
                myChainInfo: myChainInfo,
              ),

              const SizedBox(height: 24),

              // Ticket History
              _TicketHistorySection(
                ticketState: ticketState,
                onGenerateTicket: () => context.push('/generate-ticket'),
              ),

              const SizedBox(height: 24),

              // Location Section
              if (user.locationCity != null || user.locationCountry != null) ...[
                _LocationSection(user: user),
                const SizedBox(height: 24),
              ],

              // Actions
              _ActionsSection(
                onSettings: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings coming soon!')),
                  );
                },
                onLogout: _showLogoutDialog,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// Profile Card Widget
class _ProfileCard extends StatelessWidget {
  final dynamic user;
  final dynamic myChainInfo;
  final VoidCallback onCopyChainKey;

  const _ProfileCard({
    required this.user,
    this.myChainInfo,
    required this.onCopyChainKey,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.2),
              Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ],
          ),
        ),
        child: Column(
          children: [
            Hero(
              tag: 'profile_avatar',
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  (user.username ?? 'A')[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.username ?? 'Anonymous',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Position #${user.chainPosition}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: onCopyChainKey,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.key,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.chainKey,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.copy,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Chain Statistics Section
class _ChainStatsSection extends StatelessWidget {
  final dynamic user;
  final dynamic myChainInfo;

  const _ChainStatsSection({
    required this.user,
    this.myChainInfo,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _getTimeSinceJoining(DateTime joinDate) {
    final now = DateTime.now();
    final difference = now.difference(joinDate);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} in chain';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} in chain';
    } else {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} in chain';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chain Information',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _StatTile(
                icon: Icons.calendar_today,
                label: 'Joined',
                value: _formatDate(user.createdAt),
                subtitle: _getTimeSinceJoining(user.createdAt),
              ),
              const Divider(height: 1),
              if (myChainInfo?.parentUsername != null)
                _StatTile(
                  icon: Icons.person_outline,
                  label: 'Invited by',
                  value: myChainInfo.parentUsername,
                  subtitle: 'Position #${(user.chainPosition - 1)}',
                ),
              if (myChainInfo?.childUsername != null) ...[
                const Divider(height: 1),
                _StatTile(
                  icon: Icons.person_add,
                  label: 'Invited',
                  value: myChainInfo.childUsername,
                  subtitle: 'Position #${(user.chainPosition + 1)}',
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// Ticket History Section
class _TicketHistorySection extends StatelessWidget {
  final dynamic ticketState;
  final VoidCallback onGenerateTicket;

  const _TicketHistorySection({
    required this.ticketState,
    required this.onGenerateTicket,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ticket Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: onGenerateTicket,
              icon: const Icon(Icons.add),
              label: const Text('Generate'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TicketStat(
                      label: 'Generated',
                      value: ticketState.generatedCount?.toString() ?? '0',
                      color: Colors.blue,
                    ),
                    _TicketStat(
                      label: 'Used',
                      value: ticketState.usedCount?.toString() ?? '0',
                      color: Colors.green,
                    ),
                    _TicketStat(
                      label: 'Expired',
                      value: ticketState.expiredCount?.toString() ?? '0',
                      color: Colors.orange,
                    ),
                  ],
                ),
                if (ticketState.currentTicket != null) ...[
                  const Divider(height: 32),
                  Row(
                    children: [
                      Icon(
                        Icons.confirmation_number,
                        color: ticketState.currentTicket.isActive
                            ? Colors.green
                            : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Active Ticket',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      Chip(
                        label: Text(
                          ticketState.currentTicket.status.name.toUpperCase(),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: ticketState.currentTicket.isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Location Section
class _LocationSection extends StatelessWidget {
  final dynamic user;

  const _LocationSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red),
        title: const Text('Location Sharing'),
        subtitle: Text(
          user.locationCity != null || user.locationCountry != null
              ? '${user.locationCity ?? ''}, ${user.locationCountry ?? ''}'
              : 'Enabled',
        ),
        trailing: const Chip(
          label: Text('Active', style: TextStyle(fontSize: 12)),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }
}

// Actions Section
class _ActionsSection extends StatelessWidget {
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _ActionsSection({
    required this.onSettings,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onSettings,
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help center coming soon!')),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.red),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}

// Stat Tile Widget
class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Ticket Stat Widget
class _TicketStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TicketStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}