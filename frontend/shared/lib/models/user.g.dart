// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  userId: json['userId'] as String,
  chainKey: json['chainKey'] as String,
  displayName: json['displayName'] as String,
  position: (json['position'] as num).toInt(),
  parentId: json['parentId'] as String?,
  activeChildId: json['activeChildId'] as String?,
  status: json['status'] as String,
  wastedTicketsCount: (json['wastedTicketsCount'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  removedAt: json['removedAt'] == null
      ? null
      : DateTime.parse(json['removedAt'] as String),
  removalReason: json['removalReason'] as String?,
  membershipTier: json['membershipTier'] as String?,
  promotedToPermanentAt: json['promotedToPermanentAt'] == null
      ? null
      : DateTime.parse(json['promotedToPermanentAt'] as String),
  inviteeDepth: (json['inviteeDepth'] as num?)?.toInt() ?? 0,
  isPermanent: json['isPermanent'] as bool? ?? false,
  nextTicketDurationHours: (json['nextTicketDurationHours'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'userId': instance.userId,
  'chainKey': instance.chainKey,
  'displayName': instance.displayName,
  'position': instance.position,
  'parentId': instance.parentId,
  'activeChildId': instance.activeChildId,
  'status': instance.status,
  'wastedTicketsCount': instance.wastedTicketsCount,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
  'removedAt': instance.removedAt?.toIso8601String(),
  'removalReason': instance.removalReason,
  'membershipTier': instance.membershipTier,
  'promotedToPermanentAt': instance.promotedToPermanentAt?.toIso8601String(),
  'inviteeDepth': instance.inviteeDepth,
  'isPermanent': instance.isPermanent,
  'nextTicketDurationHours': instance.nextTicketDurationHours,
};
