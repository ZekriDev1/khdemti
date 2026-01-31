class AdModel {
  final String id;
  final String providerId;
  final String? serviceId;
  final String title;
  final String description;
  final String? imageUrl;
  final DateTime expiresAt;
  final bool isActive;
  final int priorityLevel; // 1: Standard, 2: Gold, 3: Platinum

  AdModel({
    required this.id,
    required this.providerId,
    this.serviceId,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.expiresAt,
    this.isActive = true,
    this.priorityLevel = 1,
  });

  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as String,
      providerId: json['provider_id'] as String,
      serviceId: json['service_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      expiresAt: DateTime.parse(json['expires_at']),
      isActive: json['is_active'] ?? true,
      priorityLevel: json['priority_level'] ?? 1,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
