class ChainStatsModel {
  final int totalUsers;
  final int totalTicketsGenerated;
  final int totalTicketsUsed;
  final int totalTicketsExpired;
  final double ticketUsageRate;
  final int activeTickets;
  final int countriesRepresented;

  ChainStatsModel({
    required this.totalUsers,
    required this.totalTicketsGenerated,
    required this.totalTicketsUsed,
    required this.totalTicketsExpired,
    required this.ticketUsageRate,
    required this.activeTickets,
    required this.countriesRepresented,
  });

  factory ChainStatsModel.fromJson(Map<String, dynamic> json) {
    return ChainStatsModel(
      totalUsers: json['totalUsers'] as int,
      totalTicketsGenerated: json['totalTicketsGenerated'] as int,
      totalTicketsUsed: json['totalTicketsUsed'] as int,
      totalTicketsExpired: json['totalTicketsExpired'] as int,
      ticketUsageRate: (json['ticketUsageRate'] as num).toDouble(),
      activeTickets: json['activeTickets'] as int,
      countriesRepresented: json['countriesRepresented'] as int,
    );
  }

  int get totalTicketsWasted => totalTicketsExpired;
  int get wastedAttempts => totalTicketsExpired;
}
