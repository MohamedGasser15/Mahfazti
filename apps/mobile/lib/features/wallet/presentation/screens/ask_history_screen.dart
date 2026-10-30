import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/themes/app_icons.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_background.dart';
import 'package:my_wallet/features/wallet/presentation/widgets/ask_chat_models.dart';

/// Full-screen list of saved conversations.
class AskHistoryScreen extends StatefulWidget {
  final bool isAr;

  const AskHistoryScreen({super.key, required this.isAr});

  @override
  State<AskHistoryScreen> createState() => _AskHistoryScreenState();
}

class _AskHistoryScreenState extends State<AskHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = widget.isAr;
    final isIOS = Platform.isIOS;

    final bg = isDark ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);
    final textMuted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final textSecondary =
        isDark ? const Color(0xFFB4B4BC) : const Color(0xFF52525B);
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final card = isDark ? const Color(0xFF141418) : Colors.white;

    final now = DateTime.now();
    final today = <AskConversation>[];
    final earlier = <AskConversation>[];
    for (final item in AskHistoryStore.items) {
      final sameDay = item.createdAt.year == now.year &&
          item.createdAt.month == now.month &&
          item.createdAt.day == now.day;
      (sameDay ? today : earlier).add(item);
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: Text(
          isAr ? 'السجل' : 'History',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: textPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: AskBackground(isDark: isDark)),
          SafeArea(
            bottom: false,
            child: (today.isEmpty && earlier.isEmpty)
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: card,
                              shape: BoxShape.circle,
                              border: Border.all(color: border, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.30 : 0.06,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                AppIcons.clock(isIOS: isIOS),
                                size: 28,
                                color: textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            isAr
                                ? 'لسه مفيش محادثات محفوظة.'
                                : 'No saved conversations yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            isAr
                                ? 'أي محادثة تبدأها مع المساعد هتتسجل هنا عشان ترجع لها في أي وقت.'
                                : 'Any conversation you start with the assistant will appear here so you can revisit it anytime.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.45,
                              fontWeight: FontWeight.w400,
                              color: textMuted,
                            ),
                          ),
                          const SizedBox(height: 48),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
                    children: [
                      if (today.isNotEmpty) ...[
                        _sectionLabel(
                          isAr ? 'اليوم' : 'TODAY',
                          textMuted,
                        ),
                        _buildGroupedSection(
                          items: today,
                          isAr: isAr,
                          isDark: isDark,
                          isIOS: isIOS,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          textSecondary: textSecondary,
                          border: border,
                          card: card,
                        ),
                        const SizedBox(height: 24),
                      ],
                      if (earlier.isNotEmpty) ...[
                        _sectionLabel(
                          isAr ? 'أقدم' : 'EARLIER',
                          textMuted,
                        ),
                        _buildGroupedSection(
                          items: earlier,
                          isAr: isAr,
                          isDark: isDark,
                          isIOS: isIOS,
                          textPrimary: textPrimary,
                          textMuted: textMuted,
                          textSecondary: textSecondary,
                          border: border,
                          card: card,
                        ),
                      ],
                      const SizedBox(height: 28),
                      Text(
                        isAr
                            ? 'اضغط مطولًا على محادثة لحذفها.'
                            : 'Hold a conversation to delete it.',
                        style: TextStyle(fontSize: 13, color: textMuted),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: color,
        ),
      ),
    );
  }

  Widget _buildGroupedSection({
    required List<AskConversation> items,
    required bool isAr,
    required bool isDark,
    required bool isIOS,
    required Color textPrimary,
    required Color textMuted,
    required Color textSecondary,
    required Color border,
    required Color card,
  }) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      if (i > 0) {
        children.add(
          Divider(
            height: 1,
            thickness: 0.5,
            indent: 16,
            endIndent: 16,
            color: border.withValues(alpha: 0.6),
          ),
        );
      }
      children.add(
        _row(
          item: items[i],
          isAr: isAr,
          textPrimary: textPrimary,
          textMuted: textMuted,
          textSecondary: textSecondary,
          border: border,
          padded: isIOS,
        ),
      );
    }

    if (isIOS) {
      return GlassContainer(
        shape: const LiquidRoundedSuperellipse(borderRadius: 18),
        settings: isDark
            ? LiquidGlassSettings.ios27Dark
            : LiquidGlassSettings.ios27Light,
        useOwnLayer: true,
        child: Column(
          children: children,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 1),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _row({
    required AskConversation item,
    required bool isAr,
    required Color textPrimary,
    required Color textMuted,
    required Color textSecondary,
    required Color border,
    bool padded = false,
  }) {
    final now = DateTime.now();
    final sameDay = item.createdAt.year == now.year &&
        item.createdAt.month == now.month &&
        item.createdAt.day == now.day;
    final preview = item.messages.isEmpty ? '' : item.messages.last.text;
    final meta = sameDay
        ? '${item.messages.length} ${isAr ? "رسائل" : "messages"}'
        : DateFormat('MMM d').format(item.createdAt);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        Navigator.pop(context, item);
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        setState(() => AskHistoryStore.items.remove(item));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padded ? 16 : 12,
          vertical: 14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),
                  if (preview.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.5, color: textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                meta,
                style: TextStyle(fontSize: 12.5, color: textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
