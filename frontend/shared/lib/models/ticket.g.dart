// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ticket.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Ticket _$TicketFromJson(Map<String, dynamic> json) => Ticket(
  ticketId: json['ticketId'] as String,
  ticketCode: json['ticketCode'] as String?,
  ownerId: json['ownerId'] as String,
  status: json['status'] as String,
  issuedAt: DateTime.parse(json['issuedAt'] as String),
  expiresAt: DateTime.parse(json['expiresAt'] as String),
  signature: json['signature'] as String,
  payload: json['payload'] as String?,
  attemptNumber: (json['attemptNumber'] as num).toInt(),
  ruleVersion: (json['ruleVersion'] as num).toInt(),
  durationHours: (json['durationHours'] as num).toInt(),
);

Map<String, dynamic> _$TicketToJson(Ticket instance) => <String, dynamic>{
  'ticketId': instance.ticketId,
  'ticketCode': instance.ticketCode,
  'ownerId': instance.ownerId,
  'status': instance.status,
  'issuedAt': instance.issuedAt.toIso8601String(),
  'expiresAt': instance.expiresAt.toIso8601String(),
  'signature': instance.signature,
  'payload': instance.payload,
  'attemptNumber': instance.attemptNumber,
  'ruleVersion': instance.ruleVersion,
  'durationHours': instance.durationHours,
};
