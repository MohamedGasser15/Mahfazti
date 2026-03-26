import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';

class RecoveryCheckUserScreen extends StatefulWidget {
  const RecoveryCheckUserScreen({super.key});

  @override
  State<RecoveryCheckUserScreen> createState() => _RecoveryCheckUserScreenState();
}

class _RecoveryCheckUserScreenState extends State<RecoveryCheckUserScreen> {
  final _controller = TextEditingController();
  final _authRepository = AuthRepository();
  bool _isLoading = false;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _isValid = _controller.text.trim().length >= 3);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final value = _controller.text.trim();
    setState(() => _isLoading = true);
    try {
      final result = await _authRepository.recoveryCheckUser(value);
      if (result['success'] == true) {
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/recovery-password',
            arguments: {'emailOrUsername': value},
          );
        }
      } else {
       MessageService.showError(result['message'] ?? context.l10n.userNotFound);
      }
    } catch (e) {
     MessageService.showError(context.l10n.somethingWentWrong);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRTL = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Icon
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.manage_accounts_outlined,
                        size: 32, color: theme.colorScheme.primary),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    context.l10n.lostAccessToEmail,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                   context.l10n.recoveryEnterUsernameOrEmail,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onBackground.withOpacity(0.6),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 40),

                  TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) { if (_isValid) _onContinue(); },
                    decoration: InputDecoration(
                     hintText: context.l10n.usernameOrEmail,
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onBackground.withOpacity(0.4),
                      ),
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onBackground.withOpacity(0.5),
                      ),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _controller.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surface,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18,
                      ),
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ElevatedButton(
              onPressed: _isValid && !_isLoading ? _onContinue : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor:
                    theme.colorScheme.primary.withOpacity(0.5),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                     context.l10n.continueText,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}