import 'package:flutter/material.dart';

/// A beautifully designed person card for displaying chain members
/// Uses Dark Mystique theme with glass morphism effects
class PersonCard extends StatelessWidget {
  final String displayName;
  final String chainKey;
  final int position;
  final bool isCurrentUser;
  final String? status;

  const PersonCard({
    super.key,
    required this.displayName,
    required this.chainKey,
    required this.position,
    this.isCurrentUser = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      decoration: BoxDecoration(
        // Glass morphism background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentUser
              ? [
                  const Color(0xFF7C3AED).withOpacity(0.2), // Purple-600
                  const Color(0xFF5B21B6).withOpacity(0.15), // Purple-800
                ]
              : [
                  const Color(0xFF1F2937).withOpacity(0.6), // Gray-800
                  const Color(0xFF111827).withOpacity(0.4), // Gray-900
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentUser
              ? const Color(0xFF7C3AED).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? const Color(0xFF7C3AED).withOpacity(0.3)
                : Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Backdrop blur effect simulation
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  // Avatar
                  _buildAvatar(),

                  const SizedBox(width: 20),

                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Display name
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Position and chain key
                        Row(
                          children: [
                            // Position badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0xFF374151),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '#$position',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Chain key
                            Flexible(
                              child: Text(
                                chainKey,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.6),
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),

                        // Status (if provided)
                        if (status != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _getStatusColor(status!),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(status!)
                                          .withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _getStatusLabel(status!),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // "You" badge for current user
                  if (isCurrentUser) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF7C3AED), // Purple-600
                            Color(0xFF5B21B6), // Purple-800
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7C3AED).withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Text(
                        'YOU',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build avatar with gradient background
  Widget _buildAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentUser
              ? [
                  const Color(0xFF7C3AED), // Purple-600
                  const Color(0xFF5B21B6), // Purple-800
                ]
              : [
                  const Color(0xFF4B5563), // Gray-600
                  const Color(0xFF374151), // Gray-700
                ],
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentUser
                ? const Color(0xFF7C3AED).withOpacity(0.4)
                : Colors.black.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Get color for status indicator
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Green-500
      case 'seed':
        return const Color(0xFFF59E0B); // Amber-500
      case 'inactive':
        return const Color(0xFF6B7280); // Gray-500
      case 'wasted':
        return const Color(0xFFEF4444); // Red-500
      default:
        return const Color(0xFF6B7280); // Gray-500
    }
  }

  /// Get label for status
  String _getStatusLabel(String status) {
    return status[0].toUpperCase() + status.substring(1).toLowerCase();
  }
}
