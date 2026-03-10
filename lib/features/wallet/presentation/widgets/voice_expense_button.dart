import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';

class VoiceExpenseButton extends StatefulWidget {
  final Function(VoiceExpenseResult result) onResult;
  final bool isDarkMode;

  const VoiceExpenseButton({
    super.key,
    required this.onResult,
    required this.isDarkMode,
  });

  @override
  State<VoiceExpenseButton> createState() => _VoiceExpenseButtonState();
}

class _VoiceExpenseButtonState extends State<VoiceExpenseButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final WalletRepository _repo = WalletRepository();

  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = '';
  
  // ✅ اللغة المختارة - default عربي
  String _selectedLocale = 'ar_EG';
  bool _isArabic = true;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onError: (error) {
        setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          if (result.finalResult) {
            _stopAndProcess();
          }
        },
        // ✅ بيستخدم اللغة المختارة
        localeId: _selectedLocale,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _stopAndProcess() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
      _isProcessing = true;
    });

    if (_recognizedText.isNotEmpty) {
      try {
        // ✅ بنبعت اللغة المختارة للـ API
        final lang = _isArabic ? 'ar' : 'en';
        final result = await _repo.parseVoiceText(
          _recognizedText,
          language: lang,
        );
        widget.onResult(result);
      } catch (e) {
        widget.onResult(VoiceExpenseResult(
          isSuccess: false,
          errorMessage: 'فشل الاتصال بالسيرفر',
        ));
      }
    }

    setState(() => _isProcessing = false);
  }

  // ✅ toggle اللغة
  void _toggleLanguage() {
    if (_isListening) return; // مش نغير وهو بيسمع
    setState(() {
      _isArabic = !_isArabic;
      _selectedLocale = _isArabic ? 'ar_EG' : 'en_US';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ✅ زرار تغيير اللغة
        GestureDetector(
          onTap: _toggleLanguage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _isListening
                  ? Colors.grey.withOpacity(0.3)
                  : (widget.isDarkMode
                      ? Colors.grey[800]
                      : Colors.grey[200]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[400]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isArabic ? '🇪🇬' : '🇺🇸',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 4),
                Text(
                  _isArabic ? 'ع' : 'EN',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: widget.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 10),

        // ✅ زرار المايك
        GestureDetector(
          onTap: _isListening ? _stopAndProcess : _startListening,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = _isListening
                  ? 1.0 + (_pulseController.value * 0.15)
                  : 1.0;
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isListening
                        ? Colors.red[700]
                        : (widget.isDarkMode
                            ? Colors.grey[800]
                            : Colors.grey[200]),
                    boxShadow: _isListening
                        ? [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            )
                          ]
                        : null,
                  ),
                  child: _isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _isListening ? Icons.stop : Icons.mic,
                          color: _isListening
                              ? Colors.white
                              : (widget.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                          size: 28,
                        ),
                ),
              );
            },
          ),
        ),

        // ✅ لو بيسمع بيظهر النص اللي بيتعرف عليه
        if (_isListening && _recognizedText.isNotEmpty) ...[
          const SizedBox(width: 10),
          Container(
            constraints: const BoxConstraints(maxWidth: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Text(
              _recognizedText,
              style: TextStyle(
                fontSize: 11,
                color: widget.isDarkMode ? Colors.white70 : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}