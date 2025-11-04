import 'package:flutter/material.dart';
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

  // New membership tier fields
  final String? membershipTier;
  final DateTime? promotedToPermanentAt;
  final int inviteeDepth;
  final bool isPermanent;
  final int? nextTicketDurationHours;

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
    this.membershipTier,
    this.promotedToPermanentAt,
    this.inviteeDepth = 0,
    this.isPermanent = false,
    this.nextTicketDurationHours,
  });

  // Helper getters for membership status
  bool get isCandidate => membershipTier == 'candidate';
  bool get isPermanentMember => membershipTier == 'permanent';

  String get membershipBadge {
    if (isPermanentMember) return '👑';
    if (isCandidate) return '🎯';
    return '';
  }

  Color get membershipColor {
    if (isPermanentMember) return Colors.amber;
    if (isCandidate) return Colors.blue;
    return Colors.grey;
  }

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
