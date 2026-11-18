import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/auth/presentation/controllers/register_controller.dart';
import 'package:my_wallet/features/auth/presentation/models/registration_step.dart';
import 'package:my_wallet/features/auth/presentation/screens/register_screen.dart';
import 'package:my_wallet/features/auth/presentation/widgets/otp_input_field.dart';
import 'package:my_wallet/features/auth/presentation/widgets/social_login_section.dart';
import 'package:my_wallet/l10n/app_localizations.dart';

Widget createTestRegisterApp({
  RegisterController? controller,
  VoidCallback? onSwitchToLogin,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: const MediaQueryData(disableAnimations: true),
      child: RegisterScreen(
        controller: controller,
        onSwitchToLogin: onSwitchToLogin,
      ),
    ),
  );
}

void main() {
  testWidgets('renders standalone RegisterScreen with email step initially', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createTestRegisterApp());
    await tester.pumpAndSettle();

    expect(find.byType(AppGlassBackButton), findsOneWidget);
    expect(find.text('Create your account'), findsOneWidget);
    expect(find.text('What is your email?'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget); // email field
    expect(find.byType(SocialLoginSection), findsOneWidget);
  });

  testWidgets('renders verification step when step is set to verification', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = RegisterController();
    addTearDown(() => controller.dispose());

    await tester.pumpWidget(createTestRegisterApp(controller: controller));
    await tester.pumpAndSettle();

    controller.setStep(RegistrationStep.verification);
    await tester.pumpAndSettle();

    expect(find.text('Enter verification code'), findsOneWidget);
    expect(find.byType(OtpInputField), findsOneWidget);
    expect(find.text('Verify'), findsOneWidget);
  });

  testWidgets('renders details step with name and password fields', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final controller = RegisterController();
    addTearDown(() => controller.dispose());

    await tester.pumpWidget(createTestRegisterApp(controller: controller));
    await tester.pumpAndSettle();

    controller.setStep(RegistrationStep.details);
    await tester.pumpAndSettle();

    expect(
      find.byType(TextFormField),
      findsNWidgets(3),
    ); // Name, Password, ConfirmPassword
    expect(find.text('Register'), findsOneWidget); // Register Button
    expect(find.text('Login'), findsOneWidget); // Toggle
  });

  testWidgets('calls onSwitchToLogin when Login toggle button tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    var switched = false;
    await tester.pumpWidget(
      createTestRegisterApp(onSwitchToLogin: () => switched = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(switched, true);
  });
}
