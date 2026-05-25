// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';

void main() {
  group('BudgetDto', () {
    group('fromJson', () {
      test('should create BudgetDto with complete JSON', () {
        final json = {
          'monthlyBudget': 5000.0,
          'currentSpending': 3200.0,
          'categoryBudgets': [
            {
              'id': 1,
              'categoryId': 10,
              'categoryNameAr': 'طعام',
              'categoryNameEn': 'Food',
              'budgetAmount': 2000.0,
              'spent': 1500.0,
            },
            {
              'id': 2,
              'categoryId': 11,
              'categoryNameAr': 'مواصلات',
              'categoryNameEn': 'Transport',
              'budgetAmount': 1000.0,
              'spent': 800.0,
            },
          ],
        };

        final budget = BudgetDto.fromJson(json);

        expect(budget.monthlyBudget, 5000.0);
        expect(budget.currentSpending, 3200.0);
        expect(budget.categoryBudgets.length, 2);
        expect(budget.categoryBudgets[0].categoryNameAr, 'طعام');
        expect(budget.categoryBudgets[1].categoryNameAr, 'مواصلات');
      });

      test('should use defaults when fields are missing', () {
        final json = <String, dynamic>{};

        final budget = BudgetDto.fromJson(json);

        expect(budget.monthlyBudget, 0.0);
        expect(budget.currentSpending, 0.0);
        expect(budget.categoryBudgets, isEmpty);
      });

      test('should use defaults when fields are null', () {
        final json = {
          'monthlyBudget': null,
          'currentSpending': null,
          'categoryBudgets': null,
        };

        final budget = BudgetDto.fromJson(json);

        expect(budget.monthlyBudget, 0.0);
        expect(budget.currentSpending, 0.0);
        expect(budget.categoryBudgets, isEmpty);
      });

      test('should handle integer values for double fields', () {
        final json = {
          'monthlyBudget': 5000,
          'currentSpending': 3200,
          'categoryBudgets': [],
        };

        final budget = BudgetDto.fromJson(json);

        expect(budget.monthlyBudget, 5000.0);
        expect(budget.currentSpending, 3200.0);
      });
    });
  });

  group('CategoryBudgetDto', () {
    group('fromJson', () {
      test('should create CategoryBudgetDto with complete JSON', () {
        final json = {
          'id': 1,
          'categoryId': 10,
          'categoryNameAr': 'طعام',
          'categoryNameEn': 'Food',
          'budgetAmount': 2000.0,
          'spent': 1500.0,
        };

        final dto = CategoryBudgetDto.fromJson(json);

        expect(dto.id, 1);
        expect(dto.categoryId, 10);
        expect(dto.categoryNameAr, 'طعام');
        expect(dto.categoryNameEn, 'Food');
        expect(dto.budget, 2000.0);
        expect(dto.spent, 1500.0);
      });

      test('should use defaults when all fields are missing', () {
        final json = <String, dynamic>{};

        final dto = CategoryBudgetDto.fromJson(json);

        expect(dto.id, 0);
        expect(dto.categoryId, 0);
        expect(dto.categoryNameAr, '');
        expect(dto.categoryNameEn, '');
        expect(dto.budget, 0.0);
        expect(dto.spent, 0.0);
      });

      test('should use defaults when fields are null', () {
        final json = {
          'id': null,
          'categoryId': null,
          'categoryNameAr': null,
          'categoryNameEn': null,
          'budgetAmount': null,
          'spent': null,
        };

        final dto = CategoryBudgetDto.fromJson(json);

        expect(dto.id, 0);
        expect(dto.categoryId, 0);
        expect(dto.categoryNameAr, '');
        expect(dto.categoryNameEn, '');
        expect(dto.budget, 0.0);
        expect(dto.spent, 0.0);
      });

      test('should handle integer budget and spent values', () {
        final json = {
          'id': 3,
          'categoryId': 12,
          'categoryNameAr': 'إيجار',
          'categoryNameEn': 'Rent',
          'budgetAmount': 1500,
          'spent': 1500,
        };

        final dto = CategoryBudgetDto.fromJson(json);

        expect(dto.budget, 1500.0);
        expect(dto.spent, 1500.0);
      });
    });
  });

  group('BudgetDto with CategoryBudgetDto integration', () {
    test('should parse nested CategoryBudgetDto list correctly', () {
      final json = {
        'monthlyBudget': 5000.0,
        'currentSpending': 2300.0,
        'categoryBudgets': [
          {
            'id': 1,
            'categoryId': 10,
            'categoryNameAr': 'طعام',
            'categoryNameEn': 'Food',
            'budgetAmount': 2000.0,
            'spent': 1500.0,
          },
        ],
      };

      final budget = BudgetDto.fromJson(json);

      expect(budget.categoryBudgets.length, 1);
      final category = budget.categoryBudgets.first;
      expect(category.id, 1);
      expect(category.categoryId, 10);
      expect(category.categoryNameAr, 'طعام');
      expect(category.categoryNameEn, 'Food');
      expect(category.budget, 2000.0);
      expect(category.spent, 1500.0);
    });
  });
}
