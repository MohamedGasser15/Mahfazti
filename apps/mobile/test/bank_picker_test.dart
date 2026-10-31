import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/data/repositories/bank_repository.dart';
import 'package:my_wallet/features/wallet/presentation/screens/bank_picker_screen.dart';

void main() {
  group('BankRepository Tests', () {
    test('cachedBanks returns default catalog offline', () {
      final repo = BankRepository();
      expect(repo.cachedBanks.length, greaterThanOrEqualTo(80));
    });
  });

  group('EgyptianBank Matching Tests', () {
    test('matches bank by English name', () {
      const bank = EgyptianBank(
        id: 'cib',
        nameAr: 'البنك التجاري الدولي (CIB)',
        nameEn: 'Commercial International Bank',
        shortName: 'CIB',
        logoAsset: 'assets/icons/banks/cib.png',
      );

      expect(bank.matches('Commercial'), isTrue);
      expect(bank.matches('cib'), isTrue);
      expect(bank.matches('xyz'), isFalse);
    });

    test('matches fintech app by name or id', () {
      final telda = kAllEgyptianBanks.firstWhere((b) => b.id == 'telda');
      expect(telda.matches('Telda'), isTrue);
      expect(telda.matches('تيلدا'), isTrue);

      final redotpay = kAllEgyptianBanks.firstWhere((b) => b.id == 'redotpay');
      expect(redotpay.matches('redotpay'), isTrue);
      expect(redotpay.matches('ريدوت'), isTrue);

      final revolut = kAllEgyptianBanks.firstWhere((b) => b.id == 'revolut');
      expect(revolut.matches('revolut'), isTrue);
      expect(revolut.matches('ريفولوت'), isTrue);

      final instapay = kAllEgyptianBanks.firstWhere((b) => b.id == 'instapay');
      expect(instapay.matches('instapay'), isTrue);
      expect(instapay.matches('إنستاباي'), isTrue);
    });

    test('matches all banks when query is empty', () {
      for (final bank in kAllEgyptianBanks) {
        expect(bank.matches(''), isTrue);
      }
    });

    test('all 80+ institutions have valid id, logo and names', () {
      expect(kAllEgyptianBanks.length, greaterThanOrEqualTo(80));
      for (final bank in kAllEgyptianBanks) {
        expect(bank.id.isNotEmpty, isTrue);
        expect(bank.nameAr.isNotEmpty, isTrue);
        expect(bank.nameEn.isNotEmpty, isTrue);
        expect(bank.logoUrl != null && bank.logoUrl!.startsWith('http'), isTrue);
      }
    });
  });

  group('BankPickerScreen Widget Tests', () {
    testWidgets('renders search bar and unified banks list', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BankPickerScreen(autoSync: false),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('إنستاباي (InstaPay)'), findsOneWidget);
      expect(find.text('البنك الأهلي المصري (NBE)'), findsOneWidget);

      // Verify that the custom bank addition option was removed as requested
      expect(find.text('إضافة اسم بنك آخر'), findsNothing);
      expect(find.text('بنك آخر'), findsNothing);
    });

    testWidgets('filters banks list when query is entered', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BankPickerScreen(autoSync: false),
          ),
        ),
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Revolut');
      await tester.pumpAndSettle();

      expect(find.text('ريفولوت (Revolut)'), findsOneWidget);
      expect(find.text('بنك مصر (Banque Misr)'), findsNothing);
    });

    testWidgets('shows empty state when no bank matches query', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BankPickerScreen(autoSync: false),
          ),
        ),
      );

      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'UnknownBank123');
      await tester.pumpAndSettle();

      expect(find.text('لا توجد نتائج لـ "UnknownBank123"'), findsOneWidget);
    });

    testWidgets('renders category chips and section headers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: BankPickerScreen(autoSync: false),
          ),
        ),
      );

      // Verify category chips exist with labels and icons
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('الأكثر طلباً'), findsOneWidget);
      expect(find.text('بنوك مصر'), findsOneWidget);
      expect(find.text('محافظ وتطبيقات'), findsOneWidget);
      expect(find.text('بنوك العالم'), findsOneWidget);

      expect(find.byIcon(Icons.apps_rounded), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsWidgets);
      expect(find.byIcon(Icons.account_balance_rounded), findsWidgets);
      expect(find.byIcon(Icons.account_balance_wallet_rounded), findsWidgets);
      expect(find.byIcon(Icons.public_rounded), findsOneWidget);

      // Verify section header exists for top section
      expect(find.text('الأكثر استخداماً'), findsOneWidget);

      // Tap on 'بنوك مصر' chip
      await tester.tap(find.text('بنوك مصر'));
      await tester.pumpAndSettle();

      // Only Egyptian banks section header should be present
      expect(find.text('البنوك المصرية'), findsOneWidget);
      expect(find.text('الأكثر استخداماً'), findsNothing);
    });
  });
}
