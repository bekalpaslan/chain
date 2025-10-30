import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/ticket_models.dart';
import '../../providers/ticket_providers.dart';
import '../../theme/app_theme.dart';

/// Banner displayed at the top of the dashboard showing active ticket status
/// Features countdown, urgency indicators, and strike warnings
class ActiveTicketBanner extends ConsumerWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const ActiveTicketBanner({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final countdownAsync = ref.watch(ticketCountdownProvider(ticket));

    return countdownAsync.when(
      data: (remaining) {
        final urgency = _getUrgencyFromDuration(remaining);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.shadowDark.withOpacity(0.9),
                  theme.deepVoid.withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: urgency.colorStart.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: urgency.glowColor,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Progress bar at the bottom
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildProgressBar(urgency, ticket.expirationProgress),
                  ),

                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header row: Icon + Title + Time
                        Row(
                          children: [
                            // Pulsing icon
                            _buildPulsingIcon(urgency),
                            const SizedBox(width: 12),

                            // Title
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your Invitation Ticket',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    urgency.label,
                                    style: TextStyle(
                                      color: urgency.colorStart,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Countdown
                            _buildCountdown(remaining, urgency),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Instructions
                        Text(
                          'Tap to share your ticket and invite someone to join The Chain',
                          style: TextStyle(
                            color: theme.gray400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPulsingIcon(TicketUrgency urgency) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (1000 / urgency.animationSpeed).round()),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final scale = 1.0 + (urgency.pulseIntensity * 0.2 * (0.5 - (value - 0.5).abs()));
        final opacity = 0.5 + (0.5 * (0.5 - (value - 0.5).abs()));

        return Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [urgency.colorStart, urgency.colorEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: urgency.glowColor.withOpacity(opacity),
                blurRadius: 12 * scale,
                spreadRadius: 4 * scale,
              ),
            ],
          ),
          child: Icon(
            Icons.qr_code_2,
            color: Colors.white,
            size: 24,
          ),
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }

  Widget _buildCountdown(Duration remaining, TicketUrgency urgency) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [urgency.colorStart, urgency.colorEnd],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: urgency.glowColor,
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            'remaining',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(TicketUrgency urgency, double progress) {
    return SizedBox(
      height: 4,
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.white.withOpacity(0.1),
        valueColor: AlwaysStoppedAnimation<Color>(urgency.colorStart),
      ),
    );
  }

  TicketUrgency _getUrgencyFromDuration(Duration remaining) {
    final hoursRemaining = remaining.inHours;

    if (hoursRemaining > 12) {
      return TicketUrgency.low;
    } else if (hoursRemaining > 6) {
      return TicketUrgency.medium;
    } else if (hoursRemaining > 1) {
      return TicketUrgency.high;
    } else {
      return TicketUrgency.critical;
    }
  }
}
