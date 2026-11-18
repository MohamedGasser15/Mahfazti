import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/api_constants.dart';

void main() {
  group('ApiEndpoints', () {
    final endpoints = [
      ApiEndpoints.login,
      ApiEndpoints.register,
      ApiEndpoints.sendCode,
      ApiEndpoints.verifyEmail,
      ApiEndpoints.forgotPassword,
      ApiEndpoints.verifyResetCode,
      ApiEndpoints.resetPassword,
      ApiEndpoints.refresh,
      ApiEndpoints.revoke,
      ApiEndpoints.logout,
      ApiEndpoints.checkEmail,
      ApiEndpoints.googleLogin,
      ApiEndpoints.facebookLogin,
      ApiEndpoints.setCurrency,
      ApiEndpoints.walletHome,
      ApiEndpoints.walletBalance,
      ApiEndpoints.walletTransactions,
      ApiEndpoints.walletAddTransaction,
      ApiEndpoints.walletDeleteTransaction,
      ApiEndpoints.walletSummary,
      ApiEndpoints.budget,
      ApiEndpoints.walletUpdateTransaction,
      ApiEndpoints.categories,
      ApiEndpoints.categoryById,
      ApiEndpoints.banks,
      ApiEndpoints.profileGet,
      ApiEndpoints.profileUpdate,
      ApiEndpoints.changePassword,
    ];

    test('all endpoint strings start with api/', () {
      for (final endpoint in endpoints) {
        expect(
          endpoint.startsWith('api/'),
          isTrue,
          reason: '$endpoint does not start with api/',
        );
      }
    });

    test('no endpoint string is empty', () {
      for (final endpoint in endpoints) {
        expect(
          endpoint.isNotEmpty,
          isTrue,
          reason: 'endpoint should not be empty',
        );
      }
    });

    test('login has expected value', () {
      expect(ApiEndpoints.login, 'api/auth/login');
    });

    test('register has expected value', () {
      expect(ApiEndpoints.register, 'api/auth/register');
    });

    test('sendCode has expected value', () {
      expect(ApiEndpoints.sendCode, 'api/auth/registration-codes');
    });

    test('verifyEmail has expected value', () {
      expect(ApiEndpoints.verifyEmail, 'api/auth/registration-codes/verify');
    });

    test('logout has expected value', () {
      expect(ApiEndpoints.logout, 'api/auth/logout');
    });

    test('checkEmail has expected value', () {
      expect(ApiEndpoints.checkEmail, 'api/Auth/check-email');
    });

    test('forgotPassword has expected value', () {
      expect(ApiEndpoints.forgotPassword, 'api/auth/password-reset-codes');
    });

    test('verifyResetCode has expected value', () {
      expect(
        ApiEndpoints.verifyResetCode,
        'api/auth/password-reset-codes/verify',
      );
    });

    test('resetPassword has expected value', () {
      expect(ApiEndpoints.resetPassword, 'api/auth/password-reset');
    });

    test('refresh has expected value', () {
      expect(ApiEndpoints.refresh, 'api/auth/token/refresh');
    });

    test('walletHome has expected value', () {
      expect(ApiEndpoints.walletHome, 'api/wallet/home');
    });

    test('walletBalance has expected value', () {
      expect(ApiEndpoints.walletBalance, 'api/wallet/balance');
    });

    test('walletTransactions has expected value', () {
      expect(ApiEndpoints.walletTransactions, 'api/wallet/transactions');
    });

    test('walletAddTransaction has expected value', () {
      expect(ApiEndpoints.walletAddTransaction, 'api/wallet/transactions/add');
    });

    test('walletDeleteTransaction has expected value', () {
      expect(
        ApiEndpoints.walletDeleteTransaction,
        'api/wallet/transactions/delete',
      );
    });

    test('walletSummary has expected value', () {
      expect(ApiEndpoints.walletSummary, 'api/wallet/summary');
    });

    test('budget has expected value', () {
      expect(ApiEndpoints.budget, 'api/budget');
    });

    test('setCurrency has expected value', () {
      expect(ApiEndpoints.setCurrency, 'api/profile/currency');
    });

    test('setLanguage has expected value', () {
      expect(ApiEndpoints.setLanguage, 'api/profile/language');
    });

    test('walletUpdateTransaction has expected value', () {
      expect(
        ApiEndpoints.walletUpdateTransaction,
        'api/wallet/transactions/update',
      );
    });

    test('categories has expected value', () {
      expect(ApiEndpoints.categories, 'api/Category');
    });

    test('categoryById has expected value', () {
      expect(ApiEndpoints.categoryById, 'api/Category/');
    });

    test('banks has expected value', () {
      expect(ApiEndpoints.banks, 'api/banks');
    });

    test('profileGet has expected value', () {
      expect(ApiEndpoints.profileGet, 'api/Profile/get');
    });

    test('profileUpdate has expected value', () {
      expect(ApiEndpoints.profileUpdate, 'api/Profile/update');
    });

    test('changePassword has expected value', () {
      expect(ApiEndpoints.changePassword, 'api/Profile/change-password');
    });
  });
}
