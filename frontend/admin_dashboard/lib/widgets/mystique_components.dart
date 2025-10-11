import 'package:flutter/material.dart';
import '../theme/dark_mystique_theme.dart';

/// Mystical Card with purple glow effect
class MystiqueCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final bool elevated;
  final VoidCallback? onTap;

  const MystiqueCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.elevated = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: DarkMystiqueTheme.shadowPurple,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: DarkMystiqueTheme.mysticViolet.withOpacity( 0.3),
            width: 1,
          ),
          boxShadow: elevated
              ? DarkMystiqueTheme.elevatedCardShadow
              : DarkMystiqueTheme.cardShadow,
        ),
        padding: padding ?? const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}

/// Glowing Button with gradient and hover effect
class MystiqueButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final MystiqueButtonVariant variant;
  final Size? minimumSize;

  const MystiqueButton({
    super.key,
    required this.text,
    this.onPressed,
    this.loading = false,
    this.icon,
    this.variant = MystiqueButtonVariant.primary,
    this.minimumSize,
  });

  @override
  State<MystiqueButton> createState() => _MystiqueButtonState();
}

class _MystiqueButtonState extends State<MystiqueButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _getGradient();
    final shadowColor = _getShadowColor();

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: shadowColor.withOpacity( _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 0,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: widget.loading ? null : widget.onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              minimumSize: widget.minimumSize ?? const Size(120, 48),
            ),
            child: Ink(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Container(
                alignment: Alignment.center,
                child: widget.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(widget.icon, size: 18),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.text,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getGradient() {
    switch (widget.variant) {
      case MystiqueButtonVariant.primary:
        return DarkMystiqueTheme.mysticGradient;
      case MystiqueButtonVariant.secondary:
        return DarkMystiqueTheme.astralGradient;
      case MystiqueButtonVariant.danger:
        return const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
    }
  }

  Color _getShadowColor() {
    switch (widget.variant) {
      case MystiqueButtonVariant.primary:
        return DarkMystiqueTheme.mysticViolet;
      case MystiqueButtonVariant.secondary:
        return DarkMystiqueTheme.ghostCyan;
      case MystiqueButtonVariant.danger:
        return DarkMystiqueTheme.errorPulse;
    }
  }
}

enum MystiqueButtonVariant { primary, secondary, danger }

/// Mystical Input Field with cyan focus glow
class MystiqueTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLines;

  const MystiqueTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  State<MystiqueTextField> createState() => _MystiqueTextFieldState();
}

class _MystiqueTextFieldState extends State<MystiqueTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _focusController;
  late Animation<double> _focusGlowAnimation;
  bool _isFocused = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _focusGlowAnimation = Tween<double>(begin: 0.0, end: 0.4).animate(
      CurvedAnimation(parent: _focusController, curve: Curves.easeOut),
    );

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
        if (_isFocused) {
          _focusController.forward();
        } else {
          _focusController.reverse();
        }
      });
    });
  }

  @override
  void dispose() {
    _focusController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _focusGlowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: DarkMystiqueTheme.ghostCyan
                          .withOpacity( _focusGlowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.obscureText,
            validator: widget.validator,
            keyboardType: widget.keyboardType,
            maxLines: widget.maxLines,
            style: const TextStyle(
              color: DarkMystiqueTheme.textPrimary,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            decoration: InputDecoration(
              labelText: widget.label,
              hintText: widget.hint,
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: DarkMystiqueTheme.etherealPurple,
                    )
                  : null,
              suffixIcon: widget.suffixIcon != null
                  ? IconButton(
                      icon: Icon(
                        widget.suffixIcon,
                        color: DarkMystiqueTheme.textSecondary,
                      ),
                      onPressed: widget.onSuffixIconTap,
                    )
                  : null,
              filled: true,
              fillColor: DarkMystiqueTheme.twilightGray,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DarkMystiqueTheme.mysticViolet.withOpacity( 0.2),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: DarkMystiqueTheme.mysticViolet.withOpacity( 0.2),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: DarkMystiqueTheme.ghostCyan,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: DarkMystiqueTheme.errorPulse,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: DarkMystiqueTheme.errorPulse,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stat Card with cosmic data visualization
class MystiqueStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? accentColor;
  final String? subtitle;

  const MystiqueStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final color = accentColor ?? DarkMystiqueTheme.mysticViolet;

    return MystiqueCard(
      elevated: true,
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon with glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  color.withOpacity( 0.3),
                  Colors.transparent,
                ],
              ),
            ),
            child: Icon(
              icon,
              size: 40,
              color: color,
            ),
          ),
          const SizedBox(height: 16),
          // Value
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [color, color.withOpacity( 0.7)],
            ).createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Title
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: DarkMystiqueTheme.textSecondary,
              letterSpacing: 0.75,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 11,
                color: DarkMystiqueTheme.textMuted,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Alert/Error Box with mystical styling
class MystiqueAlert extends StatelessWidget {
  final String message;
  final MystiqueAlertType type;
  final IconData? icon;
  final VoidCallback? onDismiss;

  const MystiqueAlert({
    super.key,
    required this.message,
    this.type = MystiqueAlertType.info,
    this.icon,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getTypeConfig();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple,
        border: Border.all(
          color: config.color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: config.color.withOpacity( 0.2),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            icon ?? config.icon,
            color: config.color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: DarkMystiqueTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              color: DarkMystiqueTheme.textMuted,
              onPressed: onDismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  _AlertConfig _getTypeConfig() {
    switch (type) {
      case MystiqueAlertType.success:
        return _AlertConfig(
          color: DarkMystiqueTheme.successGlow,
          icon: Icons.check_circle_outline,
        );
      case MystiqueAlertType.warning:
        return _AlertConfig(
          color: DarkMystiqueTheme.warningAura,
          icon: Icons.warning_amber_rounded,
        );
      case MystiqueAlertType.error:
        return _AlertConfig(
          color: DarkMystiqueTheme.errorPulse,
          icon: Icons.error_outline,
        );
      case MystiqueAlertType.info:
        return _AlertConfig(
          color: DarkMystiqueTheme.astralCyan,
          icon: Icons.info_outline,
        );
    }
  }
}

enum MystiqueAlertType { success, warning, error, info }

class _AlertConfig {
  final Color color;
  final IconData icon;

  _AlertConfig({required this.color, required this.icon});
}

/// Chain Link Visual Element
class ChainLinkDecoration extends StatelessWidget {
  final double size;
  final Color? color;
  final double opacity;

  const ChainLinkDecoration({
    super.key,
    this.size = 80,
    this.color,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final linkColor = color ?? DarkMystiqueTheme.mysticViolet;

    return CustomPaint(
      size: Size(size, size),
      painter: _ChainLinkPainter(
        color: linkColor.withOpacity( opacity),
      ),
    );
  }
}

class _ChainLinkPainter extends CustomPainter {
  final Color color;

  _ChainLinkPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final rect1 = Rect.fromCenter(
      center: Offset(size.width * 0.35, size.height * 0.5),
      width: size.width * 0.4,
      height: size.height * 0.6,
    );

    final rect2 = Rect.fromCenter(
      center: Offset(size.width * 0.65, size.height * 0.5),
      width: size.width * 0.4,
      height: size.height * 0.6,
    );

    canvas.drawOval(rect1, paint);
    canvas.drawOval(rect2, paint);
  }

  @override
  bool shouldRepaint(_ChainLinkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Loading Indicator with mystical animation
class MystiqueLoadingIndicator extends StatefulWidget {
  final String? message;
  final double size;

  const MystiqueLoadingIndicator({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  State<MystiqueLoadingIndicator> createState() =>
      _MystiqueLoadingIndicatorState();
}

class _MystiqueLoadingIndicatorState extends State<MystiqueLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DarkMystiqueTheme.etherealPurple
                        .withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  DarkMystiqueTheme.etherealPurple,
                ),
              ),
            );
          },
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              fontSize: 14,
              color: DarkMystiqueTheme.textSecondary,
              letterSpacing: 0.75,
            ),
          ),
        ],
      ],
    );
  }
}
