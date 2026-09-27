import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:my_wallet/features/wallet/data/models/voice_expense_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/wallet_repository.dart';

class VoiceExpenseButton extends StatefulWidget {
  final Function(VoiceExpenseResult result) onResult;
  final bool isDarkMode;

  final bool isCircular;

  const VoiceExpenseButton({
    super.key,
    required this.onResult,
    required this.isDarkMode,
    this.isCircular = false,
    this.isInHero = false,
  });

  final bool isInHero;

  @override
  State<VoiceExpenseButton> createState() => _VoiceExpenseButtonState();
}

class _VoiceExpenseButtonState extends State<VoiceExpenseButton>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final WalletRepository _repo = WalletRepository();

  bool _isListening = false;
  bool _isProcessing = false;
  bool _hasProcessed = false;
  String _recognizedText = '';
  bool _speechInitialized = false;

  late bool _isArabic;
  late String _selectedLocale;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final deviceLocale = Platform.localeName;
    _isArabic = deviceLocale.startsWith('ar');
    _selectedLocale = _isArabic ? 'ar_EG' : 'en_US';

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (error) {
        debugPrint('Speech error: ${error.errorMsg}');
        if (mounted) setState(() => _isListening = false);
      },
      onStatus: (status) {
        debugPrint('Speech status: $status');
        if ((status == 'done' || status == 'notListening') && _isListening) {
          _stopAndProcess();
        }
      },
    );
    if (mounted) setState(() => _speechInitialized = available);
  }

  void _toggleLanguage() {
    if (_isListening) return;
    setState(() {
      _isArabic = !_isArabic;
      _selectedLocale = _isArabic ? 'ar_EG' : 'en_US';
    });
  }

  Future<void> _startListening() async {
    if (!_speechInitialized) await _initSpeech();
    if (!_speechInitialized) return;

    setState(() {
      _isListening = true;
      _recognizedText = '';
      _hasProcessed = false;
    });

    await _speech.listen(
      onResult: (result) {
        if (mounted) setState(() => _recognizedText = result.recognizedWords);
        if (result.finalResult && !_hasProcessed) {
          _stopAndProcess();
        }
      },
      localeId: _selectedLocale,
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 3),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
      ),
    );
  }

  Future<void> _stopAndProcess() async {
    if (_hasProcessed) return;
    if (!_isListening && _recognizedText.isEmpty) return;

    _hasProcessed = true;
    await _speech.stop();

    if (mounted) setState(() { _isListening = false; _isProcessing = true; });

    if (_recognizedText.isNotEmpty) {
  try {
    final result = await _repo.parseVoiceText(
      _recognizedText,
      language: _isArabic ? 'ar' : 'en',
    );
    widget.onResult(VoiceExpenseResult(
      amount: result.amount,
      transactionType: result.transactionType,
      categoryId: result.categoryId,
      categoryNameAr: result.categoryNameAr,
      categoryNameEn: result.categoryNameEn,
      title: result.title,
      note: null,
      isSuccess: result.isSuccess,
      errorMessage: result.errorMessage,
    ));
  } catch (e) {
    widget.onResult(VoiceExpenseResult(
      isSuccess: false,
      errorMessage: 'فشل الاتصال بالسيرفر',
    ));
  }
}

    if (mounted) setState(() => _isProcessing = false);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        if (widget.isCircular) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isListening ? _stopAndProcess : _startListening,
                  onLongPress: _toggleLanguage,
                  borderRadius: BorderRadius.circular(28),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _isListening
                          ? const Color(0xFFF43F5E).withValues(alpha: 0.22)
                          : (widget.isInHero
                              ? Colors.white.withValues(alpha: 0.18)
                              : (isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5))),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isListening
                            ? const Color(0xFFF43F5E)
                            : (widget.isInHero
                                ? Colors.white.withValues(alpha: 0.32)
                                : (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7))),
                        width: _isListening ? 1.5 : (widget.isInHero ? 1.2 : 1.0),
                      ),
                      boxShadow: _isListening
                          ? [
                              BoxShadow(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.25 * _pulseController.value),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : (widget.isInHero && !isDark
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null),
                    ),
                    child: Center(
                      child: _isProcessing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.isInHero ? Colors.white : (isDark ? Colors.white : Colors.black),
                              ),
                            )
                          : Icon(
                              _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                              color: _isListening
                                  ? const Color(0xFFF43F5E)
                                  : (widget.isInHero ? Colors.white : (isDark ? Colors.white : Colors.black)),
                              size: 22,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isListening
                    ? (_isArabic ? 'أستمع...' : 'Listening...')
                    : (_isArabic ? 'صوتي' : 'Voice'),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.isInHero ? FontWeight.w700 : FontWeight.w600,
                  color: _isListening
                      ? const Color(0xFFF43F5E)
                      : (widget.isInHero
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[600])),
                  shadows: (widget.isInHero && !isDark && !_isListening)
                      ? [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.60),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          );
        }

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isListening ? _stopAndProcess : _startListening,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _isListening
                    ? const Color(0xFFF43F5E).withValues(alpha: 0.18)
                    : (isDark ? const Color(0xFF18181B) : const Color(0xFFF4F4F5)),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isListening
                      ? const Color(0xFFF43F5E)
                      : (isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7)),
                  width: _isListening ? 1.5 : 1.0,
                ),
                boxShadow: _isListening
                    ? [
                        BoxShadow(
                          color: const Color(0xFFF43F5E).withValues(alpha: 0.25 * _pulseController.value),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _isProcessing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        )
                      : Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                          color: _isListening
                              ? const Color(0xFFF43F5E)
                              : (isDark ? Colors.white : Colors.black),
                          size: 16,
                        ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _isListening
                          ? (_isArabic ? 'أستمع...' : 'Listening...')
                          : (_isArabic ? 'صوتي' : 'Voice'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isListening
                            ? const Color(0xFFF43F5E)
                            : (isDark ? Colors.white : Colors.black),
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggleLanguage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _isArabic ? 'AR' : 'EN',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}