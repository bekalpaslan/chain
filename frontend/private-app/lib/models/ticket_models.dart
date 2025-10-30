import 'package:flutter/material.dart';

/// Ticket response from the backend
class Ticket {
  final String ticketId;
  final String qrPayload;
  final String? qrCodeUrl; // Base64 PNG data URL
  final String deepLink;
  final String signature;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final TicketStatus status;
  final int timeRemainingMs; // Milliseconds remaining
  final String? ownerId;

  Ticket({
    required this.ticketId,
    required this.qrPayload,
    this.qrCodeUrl,
    required this.deepLink,
    required this.signature,
    required this.issuedAt,
    required this.expiresAt,
    required this.status,
    required this.timeRemainingMs,
    this.ownerId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      ticketId: json['ticketId'],
      qrPayload: json['qrPayload'],
      qrCodeUrl: json['qrCodeUrl'],
      deepLink: json['deepLink'],
      signature: json['signature'],
      issuedAt: DateTime.parse(json['issuedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      status: _parseTicketStatus(json['status']),
      timeRemainingMs: json['timeRemaining'] ?? 0,
      ownerId: json['ownerId'],
    );
  }

  static TicketStatus _parseTicketStatus(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return TicketStatus.active;
      case 'USED':
        return TicketStatus.used;
      case 'EXPIRED':
        return TicketStatus.expired;
      default:
        return TicketStatus.expired;
    }
  }

  Ticket copyWith({
    String? ticketId,
    String? qrPayload,
    String? qrCodeUrl,
    String? deepLink,
    String? signature,
    DateTime? issuedAt,
    DateTime? expiresAt,
    TicketStatus? status,
    int? timeRemainingMs,
    String? ownerId,
  }) {
    return Ticket(
      ticketId: ticketId ?? this.ticketId,
      qrPayload: qrPayload ?? this.qrPayload,
      qrCodeUrl: qrCodeUrl ?? this.qrCodeUrl,
      deepLink: deepLink ?? this.deepLink,
      signature: signature ?? this.signature,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      timeRemainingMs: timeRemainingMs ?? this.timeRemainingMs,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  /// Duration remaining until expiration
  Duration get timeRemaining => Duration(milliseconds: timeRemainingMs);

  /// Time remaining formatted as "XXh YYm ZZs"
  String get formattedTimeRemaining {
    final duration = timeRemaining;
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

  /// Compact time remaining format "XX:YY:ZZ"
  String get compactTimeRemaining {
    final duration = timeRemaining;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  /// Progress from 0.0 (just issued) to 1.0 (expired)
  double get expirationProgress {
    final totalDuration = expiresAt.difference(issuedAt).inMilliseconds;
    final elapsed = DateTime.now().difference(issuedAt).inMilliseconds;
    final progress = elapsed / totalDuration;
    return progress.clamp(0.0, 1.0);
  }

  /// Urgency level based on time remaining
  TicketUrgency get urgency {
    final hoursRemaining = timeRemaining.inHours;

    if (hoursRemaining > 12) {
      return TicketUrgency.low;
    } else if (hoursRemaining > 6) {
      return TicketUrgency.medium;
    } else if (hoursRemaining > 1) {
      return TicketUrgency.high;
    } else {
      return TicketUrgency.critical;
    }
  }

  /// Check if ticket is expiring soon (less than 3 hours)
  bool get isExpiringSoon => timeRemaining.inHours < 3;

  /// Check if ticket is expired
  bool get isExpired => status == TicketStatus.expired || timeRemainingMs <= 0;

  /// Check if ticket is active
  bool get isActive => status == TicketStatus.active && timeRemainingMs > 0;
}

/// Ticket status enum
enum TicketStatus {
  active,
  used,
  expired,
}

/// Ticket urgency levels based on time remaining
enum TicketUrgency {
  low,      // > 12 hours
  medium,   // 6-12 hours
  high,     // 1-6 hours
  critical, // < 1 hour
}

/// Extension methods for TicketStatus
extension TicketStatusExtension on TicketStatus {
  Color get color {
    switch (this) {
      case TicketStatus.active:
        return const Color(0xFF10B981); // emerald
      case TicketStatus.used:
        return const Color(0xFF00D4FF); // cyan (success)
      case TicketStatus.expired:
        return const Color(0xFFEF4444); // red
    }
  }

  String get label {
    switch (this) {
      case TicketStatus.active:
        return 'Active';
      case TicketStatus.used:
        return 'Used';
      case TicketStatus.expired:
        return 'Expired';
    }
  }

  IconData get icon {
    switch (this) {
      case TicketStatus.active:
        return Icons.qr_code_2;
      case TicketStatus.used:
        return Icons.check_circle;
      case TicketStatus.expired:
        return Icons.timer_off;
    }
  }
}

/// Extension methods for TicketUrgency
extension TicketUrgencyExtension on TicketUrgency {
  /// Color for urgency indicator (gradient start)
  Color get colorStart {
    switch (this) {
      case TicketUrgency.low:
        return const Color(0xFF10B981); // emerald
      case TicketUrgency.medium:
        return const Color(0xFFF59E0B); // amber
      case TicketUrgency.high:
        return const Color(0xFFF97316); // orange
      case TicketUrgency.critical:
        return const Color(0xFFEF4444); // red
    }
  }

  /// Color for urgency indicator (gradient end)
  Color get colorEnd {
    switch (this) {
      case TicketUrgency.low:
        return const Color(0xFF059669); // darker emerald
      case TicketUrgency.medium:
        return const Color(0xFFD97706); // darker amber
      case TicketUrgency.high:
        return const Color(0xFFEA580C); // darker orange
      case TicketUrgency.critical:
        return const Color(0xFFDC2626); // darker red
    }
  }

  /// Glow color for urgency effects
  Color get glowColor {
    switch (this) {
      case TicketUrgency.low:
        return const Color(0xFF10B981).withOpacity(0.3);
      case TicketUrgency.medium:
        return const Color(0xFFF59E0B).withOpacity(0.4);
      case TicketUrgency.high:
        return const Color(0xFFF97316).withOpacity(0.5);
      case TicketUrgency.critical:
        return const Color(0xFFEF4444).withOpacity(0.6);
    }
  }

  String get label {
    switch (this) {
      case TicketUrgency.low:
        return 'Plenty of time';
      case TicketUrgency.medium:
        return 'Half way there';
      case TicketUrgency.high:
        return 'Time is running out!';
      case TicketUrgency.critical:
        return 'CRITICAL - Act NOW!';
    }
  }

  /// Animation speed multiplier (faster for higher urgency)
  double get animationSpeed {
    switch (this) {
      case TicketUrgency.low:
        return 1.0;
      case TicketUrgency.medium:
        return 1.5;
      case TicketUrgency.high:
        return 2.0;
      case TicketUrgency.critical:
        return 3.0;
    }
  }

  /// Pulse intensity for animations (0.0 to 1.0)
  double get pulseIntensity {
    switch (this) {
      case TicketUrgency.low:
        return 0.2;
      case TicketUrgency.medium:
        return 0.4;
      case TicketUrgency.high:
        return 0.6;
      case TicketUrgency.critical:
        return 1.0;
    }
  }
}
