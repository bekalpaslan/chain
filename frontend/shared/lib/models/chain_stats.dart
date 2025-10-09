import 'package:json_annotation/json_annotation.dart';

part 'chain_stats.g.dart';

@JsonSerializable()
class ChainStats {
  final int totalUsers;
  final int activeTickets;
  final DateTime chainStartDate;
  final double averageGrowthRate;
  final int totalWastedTickets;
  final double wasteRate;
  final int countries;
  final DateTime lastUpdate;
  final List<RecentAttachment> recentAttachments;

  ChainStats({
    required this.totalUsers,
    required this.activeTickets,
    required this.chainStartDate,
    required this.averageGrowthRate,
    required this.totalWastedTickets,
    required this.wasteRate,
    required this.countries,
    required this.lastUpdate,
    required this.recentAttachments,
  });

  factory ChainStats.fromJson(Map<String, dynamic> json) => _$ChainStatsFromJson(json);
  Map<String, dynamic> toJson() => _$ChainStatsToJson(this);
}

@JsonSerializable()
class RecentAttachment {
  final int childPosition;
  final String displayName;
  final DateTime timestamp;
  final String country;

  RecentAttachment({
    required this.childPosition,
    required this.displayName,
    required this.timestamp,
    required this.country,
  });

  factory RecentAttachment.fromJson(Map<String, dynamic> json) => _$RecentAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$RecentAttachmentToJson(this);
}
