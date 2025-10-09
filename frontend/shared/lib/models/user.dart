import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String userId;
  final String chainKey;
  final String displayName;
  final int position;
  final String? parentId;
  final String? activeChildId;
  final String status;
  final int wastedTicketsCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? removedAt;
  final String? removalReason;

  User({
    required this.userId,
    required this.chainKey,
    required this.displayName,
    required this.position,
    this.parentId,
    this.activeChildId,
    required this.status,
    required this.wastedTicketsCount,
    required this.createdAt,
    this.updatedAt,
    this.removedAt,
    this.removalReason,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
