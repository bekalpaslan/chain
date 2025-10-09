// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChainStats _$ChainStatsFromJson(Map<String, dynamic> json) => ChainStats(
  totalUsers: (json['totalUsers'] as num).toInt(),
  activeUsers: (json['activeUsers'] as num).toInt(),
  removedUsers: (json['removedUsers'] as num).toInt(),
  totalTickets: (json['totalTickets'] as num).toInt(),
  activeTickets: (json['activeTickets'] as num).toInt(),
  usedTickets: (json['usedTickets'] as num).toInt(),
  expiredTickets: (json['expiredTickets'] as num).toInt(),
  chainLength: (json['chainLength'] as num).toInt(),
);

Map<String, dynamic> _$ChainStatsToJson(ChainStats instance) =>
    <String, dynamic>{
      'totalUsers': instance.totalUsers,
      'activeUsers': instance.activeUsers,
      'removedUsers': instance.removedUsers,
      'totalTickets': instance.totalTickets,
      'activeTickets': instance.activeTickets,
      'usedTickets': instance.usedTickets,
      'expiredTickets': instance.expiredTickets,
      'chainLength': instance.chainLength,
    };
