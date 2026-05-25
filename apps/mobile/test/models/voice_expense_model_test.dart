// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';

void main() {
  group('VoiceExpenseResult', () {
    group('fromJson - success case', () {
      test('should parse a successful voice expense result', () {
        final json = {
          'amount': 250.50,
          'transactionType': 'Withdrawal',
          'categoryId': 5,
          'categoryNameAr': 'طعام',
          'categoryNameEn': 'Food',
          'note': 'غداء مع الأصدقاء',
          'title': 'مصروف مطعم',
          'isSuccess': true,
          'errorMessage': null,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.amount, 250.50);
        expect(result.transactionType, 'Withdrawal');
        expect(result.categoryId, 5);
        expect(result.categoryNameAr, 'طعام');
        expect(result.categoryNameEn, 'Food');
        expect(result.note, 'غداء مع الأصدقاء');
        expect(result.title, 'مصروف مطعم');
        expect(result.isSuccess, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should parse a deposit type expense result', () {
        final json = {
          'amount': 5000.0,
          'transactionType': 'Deposit',
          'categoryId': 3,
          'categoryNameAr': 'راتب',
          'categoryNameEn': 'Salary',
          'note': null,
          'title': 'الراتب الشهري',
          'isSuccess': true,
          'errorMessage': null,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.amount, 5000.0);
        expect(result.transactionType, 'Deposit');
        expect(result.isSuccess, isTrue);
        expect(result.errorMessage, isNull);
      });

      test('should use default transactionType when missing', () {
        final json = {
          'amount': 100.0,
          'categoryId': 2,
          'isSuccess': true,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.transactionType, 'Withdrawal');
        expect(result.amount, 100.0);
        expect(result.isSuccess, isTrue);
      });
    });

    group('fromJson - failure case', () {
      test('should parse a failed voice expense result with error', () {
        final json = {
          'amount': null,
          'transactionType': 'Withdrawal',
          'categoryId': null,
          'categoryNameAr': null,
          'categoryNameEn': null,
          'note': null,
          'title': null,
          'isSuccess': false,
          'errorMessage': 'لم يتم التعرف على المبلغ',
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.amount, isNull);
        expect(result.transactionType, 'Withdrawal');
        expect(result.categoryId, isNull);
        expect(result.categoryNameAr, isNull);
        expect(result.categoryNameEn, isNull);
        expect(result.note, isNull);
        expect(result.title, isNull);
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'لم يتم التعرف على المبلغ');
      });

      test('should handle failure result with null errorMessage', () {
        final json = {
          'isSuccess': false,
          'errorMessage': null,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, isNull);
        expect(result.amount, isNull);
        expect(result.transactionType, 'Withdrawal');
        expect(result.title, isNull);
      });
    });

    group('fromJson - edge cases', () {
      test('should handle empty JSON', () {
        final json = <String, dynamic>{};

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.amount, isNull);
        expect(result.transactionType, 'Withdrawal');
        expect(result.categoryId, isNull);
        expect(result.categoryNameAr, isNull);
        expect(result.categoryNameEn, isNull);
        expect(result.note, isNull);
        expect(result.title, isNull);
        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, isNull);
      });

      test('should handle amount as integer', () {
        final json = {
          'amount': 100,
          'isSuccess': true,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.amount, 100.0);
      });

      test('should handle isSuccess defaulting to false', () {
        final json = {
          'amount': 50.0,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.isSuccess, isFalse);
      });

      test('should handle string values for all string fields', () {
        final json = {
          'amount': 75.0,
          'transactionType': 'Withdrawal',
          'categoryId': 7,
          'categoryNameAr': 'تسوق',
          'categoryNameEn': 'Shopping',
          'note': 'ملاحظة test',
          'title': 'عنوان test',
          'isSuccess': true,
          'errorMessage': null,
        };

        final result = VoiceExpenseResult.fromJson(json);

        expect(result.categoryNameAr, 'تسوق');
        expect(result.categoryNameEn, 'Shopping');
        expect(result.note, 'ملاحظة test');
        expect(result.title, 'عنوان test');
      });
    });
  });
}
