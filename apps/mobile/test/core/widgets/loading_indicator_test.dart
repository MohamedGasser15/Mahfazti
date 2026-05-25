import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/widgets/loading_indicator.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('LoadingIndicator', () {
    testWidgets('shows CircularProgressIndicator', (tester) async {
      await tester.pumpWidget(createTestApp(const LoadingIndicator()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('accepts custom color', (tester) async {
      await tester.pumpWidget(createTestApp(
        const LoadingIndicator(color: Colors.red),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(createTestApp(
        const LoadingIndicator(size: 60),
      ));
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 60);
      expect(sizedBox.height, 60);
    });

    testWidgets('default size is 40', (tester) async {
      await tester.pumpWidget(createTestApp(const LoadingIndicator()));
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 40);
      expect(sizedBox.height, 40);
    });
  });
}
