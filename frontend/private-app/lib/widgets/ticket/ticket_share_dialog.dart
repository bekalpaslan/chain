import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../../models/ticket_models.dart';
import '../../theme/app_theme.dart';

/// Dialog for sharing the user's invitation ticket
/// Features QR code display, native share sheet, and copy to clipboard
class TicketShareDialog extends StatefulWidget {
  final Ticket ticket;

  const TicketShareDialog({
    super.key,
    required this.ticket,
  });

  @override
  State<TicketShareDialog> createState() => _TicketShareDialogState();
}

class _TicketShareDialogState extends State<TicketShareDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final urgency = widget.ticket.urgency;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.shadowDark,
                  theme.deepVoid,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: urgency.colorStart.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: urgency.glowColor,
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                _buildHeader(theme, urgency),

                // QR Code
                _buildQRCode(theme),

                // Deep Link
                _buildDeepLink(theme),

                // Action Buttons
                _buildActionButtons(theme),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DarkMystiqueTheme theme, TicketUrgency urgency) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            urgency.colorStart.withOpacity(0.2),
            urgency.colorEnd.withOpacity(0.1),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [urgency.colorStart, urgency.colorEnd],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code_2,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share Your Ticket',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invite someone to join The Chain',
                  style: TextStyle(
                    color: theme.gray400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: theme.gray400),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(DarkMystiqueTheme theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // QR Code container with glow effect
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: widget.ticket.urgency.glowColor,
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: widget.ticket.qrCodeUrl != null
                ? _buildQRCodeImage()
                : _buildQRCodePlaceholder(theme),
          ),
          const SizedBox(height: 16),
          Text(
            'Scan to join The Chain',
            style: TextStyle(
              color: theme.gray400,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodeImage() {
    try {
      // Parse base64 data URL (format: data:image/png;base64,...)
      final qrCodeUrl = widget.ticket.qrCodeUrl!;
      if (qrCodeUrl.startsWith('data:image')) {
        final base64String = qrCodeUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: 200,
          height: 200,
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
      width: 200,
      height: 200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_2,
              size: 80,
              color: theme.gray700,
            ),
            const SizedBox(height: 8),
            Text(
              'QR Code',
              style: TextStyle(
                color: theme.gray600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeepLink(DarkMystiqueTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
                  widget.ticket.deepLink,
                  style: TextStyle(
                    color: theme.ghostCyan,
                    fontSize: 14,
                    fontFamily: 'monospace',
                  ),
                  maxLines: 1,
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

  Widget _buildActionButtons(DarkMystiqueTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // Copy button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _copyToClipboard,
              icon: Icon(
                _copied ? Icons.check : Icons.copy,
                size: 20,
              ),
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

          // Share button (will implement native share)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _shareNative,
              icon: const Icon(Icons.share, size: 20),
              label: const Text('Share'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.ticket.urgency.colorStart,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: widget.ticket.urgency.glowColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.ticket.deepLink));
    HapticFeedback.mediumImpact();

    setState(() {
      _copied = true;
    });

    // Reset after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });

    // Show snackbar
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
    HapticFeedback.mediumImpact();

    // TODO: Implement native share using share_plus package
    // For now, just copy to clipboard
    await _copyToClipboard();

    // Show message
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
