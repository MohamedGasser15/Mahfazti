import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/auth/presentation/controllers/register_controller.dart';
import 'package:my_wallet/features/auth/presentation/models/registration_step.dart';

void main() {
  group('RegisterController Tests', () {
    late RegisterController controller;

    setUp(() {
      controller = RegisterController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.step, RegistrationStep.email);
      expect(controller.registeredEmail, isNull);
      expect(controller.resendSeconds, 90);
      expect(controller.isSendingCode, false);
      expect(controller.isVerifying, false);
      expect(controller.isRegistering, false);
      expect(controller.needsFreshCode, false);
      expect(controller.obscurePassword, true);
      expect(controller.obscureConfirmPassword, true);
      expect(controller.codeControllers.length, 6);
      expect(controller.codeFocusNodes.length, 6);
    });

    test('toggle password obscurity works', () {
      expect(controller.obscurePassword, true);
      controller.toggleObscurePassword();
      expect(controller.obscurePassword, false);

      expect(controller.obscureConfirmPassword, true);
      controller.toggleObscureConfirmPassword();
      expect(controller.obscureConfirmPassword, false);
    });

    test('setStep changes step and notifies listeners', () {
      var notified = false;
      controller.addListener(() => notified = true);

      controller.setStep(RegistrationStep.verification);
      expect(controller.step, RegistrationStep.verification);
      expect(notified, true);
    });

    test('resetToEmailStep resets step to email', () {
      controller.setStep(RegistrationStep.details);
      expect(controller.step, RegistrationStep.details);

      controller.resetToEmailStep();
      expect(controller.step, RegistrationStep.email);
    });

    test('handleBack steps back appropriately', () {
      // Step: details -> verification
      controller.setStep(RegistrationStep.details);
      final handledFromDetails = controller.handleBack();
      expect(handledFromDetails, true);
      expect(controller.step, RegistrationStep.verification);
      expect(controller.needsFreshCode, true);
      expect(controller.resendSeconds, 0);

      // Step: verification -> email
      final handledFromVerification = controller.handleBack();
      expect(handledFromVerification, true);
      expect(controller.step, RegistrationStep.email);

      // Step: email -> returns false (cannot go back further)
      final handledFromEmail = controller.handleBack();
      expect(handledFromEmail, false);
      expect(controller.step, RegistrationStep.email);
    });

    test(
      'startCountdown and stopCountdown control the countdown timer',
      () async {
        controller.startCountdown();
        expect(controller.resendSeconds, 90);

        controller.stopCountdown();
        final capturedSeconds = controller.resendSeconds;
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        expect(controller.resendSeconds, capturedSeconds);
      },
    );
  });
}
