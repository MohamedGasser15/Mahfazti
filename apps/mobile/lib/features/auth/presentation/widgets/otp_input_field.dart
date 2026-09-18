import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputField extends StatefulWidget {
  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const OtpInputField({
    super.key,
    this.length = 6,
    required this.controllers,
    required this.focusNodes,
    this.onCompleted,
    this.onChanged,
  }) : assert(controllers.length == length && focusNodes.length == length);

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.length; i++) {
      widget.controllers[i].addListener(_onFieldChanged);
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.length; i++) {
      widget.controllers[i].removeListener(_onFieldChanged);
    }
    super.dispose();
  }

  void _onFieldChanged() {
    final code = widget.controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.length && !code.contains('')) {
      widget.onCompleted?.call(code);
    }
  }

  void _handlePaste(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return;

    for (int i = 0; i < widget.length; i++) {
      if (i < digits.length) {
        widget.controllers[i].text = digits[i];
      } else {
        widget.controllers[i].clear();
      }
    }

    final targetIndex = (digits.length >= widget.length)
        ? widget.length - 1
        : digits.length;
    widget.focusNodes[targetIndex].requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(widget.length, (index) {
        final controller = widget.controllers[index];
        final focusNode = widget.focusNodes[index];

        return SizedBox(
          width: 48,
          height: 58,
          child: Focus(
            onKeyEvent: (node, event) {
              if (event is KeyDownEvent &&
                  event.logicalKey == LogicalKeyboardKey.backspace) {
                if (controller.text.isEmpty && index > 0) {
                  widget.controllers[index - 1].clear();
                  widget.focusNodes[index - 1].requestFocus();
                  return KeyEventResult.handled;
                }
              }
              return KeyEventResult.ignored;
            },
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: isDark
                    ? (focusNode.hasFocus ? const Color(0xFF2A2A2A) : const Color(0xFF1E1E1E))
                    : (focusNode.hasFocus ? Colors.white : const Color(0xFFF3F4F6)),
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: controller.text.isNotEmpty
                        ? (isDark ? Colors.white54 : Colors.black45)
                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                    width: controller.text.isNotEmpty ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  // In case multiple digits pasted into a single box
                  _handlePaste(value);
                  return;
                }
                if (value.isNotEmpty) {
                  if (index < widget.length - 1) {
                    widget.focusNodes[index + 1].requestFocus();
                  } else {
                    focusNode.unfocus();
                  }
                }
              },
            ),
          ),
        );
      }),
    ),
    );
  }
}
