// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainStats _$ChainStatsFromJson(Map<String, dynamic> json) => ChainStats(
  totalUsers: (json['totalUsers'] as num).toInt(),
  activeTickets: (json['activeTickets'] as num).toInt(),
  chainStartDate: DateTime.parse(json['chainStartDate'] as String),
  averageGrowthRate: (json['averageGrowthRate'] as num).toDouble(),
  totalWastedTickets: (json['totalWastedTickets'] as num).toInt(),
  wasteRate: (json['wasteRate'] as num).toDouble(),
  countries: (json['countries'] as num).toInt(),
  lastUpdate: DateTime.parse(json['lastUpdate'] as String),
  recentAttachments: (json['recentAttachments'] as List<dynamic>)
      .map((e) => RecentAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ChainStatsToJson(ChainStats instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeTickets': instance.activeTickets,
      'chainStartDate': instance.chainStartDate.toIso8601String(),
      'averageGrowthRate': instance.averageGrowthRate,
      'totalWastedTickets': instance.totalWastedTickets,
      'wasteRate': instance.wasteRate,
      'countries': instance.countries,
      'lastUpdate': instance.lastUpdate.toIso8601String(),
      'recentAttachments': instance.recentAttachments,
    };

RecentAttachment _$RecentAttachmentFromJson(Map<String, dynamic> json) =>
    RecentAttachment(
      childPosition: (json['childPosition'] as num).toInt(),
      displayName: json['displayName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      country: json['country'] as String,
    );

Map<String, dynamic> _$RecentAttachmentToJson(RecentAttachment instance) =>
    <String, dynamic>{
      'childPosition': instance.childPosition,
      'displayName': instance.displayName,
      'timestamp': instance.timestamp.toIso8601String(),
      'country': instance.country,
    };
