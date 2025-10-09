// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_chain_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserChainResponse _$UserChainResponseFromJson(Map<String, dynamic> json) =>
    UserChainResponse(
      userId: json['userId'] as String,
      chainKey: json['chainKey'] as String,
      displayName: json['displayName'] as String,
      position: (json['position'] as num).toInt(),
      status: json['status'] as String,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      invitationStatus: json['invitationStatus'] as String,
    );

Map<String, dynamic> _$UserChainResponseToJson(UserChainResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'chainKey': instance.chainKey,
      'displayName': instance.displayName,
      'position': instance.position,
      'status': instance.status,
      'joinedAt': instance.joinedAt.toIso8601String(),
      'invitationStatus': instance.invitationStatus,
    };
