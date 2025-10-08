enum TicketStatus {
  active,
  used,
  expired;

  static TicketStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        return TicketStatus.active;
      case 'USED':
        return TicketStatus.used;
      case 'EXPIRED':
        return TicketStatus.expired;
      default:
        throw ArgumentError('Unknown ticket status: $status');
    }
  }
}

class TicketModel {
  final int id;
  final String ticketCode;
  final String qrCodeUrl;
  final DateTime expiresAt;
  final TicketStatus status;
  final int generatorId;
  final String generatorUsername;
  final int? scannedById;
  final String? scannedByUsername;
  final DateTime? scannedAt;

  TicketModel({
    required this.id,
    required this.ticketCode,
    required this.qrCodeUrl,
    required this.expiresAt,
    required this.status,
    required this.generatorId,
    required this.generatorUsername,
    this.scannedById,
    this.scannedByUsername,
    this.scannedAt,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] as int,
      ticketCode: json['ticketCode'] as String,
      qrCodeUrl: json['qrCodeUrl'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      status: TicketStatus.fromString(json['status'] as String),
      generatorId: json['generatorId'] as int,
      generatorUsername: json['generatorUsername'] as String,
      scannedById: json['scannedById'] as int?,
      scannedByUsername: json['scannedByUsername'] as String?,
      scannedAt: json['scannedAt'] != null
          ? DateTime.parse(json['scannedAt'] as String)
          : null,
    );
  }

  bool get isActive => status == TicketStatus.active && expiresAt.isAfter(DateTime.now());
  bool get isExpired => status == TicketStatus.expired || expiresAt.isBefore(DateTime.now());
  bool get isUsed => status == TicketStatus.used;
}
