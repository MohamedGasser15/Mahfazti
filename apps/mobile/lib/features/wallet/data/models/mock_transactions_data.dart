import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

/// Returns an empty list so no mock or seeded transactions are shown.
/// Transactions are strictly isolated and owned per user.
List<WalletTransaction> getRichSampleTransactions() {
  return const <WalletTransaction>[];
}
