import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/widgets/app_shimmer.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('AppShimmer', () {
    testWidgets('wraps child widget', (tester) async {
      await tester.pumpWidget(createTestApp(
        const AppShimmer(
          child: Text('Hello'),
        ),
      ));
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  group('SkeletonBox', () {
    testWidgets('renders with default dimensions', (tester) async {
      await tester.pumpWidget(createTestApp(const SkeletonBox()));
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders with custom width and height', (tester) async {
      await tester.pumpWidget(createTestApp(
        const SkeletonBox(width: 100, height: 50),
      ));
      expect(find.byType(Container), findsOneWidget);
    });

    testWidgets('renders with circular shape', (tester) async {
      await tester.pumpWidget(createTestApp(
        const SkeletonBox(width: 48, height: 48, shape: BoxShape.circle),
      ));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });
  });
}
