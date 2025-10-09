import 'package:json_annotation/json_annotation.dart';

part 'ticket.g.dart';

@JsonSerializable()
class Ticket {
  final String ticketId;
  final String? ticketCode;
  final String ownerId;
  final String status;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String signature;
  final String? payload;
  final int attemptNumber;
  final int ruleVersion;
  final int durationHours;

  Ticket({
    required this.ticketId,
    this.ticketCode,
    required this.ownerId,
    required this.status,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
    this.payload,
    required this.attemptNumber,
    required this.ruleVersion,
    required this.durationHours,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) => _$TicketFromJson(json);
  Map<String, dynamic> toJson() => _$TicketToJson(this);
}
