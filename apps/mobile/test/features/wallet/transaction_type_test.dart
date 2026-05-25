import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';

void main() {
  group('TransactionType', () {
    test('has all expected values', () {
      expect(TransactionType.values.length, 3);
      expect(TransactionType.values, contains(TransactionType.all));
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.expense));
    });

    test('all represents all transactions', () {
      expect(TransactionType.all.name, 'all');
    });

    test('income represents deposits', () {
      expect(TransactionType.income.name, 'income');
    });

    test('expense represents withdrawals', () {
      expect(TransactionType.expense.name, 'expense');
    });
  });

  group('TransactionFilter', () {
    test('creates filter with type and label', () {
      final filter = TransactionFilter(
        type: TransactionType.income,
        label: 'Income',
      );

      expect(filter.type, TransactionType.income);
      expect(filter.label, 'Income');
    });
  });
}
