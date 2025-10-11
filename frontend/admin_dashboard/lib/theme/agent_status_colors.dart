// Enhanced color palette for agent status visualization
//
// This palette provides WCAG AA compliant colors for all agent states,
// with carefully designed glow effects and emotion indicators for the
// Dark Mystique theme.

import 'package:flutter/material.dart';

/// Color constants for agent status visualization with WCAG compliance
class AgentStatusColors {
  // Prevent instantiation
  AgentStatusColors._();

  // Primary Status Colors
  static const Color working = Color(0xFF00E5FF);      // Cyan
  static const Color idle = Color(0xFF888888);         // Gray (WCAG adjusted)
  static const Color blocked = Color(0xFFFF1744);      // Red
  static const Color done = Color(0xFF00E676);         // Green
  static const Color inProgress = Color(0xFFFFD600);   // Amber

  // Glow Effects
  static const Color workingGlow = Color(0x4000E5FF);
  static const Color blockedGlow = Color(0x60FF1744);
  static const Color doneGlow = Color(0x4000E676);
  static const Color inProgressGlow = Color(0x40FFD600);
  static const Color idleGlow = Color(0x26888888);

  // Emotion Accent Colors
  static const Color emotionHappy = Color(0xFF00E676);
  static const Color emotionSatisfied = Color(0xFF4CAF50);
  static const Color emotionFrustrated = Color(0xFFFF6D00);
  static const Color emotionSad = Color(0xFFFF1744);
  static const Color emotionFocused = Color(0xFF2196F3);
  static const Color emotionNeutral = Color(0xFF9E9E9E);

  // Background Tints
  static const Color blockedTint = Color(0x0DFF1744);
  static const Color workingTint = Color(0x0D00E5FF);
  static const Color doneTint = Color(0x0D00E676);
  static const Color inProgressTint = Color(0x0DFFD600);

  /// Get primary status color by status string
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return working;
      case 'idle':
        return idle;
      case 'blocked':
        return blocked;
      case 'done':
      case 'completed':
        return done;
      case 'in_progress':
      case 'in progress':
        return inProgress;
      default:
        return idle;
    }
  }

  /// Get glow color by status string
  static Color getStatusGlow(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return workingGlow;
      case 'idle':
        return idleGlow;
      case 'blocked':
        return blockedGlow;
      case 'done':
      case 'completed':
        return doneGlow;
      case 'in_progress':
      case 'in progress':
        return inProgressGlow;
      default:
        return idleGlow;
    }
  }

  /// Get background tint by status string
  static Color getStatusTint(String status) {
    switch (status.toLowerCase()) {
      case 'working':
        return workingTint;
      case 'blocked':
        return blockedTint;
      case 'done':
      case 'completed':
        return doneTint;
      case 'in_progress':
      case 'in progress':
        return inProgressTint;
      default:
        return Colors.transparent;
    }
  }

  /// Get emotion color by emotion string
  static Color getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return emotionHappy;
      case 'satisfied':
        return emotionSatisfied;
      case 'frustrated':
        return emotionFrustrated;
      case 'sad':
        return emotionSad;
      case 'focused':
        return emotionFocused;
      case 'neutral':
      default:
        return emotionNeutral;
    }
  }

  /// Get emotion emoji by emotion string
  static String getEmotionEmoji(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return '😊';
      case 'satisfied':
        return '😌';
      case 'frustrated':
        return '😤';
      case 'sad':
        return '😔';
      case 'focused':
        return '🎯';
      case 'neutral':
      default:
        return '😐';
    }
  }

  /// Get human-readable emotion description for accessibility
  static String getEmotionDescription(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return 'Happy - Task completed successfully';
      case 'satisfied':
        return 'Satisfied - Problem resolved';
      case 'frustrated':
        return 'Frustrated - Blocked by external factor';
      case 'sad':
        return 'Sad - Task taking longer than expected';
      case 'focused':
        return 'Focused - Deep work in progress';
      case 'neutral':
      default:
        return 'Neutral - Steady progress';
    }
  }
}
