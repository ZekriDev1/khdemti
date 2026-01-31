class ServiceModel {
  final String id;
  final String name;
  final String? description;
  final String? iconName; // Helper for mapping to icons
  final String? category;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.category,
    this.isActive = true,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      category: json['category'] as String?,
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'category': category,
      'is_active': isActive,
    };
  }
}
