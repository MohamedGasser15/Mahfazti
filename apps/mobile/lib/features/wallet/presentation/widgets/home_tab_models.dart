enum TransactionType { all, income, expense }

class TransactionFilter {
  final TransactionType type;
  final String label;

  TransactionFilter({
    required this.type,
    required this.label,
  });
}
