import 'package:flutter/material.dart';
import 'dart:ui';

/// A reusable glassmorphic card component for The Chain
/// Used across both public and private apps for consistent design
class ChainCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double borderRadius;
  final double blurAmount;
  final bool showGlow;
  final bool isHoverable;

  const ChainCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.borderRadius = 16.0,
    this.blurAmount = 10.0,
    this.showGlow = false,
    this.isHoverable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor?.withOpacity(0.1) ??
                    const Color(0xFF111827).withOpacity(0.5),
                  backgroundColor?.withOpacity(0.05) ??
                    const Color(0xFF111827).withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: borderColor?.withOpacity(0.3) ??
                  const Color(0xFF7C3AED).withOpacity(0.3),
                width: borderWidth,
              ),
              boxShadow: showGlow ? [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ] : null,
            ),
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );

    if (isHoverable) {
      cardContent = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: 1.0,
          child: cardContent,
        ),
      );
    }

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: cardContent,
      );
    }

    return cardContent;
  }
}