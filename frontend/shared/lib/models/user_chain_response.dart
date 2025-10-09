import 'package:json_annotation/json_annotation.dart';

part 'user_chain_response.g.dart';

@JsonSerializable()
class UserChainResponse {
  final String userId;
  final String chainKey;
  final String displayName;
  final int position;
  final String status;
  final DateTime joinedAt;
  final String invitationStatus;

  UserChainResponse({
    required this.userId,
    required this.chainKey,
    required this.displayName,
    required this.position,
    required this.status,
    required this.joinedAt,
    required this.invitationStatus,
  });

  factory UserChainResponse.fromJson(Map<String, dynamic> json) => _$UserChainResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserChainResponseToJson(this);
}
