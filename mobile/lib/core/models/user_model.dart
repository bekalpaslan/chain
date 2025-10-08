class UserModel {
  final int id;
  final String username;
  final String chainKey;
  final String? locationCity;
  final String? locationCountry;
  final DateTime createdAt;
  final int chainPosition;

  UserModel({
    required this.id,
    required this.username,
    required this.chainKey,
    this.locationCity,
    this.locationCountry,
    required this.createdAt,
    required this.chainPosition,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      chainKey: json['chainKey'] as String,
      locationCity: json['locationCity'] as String?,
      locationCountry: json['locationCountry'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      chainPosition: json['chainPosition'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'chainKey': chainKey,
      'locationCity': locationCity,
      'locationCountry': locationCountry,
      'createdAt': createdAt.toIso8601String(),
      'chainPosition': chainPosition,
    };
  }
}
