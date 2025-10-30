import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/ticket_models.dart';
import '../models/dashboard_models.dart';
import '../providers/ticket_providers.dart';
import '../providers/dashboard_providers.dart' hide ticketCountdownProvider;
import '../theme/app_theme.dart';
import '../widgets/ticket/ticket_expired_overlay.dart';
import '../widgets/ticket/success_celebration_overlay.dart';

/// Full-screen ticket view showing QR code, countdown, and share options
/// This is the main ticket screen users see when tapping FAB or banner
class TicketViewScreen extends ConsumerStatefulWidget {
  const TicketViewScreen({super.key});

  @override
  ConsumerState<TicketViewScreen> createState() => _TicketViewScreenState();
}

class _TicketViewScreenState extends ConsumerState<TicketViewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupTicketMonitoring();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _setupTicketMonitoring() {
    // Monitor for ticket expiration and success
    // This will be handled by the ticket provider
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final ticketAsync = ref.watch(activeTicketProvider);
    final dashboardData = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: theme.deepVoid,
      body: ticketAsync.when(
        data: (ticket) {
          if (ticket == null) {
            // No ticket - user has succeeded
            return _buildNoTicketView(theme);
          }
          return _buildTicketView(ticket, theme, dashboardData.valueOrNull);
        },
        loading: () => _buildLoadingView(theme),
        error: (error, stack) => _buildErrorView(theme, error.toString()),
      ),
    );
  }

  Widget _buildTicketView(Ticket ticket, DarkMystiqueTheme theme, DashboardData? data) {
    final countdownAsync = ref.watch(ticketCountdownProvider(ticket));

    return Stack(
      children: [
        // Background with floating orbs
        _buildBackground(theme),

        // Main scrollable content
        CustomScrollView(
          slivers: [
            // App bar
            _buildAppBar(theme),

            // Main ticket content
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Countdown timer
                    countdownAsync.when(
                      data: (remaining) => _buildCountdown(remaining, ticket.urgency, theme),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // QR Code with glow
                    _buildQRCode(ticket, theme),

                    const SizedBox(height: 32),

                    // Instructions
                    _buildInstructions(theme),

                    const SizedBox(height: 24),

                    // Deep link
                    _buildDeepLink(ticket, theme),

                    const SizedBox(height: 32),

                    // Share buttons
                    _buildShareButtons(ticket, theme),

                    const SizedBox(height: 32),

                    // Stats (subtle)
                    if (data != null) _buildStats(ticket, data, theme),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Close button
        _buildCloseButton(theme),
      ],
    );
  }

  Widget _buildBackground(DarkMystiqueTheme theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.5),
          radius: 1.5,
          colors: [
            theme.mysticViolet.withOpacity(0.1),
            theme.deepVoid,
          ],
        ),
      ),
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          return CustomPaint(
            painter: _OrbsPainter(
              progress: _glowController.value,
              color1: theme.mysticViolet,
              color2: theme.ghostCyan,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  Widget _buildAppBar(DarkMystiqueTheme theme) {
    return SliverAppBar(
      backgroundColor: theme.shadowDark.withOpacity(0.9),
      elevation: 0,
      pinned: true,
      leading: const SizedBox.shrink(), // No back button
      title: Text(
        'Your Invitation Ticket',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildCountdown(Duration remaining, TicketUrgency urgency, DarkMystiqueTheme theme) {
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [urgency.colorStart, urgency.colorEnd],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: urgency.glowColor,
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            urgency.label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(hours, 'HOURS', theme),
              _buildTimeSeparator(),
              _buildTimeUnit(minutes, 'MIN', theme),
              _buildTimeSeparator(),
              _buildTimeUnit(seconds, 'SEC', theme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(int value, String label, DarkMystiqueTheme theme) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.w900,
            fontFamily: 'monospace',
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        ':',
        style: TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
    );
  }

  Widget _buildQRCode(Ticket ticket, DarkMystiqueTheme theme) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        final glowIntensity = 0.5 + (0.5 * _glowController.value);

        return Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.shadowDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: ticket.urgency.colorStart.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: ticket.urgency.glowColor.withOpacity(glowIntensity),
                blurRadius: 30 * glowIntensity,
                spreadRadius: 10 * glowIntensity,
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ticket.qrCodeUrl != null
                ? _buildQRCodeImage(ticket.qrCodeUrl!)
                : _buildQRCodePlaceholder(theme),
          ),
        );
      },
    );
  }

  Widget _buildQRCodeImage(String qrCodeUrl) {
    try {
      if (qrCodeUrl.startsWith('data:image')) {
        final base64String = qrCodeUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 250,
          height: 250,
          fit: BoxFit.contain,
        );
      }
      return _buildQRCodePlaceholder(AppTheme.darkMystique);
    } catch (e) {
      return _buildQRCodePlaceholder(AppTheme.darkMystique);
    }
  }

  Widget _buildQRCodePlaceholder(DarkMystiqueTheme theme) {
    return SizedBox(
      width: 250,
      height: 250,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 100,
              color: theme.gray700,
            ),
            const SizedBox(height: 12),
            Text(
              'QR Code',
              style: TextStyle(
                color: theme.gray600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions(DarkMystiqueTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.mysticViolet.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.ghostCyan,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Share this QR code with one person you trust to join The Chain',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeepLink(Ticket ticket, DarkMystiqueTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.shadowDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.gray700.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation Link',
            style: TextStyle(
              color: theme.gray400,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  ticket.deepLink,
                  style: TextStyle(
                    color: theme.ghostCyan,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _copied ? Icons.check : Icons.copy,
                  color: _copied ? theme.emerald : theme.mysticViolet,
                  size: 20,
                ),
                onPressed: _copyToClipboard,
                tooltip: 'Copy to clipboard',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons(Ticket ticket, DarkMystiqueTheme theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _copyToClipboard,
            icon: Icon(_copied ? Icons.check : Icons.copy, size: 20),
            label: Text(_copied ? 'Copied!' : 'Copy Link'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _copied ? theme.emerald : theme.mysticViolet,
              side: BorderSide(
                color: _copied
                    ? theme.emerald.withOpacity(0.5)
                    : theme.mysticViolet.withOpacity(0.5),
                width: 2,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _shareNative,
            icon: const Icon(Icons.share, size: 20),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ticket.urgency.colorStart,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStats(Ticket ticket, DashboardData data, DarkMystiqueTheme theme) {
    return Column(
      children: [
        Divider(color: theme.gray700.withOpacity(0.3)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Position', '${data.user.position}', theme),
            _buildStatItem('Strikes', '${data.user.wastedTicketsCount}/3', theme),
            _buildStatItem('Next', '#${data.user.position + 1}', theme),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, DarkMystiqueTheme theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.gray500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton(DarkMystiqueTheme theme) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      right: 16,
      child: IconButton(
        icon: Icon(Icons.close, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildNoTicketView(DarkMystiqueTheme theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: theme.emerald,
            ),
            const SizedBox(height: 24),
            Text(
              'You\'re All Set!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve successfully invited someone to The Chain. No more tickets needed!',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.mysticViolet,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Back to Dashboard'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView(DarkMystiqueTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.mysticViolet),
          const SizedBox(height: 24),
          Text(
            'Loading your ticket...',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(DarkMystiqueTheme theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.errorRed),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Ticket',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                ref.read(activeTicketProvider.notifier).refreshTicket();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.mysticViolet,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    final ticket = ref.read(activeTicketProvider).valueOrNull;
    if (ticket == null) return;

    await Clipboard.setData(ClipboardData(text: ticket.deepLink));
    HapticFeedback.mediumImpact();

    setState(() {
      _copied = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link copied to clipboard!'),
          backgroundColor: AppTheme.darkMystique.emerald,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _shareNative() async {
    final ticket = ref.read(activeTicketProvider).valueOrNull;
    if (ticket == null) return;

    HapticFeedback.mediumImpact();

    // TODO: Implement native share using share_plus package
    // For now, just copy to clipboard
    await _copyToClipboard();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Link copied! Share it with someone to invite them.'),
          backgroundColor: AppTheme.darkMystique.mysticViolet,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Custom painter for floating orbs in background
class _OrbsPainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  _OrbsPainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = color1.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    final paint2 = Paint()
      ..color = color2.withOpacity(0.05)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);

    // Orb 1
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * (0.3 + 0.1 * progress)),
      100,
      paint1,
    );

    // Orb 2
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * (0.6 - 0.1 * progress)),
      80,
      paint2,
    );

    // Orb 3
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * (0.8 + 0.05 * progress)),
      60,
      paint1,
    );
  }

  @override
  bool shouldRepaint(_OrbsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
