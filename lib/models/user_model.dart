enum UserRole {
  guest,      // Demo mode - limited access
  user,       // Normal customer
  worker,     // Service provider
  admin;      // Developer/God mode

  String toStringValue() {
    switch (this) {
      case UserRole.worker:
        return 'provider';
      case UserRole.user:
        return 'customer';
      default:
        return toString().split('.').last;
    }
  }

  static UserRole fromString(String value) {
    if (value == 'provider') return UserRole.worker;
    if (value == 'customer') return UserRole.user;
    
    return UserRole.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => UserRole.user,
    );
  }
  
  // Role display names
  String get displayName {
    switch (this) {
      case UserRole.guest:
        return '⚠ Guest';
      case UserRole.user:
        return '👤 User';
      case UserRole.worker:
        return '🧰 Worker';
      case UserRole.admin:
        return '👑 Admin';
    }
  }
}

class UserModel {
  final String id;
  final String? fullName;
  final String? phone;
  final String? email;
  final String? bio;
  final String? avatarUrl;
  final UserRole role;
  final String? workerType; // cleaner, plumber, electrician, etc.
  final double manualRating;
  final bool isVerified;
  final bool isOnline;
  final int? age;
  final DateTime createdAt;

  // Computed property for easy access to rating
  double get rating => manualRating;
  
  // Check if user is in demo mode
  bool get isDemoMode => role == UserRole.guest;
  
  // Check if user can book services
  bool get canBook => role == UserRole.user || role == UserRole.admin;
  
  // Check if user can work
  bool get canWork => role == UserRole.worker || role == UserRole.admin;
  
  // Check if user has admin access
  bool get isAdmin => role == UserRole.admin;

  UserModel({
    required this.id,
    this.fullName,
    this.phone,
    this.email,
    this.bio,
    this.avatarUrl,
    this.role = UserRole.user,
    this.workerType,
    this.manualRating = 0.0,
    this.isVerified = false,
    this.isOnline = false,
    this.age,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: UserRole.fromString(json['role'] ?? 'user'),
      workerType: json['worker_type'] as String?,
      manualRating: (json['manual_rating'] as num?)?.toDouble() ?? 0.0,
      isVerified: json['is_verified'] ?? false,
      isOnline: json['is_online'] ?? false,
      age: json['age'] as int?,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'phone': phone,
      'email': email,
      'bio': bio,
      'avatar_url': avatarUrl,
      'role': role.toStringValue(),
      'worker_type': workerType,
      'manual_rating': manualRating,
      'is_verified': isVerified,
      'is_online': isOnline,
      'age': age,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? bio,
    String? avatarUrl,
    bool? isOnline,
    UserRole? role,
    String? workerType,
    int? age,
    double? rating,
    bool? isVerified,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      phone: phone,
      email: email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      workerType: workerType ?? this.workerType,
      manualRating: rating ?? manualRating,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      age: age ?? this.age,
      createdAt: createdAt,
    );
  }
  
  // Factory for creating demo user
  factory UserModel.demoUser() {
    return UserModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      fullName: 'Guest User',
      role: UserRole.guest,
      isVerified: false,
      createdAt: DateTime.now(),
    );
  }
}
