import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/features/wallet/data/repositories/ai_financial_repository.dart';

/// A single chat message.
class AskMessage {
  final String text;
  final bool isUser;

  const AskMessage({required this.text, required this.isUser});

  Map<String, dynamic> toJson() => {'text': text, 'isUser': isUser};

  factory AskMessage.fromJson(Map<String, dynamic> json) => AskMessage(
    text: json['text']?.toString() ?? '',
    isUser: json['isUser'] == true,
  );
}

/// One saved conversation.
class AskConversation {
  final String? id;
  final String title;
  final List<AskMessage> messages;
  final DateTime createdAt;

  AskConversation({
    this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory AskConversation.fromJson(Map<String, dynamic> json) =>
      AskConversation(
        id: json['id']?.toString(),
        title: json['title']?.toString() ?? '',
        messages: (json['messages'] as List? ?? [])
            .map((m) => AskMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'])
            : DateTime.now(),
      );
}

/// Chat history manager connected to AI repository with local persistence.
class AskHistoryStore {
  AskHistoryStore._();

  static final List<AskConversation> items = <AskConversation>[];
  static final AiFinancialRepository _aiRepo = AiFinancialRepository();
  static const String _storageKey = 'ask_history_conversations_v2';
  static bool _loadedFromPrefs = false;

  static Future<void> loadLocalCache() async {
    if (_loadedFromPrefs) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        for (final item in list) {
          final conv = AskConversation.fromJson(item as Map<String, dynamic>);
          if (!items.any(
            (c) => (c.id != null && c.id == conv.id) || c.title == conv.title,
          )) {
            items.add(conv);
          }
        }
      }
      _loadedFromPrefs = true;
    } catch (_) {}
  }

  static Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = items.map((c) => c.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(list));
    } catch (_) {}
  }

  static void save(String title, List<AskMessage> messages, {String? id}) {
    if (messages.isEmpty) return;

    // Check if conversation already exists in local cache
    int existingIdx = -1;
    if (id != null) {
      existingIdx = items.indexWhere((c) => c.id != null && c.id == id);
    }
    if (existingIdx < 0 && items.isNotEmpty) {
      if (items.first.id == null || items.first.title == title) {
        existingIdx = 0;
      }
    }

    final conv = AskConversation(
      id: id ?? (existingIdx >= 0 ? items[existingIdx].id : null),
      title: title,
      messages: List<AskMessage>.from(messages),
      createdAt: existingIdx >= 0
          ? items[existingIdx].createdAt
          : DateTime.now(),
    );

    if (existingIdx >= 0) {
      items[existingIdx] = conv;
    } else {
      items.insert(0, conv);
    }
    _persist();
  }

  static AskConversation? getActiveConversation() {
    if (items.isNotEmpty && items.first.messages.isNotEmpty) {
      return items.first;
    }
    return null;
  }

  static String? getActiveConversationId() {
    if (items.isNotEmpty) {
      return items.first.id;
    }
    return null;
  }

  static Future<void> syncFromBackend() async {
    await loadLocalCache();
    if (AppConstants.isTestingEnvironment && !ApiService().hasTestingDio) {
      return;
    }

    try {
      final remoteList = await _aiRepo.getConversations();
      if (remoteList.isNotEmpty) {
        // Merge without losing current locally loaded active messages
        for (final r in remoteList) {
          final idx = items.indexWhere((c) => c.id == r.id);
          if (idx < 0) {
            items.add(
              AskConversation(
                id: r.id,
                title: r.title,
                messages:
                    r.lastMessageSnippet != null &&
                        r.lastMessageSnippet!.isNotEmpty
                    ? [AskMessage(text: r.lastMessageSnippet!, isUser: false)]
                    : [],
                createdAt: r.createdAt,
              ),
            );
          }
        }
        _persist();
      }
    } catch (_) {}
  }

  static void delete(AskConversation conversation) {
    items.remove(conversation);
    _persist();
    if (conversation.id != null &&
        (!AppConstants.isTestingEnvironment || ApiService().hasTestingDio)) {
      _aiRepo.deleteConversation(conversation.id!);
    }
  }
}
