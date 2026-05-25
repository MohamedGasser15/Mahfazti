import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';

void main() {
  group('LocalizationExtension', () {
    testWidgets('isArabic returns true when locale is ar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) {
              expect(context.isArabic, isTrue);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('isArabic returns false when locale is en',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: const [Locale('en'), Locale('ar')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          home: Builder(
            builder: (context) {
              expect(context.isArabic, isFalse);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
