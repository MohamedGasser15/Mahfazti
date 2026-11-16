import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/themes/app_icons.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/data/repositories/ai_financial_repository.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_background.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_chat_models.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_history_screen.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_name_sheet.dart';

/// Full-screen conversation with the assistant.
class AskChatScreen extends StatefulWidget {
  final String? firstName;
  final String? initialPrompt;
  final List<AskMessage>? initialMessages;
  final String? conversationId;

  const AskChatScreen({
    super.key,
    this.firstName,
    this.initialPrompt,
    this.initialMessages,
    this.conversationId,
  });

  @override
  State<AskChatScreen> createState() => _AskChatScreenState();
}

class _AskChatScreenState extends State<AskChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scroll = ScrollController();
  final AiFinancialRepository _aiRepo = AiFinancialRepository();

  final List<AskMessage> _messages = [];
  late String _assistantName = _readAssistantName();
  String? _activeConversationId;

  String _readAssistantName() {
    try {
      return SharedPrefs.assistantName;
    } catch (_) {
      return 'Mahfazti AI';
    }
  }

  bool? _liked;
  bool _copied = false;
  Timer? _copiedTimer;
  bool _isTyping = false;
  bool _showFollowUps = false;

  Timer? _streamTimer;
  String _pendingReply = '';
  int _streamIndex = 0;

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;

    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      _messages.addAll(widget.initialMessages!);
      if (widget.conversationId != null &&
          widget.initialMessages!.length <= 1) {
        _loadRemoteMessages(widget.conversationId!);
      }
    } else if (widget.conversationId != null) {
      _loadRemoteMessages(widget.conversationId!);
    } else if (widget.initialPrompt == null) {
      // Reopen last active conversation if user is returning to chat
      final active = AskHistoryStore.getActiveConversation();
      if (active != null && active.messages.isNotEmpty) {
        _activeConversationId = active.id;
        _messages.addAll(active.messages);
        if (active.id != null && active.messages.length <= 1) {
          _loadRemoteMessages(active.id!);
        }
      }
    }

    if (widget.initialPrompt != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _controller.text = widget.initialPrompt!;
        _send();
      });
    } else if (_messages.isNotEmpty && !_messages.last.isUser) {
      _showFollowUps = true;
    }
  }

  Future<void> _loadRemoteMessages(String convId) async {
    setState(() => _isTyping = true);
    try {
      final remoteMsgs = await _aiRepo.getMessages(convId);
      if (remoteMsgs.isNotEmpty && mounted) {
        setState(() {
          _messages.clear();
          for (final m in remoteMsgs) {
            _messages.add(AskMessage(text: m.content, isUser: m.isUser));
          }
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _showFollowUps = true;
          }
        });
        _scrollToBottom(animate: false);
        _saveToHistoryStore();
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isTyping = false);
    }
  }

  void _saveToHistoryStore() {
    if (_messages.isEmpty) return;
    final validMessages = _messages.where((m) => m.text.isNotEmpty).toList();
    if (validMessages.isEmpty) return;

    final firstUser = validMessages.firstWhere(
      (m) => m.isUser,
      orElse: () => validMessages.first,
    );
    AskHistoryStore.save(
      firstUser.text.trim().isNotEmpty
          ? firstUser.text.trim()
          : (_isAr ? 'محادثة' : 'Chat'),
      validMessages,
      id: _activeConversationId,
    );
  }

  @override
  void dispose() {
    if (_streamTimer != null &&
        _streamTimer!.isActive &&
        _pendingReply.isNotEmpty &&
        _messages.isNotEmpty) {
      _messages[_messages.length - 1] = AskMessage(
        text: _pendingReply,
        isUser: false,
      );
    }
    _saveToHistoryStore();
    _streamTimer?.cancel();
    _copiedTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      final target = _scroll.position.maxScrollExtent;
      if (!animate) {
        _scroll.jumpTo(target);
        return;
      }
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _startNewChat() {
    _saveToHistoryStore();
    _activeConversationId = null;
    _streamTimer?.cancel();
    HapticFeedback.selectionClick();
    setState(() {
      _messages.clear();
      _isTyping = false;
      _showFollowUps = false;
      _controller.clear();
    });
  }

  Future<void> _openNameSheet() async {
    HapticFeedback.selectionClick();
    final name = await showAssistantNameSheet(context, isAr: _isAr);
    if (name != null && mounted) {
      setState(() => _assistantName = name);
    }
  }

  Future<void> _openHistory() async {
    HapticFeedback.selectionClick();
    final picked = await Navigator.of(context).push<AskConversation>(
      MaterialPageRoute<AskConversation>(
        builder: (_) => AskHistoryScreen(isAr: _isAr),
      ),
    );
    if (picked != null && mounted) _loadConversation(picked);
  }

  void _loadConversation(AskConversation conversation) {
    _activeConversationId = conversation.id;
    _streamTimer?.cancel();
    setState(() {
      _messages
        ..clear()
        ..addAll(conversation.messages);
      _isTyping = false;
      _showFollowUps =
          conversation.messages.isNotEmpty &&
          !conversation.messages.last.isUser;
    });
    _scrollToBottom();

    if (conversation.id != null && conversation.messages.length <= 1) {
      _loadRemoteMessages(conversation.id!);
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.selectionClick();
    _streamTimer?.cancel();
    setState(() {
      _messages.add(AskMessage(text: text, isUser: true));
      _controller.clear();
      _isTyping = true;
      _showFollowUps = false;
    });
    _scrollToBottom();

    try {
      final response = await _aiRepo.sendMessage(
        text,
        conversationId: _activeConversationId,
        language: _isAr ? 'ar' : 'en',
      );
      _activeConversationId = response.conversationId;

      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(const AskMessage(text: '', isUser: false));
      });
      _scrollToBottom();
      _streamReply(response.reply);
    } catch (e) {
      if (!mounted) return;
      final cleanMsg = e.toString().replaceAll('Exception: ', '');
      setState(() {
        _isTyping = false;
        _messages.add(
          AskMessage(
            text: _isAr
                ? 'عذراً، حدث خطأ أثناء الاتصال بمحفظتي AI:\n$cleanMsg'
                : 'Sorry, could not connect to Mahfazti AI:\n$cleanMsg',
            isUser: false,
          ),
        );
      });
      _scrollToBottom();
      _saveToHistoryStore();
    }
  }

  void _streamReply(String text) {
    _streamTimer?.cancel();
    _pendingReply = text;
    _streamIndex = 0;

    _streamTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _pendingReply.length - _streamIndex;
      if (remaining <= 0) {
        timer.cancel();
        setState(() {
          _messages[_messages.length - 1] = AskMessage(
            text: _pendingReply,
            isUser: false,
          );
          _showFollowUps = true;
        });
        _saveToHistoryStore();
        _scrollToBottom();
        return;
      }
      final step = remaining > 80 ? 4 : (remaining > 24 ? 2 : 1);
      setState(() {
        _streamIndex = math.min(_pendingReply.length, _streamIndex + step);
        _messages[_messages.length - 1] = AskMessage(
          text: _pendingReply.substring(0, _streamIndex),
          isUser: false,
        );
      });
      _scrollToBottom(animate: false);
    });
  }

  List<String> _getDynamicFollowUps(bool isAr) {
    String lastUserText = '';
    for (int i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser) {
        lastUserText = _messages[i].text.toLowerCase();
        break;
      }
    }

    final List<String> candidates = [];

    // Contextual checks based on what the user asked
    if (lastUserText.contains('لخص') ||
        lastUserText.contains('ملخص') ||
        lastUserText.contains('شهر') ||
        lastUserText.contains('summary') ||
        lastUserText.contains('month')) {
      if (isAr) {
        candidates.addAll([
          'إيه أكتر تصنيف صرفت فيه؟',
          'ازاي أوفّر الشهر الجاي؟',
          'قارن مصاريفي بالشهر اللي فات',
          'حطلي خطة ميزانية للشهر الجديد',
        ]);
      } else {
        candidates.addAll([
          'Which category cost the most?',
          'How can I save next month?',
          'Compare with last month',
          'Plan a budget for next month',
        ]);
      }
    } else if (lastUserText.contains('وفر') ||
        lastUserText.contains('توفير') ||
        lastUserText.contains('ميزان') ||
        lastUserText.contains('تحويش') ||
        lastUserText.contains('save') ||
        lastUserText.contains('budget')) {
      if (isAr) {
        candidates.addAll([
          'قسّم دخلي بقاعدة 50/30/20',
          'إيه المصاريف اللي ممكن استغنى عنها؟',
          'إزاي أعمل صندوق طوارئ؟',
          'أقدر أحوّش كام كل شهر؟',
        ]);
      } else {
        candidates.addAll([
          'Apply the 50/30/20 budget rule',
          'Which expenses can I cut down?',
          'How to build an emergency fund?',
          'How much can I realistically save?',
        ]);
      }
    } else if (lastUserText.contains('استثمار') ||
        lastUserText.contains('دهب') ||
        lastUserText.contains('ذهب') ||
        lastUserText.contains('شهادات') ||
        lastUserText.contains('تضخم') ||
        lastUserText.contains('بورصة') ||
        lastUserText.contains('invest') ||
        lastUserText.contains('gold')) {
      if (isAr) {
        candidates.addAll([
          'إيه الفرق بين الدهب والشهادات؟',
          'إزاي أحمي فلوسي من التضخم؟',
          'أنسب طريقة لتوزيع مدخراتي',
          'أبدأ استثمار بمبلغ كام؟',
        ]);
      } else {
        candidates.addAll([
          'Gold vs bank certificates?',
          'How to protect savings from inflation?',
          'Best way to diversify my savings',
          'Minimum amount to start investing?',
        ]);
      }
    } else if (lastUserText.contains('أكبر') ||
        lastUserText.contains('فين') ||
        lastUserText.contains('مصروف') ||
        lastUserText.contains('صرف') ||
        lastUserText.contains('expense') ||
        lastUserText.contains('spend')) {
      if (isAr) {
        candidates.addAll([
          'أقدر أصرف كام الأسبوع ده؟',
          'إزاي أقلل مصاريف الأكل والخروج؟',
          'لخّص الشهر ده',
          'إيه أكبر بند أخد من فلوسي؟',
        ]);
      } else {
        candidates.addAll([
          'How much can I spend this week?',
          'Tips to cut dining & takeout costs',
          'Summarize this month',
          'What was my single biggest expense?',
        ]);
      }
    }

    final pool = isAr
        ? [
            'إيه أكبر مصروف عندي؟',
            'فين بتروح فلوسي؟',
            'ازاي أوفّر أكتر؟',
            'لخّص الشهر ده',
            'أقدر أصرف كام الأسبوع ده؟',
            'إزاي أعمل ميزانية شهرية؟',
          ]
        : [
            'What is my biggest expense?',
            'Where is my money going?',
            'How can I save more?',
            'Summarize this month',
            'How much can I spend this week?',
            'How do I build a monthly budget?',
          ];

    for (final p in pool) {
      if (!candidates.contains(p)) {
        candidates.add(p);
      }
    }

    // Filter out questions the user has already asked in this chat
    final userQuestions = _messages
        .where((m) => m.isUser)
        .map((m) => m.text.trim().toLowerCase())
        .toSet();

    final result = candidates
        .where((c) {
          final cl = c.trim().toLowerCase();
          return !userQuestions.any(
            (uq) =>
                uq == cl ||
                (uq.length > 5 && cl.contains(uq)) ||
                (cl.length > 5 && uq.contains(cl)),
          );
        })
        .take(3)
        .toList();

    return result.isNotEmpty ? result : candidates.take(3).toList();
  }

  void _askNow(String prompt) {
    _controller.value = TextEditingValue(
      text: prompt,
      selection: TextSelection.collapsed(offset: prompt.length),
    );
    _send();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = _isAr;
    final isIOS = Platform.isIOS;

    final bg = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);
    final textMuted = isDark
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final textSecondary = isDark
        ? const Color(0xFFB4B4BC)
        : const Color(0xFF52525B);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final card = isDark ? const Color(0xFF141418) : Colors.white;

    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomClearance = 20.0 + math.max<double>(keyboardInset, 16.0);

    final greeting = widget.firstName == null
        ? (isAr ? 'أهلاً 👋' : 'Hey there 👋')
        : (isAr ? 'أهلاً ${widget.firstName}.' : 'Hey ${widget.firstName}.');

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: AskBackground(isDark: isDark)),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(
                  isDark: isDark,
                  isAr: isAr,
                  isIOS: isIOS,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  border: border,
                  card: card,
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _focusNode.unfocus(),
                    child: _messages.isEmpty
                        ? _buildEmpty(
                            isDark: isDark,
                            isAr: isAr,
                            greeting: greeting,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            textMuted: textMuted,
                            border: border,
                            card: card,
                            bottomClearance: bottomClearance,
                          )
                        : _buildChat(
                            isDark: isDark,
                            isAr: isAr,
                            isIOS: isIOS,
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            border: border,
                            card: card,
                            bottomClearance: bottomClearance,
                          ),
                  ),
                ),
                _buildComposer(
                  isDark: isDark,
                  isAr: isAr,
                  isIOS: isIOS,
                  textPrimary: textPrimary,
                  textMuted: textMuted,
                  border: border,
                  bottomClearance: bottomClearance,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required bool isDark,
    required bool isAr,
    required bool isIOS,
    required Color textPrimary,
    required Color textMuted,
    required Color border,
    required Color card,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          if (isIOS)
            const AppGlassBackButton()
          else
            _HeaderButton(
              icon: appBackIcon(isIOS: false, isRtl: isAr),
              onTap: () => Navigator.maybePop(context),
              border: border,
              card: card,
              color: textPrimary,
            ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _openNameSheet,
              child: Text(
                _assistantName,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isIOS)
            GlassButton.custom(
              height: 44,
              shape: const LiquidRoundedRectangle(borderRadius: 22),
              useOwnLayer: true,
              quality: GlassQuality.premium,
              canRequestFocus: false,
              excludeFromSemantics: true,
              stretch: 0.35,
              settings: isDark
                  ? LiquidGlassSettings.ios27Dark
                  : LiquidGlassSettings.ios27Light,
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _openHistory,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.only(left: 14, right: 10),
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          AppIcons.clock(isIOS: true),
                          size: 20,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _startNewChat,
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.only(left: 10, right: 14),
                      color: Colors.transparent,
                      child: Center(
                        child: Icon(
                          AppIcons.add(isIOS: true),
                          size: 20,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            _HeaderButton(
              icon: AppIcons.clock(isIOS: false),
              onTap: _openHistory,
              border: border,
              card: card,
              color: textMuted,
            ),
            const SizedBox(width: 8),
            _HeaderButton(
              icon: AppIcons.add(isIOS: false),
              onTap: _startNewChat,
              border: border,
              card: card,
              color: textMuted,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty({
    required bool isDark,
    required bool isAr,
    required String greeting,
    required Color textPrimary,
    required Color textSecondary,
    required Color textMuted,
    required Color border,
    required Color card,
    required double bottomClearance,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(28, 0, 28, bottomClearance + 92),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: math.max(
              0,
              constraints.maxHeight - (bottomClearance + 92),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 104),
              AskLogo(size: 64, isDark: isDark),
              const SizedBox(height: 14),
              Text(
                _assistantName,
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
              const SizedBox(height: 8),
              Text(
                greeting,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isAr
                    ? 'اسألني أي حاجة عن فلوسك — أنا عارف مصاريفك وحساباتك وميزانيتك.'
                    : 'Ask me anything about your money — I know your transactions, accounts, and budgets.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.5,
                  height: 1.5,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChat({
    required bool isDark,
    required bool isAr,
    required bool isIOS,
    required Color textPrimary,
    required Color textMuted,
    required Color border,
    required Color card,
    required double bottomClearance,
  }) {
    final followUps = _getDynamicFollowUps(isAr);

    return ListView(
      controller: _scroll,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomClearance + 92),
      children: [
        for (final message in _messages)
          _ChatBubble(
            message: message,
            isDark: isDark,
            isIOS: isIOS,
            textPrimary: textPrimary,
            border: border,
            card: card,
          ),
        if (_isTyping)
          _TypingBubble(
            isDark: isDark,
            isIOS: isIOS,
            border: border,
            card: card,
            textMuted: textMuted,
          ),
        if (_showFollowUps && followUps.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 14, color: textMuted),
              const SizedBox(width: 6),
              Text(
                isAr ? 'جرّب تسأل كمان:' : 'Try next:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final followUp in followUps)
                _SuggestionPill(
                  label: followUp,
                  isDark: isDark,
                  isIOS: isIOS,
                  showArrow: true,
                  onTap: () => _askNow(followUp),
                ),
            ],
          ),
        ],
        if (!_isTyping && _messages.isNotEmpty && !_messages.last.isUser) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              _ActionIcon(
                icon: _copied
                    ? AppIcons.check(isIOS: isIOS)
                    : AppIcons.copy(isIOS: isIOS),
                active: _copied,
                color: textMuted,
                onTap: _copyLastReply,
              ),
              const SizedBox(width: 12),
              Text(
                isAr ? 'مفيد؟' : 'Helpful?',
                style: TextStyle(fontSize: 13, color: textMuted),
              ),
              const SizedBox(width: 8),
              _ActionIcon(
                icon: AppIcons.thumbUp(isIOS: isIOS),
                active: _liked == true,
                color: textMuted,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _liked = _liked == true ? null : true);
                },
              ),
              const SizedBox(width: 4),
              _ActionIcon(
                icon: AppIcons.thumbDown(isIOS: isIOS),
                active: _liked == false,
                color: textMuted,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _liked = _liked == false ? null : false);
                },
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _copyLastReply() {
    final reply = _messages.lastWhere(
      (m) => !m.isUser,
      orElse: () => const AskMessage(text: '', isUser: false),
    );
    if (reply.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: reply.text));
    HapticFeedback.selectionClick();
    setState(() => _copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Widget _buildComposer({
    required bool isDark,
    required bool isAr,
    required bool isIOS,
    required Color textPrimary,
    required Color textMuted,
    required Color border,
    required double bottomClearance,
  }) {
    final surface = isDark ? const Color(0xFF141418) : Colors.white;
    final borderColor = border;

    final inputContent = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _send(),
              keyboardAppearance: isDark ? Brightness.dark : Brightness.light,
              cursorColor: textPrimary,
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: FontWeight.w500,
                color: textPrimary,
              ),
              decoration: InputDecoration(
                filled: false,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
                hintText: isAr ? 'اكتب أي حاجة...' : 'Say anything...',
                hintStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: textMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return GestureDetector(
              onTap: hasText ? _send : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: hasText
                      ? textPrimary
                      : (isDark
                            ? Colors.white.withValues(alpha: 0.10)
                            : Colors.black.withValues(alpha: 0.06)),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    AppIcons.sendUp(isIOS: isIOS),
                    size: 16,
                    color: hasText
                        ? (isDark ? Colors.black : Colors.white)
                        : textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, bottomClearance),
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        child: inputContent,
      ),
    );
  }
}

/// Small round header action.
class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color border;
  final Color card;
  final Color color;

  const _HeaderButton({
    required this.icon,
    required this.onTap,
    required this.border,
    required this.card,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: card,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 1),
        ),
        child: Icon(icon, size: 17, color: color),
      ),
    );
  }
}

/// A single chat message bubble.
class _ChatBubble extends StatelessWidget {
  final AskMessage message;
  final bool isDark;
  final bool isIOS;
  final Color textPrimary;
  final Color border;
  final Color card;

  const _ChatBubble({
    required this.message,
    required this.isDark,
    required this.isIOS,
    required this.textPrimary,
    required this.border,
    required this.card,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final maxWidth = MediaQuery.of(context).size.width * 0.78;

    if (isUser) {
      return Align(
        alignment: AlignmentDirectional.centerEnd,
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: textPrimary,
            borderRadius: const BorderRadiusDirectional.only(
              topStart: Radius.circular(20),
              topEnd: Radius.circular(20),
              bottomStart: Radius.circular(20),
              bottomEnd: Radius.circular(6),
            ),
          ),
          child: _FormattedMessageText(
            text: message.text,
            style: TextStyle(
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.black : Colors.white,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
            bottomStart: Radius.circular(6),
            bottomEnd: Radius.circular(20),
          ),
          border: Border.all(color: border, width: 1),
        ),
        child: _FormattedMessageText(
          text: message.text,
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF09090B),
          ),
        ),
      ),
    );
  }
}

/// Renders message text parsing markdown bold (**text**) and bullet lists cleanly.
class _FormattedMessageText extends StatelessWidget {
  final String text;
  final TextStyle style;

  const _FormattedMessageText({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    // Clean list bullets: turn leading "* " or "- " into a clean bullet "• "
    final cleanText = text.replaceAll(RegExp(r'(^|\n)[\*\-]\s+'), r'$1• ');

    // Match **bold**
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final spans = <TextSpan>[];
    int lastMatchEnd = 0;

    for (final match in boldRegex.allMatches(cleanText)) {
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: cleanText.substring(lastMatchEnd, match.start),
            style: style,
          ),
        );
      }

      final boldContent = match.group(1) ?? '';
      spans.add(
        TextSpan(
          text: boldContent,
          style: style.copyWith(fontWeight: FontWeight.w800),
        ),
      );

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < cleanText.length) {
      spans.add(
        TextSpan(text: cleanText.substring(lastMatchEnd), style: style),
      );
    }

    if (spans.isEmpty) {
      return Text(cleanText, style: style);
    }

    return Text.rich(TextSpan(children: spans), style: style);
  }
}

/// Three bouncing dots while the assistant "thinks".
class _TypingBubble extends StatefulWidget {
  final bool isDark;
  final bool isIOS;
  final Color border;
  final Color card;
  final Color textMuted;

  const _TypingBubble({
    required this.isDark,
    required this.isIOS,
    required this.border,
    required this.card,
    required this.textMuted,
  });

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dots = AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0) const SizedBox(width: 5),
              Opacity(
                opacity:
                    0.25 +
                    0.75 *
                        ((math.sin(_controller.value * 2 * math.pi - i * 0.7) +
                                1) /
                            2),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.textMuted,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: widget.card,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(20),
            topEnd: Radius.circular(20),
            bottomStart: Radius.circular(6),
            bottomEnd: Radius.circular(20),
          ),
          border: Border.all(color: widget.border, width: 1),
        ),
        child: dots,
      ),
    );
  }
}

/// Suggestion pill.
class _SuggestionPill extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isIOS;
  final VoidCallback onTap;
  final bool showArrow;

  const _SuggestionPill({
    required this.label,
    required this.isDark,
    required this.isIOS,
    required this.onTap,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textColor = isDark
        ? const Color(0xFFE4E4E7)
        : const Color(0xFF27272A);

    void handleTap() {
      HapticFeedback.selectionClick();
      onTap();
    }

    return GestureDetector(
      onTap: handleTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF141418) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              Icon(
                AppIcons.arrowUpRight(isIOS: isIOS),
                size: 13,
                color: textColor.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The Mahfazti mark, themed for light/dark.
class AskLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const AskLogo({super.key, required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        isDark
            ? 'assets/icons/mahfazti-logo-dark.png'
            : 'assets/icons/mahfazti-logo-light.png',
        width: size,
        height: size,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

/// Small icon action used under the assistant reply.
class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _ActionIcon({
    required this.icon,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: active ? color : color.withValues(alpha: 0.75),
        ),
      ),
    );
  }
}
