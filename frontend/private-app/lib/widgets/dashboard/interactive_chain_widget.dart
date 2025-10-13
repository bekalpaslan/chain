import 'package:flutter/material.dart';
import '../../models/dashboard_models.dart';
import '../../theme/app_theme.dart';

/// Interactive chain visualization widget
/// TODO: Implement full interactive chain visualization
class InteractiveChainWidget extends StatelessWidget {
  final List<ChainMember> members;
  final int currentUserPosition;
  final Function(ChainMember) onMemberTap;

  const InteractiveChainWidget({
    super.key,
    required this.members,
    required this.currentUserPosition,
    required this.onMemberTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.darkMystique;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Chain',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          // Simplified chain visualization for now
          ...members.map((member) => _buildMemberCard(member, theme)).toList(),
        ],
      ),
    );
  }

  Widget _buildMemberCard(ChainMember member, DarkMystiqueTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: member.isCurrentUser
            ? theme.mysticViolet.withOpacity(0.2)
            : theme.shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: member.isCurrentUser
              ? theme.mysticViolet
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: member.status.color.withOpacity(0.2),
            child: Text(
              '#${member.position}',
              style: TextStyle(
                color: member.status.color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  member.chainKey,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (member.isCurrentUser)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.mysticViolet,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'YOU',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}