import 'package:dio/dio.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/mock_backend_engine.dart';
import 'package:my_wallet/core/utils/api_error_handler.dart';
import 'package:my_wallet/features/wallet/data/models/budget_models.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

class WalletRepository {
  final ApiService _apiService = ApiService();

  bool get _useMock =>
      (AppConstants.useMockBackend || AppConstants.isTestingEnvironment) &&
      !_apiService.hasTestingDio;

  Future<WalletHomeData> getHomeData({
    int? accountId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    if (_useMock) {
      return MockBackendEngine.instance.getHomeData();
    }

    try {
      final queryParams = <String, dynamic>{};
      if (accountId != null) {
        queryParams['accountId'] = accountId;
      }
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toUtc().toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toUtc().toIso8601String();
      }

      final response = await _apiService.get(
        ApiEndpoints.walletHome,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
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
    if (_useMock) {
      return MockBackendEngine.instance.getBalance();
    }

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
    int? accountId,
    String? searchQuery,
  }) async {
    if (_useMock) {
      return MockBackendEngine.instance.getTransactions(
        page: page,
        pageSize: pageSize,
        fromDate: fromDate,
        toDate: toDate,
        type: type,
        categoryId: categoryId,
        searchQuery: searchQuery,
      );
    }

    try {
      final queryParams = <String, dynamic>{'page': page, 'pageSize': pageSize};

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
      if (accountId != null) {
        queryParams['accountId'] = accountId;
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
    String? title,
    String? description,
    required double amount,
    required String type,
    required int categoryId,
    int? accountId,
    int? toAccountId,
    double? transferFee,
    String? currency,
    DateTime? transactionDate,
    String? receiptImageUrl,
    int? recurringBillId,
    String? tags,
    bool isRecurring = false,
  }) async {
    if (_useMock) {
      return MockBackendEngine.instance.addTransaction(
        title: title,
        description: description,
        amount: amount,
        type: type,
        categoryId: categoryId,
        transactionDate: transactionDate,
        isRecurring: isRecurring,
      );
    }

    try {
      final body = <String, dynamic>{
        'amount': amount,
        'type': type,
        'categoryId': categoryId,
      };
      if (title != null && title.isNotEmpty) {
        body['title'] = title;
      }
      if (description != null && description.isNotEmpty) {
        body['description'] = description;
      }
      if (accountId != null) {
        body['accountId'] = accountId;
      }
      if (toAccountId != null) {
        body['toAccountId'] = toAccountId;
      }
      if (transferFee != null) {
        body['transferFee'] = transferFee;
      }
      if (currency != null) {
        body['currency'] = currency;
      }
      if (receiptImageUrl != null) {
        body['receiptImageUrl'] = receiptImageUrl;
      }
      if (recurringBillId != null) {
        body['recurringBillId'] = recurringBillId;
      }
      if (tags != null) {
        body['tags'] = tags;
      }
      if (transactionDate != null) {
        body['transactionDate'] = transactionDate.toUtc().toIso8601String();
      }

      final response = await _apiService.post(
        ApiEndpoints.walletAddTransaction,
        body,
        requiresAuth: true,
      );

      return WalletTransaction.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<WalletTransaction> updateTransaction(
    int transactionId, {
    String? title,
    String? description,
    required double amount,
    required String type,
    required int categoryId,
    int? accountId,
    int? toAccountId,
    double? transferFee,
    String? currency,
    DateTime? transactionDate,
    String? receiptImageUrl,
    int? recurringBillId,
    String? tags,
    bool isRecurring = false,
    String? recurringInterval,
    DateTime? recurringEndDate,
  }) async {
    if (_useMock) {
      return MockBackendEngine.instance.updateTransaction(
        id: transactionId,
        title: title,
        description: description,
        amount: amount,
        type: type,
        categoryId: categoryId,
        transactionDate: transactionDate,
      );
    }

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
      if (accountId != null) {
        body['accountId'] = accountId;
      }
      if (toAccountId != null) {
        body['toAccountId'] = toAccountId;
      }
      if (transferFee != null) {
        body['transferFee'] = transferFee;
      }
      if (currency != null) {
        body['currency'] = currency;
      }
      if (receiptImageUrl != null) {
        body['receiptImageUrl'] = receiptImageUrl;
      }
      if (recurringBillId != null) {
        body['recurringBillId'] = recurringBillId;
      }
      if (tags != null) {
        body['tags'] = tags;
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

  Future<bool> transferFunds({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    double transferFee = 0.0,
    String? notes,
  }) async {
    if (_useMock) return true;

    try {
      final body = <String, dynamic>{
        'fromAccountId': fromAccountId,
        'toAccountId': toAccountId,
        'amount': amount,
        'transferFee': transferFee,
      };
      if (notes != null && notes.isNotEmpty) {
        body['notes'] = notes;
      }

      await _apiService.post(
        ApiEndpoints.walletTransfer,
        body,
        requiresAuth: true,
      );

      return true;
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to transfer funds: $e');
    }
  }

  Future<VoiceExpenseResult> parseVoiceText(
    String text, {
    String language = 'ar',
  }) async {
    try {
      final response = await _apiService.post(ApiEndpoints.walletVoiceParse, {
        'text': text,
        'language': language,
      }, requiresAuth: true);
      return VoiceExpenseResult.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to parse voice text: $e');
    }
  }

  Future<bool> deleteTransaction(int transactionId) async {
    if (_useMock) {
      await MockBackendEngine.instance.deleteTransaction(transactionId);
      return true;
    }

    try {
      final response = await _apiService.delete(
        '${ApiEndpoints.walletDeleteTransaction}/$transactionId',
        requiresAuth: true,
      );
      if (response.statusCode == 204 || response.statusCode == 200) {
        return true;
      }
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

  Future<BudgetDto> getBudget({int? month, int? year}) async {
    if (_useMock) {
      return MockBackendEngine.instance.getBudget();
    }

    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _apiService.get(
        ApiEndpoints.budget,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
        requiresAuth: true,
      );
      return BudgetDto.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to load budget: $e');
    }
  }

  Future<void> updateMonthlyBudget(double monthlyBudget) async {
    if (_useMock) {
      return MockBackendEngine.instance.updateMonthlyBudget(monthlyBudget);
    }

    try {
      await _apiService.put(ApiEndpoints.budget, {
        'monthlyBudget': monthlyBudget,
      }, requiresAuth: true);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update monthly budget: $e');
    }
  }

  Future<void> updateCategoryBudget(int categoryId, double budget) async {
    if (_useMock) {
      return MockBackendEngine.instance.updateCategoryBudget(
        categoryId,
        budget,
      );
    }

    try {
      await _apiService.put(ApiEndpoints.budgetCategory, {
        'categoryId': categoryId,
        'budget': budget,
      }, requiresAuth: true);
    } on DioException catch (e) {
      throw Exception(ApiErrorHandler.getErrorMessage(e));
    } catch (e) {
      throw Exception('Failed to update category budget: $e');
    }
  }

  Future<WalletSummary> getSummary({
    required DateTime fromDate,
    required DateTime toDate,
    int? accountId,
  }) async {
    if (_useMock) {
      return MockBackendEngine.instance.getSummary(
        fromDate: fromDate,
        toDate: toDate,
        accountId: accountId,
      );
    }

    try {
      final response = await _apiService.get(
        ApiEndpoints.walletSummary,
        queryParams: {
          'fromDate': fromDate.toIso8601String(),
          'toDate': toDate.toIso8601String(),
          if (accountId != null) 'accountId': accountId,
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
