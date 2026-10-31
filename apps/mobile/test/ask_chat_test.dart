import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_chat_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_history_screen.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_tab.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_chat_models.dart';

void main() {
  setUp(() => AskHistoryStore.items.clear());

  testWidgets('empty state shows identity block', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AskChatScreen(firstName: 'Mohamed'),
    ));
    await tester.pump();

    expect(find.text('Mahfazti AI'), findsWidgets);
    expect(find.textContaining('Hey Mohamed'), findsOneWidget);
    expect(
      find.textContaining('I know your transactions'),
      findsOneWidget,
    );
  });

  testWidgets('ask chat screen displays user and assistant messages properly',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AskChatScreen(
        initialMessages: [
          AskMessage(text: 'How much did I spend?', isUser: true),
          AskMessage(text: 'You spent 1,200 EGP this week.', isUser: false),
        ],
      ),
    ));
    await tester.pump();

    expect(find.text('How much did I spend?'), findsOneWidget);
    expect(find.text('You spent 1,200 EGP this week.'), findsOneWidget);
  });

  testWidgets('AskTab renders greeting and suggestion pills', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AskTab(),
    ));
    await tester.pump();

    expect(find.textContaining('Mahfazti'), findsWidgets);
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('history page shows beautiful empty state when no conversations',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AskHistoryScreen(isAr: false),
    ));
    await tester.pump();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('No saved conversations yet.'), findsOneWidget);
    expect(find.textContaining('Any conversation you start'), findsOneWidget);
  });

  testWidgets('history page groups today and earlier', (tester) async {
    AskHistoryStore.save('Hi', [
      const AskMessage(text: 'Hi', isUser: true),
      const AskMessage(text: 'Not sure what you mean…', isUser: false),
    ]);

    await tester.pumpWidget(const MaterialApp(
      home: AskHistoryScreen(isAr: false),
    ));
    await tester.pump();

    expect(find.text('History'), findsOneWidget);
    expect(find.text('TODAY'), findsOneWidget);
    expect(find.text('2 messages'), findsOneWidget);
    expect(find.text('Hold a conversation to delete it.'), findsOneWidget);
    expect(find.text('Hi'), findsWidgets);
  });

  testWidgets('long press deletes a conversation', (tester) async {
    AskHistoryStore.save('Bob', [
      const AskMessage(text: 'Bob', isUser: true),
    ]);

    await tester.pumpWidget(const MaterialApp(
      home: AskHistoryScreen(isAr: false),
    ));
    await tester.pump();

    await tester.longPress(find.text('Bob').first);
    await tester.pump();

    expect(AskHistoryStore.items, isEmpty);
  });
}
