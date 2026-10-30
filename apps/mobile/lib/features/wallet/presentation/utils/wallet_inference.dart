import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

/// Which wallet a transaction was most likely paid from.
///
/// NOTE: the backend does not link transactions to accounts yet (no
/// `accountId` on `WalletTransaction`), so the wallet is inferred from the
/// title / description / category — the same heuristics the Transactions
/// screen already uses for its "All Accounts / Bank / Cash / E-Wallet" filter.
/// Replace this with the real field once the API exposes it.
enum InferredWallet { banqueMisr, cashWallet, eWallet }

InferredWallet inferTransactionWallet(WalletTransaction transaction) {
  final title = transaction.title.toLowerCase();
  final description = (transaction.description ?? '').toLowerCase();
  final categoryEn = (transaction.categoryNameEn ?? '').toLowerCase();
  final categoryAr = transaction.categoryNameAr ?? '';

  bool categoryHas(List<String> keys) =>
      keys.any((key) => categoryEn.contains(key) || categoryAr.contains(key));

  // Bank account: salary, income, investments, bonuses, bank transfers.
  final looksLikeBank = categoryHas([
        'salary',
        'income',
        'invest',
        'bonus',
        'راتب',
        'استثمار',
        'دخل',
        'مكافأة',
      ]) ||
      title.contains('راتب') ||
      title.contains('بنك') ||
      title.contains('bank') ||
      description.contains('بنك') ||
      description.contains('تحويل بنكي');
  if (looksLikeBank) return InferredWallet.banqueMisr;

  // Digital wallet: bills, telecom/internet, freelance income.
  final looksLikeEWallet = categoryHas([
        'bill',
        'utilit',
        'freelance',
        'فواتير',
        'إنترنت',
      ]) ||
      title.contains('إنترنت') ||
      title.contains('فودافون') ||
      title.contains('netflix') ||
      title.contains('spotify') ||
      description.contains('فودافون') ||
      description.contains('فايبر');
  if (looksLikeEWallet) return InferredWallet.eWallet;

  // Everything else is treated as day-to-day cash spending.
  return InferredWallet.cashWallet;
}

String inferredWalletName(
  WalletTransaction transaction, {
  required bool isAr,
}) {
  switch (inferTransactionWallet(transaction)) {
    case InferredWallet.banqueMisr:
      return isAr ? 'بنك مصر' : 'Banque Misr';
    case InferredWallet.eWallet:
      return isAr ? 'محفظة إلكترونية' : 'E-Wallet';
    case InferredWallet.cashWallet:
      return isAr ? 'محفظة كاش' : 'Cash Wallet';
  }
}
