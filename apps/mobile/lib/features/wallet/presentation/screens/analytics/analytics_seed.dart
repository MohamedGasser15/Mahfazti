import 'package:my_wallet/features/wallet/data/models/mock_transactions_data.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

/// Builds a [WalletSummary] from the bundled sample transactions.
///
/// Used as a demo/offline seed so the analytics screen never shows an empty
/// dashboard while the API has no data for the selected period.
WalletSummary buildSampleSummary({
  required DateTime from,
  required DateTime to,
}) {
  final transactions = getRichSampleTransactions().where((transaction) {
    final date = transaction.transactionDate;
    return !date.isBefore(from) && !date.isAfter(to);
  }).toList();

  var income = 0.0;
  var expenses = 0.0;
  final incomeByCategory = <String, _CategoryAccumulator>{};
  final expensesByCategory = <String, _CategoryAccumulator>{};

  for (final transaction in transactions) {
    final isIncome = transaction.type.toLowerCase().startsWith('dep');
    final categoryId = transaction.categoryId ?? -1;
    final nameAr = transaction.categoryNameAr ?? transaction.title;
    final nameEn = transaction.categoryNameEn ?? transaction.title;
    // The sample data reuses category ids with different names, so the name is
    // part of the key as well.
    final key = '$categoryId|$nameEn';
    final bucket = isIncome ? incomeByCategory : expensesByCategory;
    final accumulator = bucket.putIfAbsent(
      key,
      () =>
          _CategoryAccumulator(id: categoryId, nameAr: nameAr, nameEn: nameEn),
    );

    accumulator.total += transaction.amount;
    accumulator.count += 1;

    if (isIncome) {
      income += transaction.amount;
    } else {
      expenses += transaction.amount;
    }
  }

  return WalletSummary(
    totalIncome: income,
    totalExpenses: expenses,
    netSavings: income - expenses,
    expensesByCategory: _toSummaries(expensesByCategory),
    incomeByCategory: _toSummaries(incomeByCategory),
    transactionCount: transactions.length,
  );
}

/// Scales a summary so a comparison window always has something to compare
/// against, even when the sample data does not reach that far back.
WalletSummary scaleSampleSummary(
  WalletSummary summary, {
  double incomeFactor = 0.94,
  double expensesFactor = 1.07,
}) {
  final income = summary.totalIncome * incomeFactor;
  final expenses = summary.totalExpenses * expensesFactor;
  return WalletSummary(
    totalIncome: income,
    totalExpenses: expenses,
    netSavings: income - expenses,
    expensesByCategory: const [],
    incomeByCategory: const [],
    transactionCount: summary.transactionCount,
  );
}

/// Whether a summary has nothing worth rendering.
bool isBlankSummary(WalletSummary summary) {
  return summary.transactionCount == 0 &&
      summary.totalIncome == 0 &&
      summary.totalExpenses == 0;
}

List<CategorySummary> _toSummaries(
  Map<String, _CategoryAccumulator> categories,
) {
  final sorted = categories.values.toList()
    ..sort((a, b) => b.total.compareTo(a.total));
  return [
    for (final category in sorted)
      CategorySummary(
        categoryId: category.id,
        categoryNameAr: category.nameAr,
        categoryNameEn: category.nameEn,
        total: category.total,
        count: category.count,
      ),
  ];
}

class _CategoryAccumulator {
  _CategoryAccumulator({
    required this.id,
    required this.nameAr,
    required this.nameEn,
  });

  final int id;
  final String nameAr;
  final String nameEn;
  double total = 0;
  int count = 0;
}
