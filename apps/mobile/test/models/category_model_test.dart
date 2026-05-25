// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/data/models/category_model.dart';

void main() {
  group('Category', () {
    group('fromJson', () {
      test('should create Category from JSON with all fields including dates', () {
        final json = {
          'id': 1,
          'nameAr': 'طعام',
          'nameEn': 'Food',
          'createdAt': '2025-01-01T00:00:00.000',
          'updatedAt': '2025-01-10T00:00:00.000',
        };

        final category = Category.fromJson(json);

        expect(category.id, 1);
        expect(category.nameAr, 'طعام');
        expect(category.nameEn, 'Food');
        expect(category.createdAt, DateTime(2025, 1, 1));
        expect(category.updatedAt, DateTime(2025, 1, 10));
      });

      test('should create Category from JSON with nullable dates as null', () {
        final json = {
          'id': 2,
          'nameAr': 'مواصلات',
          'nameEn': 'Transport',
        };

        final category = Category.fromJson(json);

        expect(category.id, 2);
        expect(category.nameAr, 'مواصلات');
        expect(category.nameEn, 'Transport');
        expect(category.createdAt, isNull);
        expect(category.updatedAt, isNull);
      });

      test('should handle null createdAt and updatedAt explicitly', () {
        final json = {
          'id': 3,
          'nameAr': 'تسوق',
          'nameEn': 'Shopping',
          'createdAt': null,
          'updatedAt': null,
        };

        final category = Category.fromJson(json);

        expect(category.createdAt, isNull);
        expect(category.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('should serialize Category with dates to JSON', () {
        final category = Category(
          id: 1,
          nameAr: 'طعام',
          nameEn: 'Food',
          createdAt: DateTime(2025, 1, 1),
          updatedAt: DateTime(2025, 1, 10),
        );

        final json = category.toJson();

        expect(json['id'], 1);
        expect(json['nameAr'], 'طعام');
        expect(json['nameEn'], 'Food');
        expect(json['createdAt'], '2025-01-01T00:00:00.000');
        expect(json['updatedAt'], '2025-01-10T00:00:00.000');
      });

      test('should omit nullable dates when they are null', () {
        final category = Category(
          id: 2,
          nameAr: 'مواصلات',
          nameEn: 'Transport',
        );

        final json = category.toJson();

        expect(json['id'], 2);
        expect(json['nameAr'], 'مواصلات');
        expect(json['nameEn'], 'Transport');
        expect(json.containsKey('createdAt'), false);
        expect(json.containsKey('updatedAt'), false);
      });
    });

    group('round-trip fromJson -> toJson', () {
      test('should preserve all fields through serialization', () {
        final originalJson = {
          'id': 1,
          'nameAr': 'تعليم',
          'nameEn': 'Education',
          'createdAt': '2025-01-15T10:30:00.000',
          'updatedAt': '2025-01-20T14:45:00.000',
        };

        final category = Category.fromJson(originalJson);
        final json = category.toJson();

        expect(json['id'], originalJson['id']);
        expect(json['nameAr'], originalJson['nameAr']);
        expect(json['nameEn'], originalJson['nameEn']);
        expect(json['createdAt'], originalJson['createdAt']);
        expect(json['updatedAt'], originalJson['updatedAt']);
      });

      test('should preserve null dates through serialization', () {
        final originalJson = {
          'id': 2,
          'nameAr': 'صحة',
          'nameEn': 'Health',
        };

        final category = Category.fromJson(originalJson);
        final json = category.toJson();

        expect(json['id'], originalJson['id']);
        expect(json['nameAr'], originalJson['nameAr']);
        expect(json['nameEn'], originalJson['nameEn']);
        expect(json.containsKey('createdAt'), false);
        expect(json.containsKey('updatedAt'), false);
      });
    });
  });
}
