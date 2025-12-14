import 'package:flutter/material.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'dart:async';

/// Screen showing the result of scanning a QR code ticket
/// Displays inviter info and allows user to proceed to registration
class TicketScanResultScreen extends StatefulWidget {
  const TicketScanResultScreen({super.key});

  @override
  State<TicketScanResultScreen> createState() => _TicketScanResultScreenState();
}

class _TicketScanResultScreenState extends State<TicketScanResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  Map<String, dynamic>? _scanResult;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_scanResult == null) {
      _scanResult = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _initCountdown();
    }
  }

  void _initCountdown() {
    final timeRemaining = _scanResult?['timeRemaining'] as int? ?? 0;
    _remainingTime = Duration(milliseconds: timeRemaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isValid = _scanResult?['isValid'] as bool? ?? false;
    final validationMessage = _scanResult?['validationMessage'] as String? ?? 'Unknown error';

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
          'Scan Result',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status Header
                _buildStatusHeader(isValid, validationMessage),
                const SizedBox(height: 32),

                if (isValid) ...[
                  // Inviter Card
                  _buildInviterCard(),
                  const SizedBox(height: 24),

                  // Position Card
                  _buildPositionCard(),
                  const SizedBox(height: 24),

                  // Time Remaining
                  _buildTimeCard(),
                  const SizedBox(height: 24),

                  // Chain Stats
                  _buildChainStatsCard(),
                ] else ...[
                  _buildErrorCard(validationMessage),
                ],

                const SizedBox(height: 32),

                // Action Buttons
                _buildActionButtons(isValid),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isValid, String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValid
              ? [
                  DarkMystiqueTheme.successGlow.withOpacity(0.2),
                  DarkMystiqueTheme.ghostCyan.withOpacity(0.1),
                ]
              : [
                  DarkMystiqueTheme.errorPulse.withOpacity(0.2),
                  DarkMystiqueTheme.errorPulse.withOpacity(0.1),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isValid
              ? DarkMystiqueTheme.successGlow.withOpacity(0.4)
              : DarkMystiqueTheme.errorPulse.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle_outline : Icons.error_outline,
            color: isValid ? DarkMystiqueTheme.successGlow : DarkMystiqueTheme.errorPulse,
            size: 48,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Valid Invitation!' : 'Invalid Invitation',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isValid ? DarkMystiqueTheme.successGlow : DarkMystiqueTheme.errorPulse,
                  ),
                ),
                if (isValid) ...[
                  const SizedBox(height: 4),
                  Text(
                    'You can join The Chain!',
                    style: TextStyle(
                      color: DarkMystiqueTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviterCard() {
    final inviterName = _scanResult?['inviterDisplayName'] as String? ?? 'Unknown';
    final inviterChainKey = _scanResult?['inviterChainKey'] as String? ?? 'N/A';
    final inviterPosition = _scanResult?['inviterPosition'] as int? ?? 0;
    final inviterTier = _scanResult?['inviterMembershipTier'] as String? ?? 'candidate';

    return MystiqueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INVITED BY',
            style: TextStyle(
              color: DarkMystiqueTheme.textMuted,
              fontSize: 11,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [DarkMystiqueTheme.mysticViolet, DarkMystiqueTheme.ghostCyan],
                  ),
                ),
                child: Center(
                  child: Text(
                    inviterName.isNotEmpty ? inviterName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inviterName,
                      style: const TextStyle(
                        color: DarkMystiqueTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      inviterChainKey,
                      style: TextStyle(
                        color: DarkMystiqueTheme.ghostCyan,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('Position', '#$inviterPosition', DarkMystiqueTheme.ghostCyan),
              Container(width: 1, height: 40, color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2)),
              _buildStatColumn('Tier', inviterTier.toUpperCase(), DarkMystiqueTheme.warningAura),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPositionCard() {
    final futurePosition = _scanResult?['yourFuturePosition'] as int? ?? 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DarkMystiqueTheme.mysticViolet.withOpacity(0.15),
            DarkMystiqueTheme.ghostCyan.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.person_add, size: 40, color: DarkMystiqueTheme.etherealPurple),
          const SizedBox(height: 12),
          Text(
            'Your Future Position',
            style: TextStyle(
              color: DarkMystiqueTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '#$futurePosition',
            style: const TextStyle(
              color: DarkMystiqueTheme.etherealPurple,
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'in The Chain',
            style: TextStyle(
              color: DarkMystiqueTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeCard() {
    final isUrgent = _remainingTime.inMinutes < 30;
    final isCritical = _remainingTime.inMinutes < 5;

    return MystiqueCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: isCritical
                    ? DarkMystiqueTheme.errorPulse
                    : isUrgent
                        ? DarkMystiqueTheme.warningAura
                        : DarkMystiqueTheme.ghostCyan,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Time Remaining',
                style: TextStyle(
                  color: DarkMystiqueTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatDuration(_remainingTime),
            style: TextStyle(
              color: isCritical
                  ? DarkMystiqueTheme.errorPulse
                  : isUrgent
                      ? DarkMystiqueTheme.warningAura
                      : DarkMystiqueTheme.successGlow,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (isCritical) ...[
            const SizedBox(height: 8),
            Text(
              'Hurry! Invitation expires soon',
              style: TextStyle(
                color: DarkMystiqueTheme.errorPulse,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChainStatsCard() {
    final totalMembers = _scanResult?['totalChainMembers'] as int? ?? 0;

    return MystiqueCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.groups_outlined, color: DarkMystiqueTheme.ghostCyan, size: 24),
          const SizedBox(width: 12),
          Text(
            'Total Chain Members: ',
            style: TextStyle(
              color: DarkMystiqueTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            '$totalMembers',
            style: const TextStyle(
              color: DarkMystiqueTheme.ghostCyan,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return MystiqueCard(
      child: Column(
        children: [
          Icon(Icons.block, size: 64, color: DarkMystiqueTheme.errorPulse),
          const SizedBox(height: 16),
          const Text(
            'Cannot Proceed',
            style: TextStyle(
              color: DarkMystiqueTheme.errorPulse,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              color: DarkMystiqueTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Please scan a valid invitation QR code to continue.',
            style: TextStyle(
              color: DarkMystiqueTheme.textMuted,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: DarkMystiqueTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isValid) {
    return Column(
      children: [
        MystiqueButton(
          text: 'Continue to Registration',
          icon: Icons.arrow_forward,
          onPressed: isValid
              ? () {
                  Navigator.pushNamed(
                    context,
                    '/register',
                    arguments: {
                      'ticketId': _scanResult?['ticketId']?.toString() ?? '',
                      'ticketSignature': _scanResult?['ticketSignature'] ?? '',
                      'inviterName': _scanResult?['inviterDisplayName'] ?? 'Unknown',
                      'inviterChainKey': _scanResult?['inviterChainKey'] ?? 'N/A',
                      'inviterPosition': _scanResult?['inviterPosition'] ?? 0,
                      'yourFuturePosition': _scanResult?['yourFuturePosition'] ?? 0,
                    },
                  );
                }
              : null,
        ),
        const SizedBox(height: 16),
        MystiqueButton(
          text: 'Scan Another',
          icon: Icons.qr_code_scanner,
          variant: MystiqueButtonVariant.secondary,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
