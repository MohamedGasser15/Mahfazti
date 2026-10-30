/// A single chat message.
class AskMessage {
  final String text;
  final bool isUser;

  const AskMessage({required this.text, required this.isUser});
}

/// One saved conversation (in-memory for now).
class AskConversation {
  final String title;
  final List<AskMessage> messages;
  final DateTime createdAt;

  AskConversation({
    required this.title,
    required this.messages,
    required this.createdAt,
  });
}

/// In-memory chat history until the backend lands.
class AskHistoryStore {
  AskHistoryStore._();

  static final List<AskConversation> items = <AskConversation>[];

  static void save(String title, List<AskMessage> messages) {
    if (messages.isEmpty) return;
    items.insert(
      0,
      AskConversation(
        title: title,
        messages: List<AskMessage>.from(messages),
        createdAt: DateTime.now(),
      ),
    );
  }
}

