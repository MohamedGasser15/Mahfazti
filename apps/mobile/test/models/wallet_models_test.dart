// ignore_for_file: prefer_const_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';

void main() {
  group('WalletBalance', () {
    const totalBalance = 5000.0;
    const totalDeposits = 15000.0;
    const totalWithdrawals = 10000.0;

    final balanceJson = {
      'totalBalance': totalBalance,
      'totalDeposits': totalDeposits,
      'totalWithdrawals': totalWithdrawals,
    };

    group('fromJson', () {
      test('should create WalletBalance from JSON', () {
        final balance = WalletBalance.fromJson(balanceJson);

        expect(balance.totalBalance, totalBalance);
        expect(balance.totalDeposits, totalDeposits);
        expect(balance.totalWithdrawals, totalWithdrawals);
      });
    });

    group('toJson', () {
      test('should convert WalletBalance to JSON correctly', () {
        final balance = WalletBalance(
          totalBalance: totalBalance,
          totalDeposits: totalDeposits,
          totalWithdrawals: totalWithdrawals,
        );

        final json = balance.toJson();

        expect(json['totalBalance'], totalBalance);
        expect(json['totalDeposits'], totalDeposits);
        expect(json['totalWithdrawals'], totalWithdrawals);
      });
    });

    group('equality', () {
      test('two instances with same values should be equal', () {
        const a = WalletBalance(
          totalBalance: 100,
          totalDeposits: 200,
          totalWithdrawals: 100,
        );
        const b = WalletBalance(
          totalBalance: 100,
          totalDeposits: 200,
          totalWithdrawals: 100,
        );

        expect(a, equals(b));
      });

      test('two instances with different values should not be equal', () {
        const a = WalletBalance(
          totalBalance: 100,
          totalDeposits: 200,
          totalWithdrawals: 100,
        );
        const b = WalletBalance(
          totalBalance: 50,
          totalDeposits: 200,
          totalWithdrawals: 100,
        );

        expect(a, isNot(equals(b)));
      });

      test('props should contain all fields', () {
        final balance = WalletBalance(
          totalBalance: totalBalance,
          totalDeposits: totalDeposits,
          totalWithdrawals: totalWithdrawals,
        );

        expect(balance.props, containsAll([totalBalance, totalDeposits, totalWithdrawals]));
      });
    });
  });

  group('WalletTransaction', () {
    final transactionDate = DateTime(2025, 1, 15);
    final createdAt = DateTime(2025, 1, 10);
    final updatedAt = DateTime(2025, 1, 12);

    final depositJson = {
      'id': 1,
      'userId': 'user_1',
      'title': 'Salary Deposit',
      'description': 'Monthly salary',
      'amount': 5000.0,
      'transactionDate': '2025-01-15T00:00:00.000',
      'type': 'deposit',
      'categoryId': 3,
      'categoryNameAr': 'راتب',
      'categoryNameEn': 'Salary',
      'isRecurring': true,
      'recurringInterval': 'monthly',
      'recurringEndDate': '2026-01-15T00:00:00.000',
      'createdAt': '2025-01-10T00:00:00.000',
      'updatedAt': '2025-01-12T00:00:00.000',
    };

    final withdrawalJson = {
      'id': 2,
      'userId': null,
      'title': 'Groceries',
      'description': null,
      'amount': 150.75,
      'transactionDate': '2025-01-15T00:00:00.000',
      'type': 'withdrawal',
      'categoryId': null,
      'categoryNameAr': null,
      'categoryNameEn': null,
      'isRecurring': false,
      'recurringInterval': null,
      'recurringEndDate': null,
      'createdAt': null,
      'updatedAt': null,
    };

    group('fromJson', () {
      test('should create WalletTransaction from complete deposit JSON', () {
        final tx = WalletTransaction.fromJson(depositJson);

        expect(tx.id, 1);
        expect(tx.userId, 'user_1');
        expect(tx.title, 'Salary Deposit');
        expect(tx.description, 'Monthly salary');
        expect(tx.amount, 5000.0);
        expect(tx.transactionDate, transactionDate);
        expect(tx.type, 'deposit');
        expect(tx.categoryId, 3);
        expect(tx.categoryNameAr, 'راتب');
        expect(tx.categoryNameEn, 'Salary');
        expect(tx.isRecurring, true);
        expect(tx.recurringInterval, 'monthly');
        expect(tx.recurringEndDate, DateTime(2026, 1, 15));
        expect(tx.createdAt, createdAt);
        expect(tx.updatedAt, updatedAt);
      });

      test('should create WalletTransaction with nullable fields as null', () {
        final tx = WalletTransaction.fromJson(withdrawalJson);

        expect(tx.id, 2);
        expect(tx.userId, isNull);
        expect(tx.title, 'Groceries');
        expect(tx.description, isNull);
        expect(tx.amount, 150.75);
        expect(tx.type, 'withdrawal');
        expect(tx.categoryId, isNull);
        expect(tx.categoryNameAr, isNull);
        expect(tx.categoryNameEn, isNull);
        expect(tx.isRecurring, false);
        expect(tx.recurringInterval, isNull);
        expect(tx.recurringEndDate, isNull);
        expect(tx.createdAt, isNull);
        expect(tx.updatedAt, isNull);
      });
    });

    group('toJson', () {
      test('should serialize complete transaction to JSON', () {
        final tx = WalletTransaction.fromJson(depositJson);
        final json = tx.toJson();

        expect(json['id'], 1);
        expect(json['userId'], 'user_1');
        expect(json['title'], 'Salary Deposit');
        expect(json['description'], 'Monthly salary');
        expect(json['amount'], 5000.0);
        expect(json['transactionDate'], '2025-01-15T00:00:00.000');
        expect(json['type'], 'deposit');
        expect(json['categoryId'], 3);
        expect(json['categoryNameAr'], 'راتب');
        expect(json['categoryNameEn'], 'Salary');
        expect(json['isRecurring'], true);
        expect(json['recurringInterval'], 'monthly');
        expect(json['recurringEndDate'], '2026-01-15T00:00:00.000');
        expect(json['createdAt'], '2025-01-10T00:00:00.000');
        expect(json['updatedAt'], '2025-01-12T00:00:00.000');
      });

      test('should omit null fields from JSON', () {
        final tx = WalletTransaction.fromJson(withdrawalJson);
        final json = tx.toJson();

        expect(json.containsKey('userId'), false);
        expect(json.containsKey('description'), false);
        expect(json.containsKey('categoryId'), false);
        expect(json.containsKey('categoryNameAr'), false);
        expect(json.containsKey('categoryNameEn'), false);
        expect(json.containsKey('recurringInterval'), false);
        expect(json.containsKey('recurringEndDate'), false);
        expect(json.containsKey('createdAt'), false);
        expect(json.containsKey('updatedAt'), false);
      });
    });

    group('computed properties', () {
      test('isDeposit should return true for deposit type', () {
        final tx = WalletTransaction.fromJson(depositJson);
        expect(tx.isDeposit, isTrue);
      });

      test('isDeposit should return false for withdrawal type', () {
        final tx = WalletTransaction.fromJson(withdrawalJson);
        expect(tx.isDeposit, isFalse);
      });

      test('isWithdrawal should return true for withdrawal type', () {
        final tx = WalletTransaction.fromJson(withdrawalJson);
        expect(tx.isWithdrawal, isTrue);
      });

      test('isWithdrawal should return false for deposit type', () {
        final tx = WalletTransaction.fromJson(depositJson);
        expect(tx.isWithdrawal, isFalse);
      });

      test('formattedAmount should prefix with + for deposits', () {
        final tx = WalletTransaction.fromJson(depositJson);
        expect(tx.formattedAmount, '+\$5000.00');
      });

      test('formattedAmount should prefix with - for withdrawals', () {
        final tx = WalletTransaction.fromJson(withdrawalJson);
        expect(tx.formattedAmount, '-\$150.75');
      });

      group('icon', () {
        test('should return restaurant icon for food category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Food',
          });
          expect(tx.icon, Icons.restaurant);
        });

        test('should return shopping_bag icon for shopping category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Shopping',
          });
          expect(tx.icon, Icons.shopping_bag);
        });

        test('should return directions_car icon for transport category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Transport',
          });
          expect(tx.icon, Icons.directions_car);
        });

        test('should return movie icon for entertainment category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Entertainment',
          });
          expect(tx.icon, Icons.movie);
        });

        test('should return receipt icon for bills category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Bills',
          });
          expect(tx.icon, Icons.receipt);
        });

        test('should return medical_services icon for health category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Health',
          });
          expect(tx.icon, Icons.medical_services);
        });

        test('should return school icon for education category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Education',
          });
          expect(tx.icon, Icons.school);
        });

        test('should return account_balance_wallet icon for salary category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Salary',
          });
          expect(tx.icon, Icons.account_balance_wallet);
        });

        test('should return default arrow_downward for deposits with unknown category', () {
          final tx = WalletTransaction.fromJson({
            ...depositJson,
            'categoryNameEn': 'Unknown',
          });
          expect(tx.icon, Icons.arrow_downward);
        });

        test('should return default arrow_upward for withdrawals with unknown category', () {
          final tx = WalletTransaction.fromJson({
            ...withdrawalJson,
            'categoryNameEn': 'Unknown',
          });
          expect(tx.icon, Icons.arrow_upward);
        });
      });
    });

    group('equality', () {
      test('two identical transactions should be equal', () {
        final a = WalletTransaction.fromJson(depositJson);
        final b = WalletTransaction.fromJson(depositJson);

        expect(a, equals(b));
      });

      test('two different transactions should not be equal', () {
        final a = WalletTransaction.fromJson(depositJson);
        final b = WalletTransaction.fromJson(withdrawalJson);

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('WalletHomeData', () {
    final homeJson = {
      'balance': {
        'totalBalance': 5000.0,
        'totalDeposits': 15000.0,
        'totalWithdrawals': 10000.0,
      },
      'recentTransactions': [
        {
          'id': 1,
          'title': 'Transaction 1',
          'amount': 100.0,
          'transactionDate': '2025-01-15T00:00:00.000',
          'type': 'deposit',
          'isRecurring': false,
        },
        {
          'id': 2,
          'title': 'Transaction 2',
          'amount': 50.0,
          'transactionDate': '2025-01-14T00:00:00.000',
          'type': 'withdrawal',
          'isRecurring': false,
        },
      ],
      'totalTransactionCount': 42,
    };

    group('fromJson', () {
      test('should create WalletHomeData from JSON', () {
        final data = WalletHomeData.fromJson(homeJson);

        expect(data.balance.totalBalance, 5000.0);
        expect(data.recentTransactions.length, 2);
        expect(data.recentTransactions[0].title, 'Transaction 1');
        expect(data.recentTransactions[1].title, 'Transaction 2');
        expect(data.totalTransactionCount, 42);
      });
    });

    group('equality', () {
      test('two identical instances should be equal', () {
        final a = WalletHomeData.fromJson(homeJson);
        final b = WalletHomeData.fromJson(homeJson);

        expect(a, equals(b));
      });
    });
  });

  group('TransactionListResponse', () {
    final listJson = {
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

    group('fromJson', () {
      test('should create TransactionListResponse from JSON', () {
        final response = TransactionListResponse.fromJson(listJson);

        expect(response.transactions.length, 1);
        expect(response.transactions[0].title, 'TX 1');
        expect(response.totalCount, 1);
        expect(response.page, 1);
        expect(response.pageSize, 20);
        expect(response.totalPages, 1);
      });
    });

    group('equality', () {
      test('two identical responses should be equal', () {
        final a = TransactionListResponse.fromJson(listJson);
        final b = TransactionListResponse.fromJson(listJson);

        expect(a, equals(b));
      });
    });
  });

  group('WalletSummary', () {
    final summaryJson = {
      'totalIncome': 10000.0,
      'totalExpenses': 6000.0,
      'netSavings': 4000.0,
      'expensesByCategory': [
        {
          'categoryId': 1,
          'categoryNameAr': 'طعام',
          'categoryNameEn': 'Food',
          'total': 2000.0,
          'count': 10,
        },
      ],
      'incomeByCategory': [
        {
          'categoryId': 2,
          'categoryNameAr': 'راتب',
          'categoryNameEn': 'Salary',
          'total': 10000.0,
          'count': 1,
        },
      ],
      'transactionCount': 50,
    };

    group('fromJson', () {
      test('should create WalletSummary from JSON', () {
        final summary = WalletSummary.fromJson(summaryJson);

        expect(summary.totalIncome, 10000.0);
        expect(summary.totalExpenses, 6000.0);
        expect(summary.netSavings, 4000.0);
        expect(summary.expensesByCategory.length, 1);
        expect(summary.incomeByCategory.length, 1);
        expect(summary.transactionCount, 50);
      });
    });

    group('equality', () {
      test('two identical summaries should be equal', () {
        final a = WalletSummary.fromJson(summaryJson);
        final b = WalletSummary.fromJson(summaryJson);

        expect(a, equals(b));
      });
    });
  });

  group('CategorySummary', () {
    final categoryJson = {
      'categoryId': 1,
      'categoryNameAr': 'طعام',
      'categoryNameEn': 'Food',
      'total': 2000.0,
      'count': 10,
    };

    group('fromJson', () {
      test('should create CategorySummary from JSON', () {
        final summary = CategorySummary.fromJson(categoryJson);

        expect(summary.categoryId, 1);
        expect(summary.categoryNameAr, 'طعام');
        expect(summary.categoryNameEn, 'Food');
        expect(summary.total, 2000.0);
        expect(summary.count, 10);
      });
    });

    group('equality', () {
      test('two identical category summaries should be equal', () {
        final a = CategorySummary.fromJson(categoryJson);
        final b = CategorySummary.fromJson(categoryJson);

        expect(a, equals(b));
      });

      test('two different category summaries should not be equal', () {
        final a = CategorySummary.fromJson(categoryJson);
        final b = CategorySummary.fromJson(const {
          'categoryId': 2,
          'categoryNameAr': 'مواصلات',
          'categoryNameEn': 'Transport',
          'total': 500.0,
          'count': 5,
        });

        expect(a, isNot(equals(b)));
      });
    });
  });
}
