import 'package:dio/dio.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

class WalletRepository {
  final ApiService _apiService = ApiService();

  Future<WalletHomeData> getHomeData() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.walletHome,
        requiresAuth: true,
      );

      return WalletHomeData.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load home data: $e');
    }
  }

  Future<WalletBalance> getBalance() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.walletBalance,
        requiresAuth: true,
      );

      return WalletBalance.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load balance: $e');
    }
  }

  Future<TransactionListResponse> getTransactions({
    int page = 1,
    int pageSize = 20,
    DateTime? fromDate,
    DateTime? toDate,
    String? type,
    int? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };

      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }
      if (type != null && type.isNotEmpty) {
        queryParams['type'] = type;
      }
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _apiService.get(
        ApiEndpoints.walletTransactions,
        queryParams: queryParams,
        requiresAuth: true,
      );

      return TransactionListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

Future<WalletTransaction> addTransaction({
  String? description,
  required double amount,
  required String type,
  required int categoryId,
}) async {
  try {
    final body = <String, dynamic>{
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    final response = await _apiService.post(
      ApiEndpoints.walletAddTransaction,
      body,
      requiresAuth: true,
    );
    return WalletTransaction.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception(ApiErrorHandler.getErrorMessage(e));
  }
}

  Future<WalletTransaction> updateTransaction(
    int transactionId, {
    required String title,
    String? description,
    required double amount,
    required String type,
    required int categoryId,
    DateTime? transactionDate,
    bool isRecurring = false,
    String? recurringInterval,
    DateTime? recurringEndDate,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'amount': amount,
        'type': type,
        'categoryId': categoryId,
        'isRecurring': isRecurring,
      };

      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (transactionDate != null) {
        body['transactionDate'] = transactionDate.toIso8601String();
      }
      if (recurringInterval != null) {
        body['recurringInterval'] = recurringInterval;
      }
      if (recurringEndDate != null) {
        body['recurringEndDate'] = recurringEndDate.toIso8601String();
      }

      final response = await _apiService.put(
        '${ApiEndpoints.walletUpdateTransaction}/$transactionId',
        body,
        requiresAuth: true,
      );

      return WalletTransaction.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

Future<VoiceExpenseResult> parseVoiceText(String text, {String language = 'ar'}) async {
  try {
    final response = await _apiService.post(
      ApiEndpoints.walletVoiceParse,
      {'text': text, 'language': language},
      requiresAuth: true,
    );
    return VoiceExpenseResult.fromJson(response.data);
  } on DioException catch (e) {
    throw Exception(ApiErrorHandler.getErrorMessage(e));
  }
}

  Future<bool> deleteTransaction(int transactionId) async {
    try {
      await _apiService.delete(
        '${ApiEndpoints.walletDeleteTransaction}/$transactionId',
        requiresAuth: true,
      );
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 204 || e.response?.statusCode == 200) {
        return true;
      }
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<BudgetDto> getBudget() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.budget,
        requiresAuth: true,
      );
      return BudgetDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> updateMonthlyBudget(double monthlyBudget) async {
    try {
      await _apiService.put(
        ApiEndpoints.budget,
        {'monthlyBudget': monthlyBudget},
        requiresAuth: true,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<void> updateCategoryBudget(int categoryId, double budget) async {
    try {
      await _apiService.put(
        ApiEndpoints.budgetCategory,
        {'categoryId': categoryId, 'budget': budget},
        requiresAuth: true,
      );
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    }
  }

  Future<WalletSummary> getSummary({
    required DateTime fromDate,
    required DateTime toDate,
  }) async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.walletSummary,
        queryParams: {
          'fromDate': fromDate.toIso8601String(),
          'toDate': toDate.toIso8601String(),
        },
        requiresAuth: true,
      );

      return WalletSummary.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load summary: $e');
    }
  }
}
