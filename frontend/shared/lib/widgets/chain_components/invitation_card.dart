import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'chain_card.dart';

/// A beautiful invitation/ticket card component with QR code
/// Shows ticket status, expiration countdown, and share options
class InvitationCard extends StatefulWidget {
  final String? ticketCode;
  final String? qrCodeUrl;
  final DateTime? expiresAt;
  final bool isActive;
  final bool isExpired;
  final String? inviteeeName;
  final VoidCallback? onShare;
  final VoidCallback? onRevoke;
  final VoidCallback? onCreateNew;

  const InvitationCard({
    super.key,
    this.ticketCode,
    this.qrCodeUrl,
    this.expiresAt,
    this.isActive = false,
    this.isExpired = false,
    this.inviteeeName,
    this.onShare,
    this.onRevoke,
    this.onCreateNew,
  });

  @override
  State<InvitationCard> createState() => _InvitationCardState();
}

class _InvitationCardState extends State<InvitationCard>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  String _timeRemaining = '';

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _updateTimeRemaining();
    if (widget.isActive && !widget.isExpired) {
      _startCountdown();
    }
  }

  void _startCountdown() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _updateTimeRemaining();
        });
        if (widget.isActive && !widget.isExpired) {
          _startCountdown();
        }
      }
    });
  }

  void _updateTimeRemaining() {
    if (widget.expiresAt == null) {
      _timeRemaining = '';
      return;
    }

    final now = DateTime.now();
    final difference = widget.expiresAt!.difference(now);

    if (difference.isNegative) {
      _timeRemaining = 'EXPIRED';
    } else {
      final hours = difference.inHours;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;
      _timeRemaining = '${hours}h ${minutes}m ${seconds}s';
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return _buildEmptyState();
    }

    if (widget.isExpired) {
      return _buildExpiredState();
    }

    return _buildActiveTicket();
  }

  Widget _buildActiveTicket() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: ChainCard(
            showGlow: true,
            borderColor: const Color(0xFF00D4FF),
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF00D4FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.confirmation_number,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'ACTIVE INVITATION',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share, size: 20),
                      color: Colors.white.withOpacity(0.7),
                      onPressed: widget.onShare,
                      tooltip: 'Share Invitation',
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // QR Code Container
                Container(
                  width: 200,
                  height: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating decoration
                      AnimatedBuilder(
                        animation: _rotationAnimation,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _rotationAnimation.value,
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                gradient: SweepGradient(
                                  colors: [
                                    const Color(0xFF7C3AED).withOpacity(0.3),
                                    const Color(0xFF00D4FF).withOpacity(0.3),
                                    const Color(0xFF7C3AED).withOpacity(0.3),
                                  ],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          );
                        },
                      ),
                      // QR Code placeholder
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: widget.qrCodeUrl != null
                          ? Image.network(
                              widget.qrCodeUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stack) {
                                return _buildQRPlaceholder();
                              },
                            )
                          : _buildQRPlaceholder(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ticket Code
                if (widget.ticketCode != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.ticketCode!,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00D4FF),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 16),
                          color: Colors.white.withOpacity(0.5),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: widget.ticketCode!),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Code copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          tooltip: 'Copy Code',
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Countdown Timer
                Column(
                  children: [
                    Text(
                      'EXPIRES IN',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ).createShader(bounds),
                      child: Text(
                        _timeRemaining,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Button
                if (widget.onRevoke != null)
                  TextButton.icon(
                    onPressed: widget.onRevoke,
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Revoke Invitation'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ChainCard(
      borderColor: Colors.white.withOpacity(0.2),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF111827),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add_circle_outline,
              size: 40,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Active Invitation',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new invitation to\ngrow the chain',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.onCreateNew != null)
            ElevatedButton.icon(
              onPressed: widget.onCreateNew,
              icon: const Icon(Icons.confirmation_number),
              label: const Text('Create Invitation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpiredState() {
    return ChainCard(
      borderColor: const Color(0xFFEF4444).withOpacity(0.3),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEF4444).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.timer_off,
              size: 40,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Invitation Expired',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This invitation has expired.\nCreate a new one to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.onCreateNew != null)
            ElevatedButton.icon(
              onPressed: widget.onCreateNew,
              icon: const Icon(Icons.refresh),
              label: const Text('Create New Invitation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQRPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2,
            size: 80,
            color: Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 8),
          Text(
            'QR CODE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.3),
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}