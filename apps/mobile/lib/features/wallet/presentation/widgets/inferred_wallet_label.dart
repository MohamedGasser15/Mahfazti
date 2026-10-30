import 'package:flutter/material.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/presentation/utils/wallet_inference.dart';

/// Small icon + label that tells which wallet a transaction was paid from.
///
/// Each wallet gets its own accent color and glyph so the rows scan quickly:
/// Banque Misr (blue bank), Cash Wallet (green cash), E-Wallet (violet phone).
class InferredWalletLabel extends StatelessWidget {
  final WalletTransaction transaction;
  final bool isDarkMode;

  const InferredWalletLabel({
    super.key,
    required this.transaction,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final wallet = inferTransactionWallet(transaction);
    // Neutral tone — wallets are told apart by their glyph, not by color.
    final color =
        isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(_glyph(wallet), size: 11.5, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            inferredWalletName(transaction, isAr: isAr),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  IconData _glyph(InferredWallet wallet) {
    switch (wallet) {
      case InferredWallet.banqueMisr:
        return Icons.account_balance_rounded;
      case InferredWallet.cashWallet:
        return Icons.payments_rounded;
      case InferredWallet.eWallet:
        return Icons.smartphone_rounded;
    }
  }
}
