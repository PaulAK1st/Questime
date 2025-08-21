class GuestUser {
  final String id;
  final String displayName;
  final DateTime createdAt;

  GuestUser({
    required this.id,
    required this.displayName,
    required this.createdAt,
  });

  bool get isExpired {
    return DateTime.now().isAfter(createdAt.add(const Duration(hours: 1)));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GuestUser.fromJson(Map<String, dynamic> json) {
    return GuestUser(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
