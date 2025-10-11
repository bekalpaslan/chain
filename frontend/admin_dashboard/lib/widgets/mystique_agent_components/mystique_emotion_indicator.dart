import 'package:flutter/material.dart';
import '../../theme/agent_status_colors.dart';

/// Display style for the emotion indicator
enum EmotionDisplayStyle {
  /// Pill-style with icon, label, and colored background
  pill,

  /// Icon and text without background
  text,

  /// Icon only (most compact)
  iconOnly,
}

/// Emotion indicator component for displaying agent emotional states
///
/// Features:
/// - Emoji-based visual indicators
/// - Color-coded labels matching emotion
/// - Flexible display styles (pill, text, icon-only)
/// - WCAG AA compliant colors
/// - Screen reader accessible with detailed descriptions
/// - Smooth color transitions
class MystiqueEmotionIndicator extends StatelessWidget {
  /// The current emotion of the agent
  ///
  /// Valid values: 'happy', 'satisfied', 'neutral', 'frustrated', 'sad', 'focused'
  final String emotion;

  /// Show text label alongside icon
  final bool showLabel;

  /// Display style for the indicator
  final EmotionDisplayStyle style;

  /// Size of the emoji icon (default: 16.0)
  final double iconSize;

  /// Enable animated transitions when emotion changes
  final bool animated;

  /// Callback when indicator is tapped
  final VoidCallback? onTap;

  const MystiqueEmotionIndicator({
    super.key,
    required this.emotion,
    this.showLabel = true,
    this.style = EmotionDisplayStyle.pill,
    this.iconSize = 16.0,
    this.animated = true,
    this.onTap,
  });

  /// Get formatted emotion text
  String _getEmotionText() {
    return emotion[0].toUpperCase() + emotion.substring(1).toLowerCase();
  }

  /// Build emoji icon
  Widget _buildIcon() {
    final emoji = AgentStatusColors.getEmotionEmoji(emotion);

    return Text(
      emoji,
      style: TextStyle(
        fontSize: iconSize,
        height: 1.0,
      ),
    );
  }

  /// Build text label
  Widget _buildLabel(Color color) {
    final emotionText = _getEmotionText();

    return Text(
      emotionText,
      style: TextStyle(
        fontSize: iconSize * 0.875, // Slightly smaller than icon
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Build pill-style indicator
  Widget _buildPillStyle() {
    final color = AgentStatusColors.getEmotionColor(emotion);
    final backgroundColor = color.withValues(alpha: 0.15);
    final borderColor = color.withValues(alpha: 0.3);

    final content = Container(
      padding: EdgeInsets.symmetric(
        horizontal: iconSize * 0.75,
        vertical: iconSize * 0.375,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(iconSize * 1.5),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(),
          if (showLabel) ...[
            SizedBox(width: iconSize * 0.375),
            _buildLabel(color),
          ],
        ],
      ),
    );

    return animated
        ? AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: content,
          )
        : content;
  }

  /// Build text-style indicator
  Widget _buildTextStyle() {
    final color = AgentStatusColors.getEmotionColor(emotion);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIcon(),
        if (showLabel) ...[
          SizedBox(width: iconSize * 0.5),
          _buildLabel(color),
        ],
      ],
    );

    return animated
        ? AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            style: TextStyle(color: color),
            child: content,
          )
        : content;
  }

  /// Build icon-only indicator
  Widget _buildIconOnlyStyle() {
    return _buildIcon();
  }

  @override
  Widget build(BuildContext context) {
    // Build the main content based on style
    Widget content;

    switch (style) {
      case EmotionDisplayStyle.pill:
        content = _buildPillStyle();
      case EmotionDisplayStyle.text:
        content = _buildTextStyle();
      case EmotionDisplayStyle.iconOnly:
        content = _buildIconOnlyStyle();
    }

    // Wrap in Semantics for accessibility
    final emotionDescription = AgentStatusColors.getEmotionDescription(emotion);
    content = Semantics(
      label: 'Emotion: $emotionDescription',
      readOnly: onTap == null,
      button: onTap != null,
      child: content,
    );

    // Make interactive if onTap is provided
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(iconSize * 1.5),
        child: content,
      );
    }

    // Add tooltip with full description
    content = Tooltip(
      message: emotionDescription,
      waitDuration: const Duration(milliseconds: 500),
      child: content,
    );

    return content;
  }
}

/// Compact emotion indicator for use in tight spaces
///
/// Always displays icon-only style regardless of configuration
class CompactEmotionIndicator extends StatelessWidget {
  /// The current emotion
  final String emotion;

  /// Size of the emoji (default: 14.0 for compact display)
  final double size;

  /// Callback when tapped
  final VoidCallback? onTap;

  const CompactEmotionIndicator({
    super.key,
    required this.emotion,
    this.size = 14.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MystiqueEmotionIndicator(
      emotion: emotion,
      style: EmotionDisplayStyle.iconOnly,
      iconSize: size,
      showLabel: false,
      onTap: onTap,
    );
  }
}

/// Full emotion indicator with label for primary displays
///
/// Always displays pill style with label
class FullEmotionIndicator extends StatelessWidget {
  /// The current emotion
  final String emotion;

  /// Size of the emoji icon (default: 16.0)
  final double size;

  /// Callback when tapped
  final VoidCallback? onTap;

  /// Enable animated transitions
  final bool animated;

  const FullEmotionIndicator({
    super.key,
    required this.emotion,
    this.size = 16.0,
    this.onTap,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return MystiqueEmotionIndicator(
      emotion: emotion,
      style: EmotionDisplayStyle.pill,
      iconSize: size,
      showLabel: true,
      animated: animated,
      onTap: onTap,
    );
  }
}
