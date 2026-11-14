class Category {
  final int id;
  final String nameAr;
  final String nameEn;

  /// 'Expense' or 'Income' — stored for display/icon purposes only.
  /// No longer used to filter the category picker.
  final String type;
  final String icon;
  final int transactionCount;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Category({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.type = 'Expense',
    this.icon = 'tag',
    this.transactionCount = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      nameAr: json['nameAr'] as String? ?? '',
      nameEn: json['nameEn'] as String? ?? '',
      type: json['type'] as String? ?? 'Expense',
      icon: json['icon'] as String? ?? 'tag',
      transactionCount: json['transactionCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'nameAr': nameAr,
    'nameEn': nameEn,
    'type': type,
    'icon': icon,
    'transactionCount': transactionCount,
    'isActive': isActive,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
  };
}
