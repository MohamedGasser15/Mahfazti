import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/home_tab_models.dart';

void main() {
  group('TransactionType', () {
    test('has all expected values', () {
      expect(TransactionType.values.length, 4);
      expect(TransactionType.values, contains(TransactionType.all));
      expect(TransactionType.values, contains(TransactionType.income));
      expect(TransactionType.values, contains(TransactionType.expense));
      expect(TransactionType.values, contains(TransactionType.transfer));
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

    test('transfer represents transfers', () {
      expect(TransactionType.transfer.name, 'transfer');
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
