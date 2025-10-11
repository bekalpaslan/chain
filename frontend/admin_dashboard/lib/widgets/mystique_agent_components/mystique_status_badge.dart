import 'package:flutter/material.dart';
import '../../theme/agent_status_colors.dart';

/// Display style for the status badge
enum StatusBadgeStyle {
  /// Full display with icon and text
  full,

  /// Icon only (compact mode)
  iconOnly,

  /// Text only (no icon)
  textOnly,
}

/// Animated status badge component for agent status display
///
/// Features:
/// - Pulsing animation for 'working' status (1.5s cycle)
/// - Status-specific icons and colors
/// - WCAG AA compliant colors
/// - Screen reader accessible
/// - Keyboard focusable when interactive
class MystiqueStatusBadge extends StatefulWidget {
  /// The current status of the agent
  ///
  /// Valid values: 'working', 'idle', 'blocked', 'done', 'in_progress'
  final String status;

  /// Enable pulsing animation (primarily for 'working' status)
  final bool animated;

  /// Size of the status indicator dot (default: 16.0)
  final double size;

  /// Callback when badge is tapped (makes badge interactive)
  final VoidCallback? onTap;

  /// Display style for the badge
  final StatusBadgeStyle style;

  /// Show tooltip on hover
  final bool showTooltip;

  const MystiqueStatusBadge({
    super.key,
    required this.status,
    this.animated = true,
    this.size = 16.0,
    this.onTap,
    this.style = StatusBadgeStyle.full,
    this.showTooltip = true,
  });

  @override
  State<MystiqueStatusBadge> createState() => _MystiqueStatusBadgeState();
}

class _MystiqueStatusBadgeState extends State<MystiqueStatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize pulse animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Scale animation: 1.0 → 1.15 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Opacity animation: 1.0 → 0.7 → 1.0
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.7, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Start animation if enabled and status is 'working'
    if (widget.animated && widget.status.toLowerCase() == 'working') {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(MystiqueStatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update animation state if status changes
    if (widget.status != oldWidget.status || widget.animated != oldWidget.animated) {
      if (widget.animated && widget.status.toLowerCase() == 'working') {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Get icon widget for the current status
  Widget _getStatusIcon() {
    final color = AgentStatusColors.getStatusColor(widget.status);
    final size = widget.size;

    switch (widget.status.toLowerCase()) {
      case 'working':
        // Pulsing dot
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: AgentStatusColors.getStatusGlow(widget.status),
                        blurRadius: size * 0.5,
                        spreadRadius: size * 0.125,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

      case 'idle':
        // Hollow circle
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        );

      case 'blocked':
        // Warning triangle
        return Icon(
          Icons.warning,
          size: size,
          color: color,
        );

      case 'done':
      case 'completed':
        // Checkmark
        return Icon(
          Icons.check_circle,
          size: size,
          color: color,
        );

      case 'in_progress':
      case 'in progress':
        // Spinner/rotating arrow
        return Icon(
          Icons.autorenew,
          size: size,
          color: color,
        );

      default:
        // Default to filled dot
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        );
    }
  }

  /// Get formatted status text
  String _getStatusText() {
    return widget.status.toUpperCase().replaceAll('_', ' ');
  }

  /// Build the badge widget
  Widget _buildBadge() {
    final statusText = _getStatusText();
    final color = AgentStatusColors.getStatusColor(widget.status);

    Widget content;

    switch (widget.style) {
      case StatusBadgeStyle.iconOnly:
        content = _getStatusIcon();

      case StatusBadgeStyle.textOnly:
        content = Text(
          statusText,
          style: TextStyle(
            fontSize: widget.size * 0.875, // 14px when size is 16px
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.5,
          ),
        );

      case StatusBadgeStyle.full:
        content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Isolate animation to prevent unnecessary rebuilds
            RepaintBoundary(
              child: _getStatusIcon(),
            ),
            SizedBox(width: widget.size * 0.5), // 8px spacing
            Text(
              statusText,
              style: TextStyle(
                fontSize: widget.size * 0.875, // 14px when size is 16px
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
    }

    // Wrap in Semantics for accessibility
    content = Semantics(
      label: 'Agent status: $statusText',
      readOnly: widget.onTap == null,
      button: widget.onTap != null,
      child: content,
    );

    // Make interactive if onTap is provided
    if (widget.onTap != null) {
      content = InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(widget.size * 0.5),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.size * 0.5,
            vertical: widget.size * 0.25,
          ),
          child: content,
        ),
      );
    }

    // Add tooltip if enabled
    if (widget.showTooltip) {
      final tooltipMessage = _getTooltipMessage();
      content = Tooltip(
        message: tooltipMessage,
        waitDuration: const Duration(milliseconds: 500),
        child: content,
      );
    }

    return content;
  }

  /// Get tooltip message based on status
  String _getTooltipMessage() {
    switch (widget.status.toLowerCase()) {
      case 'working':
        return 'Agent is actively working on a task';
      case 'idle':
        return 'Agent is idle, waiting for tasks';
      case 'blocked':
        return 'Agent is blocked or encountered an error';
      case 'done':
      case 'completed':
        return 'Agent has completed its task';
      case 'in_progress':
      case 'in progress':
        return 'Agent has a task in progress';
      default:
        return 'Agent status: ${widget.status}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildBadge();
  }
}
