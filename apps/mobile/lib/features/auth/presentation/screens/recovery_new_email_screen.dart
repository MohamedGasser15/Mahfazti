import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class RecoveryNewEmailScreen extends StatefulWidget {
  final String emailOrUsername;
  final String password;
  const RecoveryNewEmailScreen({
    super.key,
    required this.emailOrUsername,
    required this.password,
  });

  @override
  State<RecoveryNewEmailScreen> createState() => _RecoveryNewEmailScreenState();
}

class _RecoveryNewEmailScreenState extends State<RecoveryNewEmailScreen> with TickerProviderStateMixin {
  final _controller = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _isValid = false;

  late AnimationController _fadeController;
  late Animation<double> _logoFade;
  late Animation<Offset> _logoSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final email = _controller.text.trim();
      final emailRegex =
          RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
      setState(() => _isValid = emailRegex.hasMatch(email));
    });

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );
    _logoSlide = Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.3, curve: Curves.easeOut)),
    );

    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );
    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.5, curve: Curves.easeOut)),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.7, curve: Curves.easeOut)),
    );

    _buttonFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final newEmail = _controller.text.trim();
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.recoveryRequestEmailChange(
        emailOrUsername: widget.emailOrUsername,
        newEmail: newEmail,
      );

      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/recovery-otp',
            arguments: {
              'emailOrUsername': widget.emailOrUsername,
              'newEmail': newEmail,
            },
          );
        }
      } else if (mounted) {
        MessageService.showError(context: context, message: result['message'] ?? context.l10n.emailAlreadyInUse);
      }
    } catch (e) {
      if (mounted) {
        MessageService.showError(context: context, message: context.l10n.somethingWentWrong);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Logo
                    SlideTransition(
                      position: _logoSlide,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Center(
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.primary.withValues(alpha: 0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.account_balance_wallet,
                              size: 40,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Title & Subtitle
                    SlideTransition(
                      position: _titleSlide,
                      child: FadeTransition(
                        opacity: _titleFade,
                        child: Column(
                          children: [
                            Center(
                              child: Text(
                                context.l10n.enterNewEmail,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: Text(
                                context.l10n.enterNewEmailDescription,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Form
                    SlideTransition(
                      position: _formSlide,
                      child: FadeTransition(
                        opacity: _formFade,
                        child: TextField(
                          controller: _controller,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) { if (_isValid) _onContinue(); },
                          decoration: InputDecoration(
                            hintText: context.l10n.newEmailAddressHint,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                            suffixIcon: _controller.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => _controller.clear(),
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark ? Colors.grey[900] : Colors.grey[50],
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18,
                            ),
                          ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Button
            SlideTransition(
              position: _buttonSlide,
              child: FadeTransition(
                opacity: _buttonFade,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isValid && !_isLoading ? _onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValid ? Colors.white : Colors.grey[300],
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.black38,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isValid ? 4 : 0,
                        shadowColor: Colors.black26,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              context.l10n.sendVerificationCode,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
