import 'package:json_annotation/json_annotation.dart';

part 'chain_stats.g.dart';

@JsonSerializable()
class ChainStats {
  final int totalUsers;
  final int activeUsers;
  final int removedUsers;
  final int totalTickets;
  final int activeTickets;
  final int usedTickets;
  final int expiredTickets;
  final int chainLength;

  ChainStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.removedUsers,
    required this.totalTickets,
    required this.activeTickets,
    required this.usedTickets,
    required this.expiredTickets,
    required this.chainLength,
  });

  factory ChainStats.fromJson(Map<String, dynamic> json) => _$ChainStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ChainStatsToJson(this);
}
