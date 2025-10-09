import 'package:json_annotation/json_annotation.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class TokenInfo {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  TokenInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory TokenInfo.fromJson(Map<String, dynamic> json) => _$TokenInfoFromJson(json);
  Map<String, dynamic> toJson() => _$TokenInfoToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String userId;
  final String chainKey;
  final String displayName;
  final int position;
  final String? parentId;
  final TokenInfo tokens;

  AuthResponse({
    required this.userId,
    required this.chainKey,
    required this.displayName,
    required this.position,
    this.parentId,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
