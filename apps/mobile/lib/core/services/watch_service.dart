import 'package:flutter/services.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_repository.dart';

class WatchService {
  static const _channel = MethodChannel('com.mahfazti.watch/connector');
  
  static final WalletRepository _walletRepo = WalletRepository();
  static final CategoryRepository _categoryRepo = CategoryRepository();

  // ── Initialize - بنناديه مرة واحدة في main.dart ──
  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  // ── استقبال calls من الـ Native (AppDelegate) ──
static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'getHomeData':        // ✅ نفس الـ action اللي Watch بيبعته
        return await _getHomeData();
      case 'parseVoice':         // ✅ نفس الـ action
        final args = call.arguments as Map<dynamic, dynamic>;
        return await _parseVoice(
          args['text'] as String? ?? '',
          args['language'] as String? ?? 'en',
        );
      case 'addTransaction':     // ✅ نفس الـ action
        final args = call.arguments as Map<dynamic, dynamic>;
        return await _addTransaction(
          (args['amount'] as num?)?.toDouble() ?? 0,
          args['type'] as String? ?? 'Withdrawal',
          args['category'] as String? ?? 'Other',
        );
      default:
        throw PlatformException(code: 'NOT_IMPLEMENTED');
    }
}
  // ── جيب البيانات من الـ API وبعتها للـ Watch ──
  static Future<Map<String, dynamic>> _getHomeData() async {
    try {
      final data = await _walletRepo.getHomeData();

      // ✅ نحول البيانات لـ Map بسيطة يفهمها الـ Watch
      return {
        'totalBalance': data.balance.totalBalance,
        'totalDeposits': data.balance.totalDeposits,
        'totalWithdrawals': data.balance.totalWithdrawals,
        'recentTransactions': data.recentTransactions.take(5).map((t) => {
          'id': t.id,
          'title': t.title,
          'amount': t.amount,
          'type': t.type,
          'categoryNameEn': t.categoryNameEn ?? '',
          'categoryNameAr': t.categoryNameAr ?? '',
        }).toList(),
      };
    } catch (e) {
      return {
        'totalBalance': 0.0,
        'totalDeposits': 0.0,
        'totalWithdrawals': 0.0,
        'recentTransactions': [],
        'error': e.toString(),
      };
    }
  }

  // ── ابعت النص للـ API يحلله ──
  static Future<Map<String, dynamic>> _parseVoice(
    String text,
    String language,
  ) async {
    try {
      final result = await _walletRepo.parseVoiceText(
        text,
        language: language,
      );

      return {
        'amount': result.amount,
        'transactionType': result.transactionType,
        'categoryId': result.categoryId,
        'categoryNameEn': result.categoryNameEn ?? 'Other',
        'categoryNameAr': result.categoryNameAr ?? 'أخرى',
        'isSuccess': result.isSuccess,
      };
    } catch (e) {
      return {
        'isSuccess': false,
        'error': e.toString(),
      };
    }
  }

  // ── ضيف الـ transaction عن طريق الـ API ──
  static Future<bool> _addTransaction(
    double amount,
    String type,
    String categoryNameEn,
  ) async {
    try {
      // ✅ نلاقي الـ categoryId من الاسم
      final categories = await _categoryRepo.getAllCategories();
      final category = categories.firstWhere(
        (c) => c.nameEn.toLowerCase() == categoryNameEn.toLowerCase(),
        orElse: () => categories.last, // Other كـ fallback
      );

      await _walletRepo.addTransaction(
        amount: amount,
        type: type,
        categoryId: category.id,
        description: 'Added from Apple Watch',
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  // ── بعت update للـ Watch لما البيانات تتغير (اختياري) ──
  static Future<void> pushDataToWatch() async {
    try {
      final data = await _getHomeData();
      await _channel.invokeMethod('sendDataToWatch', data);
    } catch (e) {
      // Watch ممكن يكون مش متصل - مش error
    }
  }
}