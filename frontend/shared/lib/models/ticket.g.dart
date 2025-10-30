// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  ticketId: json['ticketId'] as String,
  qrPayload: json['qrPayload'] as String,
  qrCodeUrl: json['qrCodeUrl'] as String?,
  deepLink: json['deepLink'] as String,
  signature: json['signature'] as String,
  issuedAt: DateTime.parse(json['issuedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  status: json['status'] as String,
  timeRemaining: (json['timeRemaining'] as num).toInt(),
  ownerId: json['ownerId'] as String?,
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'ticketId': instance.ticketId,
  'qrPayload': instance.qrPayload,
  'qrCodeUrl': instance.qrCodeUrl,
  'deepLink': instance.deepLink,
  'signature': instance.signature,
  'issuedAt': instance.issuedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'status': instance.status,
  'timeRemaining': instance.timeRemaining,
  'ownerId': instance.ownerId,
};
