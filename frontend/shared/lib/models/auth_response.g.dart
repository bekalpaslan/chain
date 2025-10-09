// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenInfo _$TokenInfoFromJson(Map<String, dynamic> json) => TokenInfo(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
  expiresIn: (json['expiresIn'] as num).toInt(),
);

Map<String, dynamic> _$TokenInfoToJson(TokenInfo instance) => <String, dynamic>{
  'accessToken': instance.accessToken,
  'refreshToken': instance.refreshToken,
  'expiresIn': instance.expiresIn,
};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  userId: json['userId'] as String,
  chainKey: json['chainKey'] as String,
  displayName: json['displayName'] as String,
  position: (json['position'] as num).toInt(),
  parentId: json['parentId'] as String?,
  tokens: TokenInfo.fromJson(json['tokens'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'chainKey': instance.chainKey,
      'displayName': instance.displayName,
      'position': instance.position,
      'parentId': instance.parentId,
      'tokens': instance.tokens,
    };
