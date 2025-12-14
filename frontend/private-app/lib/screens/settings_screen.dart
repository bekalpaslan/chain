import 'package:flutter/material.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/utils/storage_helper.dart';

/// Settings screen with Dark Mystique theme
/// Provides account settings, notifications, and app info
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  bool _ticketExpiryAlerts = true;
  bool _chainActivityAlerts = true;
  bool _isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
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
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account Section
            _buildSectionHeader('Account', Icons.person_outline),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildNavigationTile(
                icon: Icons.badge_outlined,
                title: 'Profile',
                subtitle: 'View and edit your profile',
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.security_outlined,
                title: 'Security',
                subtitle: 'Password and authentication',
                onTap: () => _showComingSoon('Security settings'),
              ),
            ]),

            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionHeader('Notifications', Icons.notifications_outlined),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_active_outlined,
                title: 'Push Notifications',
                subtitle: 'Enable all notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                    if (!value) {
                      _ticketExpiryAlerts = false;
                      _chainActivityAlerts = false;
                    }
                  });
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.timer_outlined,
                title: 'Ticket Expiry Alerts',
                subtitle: 'Get notified before tickets expire',
                value: _ticketExpiryAlerts,
                enabled: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _ticketExpiryAlerts = value);
                },
              ),
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.link_outlined,
                title: 'Chain Activity',
                subtitle: 'New members, invitations accepted',
                value: _chainActivityAlerts,
                enabled: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _chainActivityAlerts = value);
                },
              ),
            ]),

            const SizedBox(height: 24),

            // About Section
            _buildSectionHeader('About', Icons.info_outline),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildInfoTile(
                icon: Icons.code_outlined,
                title: 'Version',
                value: '1.0.0',
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _showComingSoon('Terms of Service'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _showComingSoon('Privacy Policy'),
              ),
              _buildDivider(),
              _buildNavigationTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                onTap: () => _showComingSoon('Help & Support'),
              ),
            ]),

            const SizedBox(height: 24),

            // Logout Button
            Center(
              child: MystiqueButton(
                text: _isLoggingOut ? 'Signing Out...' : 'Sign Out',
                icon: Icons.logout,
                loading: _isLoggingOut,
                variant: MystiqueButtonVariant.secondary,
                onPressed: _isLoggingOut ? null : _handleLogout,
                minimumSize: const Size(200, 48),
              ),
            ),

            const SizedBox(height: 16),

            // Danger Zone
            _buildSectionHeader('Danger Zone', Icons.warning_amber_rounded, color: DarkMystiqueTheme.errorPulse),
            const SizedBox(height: 12),
            _buildSettingsCard([
              _buildDangerTile(
                icon: Icons.delete_forever_outlined,
                title: 'Delete Account',
                subtitle: 'Permanently remove your account',
                onTap: _showDeleteAccountDialog,
              ),
            ], isDanger: true),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    final headerColor = color ?? DarkMystiqueTheme.etherealPurple;
    return Row(
      children: [
        Icon(icon, color: headerColor, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: headerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children, {bool isDanger = false}) {
    return Container(
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDanger
              ? DarkMystiqueTheme.errorPulse.withOpacity(0.3)
              : DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: DarkMystiqueTheme.etherealPurple, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: DarkMystiqueTheme.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: DarkMystiqueTheme.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: DarkMystiqueTheme.textMuted,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.mysticViolet.withOpacity(enabled ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled
                  ? DarkMystiqueTheme.etherealPurple
                  : DarkMystiqueTheme.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: enabled
                        ? DarkMystiqueTheme.textPrimary
                        : DarkMystiqueTheme.textMuted,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: enabled
                          ? DarkMystiqueTheme.textMuted
                          : DarkMystiqueTheme.textMuted.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value && enabled,
            onChanged: enabled ? onChanged : null,
            activeColor: DarkMystiqueTheme.ghostCyan,
            activeTrackColor: DarkMystiqueTheme.ghostCyan.withOpacity(0.3),
            inactiveThumbColor: DarkMystiqueTheme.textMuted,
            inactiveTrackColor: DarkMystiqueTheme.twilightGray,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.mysticViolet.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: DarkMystiqueTheme.etherealPurple, size: 20),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: DarkMystiqueTheme.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: DarkMystiqueTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.errorPulse.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: DarkMystiqueTheme.errorPulse, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: DarkMystiqueTheme.errorPulse,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: DarkMystiqueTheme.errorPulse.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: DarkMystiqueTheme.errorPulse,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);

    try {
      // Clear all stored auth data
      await StorageHelper.clearAuthData();

      if (mounted) {
        // Navigate to landing page and clear navigation stack
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoggingOut = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: DarkMystiqueTheme.errorPulse,
          ),
        );
      }
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: DarkMystiqueTheme.mysticViolet,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: DarkMystiqueTheme.shadowPurple,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: DarkMystiqueTheme.errorPulse.withOpacity(0.3),
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: DarkMystiqueTheme.errorPulse),
            const SizedBox(width: 12),
            const Text(
              'Delete Account',
              style: TextStyle(
                color: DarkMystiqueTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(
                color: DarkMystiqueTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: DarkMystiqueTheme.errorPulse.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: DarkMystiqueTheme.errorPulse.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.link_off,
                    color: DarkMystiqueTheme.errorPulse.withOpacity(0.8),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Your position in the chain will be permanently removed.',
                      style: TextStyle(
                        color: DarkMystiqueTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: DarkMystiqueTheme.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Account deletion');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DarkMystiqueTheme.errorPulse,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
