import 'package:flutter/material.dart';

class CategoryGroup {
  final String id;
  final String name;
  final int colorValue;
  final int iconIndex;
  final DateTime createdAt;

  const CategoryGroup({
    required this.id,
    required this.name,
    required this.colorValue,
    this.iconIndex = 0,
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  CategoryGroup copyWith({
    String? id,
    String? name,
    int? colorValue,
    int? iconIndex,
    DateTime? createdAt,
  }) {
    return CategoryGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      iconIndex: iconIndex ?? this.iconIndex,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'colorValue': colorValue,
    'iconIndex': iconIndex,
    'createdAt': createdAt.toIso8601String(),
  };

  factory CategoryGroup.fromJson(Map<String, dynamic> json) {
    return CategoryGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      colorValue: json['colorValue'] as int? ?? 0xFF6366F1,
      iconIndex: json['iconIndex'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
