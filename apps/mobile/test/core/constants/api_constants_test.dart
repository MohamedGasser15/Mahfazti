import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/api_constants.dart';

void main() {
  group('ApiEndpoints', () {
    final endpoints = [
      ApiEndpoints.sendVerification,
      ApiEndpoints.verifyCode,
      ApiEndpoints.resendCode,
      ApiEndpoints.verifyAndComplete,
      ApiEndpoints.logout,
      ApiEndpoints.checkEmail,
      ApiEndpoints.recoveryCheckUser,
      ApiEndpoints.recoveryVerifyPassword,
      ApiEndpoints.recoveryRequestEmailChange,
      ApiEndpoints.recoveryConfirmEmailChange,
      ApiEndpoints.forgotPasscode,
      ApiEndpoints.resetPasscode,
      ApiEndpoints.walletHome,
      ApiEndpoints.walletBalance,
      ApiEndpoints.walletTransactions,
      ApiEndpoints.walletAddTransaction,
      ApiEndpoints.walletDeleteTransaction,
      ApiEndpoints.walletSummary,
      ApiEndpoints.budget,
      ApiEndpoints.setCurrency,
      ApiEndpoints.walletUpdateTransaction,
      ApiEndpoints.categories,
      ApiEndpoints.categoryById,
      ApiEndpoints.profileGet,
      ApiEndpoints.profileUpdate,
      ApiEndpoints.changePassword,
    ];

    test('all endpoint strings start with api/', () {
      for (final endpoint in endpoints) {
        expect(endpoint.startsWith('api/'), isTrue,
            reason: '$endpoint does not start with api/');
      }
    });

    test('no endpoint string is empty', () {
      for (final endpoint in endpoints) {
        expect(endpoint.isNotEmpty, isTrue,
            reason: 'endpoint should not be empty');
      }
    });

    test('sendVerification has expected value', () {
      expect(ApiEndpoints.sendVerification, 'api/auth/send-verification');
    });

    test('verifyCode has expected value', () {
      expect(ApiEndpoints.verifyCode, 'api/auth/verify-code');
    });

    test('resendCode has expected value', () {
      expect(ApiEndpoints.resendCode, 'api/auth/resend-code');
    });

    test('verifyAndComplete has expected value', () {
      expect(ApiEndpoints.verifyAndComplete, 'api/auth/verify-complete');
    });

    test('logout has expected value', () {
      expect(ApiEndpoints.logout, 'api/auth/logout');
    });

    test('checkEmail has expected value', () {
      expect(ApiEndpoints.checkEmail, 'api/auth/check-email');
    });

    test('recoveryCheckUser has expected value', () {
      expect(ApiEndpoints.recoveryCheckUser, 'api/auth/recovery/check-user');
    });

    test('recoveryVerifyPassword has expected value', () {
      expect(
          ApiEndpoints.recoveryVerifyPassword, 'api/auth/recovery/verify-password');
    });

    test('recoveryRequestEmailChange has expected value', () {
      expect(ApiEndpoints.recoveryRequestEmailChange,
          'api/auth/recovery/request-email-change');
    });

    test('recoveryConfirmEmailChange has expected value', () {
      expect(ApiEndpoints.recoveryConfirmEmailChange,
          'api/auth/recovery/confirm-email-change');
    });

    test('forgotPasscode has expected value', () {
      expect(ApiEndpoints.forgotPasscode, 'api/auth/passcode/forgot');
    });

    test('resetPasscode has expected value', () {
      expect(ApiEndpoints.resetPasscode, 'api/auth/passcode/reset');
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
          ApiEndpoints.walletDeleteTransaction, 'api/wallet/transactions/delete');
    });

    test('walletSummary has expected value', () {
      expect(ApiEndpoints.walletSummary, 'api/wallet/summary');
    });

    test('budget has expected value', () {
      expect(ApiEndpoints.budget, 'api/budget');
    });

    test('setCurrency has expected value', () {
      expect(ApiEndpoints.setCurrency, 'api/auth/set-currency');
    });

    test('walletUpdateTransaction has expected value', () {
      expect(
          ApiEndpoints.walletUpdateTransaction, 'api/wallet/transactions/update');
    });

    test('categories has expected value', () {
      expect(ApiEndpoints.categories, 'api/Category');
    });

    test('categoryById has expected value', () {
      expect(ApiEndpoints.categoryById, 'api/Category/');
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
