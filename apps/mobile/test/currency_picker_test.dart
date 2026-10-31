import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/presentation/screens/currency_picker_screen.dart';

void main() {
  group('CurrencyPickerScreen Tests', () {
    testWidgets('renders app bar with back button, search bar, and currency list items',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CurrencyPickerScreen(initialCurrency: 'EGP'),
        ),
      );

      // Verify page title and back button
      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.byType(AppGlassBackButton), findsOneWidget);

      // Verify search input
      expect(find.byType(TextField), findsOneWidget);

      // Verify top currency tiles (EGP & SAR)
      expect(find.text('EGP'), findsWidgets);
      expect(find.text('SAR'), findsWidgets);

      // Verify Egypt currency tile details
      expect(find.text('Egyptian Pound'), findsOneWidget);
      expect(find.text('🇪🇬'), findsWidgets);
    });

    testWidgets('filters currencies by query', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CurrencyPickerScreen(initialCurrency: 'USD'),
        ),
      );

      // Enter 'Saudi' in search
      await tester.enterText(find.byType(TextField), 'Saudi');
      await tester.pumpAndSettle();

      expect(find.text('SAR'), findsWidgets);
      expect(find.text('Saudi Riyal'), findsOneWidget);
      expect(find.text('Egyptian Pound'), findsNothing);
    });

    test('AppCurrency matches handles Arabic, English, symbol, and code', () {
      const egp = AppCurrency(
        code: 'EGP',
        nameEn: 'Egyptian Pound',
        nameAr: 'جنيه مصري',
        flag: '🇪🇬',
        symbol: 'E£',
        symbolAr: 'ج.م',
        keywords: ['مصر', 'جنيه', 'egypt'],
      );

      expect(egp.matches('egp'), isTrue);
      expect(egp.matches('Pound'), isTrue);
      expect(egp.matches('جنيه'), isTrue);
      expect(egp.matches('مصر'), isTrue);
      expect(egp.matches('ج.م'), isTrue);
      expect(egp.matches('JPY'), isFalse);
    });
  });
}
