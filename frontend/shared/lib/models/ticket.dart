import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

/// Ticket response from the backend API
@JsonSerializable()
class Ticket {
  final String ticketId;
  final String qrPayload;
  final String? qrCodeUrl; // Base64 PNG data URL
  final String deepLink;
  final String signature;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String status; // ACTIVE, USED, EXPIRED
  final int timeRemaining; // milliseconds
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
    required this.timeRemaining,
    this.ownerId,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);

  /// Duration remaining until expiration
  Duration get timeRemainingDuration => Duration(milliseconds: timeRemaining);

  /// Time remaining formatted as "XXh YYm ZZs"
  String get formattedTimeRemaining {
    final duration = timeRemainingDuration;
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
    final duration = timeRemainingDuration;
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
           '${minutes.toString().padLeft(2, '0')}:'
           '${seconds.toString().padLeft(2, '0')}';
  }

  /// Check if ticket is active
  bool get isActive => status.toUpperCase() == 'ACTIVE' && timeRemaining > 0;

  /// Check if ticket is expired
  bool get isExpired => status.toUpperCase() == 'EXPIRED' || timeRemaining <= 0;

  /// Check if ticket is expiring soon (less than 3 hours)
  bool get isExpiringSoon => timeRemainingDuration.inHours < 3;
}
