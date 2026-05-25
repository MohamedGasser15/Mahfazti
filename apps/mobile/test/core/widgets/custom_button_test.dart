import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/widgets/custom_button.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void _noop() {}

void main() {
  group('CustomButton', () {
    testWidgets('renders text correctly', (tester) async {
      await tester.pumpWidget(createTestApp(
        const CustomButton(text: 'Submit', onPressed: _noop),
      ));
      expect(find.text('Submit'), findsOneWidget);
    });

    testWidgets('fires onPressed when tapped', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createTestApp(
        CustomButton(text: 'Tap', onPressed: () => pressed = true),
      ));
      await tester.tap(find.text('Tap'));
      expect(pressed, isTrue);
    });

    testWidgets('does not fire onPressed when isLoading is true', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createTestApp(
        CustomButton(
          text: 'Loading',
          onPressed: () => pressed = true,
          isLoading: true,
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });

    testWidgets('does not fire onPressed when isEnabled is false', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createTestApp(
        CustomButton(
          text: 'Disabled',
          onPressed: () => pressed = true,
          isEnabled: false,
        ),
      ));
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);
    });

    testWidgets('shows CircularProgressIndicator when isLoading', (tester) async {
      await tester.pumpWidget(createTestApp(
        const CustomButton(
          text: 'Save',
          onPressed: _noop,
          isLoading: true,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(createTestApp(
        const CustomButton(text: 'Save', onPressed: _noop),
      ));
      expect(find.text('Save'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('accepts custom backgroundColor and textColor', (tester) async {
      await tester.pumpWidget(createTestApp(
        const CustomButton(
          text: 'Styled',
          onPressed: _noop,
          backgroundColor: Colors.purple,
          textColor: Colors.yellow,
        ),
      ));
      expect(find.text('Styled'), findsOneWidget);
    });
  });
}
