import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neo_cupertino/neo_cupertino.dart';

import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/wallet/presentation/screens/ask_chat_screen.dart'
    show AskLogo;

/// Lets the user rename the assistant. Returns the saved name (or null when
/// dismissed without saving).
Future<String?> showAssistantNameSheet(
  BuildContext context, {
  required bool isAr,
}) async {
  if (Platform.isIOS) {
    final sheetController = GlassModalSheetController();
    return await GlassModalSheet.present<String>(
      context: context,
      controller: sheetController,
      halfSize: 0.54,
      fullSize: 0.76,
      initialState: GlassSheetState.half,
      showDragIndicator: true,
      builder: (sheetContext) => Material(
        type: MaterialType.transparency,
        child: _AssistantNameSheet(
          isAr: isAr,
          controller: sheetController,
          isGlass: true,
        ),
      ),
    );
  } else {
    return await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AssistantNameSheet(isAr: isAr),
    );
  }
}

class _AssistantNameSheet extends StatefulWidget {
  final bool isAr;
  final GlassModalSheetController? controller;
  final bool isGlass;

  const _AssistantNameSheet({
    required this.isAr,
    this.controller,
    this.isGlass = false,
  });

  @override
  State<_AssistantNameSheet> createState() => _AssistantNameSheetState();
}

class _AssistantNameSheetState extends State<_AssistantNameSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: _customName(),
  );
  final FocusNode _focusNode = FocusNode();

  String? _customName() {
    try {
      final name = SharedPrefs.assistantName;
      return name == 'Mahfazti AI' ? null : name;
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _save() {
    HapticFeedback.selectionClick();
    final value = _controller.text.trim();
    SharedPrefs.setAssistantName(value);
    Navigator.of(context).pop(value.isEmpty ? 'Mahfazti AI' : value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = widget.isAr;

    final card = isDark ? const Color(0xFF141418) : Colors.white;
    final border = isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final textPrimary = isDark ? Colors.white : const Color(0xFF09090B);
    final textMuted = isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final surface = isDark ? const Color(0xFF1A1A1E) : const Color(0xFFF3F3F6);

    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    final content = Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        widget.isGlass ? 28 : 12,
        20,
        24 + viewInsets,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isGlass)
            const SizedBox(height: 16)
          else
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          Center(child: AskLogo(size: 56, isDark: isDark)),
          const SizedBox(height: 16),
          Text(
            isAr ? 'اسمّي مساعدك' : 'Name your assistant',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isAr
                ? 'سمّيه أي حاجة، وهو هيتجاوب عليها.'
                : 'Call it whatever you want, it will answer to it.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.4,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 18),
          widget.isGlass
              ? GlassContainer(
                  height: 52,
                  shape: const LiquidRoundedSuperellipse(borderRadius: 16),
                  settings: isDark
                      ? LiquidGlassSettings.ios27Dark
                      : LiquidGlassSettings.ios27Light,
                  useOwnLayer: true,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Center(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.words,
                      keyboardAppearance:
                          isDark ? Brightness.dark : Brightness.light,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: false,
                        fillColor: Colors.transparent,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: 'Mahfazti AI',
                        hintStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textMuted,
                        ),
                      ),
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textAlign: TextAlign.center,
                    textCapitalization: TextCapitalization.words,
                    keyboardAppearance:
                        isDark ? Brightness.dark : Brightness.light,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                    decoration: InputDecoration(
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isCollapsed: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      hintText: 'Mahfazti AI',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          Text(
            isAr
                ? 'سيبه فاضي عشان ترجع لـ Mahfazti AI.'
                : 'Leave it empty to go back to Mahfazti AI.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: textMuted),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: textPrimary,
                foregroundColor: isDark ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                isAr ? 'حفظ' : 'Save',
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.isGlass) {
      return content;
    }

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: Border.all(color: border, width: 1),
      ),
      child: content,
    );
  }
}
