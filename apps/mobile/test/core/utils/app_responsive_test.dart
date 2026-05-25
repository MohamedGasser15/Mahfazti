import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';

Widget buildAppWithSize(Size size, Widget child) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: MaterialApp(home: child),
  );
}

void main() {
  group('AppResponsive', () {
    group('isTablet', () {
      testWidgets('returns true when shortest side >= 600',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.isTablet(context), isTrue);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns false when shortest side < 600',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.isTablet(context), isFalse);
            return const SizedBox();
          }),
        ));
      });
    });

    group('isSmallPhone', () {
      testWidgets('returns true when width < 390',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(370, 700),
          Builder(builder: (context) {
            expect(AppResponsive.isSmallPhone(context), isTrue);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns false when width >= 390',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.isSmallPhone(context), isFalse);
            return const SizedBox();
          }),
        ));
      });
    });

    group('fontScale', () {
      testWidgets('returns 1.15 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.fontScale(context), 1.15);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 1.0 for phone', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.fontScale(context), 1.0);
            return const SizedBox();
          }),
        ));
      });
    });

    group('screenPadding', () {
      testWidgets('returns tablet padding on tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(
              AppResponsive.screenPadding(context),
              const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
            );
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns phone padding on phone',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(
              AppResponsive.screenPadding(context),
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            );
            return const SizedBox();
          }),
        ));
      });
    });

    group('horizontalPadding', () {
      testWidgets('returns 60 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(
              AppResponsive.horizontalPadding(context),
              const EdgeInsets.symmetric(horizontal: 60),
            );
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 20 for phone', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(
              AppResponsive.horizontalPadding(context),
              const EdgeInsets.symmetric(horizontal: 20),
            );
            return const SizedBox();
          }),
        ));
      });
    });

    group('bottomNavHeight', () {
      testWidgets('returns 100 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.bottomNavHeight(context), 100);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 80 for phone', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.bottomNavHeight(context), 80);
            return const SizedBox();
          }),
        ));
      });
    });

    group('cardWidth', () {
      testWidgets('returns 0.65 * width for tablet',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.cardWidth(context), 800 * 0.65);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 0.92 * width for phone',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.cardWidth(context), 400 * 0.92);
            return const SizedBox();
          }),
        ));
      });
    });

    group('dialogWidth', () {
      testWidgets('returns 500 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.dialogWidth(context), 500);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 0.92 * width for phone',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.dialogWidth(context), 400 * 0.92);
            return const SizedBox();
          }),
        ));
      });
    });

    group('gridColumnCount', () {
      testWidgets('returns 3 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(800, 1000),
          Builder(builder: (context) {
            expect(AppResponsive.gridColumnCount(context), 3);
            return const SizedBox();
          }),
        ));
      });

      testWidgets('returns 2 for phone', (WidgetTester tester) async {
        await tester.pumpWidget(buildAppWithSize(
          const Size(400, 800),
          Builder(builder: (context) {
            expect(AppResponsive.gridColumnCount(context), 2);
            return const SizedBox();
          }),
        ));
      });
    });
  });
}
