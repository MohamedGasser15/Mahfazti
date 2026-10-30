import 'dart:convert';
import 'dart:math' as math;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/themes/app_icons.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_chat_screen.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_background.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_chat_models.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_history_screen.dart';

/// The Ask hub: identity, greeting and ready-made prompts. Tapping the
/// composer-looking field opens the full conversation screen.
class AskTab extends StatefulWidget {
  const AskTab({super.key});

  @override
  State<AskTab> createState() => _AskTabState();
}

class _AskTabState extends State<AskTab> {
  String? _firstName;

  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstName = _readFirstName();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Sends the message on the hub, then opens the conversation screen where
  /// the assistant answers.
  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      _focusNode.requestFocus();
      return;
    }
    _controller.clear();
    _focusNode.unfocus();
    _openChat(prompt: text);
  }

  String? _readFirstName() {
    try {
      final raw = SharedPrefs.userData;
      if (raw == null || raw.isEmpty) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final name = (map['fullName'] ?? map['userName'] ?? '').toString().trim();
      if (name.isEmpty) return null;
      return name.split(RegExp(r'\s+')).first;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openChat({
    String? prompt,
    List<AskMessage>? messages,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AskChatScreen(
          firstName: _firstName,
          initialPrompt: prompt,
          initialMessages: messages,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openHistory() async {
    HapticFeedback.selectionClick();
    final picked = await Navigator.of(context).push<AskConversation>(
      MaterialPageRoute<AskConversation>(
        builder: (_) => AskHistoryScreen(isAr: _isAr),
      ),
    );
    if (picked != null && mounted) {
      _openChat(messages: picked.messages);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final isIOS = Platform.isIOS;

    final bg = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);
    final textMuted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final textSecondary =
        isDark ? const Color(0xFFB4B4BC) : const Color(0xFF52525B);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    final prompts = isAr
        ? const [
            'فين بتروح فلوسي؟',
            'ازاي أوفّر أكتر؟',
            'لخّص الشهر ده',
            'إيه أكبر مصروف عندي؟',
            'أقدر أصرف ٢٠٠٠ الأسبوع ده؟',
          ]
        : const [
            'Where is my money going?',
            'How can I save more?',
            'Summarize this month',
            'What is my biggest expense?',
            'Can I afford a 2,000 trip?',
          ];

    // Bottom clearance: keyboard when open, otherwise the floating tab bar.
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    // The floating tab bar exists on both platforms, so always leave room.
    final tabBarClearance = 54.0 + MediaQuery.of(context).viewPadding.bottom;
    final bottomClearance =
        20.0 + math.max<double>(keyboardInset, tabBarClearance);

    final greeting = _firstName == null
        ? (isAr ? 'أهلاً 👋' : 'Hey there 👋')
        : (isAr ? 'أهلاً $_firstName.' : 'Hey $_firstName.');

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(child: AskBackground(isDark: isDark)),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _focusNode.unfocus(),
                    child: Column(
                      children: [
                        _buildHeader(isAr, isDark, isIOS, textPrimary),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: EdgeInsets.fromLTRB(
                              24,
                              12,
                              24,
                              bottomClearance + 92,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                Text(
                                  greeting,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    color: textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  isAr
                                      ? 'أنا Mahfazti — مساعدك في الفلوس. أقدر أفحص مصاريفك، أقارن الشهور، وأساعدك تخطّط اللي جاي.'
                                      : "I'm Mahfazti — your money copilot. I can dig into your spending, compare months and help you plan ahead.",
                                  style: TextStyle(
                                    fontSize: 16.5,
                                    height: 1.45,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: -0.2,
                                    color: textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 22),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: [
                                    for (final prompt in prompts)
                                      _SuggestionPill(
                                        label: prompt,
                                        isDark: isDark,
                                        isIOS: isIOS,
                                        onTap: () => _openChat(prompt: prompt),
                                      ),
                                  ],
                                ),
                                _buildRecent(
                                  isAr: isAr,
                                  isDark: isDark,
                                  isIOS: isIOS,
                                  textPrimary: textPrimary,
                                  textMuted: textMuted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _buildLauncher(
                    isAr: isAr,
                    isDark: isDark,
                    isIOS: isIOS,
                    textMuted: textMuted,
                    textPrimary: textPrimary,
                    border: border,
                    bottomClearance: bottomClearance,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isAr => Localizations.localeOf(context).languageCode == 'ar';

  Widget _buildRecent({
    required bool isAr,
    required bool isDark,
    required bool isIOS,
    required Color textPrimary,
    required Color textMuted,
  }) {
    final items = AskHistoryStore.items.take(3).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final card = isDark ? const Color(0xFF141418) : Colors.white;

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        rows.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: isIOS ? 16 : 0,
            endIndent: isIOS ? 16 : 0,
            color: border.withValues(alpha: 0.6),
          ),
        );
      }
      rows.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            _openChat(messages: items[i].messages);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isIOS ? 16 : 0,
              vertical: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    items[i].title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${items[i].messages.length} ${isAr ? "رسائل" : "messages"}',
                  style: TextStyle(fontSize: 12, color: textMuted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  isAr ? 'الحديثة' : 'RECENT',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: textMuted,
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _openHistory,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    isAr ? 'الكل' : 'See all',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(children: rows),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isAr, bool isDark, bool isIOS, Color textPrimary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Row(
        children: [
          _AskLogo(size: 30, isDark: isDark),
          const SizedBox(width: 10),
          Text(
            isAr ? 'محفظتي' : 'Mahfazti',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: textPrimary,
            ),
          ),
          const Spacer(),
          if (isIOS)
            GlassButton(
              width: 38,
              height: 38,
              shape: const LiquidOval(),
              settings: isDark
                  ? LiquidGlassSettings.ios27Dark
                  : LiquidGlassSettings.ios27Light,
              useOwnLayer: true,
              onTap: _openHistory,
              icon: Icon(
                AppIcons.clock(isIOS: true),
                size: 18,
                color: textPrimary,
              ),
            )
          else
            GestureDetector(
              onTap: _openHistory,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF141418) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF27272A)
                        : const Color(0xFFE4E4E7),
                    width: 1,
                  ),
                ),
                child: Icon(
                  AppIcons.clock(isIOS: false),
                  size: 18,
                  color: textPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLauncher({
    required bool isAr,
    required bool isDark,
    required bool isIOS,
    required Color textMuted,
    required Color textPrimary,
    required Color border,
    required double bottomClearance,
  }) {
    final surface = isDark ? const Color(0xFF141418) : Colors.white;
    final borderColor = border;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomClearance),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.10),
              blurRadius: isDark ? 28 : 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _submit(),
                keyboardAppearance:
                    isDark ? Brightness.dark : Brightness.light,
                cursorColor: textPrimary,
                style: TextStyle(
                  fontSize: 15,
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  hintText: isAr ? 'اكتب أي حاجة...' : 'Ask me anything...',
                  hintStyle: TextStyle(fontSize: 15, color: textMuted),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submit,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: textPrimary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppIcons.sendUp(isIOS: isIOS),
                  size: 16,
                  color: isDark ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The Mahfazti mark, themed for light/dark.
class _AskLogo extends StatelessWidget {
  final double size;
  final bool isDark;

  const _AskLogo({required this.size, required this.isDark});

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

/// Suggestion pill.
class _SuggestionPill extends StatelessWidget {
  final String label;
  final bool isDark;
  final bool isIOS;
  final VoidCallback onTap;

  const _SuggestionPill({
    required this.label,
    required this.isDark,
    required this.isIOS,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textColor = isDark ? const Color(0xFFE4E4E7) : const Color(0xFF27272A);

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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
