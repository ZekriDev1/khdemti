enum UserRole {
  customer,
  provider,
  admin,
  super_admin;

  String toStringValue() {
    return toString().split('.').last;
  }

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => UserRole.customer,
    );
  }
}

class UserModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? bio;
  final String? avatarUrl;
  final UserRole role;
  final double manualRating; // For admin set ratings
  final bool isVerified;
  final bool isOnline;
  final DateTime createdAt;

  UserModel({
    required this.id,
    this.fullName,
    this.phone,
    this.bio,
    this.avatarUrl,
    this.role = UserRole.customer,
    this.manualRating = 0.0,
    this.isVerified = false,
    this.isOnline = false,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] ?? 'customer'),
      manualRating: (json['manual_rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      isOnline: json['is_online'] ?? false,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'bio': bio,
      'avatar_url': avatarUrl,
      'role': role.toStringValue(),
      'manual_rating': manualRating,
      'is_verified': isVerified,
      'is_online': isOnline,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? bio,
    String? avatarUrl,
    bool? isOnline,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role,
      manualRating: manualRating,
      isVerified: isVerified,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt,
    );
  }
}
