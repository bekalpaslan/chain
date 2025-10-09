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
};
