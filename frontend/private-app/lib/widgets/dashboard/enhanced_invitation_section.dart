import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thechain_shared/widgets/chain_components.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Enhanced invitation section using shared components
/// Displays current invitation status and chain position
class EnhancedInvitationSection extends StatelessWidget {
  final DashboardData data;
  final VoidCallback? onCreateInvitation;
  final VoidCallback? onShareInvitation;
  final VoidCallback? onRevokeInvitation;
  final VoidCallback? onViewChain;

  const EnhancedInvitationSection({
    super.key,
    required this.data,
    this.onCreateInvitation,
    this.onShareInvitation,
    this.onRevokeInvitation,
    this.onViewChain,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 600;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [theme.mysticViolet, theme.ghostCyan],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Your Chain Connection',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chain position visualizer
          ChainPositionVisualizer(
            parentName: data.chainMembers.length > 1
              ? data.chainMembers[0].displayName
              : null,
            parentAvatar: data.chainMembers.length > 1
              ? data.chainMembers[0].avatarEmoji ?? '👤'
              : null,
            parentPosition: data.chainMembers.length > 1
              ? data.chainMembers[0].position
              : null,
            userName: data.user.displayName ?? data.user.username ?? 'You',
            userAvatar: data.user.avatarEmoji ?? '🎯',
            userPosition: data.user.position ?? 1,
            childName: data.chainMembers.length > 2
              ? data.chainMembers[2].displayName
              : null,
            childAvatar: data.chainMembers.length > 2
              ? data.chainMembers[2].avatarEmoji
              : null,
            childPosition: data.chainMembers.length > 2
              ? data.chainMembers[2].position
              : null,
            isCompact: isCompact,
            onUserTap: onViewChain,
          ),

          const SizedBox(height: 24),

          // Invitation card
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isCompact ? double.infinity : 400,
              ),
              child: InvitationCard(
                ticketCode: data.hasActiveTicket
                  ? 'CHAIN-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
                  : null,
                qrCodeUrl: data.hasActiveTicket
                  ? 'https://api.qr-server.com/v1/create-qr-code/?size=200x200&data=CHAIN-INVITE'
                  : null,
                expiresAt: data.hasActiveTicket
                  ? DateTime.now().add(const Duration(hours: 23, minutes: 45))
                  : null,
                isActive: data.hasActiveTicket,
                isExpired: false,
                onShare: onShareInvitation,
                onRevoke: onRevokeInvitation,
                onCreateNew: onCreateInvitation,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons row
          if (!isCompact) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.timeline,
                  label: 'View Full Chain',
                  onTap: onViewChain,
                  color: theme.mysticViolet,
                ),
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Share Profile',
                  onTap: () => _shareProfile(context),
                  color: theme.ghostCyan,
                ),
                _buildActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan Code',
                  onTap: () => _scanCode(context),
                  color: theme.emerald,
                ),
              ],
            ),
          ] else ...[
            // Compact view - stack buttons vertically
            Column(
              children: [
                _buildCompactActionButton(
                  icon: Icons.timeline,
                  label: 'View Full Chain',
                  onTap: onViewChain,
                  color: theme.mysticViolet,
                ),
                const SizedBox(height: 8),
                _buildCompactActionButton(
                  icon: Icons.share,
                  label: 'Share Your Profile',
                  onTap: () => _shareProfile(context),
                  color: theme.ghostCyan,
                ),
                const SizedBox(height: 8),
                _buildCompactActionButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Scan Invitation Code',
                  onTap: () => _scanCode(context),
                  color: theme.emerald,
                ),
              ],
            ),
          ],

          const SizedBox(height: 24),

          // Stats summary
          ChainCard(
            padding: const EdgeInsets.all(16),
            borderColor: theme.mysticViolet.withOpacity(0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  label: 'YOUR RANK',
                  value: '#${data.user.position ?? 1}',
                  color: theme.gold,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildMiniStat(
                  label: 'INVITED BY',
                  value: data.chainMembers.isNotEmpty
                    ? data.chainMembers[0].displayName.split(' ')[0]
                    : 'Genesis',
                  color: theme.ghostCyan,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.1),
                ),
                _buildMiniStat(
                  label: 'YOU INVITED',
                  value: data.hasActiveTicket ? 'Pending' : 'None',
                  color: data.hasActiveTicket ? theme.amber : Colors.white.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
    required Color color,
  }) {
    return ChainCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderColor: color.withOpacity(0.5),
      isHoverable: true,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withOpacity(0.3),
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _shareProfile(BuildContext context) {
    final profileUrl = 'https://thechain.app/u/${data.user.chainKey}';
    Clipboard.setData(ClipboardData(text: profileUrl));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text('Profile link copied to clipboard'),
          ],
        ),
        backgroundColor: const Color(0xFF111827),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _scanCode(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: Color(0xFF00D4FF)),
            const SizedBox(width: 8),
            const Text('QR Scanner coming soon...'),
          ],
        ),
        backgroundColor: const Color(0xFF111827),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}