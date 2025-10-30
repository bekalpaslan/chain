import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Warning banner shown when user has 2 or 3 wasted tickets (strikes)
/// Displays escalating warnings about chain removal
class StrikeWarningBanner extends StatelessWidget {
  final int strikeCount;

  const StrikeWarningBanner({
    super.key,
    required this.strikeCount,
  });

  @override
  Widget build(BuildContext context) {
    if (strikeCount < 2) return const SizedBox.shrink();

    final DarkMystiqueTheme theme = AppTheme.darkMystique;
    final isFinalWarning = strikeCount >= 2;
    final severity = strikeCount == 2 ? _WarningSeverity.high : _WarningSeverity.critical;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            severity.backgroundColor.withOpacity(0.2),
            severity.backgroundColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severity.borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: severity.glowColor,
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Warning icon with animation
            _buildWarningIcon(severity),
            const SizedBox(width: 12),

            // Warning text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: severity.iconColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        severity.title,
                        style: TextStyle(
                          color: severity.textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    severity.message(strikeCount),
                    style: TextStyle(
                      color: theme.gray400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Strike counter
            _buildStrikeCounter(strikeCount, severity),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningIcon(_WarningSeverity severity) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final scale = 1.0 + (0.3 * (0.5 - (value - 0.5).abs()));
        final opacity = 0.4 + (0.6 * (0.5 - (value - 0.5).abs()));

        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: severity.iconBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: severity.glowColor.withOpacity(opacity),
                blurRadius: 12 * scale,
                spreadRadius: 2 * scale,
              ),
            ],
          ),
          child: Icon(
            Icons.warning_rounded,
            color: severity.iconColor,
            size: 24,
          ),
        );
      },
      onEnd: () {
        // Loop animation
      },
    );
  }

  Widget _buildStrikeCounter(int count, _WarningSeverity severity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: severity.counterBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: severity.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '$count/3',
            style: TextStyle(
              color: severity.textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          Text(
            'STRIKES',
            style: TextStyle(
              color: severity.textColor.withOpacity(0.8),
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Warning severity levels
enum _WarningSeverity {
  high,
  critical;

  String get title {
    switch (this) {
      case _WarningSeverity.high:
        return 'Warning: Strike 2/3';
      case _WarningSeverity.critical:
        return 'FINAL WARNING: Strike 3/3';
    }
  }

  String message(int strikes) {
    switch (this) {
      case _WarningSeverity.high:
        return 'One more expired ticket and you\'ll be removed from The Chain. Share your ticket now!';
      case _WarningSeverity.critical:
        return 'This is your last chance! If this ticket expires, you will be permanently removed from The Chain.';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFF97316); // Orange
      case _WarningSeverity.critical:
        return const Color(0xFFEF4444); // Red
    }
  }

  Color get borderColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFFB923C);
      case _WarningSeverity.critical:
        return const Color(0xFFF87171);
    }
  }

  Color get glowColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFF97316).withOpacity(0.4);
      case _WarningSeverity.critical:
        return const Color(0xFFEF4444).withOpacity(0.6);
    }
  }

  Color get iconColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFFEF3C7); // Light amber
      case _WarningSeverity.critical:
        return Colors.white;
    }
  }

  Color get iconBackgroundColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFF97316).withOpacity(0.3);
      case _WarningSeverity.critical:
        return const Color(0xFFEF4444).withOpacity(0.3);
    }
  }

  Color get textColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFFED7AA);
      case _WarningSeverity.critical:
        return Colors.white;
    }
  }

  Color get counterBackgroundColor {
    switch (this) {
      case _WarningSeverity.high:
        return const Color(0xFFC2410C).withOpacity(0.3);
      case _WarningSeverity.critical:
        return const Color(0xFFDC2626).withOpacity(0.3);
    }
  }
}
