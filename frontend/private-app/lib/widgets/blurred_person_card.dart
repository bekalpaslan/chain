import 'package:flutter/material.dart';
import 'dart:ui';

/// A blurred person card widget for displaying pending/ghost chain members
/// Uses true BackdropFilter for authentic glass morphism effect
class BlurredPersonCard extends StatelessWidget {
  final String? displayName;
  final String? chainKey;
  final int position;
  final bool isPending;
  final bool isGhost;
  final double blurIntensity;
  final VoidCallback? onTap;

  const BlurredPersonCard({
    super.key,
    this.displayName,
    this.chainKey,
    required this.position,
    this.isPending = false,
    this.isGhost = false,
    this.blurIntensity = 10.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPlaceholder = displayName == null || displayName!.isEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isGhost
                ? Colors.white.withOpacity(0.05)
                : isPending
                    ? const Color(0xFFF59E0B).withOpacity(0.3) // Amber for pending
                    : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            // True backdrop blur effect
            filter: ImageFilter.blur(
              sigmaX: blurIntensity,
              sigmaY: blurIntensity,
            ),
            child: Container(
              decoration: BoxDecoration(
                // Gradient overlay with reduced opacity for blur visibility
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isGhost
                      ? [
                          Colors.grey.withOpacity(0.1),
                          Colors.grey.withOpacity(0.05),
                        ]
                      : isPending
                          ? [
                              const Color(0xFFF59E0B).withOpacity(0.1), // Amber
                              const Color(0xFFF59E0B).withOpacity(0.05),
                            ]
                          : [
                              const Color(0xFF1F2937).withOpacity(0.3),
                              const Color(0xFF111827).withOpacity(0.2),
                            ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isGhost
                        ? Colors.black.withOpacity(0.1)
                        : isPending
                            ? const Color(0xFFF59E0B).withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Noise texture overlay for glass effect
                  Opacity(
                    opacity: 0.05,
                    child: Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/noise.png'),
                          fit: BoxFit.cover,
                          repeat: ImageRepeat.repeat,
                        ),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        // Avatar placeholder
                        _buildBlurredAvatar(isPlaceholder),

                        const SizedBox(width: 20),

                        // User info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Display name or placeholder
                              if (isPlaceholder) ...[
                                Container(
                                  height: 20,
                                  width: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  displayName!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isGhost
                                        ? Colors.white.withOpacity(0.3)
                                        : isPending
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],

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
                                      color: isGhost
                                          ? Colors.grey.withOpacity(0.2)
                                          : isPending
                                              ? const Color(0xFFF59E0B).withOpacity(0.2)
                                              : const Color(0xFF374151).withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '#$position',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withOpacity(
                                          isGhost ? 0.3 : 0.6,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 10),

                                  // Chain key or placeholder
                                  if (chainKey == null || chainKey!.isEmpty) ...[
                                    Container(
                                      height: 16,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ] else ...[
                                    Flexible(
                                      child: Text(
                                        chainKey!,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withOpacity(
                                            isGhost ? 0.2 : 0.4,
                                          ),
                                          letterSpacing: 0.5,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              // Status indicator
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isGhost
                                          ? Colors.grey.withOpacity(0.3)
                                          : isPending
                                              ? const Color(0xFFF59E0B).withOpacity(0.6)
                                              : const Color(0xFF10B981).withOpacity(0.6),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isGhost
                                              ? Colors.grey.withOpacity(0.2)
                                              : isPending
                                                  ? const Color(0xFFF59E0B).withOpacity(0.3)
                                                  : const Color(0xFF10B981).withOpacity(0.3),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isGhost
                                        ? 'Empty Slot'
                                        : isPending
                                            ? 'Invitation Pending'
                                            : 'Waiting to Join',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withOpacity(
                                        isGhost ? 0.3 : 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Action hint
                        if (!isGhost && !isPending) ...[
                          Icon(
                            Icons.touch_app,
                            color: Colors.white.withOpacity(0.2),
                            size: 20,
                          ),
                        ] else if (isPending) ...[
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                const Color(0xFFF59E0B).withOpacity(0.5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Shimmer effect for pending state
                  if (isPending)
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 2),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.transparent,
                              const Color(0xFFF59E0B).withOpacity(0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            transform: const GradientRotation(0.5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build blurred avatar placeholder
  Widget _buildBlurredAvatar(bool isPlaceholder) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGhost
              ? [
                  Colors.grey.withOpacity(0.2),
                  Colors.grey.withOpacity(0.1),
                ]
              : isPending
                  ? [
                      const Color(0xFFF59E0B).withOpacity(0.3),
                      const Color(0xFFF59E0B).withOpacity(0.2),
                    ]
                  : [
                      const Color(0xFF4B5563).withOpacity(0.4),
                      const Color(0xFF374151).withOpacity(0.3),
                    ],
        ),
        boxShadow: [
          BoxShadow(
            color: isGhost
                ? Colors.black.withOpacity(0.1)
                : isPending
                    ? const Color(0xFFF59E0B).withOpacity(0.2)
                    : Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: Colors.white.withOpacity(0.05),
            child: Center(
              child: isPlaceholder
                  ? Icon(
                      Icons.person_outline,
                      size: 32,
                      color: Colors.white.withOpacity(
                        isGhost ? 0.2 : 0.4,
                      ),
                    )
                  : Text(
                      displayName != null && displayName!.isNotEmpty
                          ? displayName![0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withOpacity(
                          isGhost ? 0.3 : 0.6,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Example usage widget showing different states
class BlurredPersonCardExample extends StatelessWidget {
  const BlurredPersonCardExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 16,
            children: [
              // Ghost slot - empty position in chain
              const BlurredPersonCard(
                position: 1001,
                isGhost: true,
                blurIntensity: 15.0,
              ),

              // Pending invitation - waiting for response
              const BlurredPersonCard(
                displayName: "Pending User",
                chainKey: "CHAIN??????",
                position: 1002,
                isPending: true,
                blurIntensity: 8.0,
              ),

              // Regular blurred - privacy mode or restricted view
              BlurredPersonCard(
                displayName: "Private User",
                chainKey: "CHAIN000999",
                position: 1003,
                blurIntensity: 5.0,
                onTap: () {
                  // Handle tap
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}