import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/services/message_service.dart';

void main() {
  group('MessageService', () {
    Future<void> pumpApp(WidgetTester tester, {Locale locale = const Locale('en')}) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: locale,
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: const _TestHome(),
        ),
      );
    }

    testWidgets('showSuccess creates overlay with success message',
        (WidgetTester tester) async {
      await pumpApp(tester);
      MessageService.showSuccess(
        context: tester.element(find.byType(_TestHome)),
        message: 'Success message',
      );
      await tester.pump();

      expect(find.text('Success message'), findsOneWidget);
      expect(
        find.byIcon(Icons.check_circle_outline_rounded),
        findsOneWidget,
      );
    });

    testWidgets('showError creates overlay with error message',
        (WidgetTester tester) async {
      await pumpApp(tester);
      MessageService.showError(
        context: tester.element(find.byType(_TestHome)),
        message: 'Error message',
      );
      await tester.pump();

      expect(find.text('Error message'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('showInfo creates overlay with info message',
        (WidgetTester tester) async {
      await pumpApp(tester);
      MessageService.showInfo(
        context: tester.element(find.byType(_TestHome)),
        message: 'Info message',
      );
      await tester.pump();

      expect(find.text('Info message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('showWarning creates overlay with warning message',
        (WidgetTester tester) async {
      await pumpApp(tester);
      MessageService.showWarning(
        context: tester.element(find.byType(_TestHome)),
        message: 'Warning message',
      );
      await tester.pump();

      expect(find.text('Warning message'), findsOneWidget);
      expect(
        find.byIcon(Icons.warning_amber_rounded),
        findsOneWidget,
      );
    });

    testWidgets('dismissing overlay on tap removes it',
        (WidgetTester tester) async {
      await pumpApp(tester);
      MessageService.showSuccess(
        context: tester.element(find.byType(_TestHome)),
        message: 'Dismiss me',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Dismiss me'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Dismiss me'), findsNothing);
    });
  });
}

class _TestHome extends StatelessWidget {
  const _TestHome();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Home')),
    );
  }
}
