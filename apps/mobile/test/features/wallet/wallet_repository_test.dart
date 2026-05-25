import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

Dio _mockDio(Map<String, Response Function(RequestOptions)> handlers) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      for (final entry in handlers.entries) {
        if (options.path.contains(entry.key)) {
          handler.resolve(entry.value(options));
          return;
        }
      }
      handler.reject(DioException(
        requestOptions: options,
        type: DioExceptionType.unknown,
      ));
    },
  ));
  return dio;
}

Response _jsonResponse(RequestOptions options, Map<String, dynamic> data,
    {int statusCode = 200}) {
  return Response(requestOptions: options, data: data, statusCode: statusCode);
}

const _homeResponse = {
  'balance': {
    'totalBalance': 5000.0,
    'totalDeposits': 15000.0,
    'totalWithdrawals': 10000.0,
  },
  'recentTransactions': [
    {
      'id': 1,
      'title': 'Salary',
      'amount': 5000.0,
      'transactionDate': '2025-01-15T00:00:00.000',
      'type': 'deposit',
      'isRecurring': false,
    },
  ],
  'totalTransactionCount': 42,
};

const _balanceResponse = {
  'totalBalance': 5000.0,
  'totalDeposits': 15000.0,
  'totalWithdrawals': 10000.0,
};

const _transactionResponse = {
  'id': 1,
  'title': 'New Transaction',
  'amount': 100.0,
  'transactionDate': '2025-01-15T00:00:00.000',
  'type': 'deposit',
  'isRecurring': false,
};

const _listResponse = {
  'transactions': [
    {
      'id': 1,
      'title': 'TX 1',
      'amount': 100.0,
      'transactionDate': '2025-01-15T00:00:00.000',
      'type': 'deposit',
      'isRecurring': false,
    },
  ],
  'totalCount': 1,
  'page': 1,
  'pageSize': 20,
  'totalPages': 1,
};

void main() {
  group('WalletRepository', () {
    late WalletRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await SharedPrefs.init();
      repository = WalletRepository();
    });

    group('getHomeData', () {
      test('returns WalletHomeData on success', () async {
        ApiService().dioForTesting = _mockDio({
          'home': (options) =>
              _jsonResponse(options, _homeResponse),
        });

        final result = await repository.getHomeData();

        expect(result, isA<WalletHomeData>());
        expect(result.balance.totalBalance, 5000.0);
        expect(result.recentTransactions.length, 1);
        expect(result.totalTransactionCount, 42);
      });
    });

    group('getBalance', () {
      test('returns WalletBalance on success', () async {
        ApiService().dioForTesting = _mockDio({
          'balance': (options) =>
              _jsonResponse(options, _balanceResponse),
        });

        final result = await repository.getBalance();

        expect(result, isA<WalletBalance>());
        expect(result.totalBalance, 5000.0);
        expect(result.totalDeposits, 15000.0);
        expect(result.totalWithdrawals, 10000.0);
      });
    });

    group('getTransactions', () {
      test('returns TransactionListResponse on success', () async {
        ApiService().dioForTesting = _mockDio({
          'transactions': (options) =>
              _jsonResponse(options, _listResponse),
        });

        final result = await repository.getTransactions();

        expect(result, isA<TransactionListResponse>());
        expect(result.transactions.length, 1);
        expect(result.totalCount, 1);
      });
    });

    group('addTransaction', () {
      test('returns WalletTransaction on success', () async {
        ApiService().dioForTesting = _mockDio({
          'add': (options) =>
              _jsonResponse(options, _transactionResponse),
        });

        final result = await repository.addTransaction(
          amount: 100.0,
          type: 'deposit',
          categoryId: 1,
        );

        expect(result, isA<WalletTransaction>());
        expect(result.id, 1);
        expect(result.amount, 100.0);
      });
    });

    group('deleteTransaction', () {
      test('returns true on success', () async {
        ApiService().dioForTesting = _mockDio({
          'delete': (options) =>
              _jsonResponse(options, {'success': true}),
        });

        final result = await repository.deleteTransaction(1);

        expect(result, isTrue);
      });
    });

    group('getSummary', () {
      test('returns WalletSummary on success', () async {
        ApiService().dioForTesting = _mockDio({
          'summary': (options) => _jsonResponse(options, {
                'totalIncome': 10000.0,
                'totalExpenses': 6000.0,
                'netSavings': 4000.0,
                'expensesByCategory': [],
                'incomeByCategory': [],
                'transactionCount': 50,
              }),
        });

        final result = await repository.getSummary(
          fromDate: DateTime(2025, 1, 1),
          toDate: DateTime(2025, 1, 31),
        );

        expect(result, isA<WalletSummary>());
        expect(result.totalIncome, 10000.0);
        expect(result.totalExpenses, 6000.0);
      });
    });
  });
}
