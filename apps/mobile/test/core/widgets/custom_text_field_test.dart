import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/core/widgets/custom_text_field.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(home: Scaffold(body: SingleChildScrollView(child: child)));
}

void main() {
  group('CustomTextField', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(createTestApp(
        CustomTextField(
          controller: TextEditingController(),
          label: 'Email',
        ),
      ));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('accepts input text', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(createTestApp(
        CustomTextField(
          controller: controller,
          label: 'Name',
        ),
      ));
      await tester.enterText(find.byType(TextFormField), 'John');
      expect(controller.text, 'John');
    });

    testWidgets('shows hint text when provided', (tester) async {
      await tester.pumpWidget(createTestApp(
        CustomTextField(
          controller: TextEditingController(),
          label: 'Password',
          hintText: 'Enter password',
        ),
      ));
      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('validator works on invalid input', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextField(
                controller: TextEditingController(),
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
          ),
        ),
      );
      formKey.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('shows prefix icon when provided', (tester) async {
      await tester.pumpWidget(createTestApp(
        CustomTextField(
          controller: TextEditingController(),
          label: 'Search',
          prefixIcon: const Icon(Icons.search),
        ),
      ));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
