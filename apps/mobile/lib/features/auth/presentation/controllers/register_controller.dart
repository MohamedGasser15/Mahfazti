import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_wallet/features/auth/data/repositories/auth_repository.dart';
import 'package:my_wallet/features/auth/presentation/models/registration_step.dart';

class RegisterController extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterController({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    _codeControllers = List.generate(
      codeLength,
      (_) => TextEditingController(),
    );
    _codeFocusNodes = List.generate(codeLength, (_) => FocusNode());
  }

  static const int codeLength = 6;

  // Step & Data
  RegistrationStep _step = RegistrationStep.email;
  String? _registeredEmail;
  int _resendSeconds = 90;
  Timer? _resendTimer;

  // Loading & Flow flags
  bool _isSendingCode = false;
  bool _isVerifying = false;
  bool _isRegistering = false;
  bool _needsFreshCode = false;

  // Password obscurity
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // OTP inputs
  late final List<TextEditingController> _codeControllers;
  late final List<FocusNode> _codeFocusNodes;

  // Form Keys & Controllers
  final GlobalKey<FormState> emailFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> detailsFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  // Getters
  RegistrationStep get step => _step;
  String? get registeredEmail => _registeredEmail;
  int get resendSeconds => _resendSeconds;
  bool get isSendingCode => _isSendingCode;
  bool get isVerifying => _isVerifying;
  bool get isRegistering => _isRegistering;
  bool get needsFreshCode => _needsFreshCode;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  List<TextEditingController> get codeControllers => _codeControllers;
  List<FocusNode> get codeFocusNodes => _codeFocusNodes;

  String get otpCode => _codeControllers.map((c) => c.text).join();

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setStep(RegistrationStep newStep) {
    if (_step == newStep) return;
    _step = newStep;
    notifyListeners();
  }

  void resetToEmailStep() {
    _resendTimer?.cancel();
    _step = RegistrationStep.email;
    notifyListeners();
  }

  void startCountdown() {
    _resendTimer?.cancel();
    _resendSeconds = 90;
    notifyListeners();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds <= 0) {
        timer.cancel();
        return;
      }
      _resendSeconds--;
      notifyListeners();
    });
  }

  void stopCountdown() {
    _resendTimer?.cancel();
  }

  /// Handles back button press inside the registration flow.
  /// Returns `true` if handled within the wizard steps,
  /// or `false` if already at the first step (`RegistrationStep.email`).
  bool handleBack() {
    if (_step == RegistrationStep.details) {
      _resendTimer?.cancel();
      for (final controller in _codeControllers) {
        controller.clear();
      }
      _step = RegistrationStep.verification;
      _resendSeconds = 0;
      _needsFreshCode = true;
      notifyListeners();
      return true;
    } else if (_step == RegistrationStep.verification) {
      _resendTimer?.cancel();
      _step = RegistrationStep.email;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> sendCode({
    required void Function(String message) onError,
    required void Function(String message) onSuccess,
    required String validEmailRequiredMessage,
    required String Function(String email) verificationCodeSentMessage,
  }) async {
    if (_isSendingCode) return false;
    final email = emailController.text.trim();
    if (!(emailFormKey.currentState?.validate() ?? false)) return false;
    if (email.isEmpty) {
      onError(validEmailRequiredMessage);
      return false;
    }

    _isSendingCode = true;
    notifyListeners();
    try {
      await _authRepository.sendCode(email: email);
      _registeredEmail = email;
      for (final c in _codeControllers) {
        c.clear();
      }
      _step = RegistrationStep.verification;
      _needsFreshCode = false;
      startCountdown();
      onSuccess(verificationCodeSentMessage(email));
      return true;
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isSendingCode = false;
      notifyListeners();
    }
  }

  Future<bool> verifyCode({
    required void Function(String message) onError,
    required String digitCodeRequiredMessage,
  }) async {
    if (_isVerifying || _registeredEmail == null || _needsFreshCode) {
      return false;
    }
    final code = otpCode;
    if (code.length != codeLength) {
      onError(digitCodeRequiredMessage);
      return false;
    }

    _isVerifying = true;
    notifyListeners();
    try {
      await _authRepository.verifyEmail(email: _registeredEmail!, code: code);
      _resendTimer?.cancel();
      _step = RegistrationStep.details;
      return true;
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  Future<bool> register({
    required void Function(String message) onError,
    required void Function(String message) onSuccess,
    required String accountCreatedSuccessMessage,
  }) async {
    if (!(detailsFormKey.currentState?.validate() ?? false)) return false;
    final fullName = nameController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    _isRegistering = true;
    notifyListeners();
    try {
      await _authRepository.register(
        fullName: fullName,
        email: _registeredEmail!,
        password: password,
        confirmPassword: confirmPassword,
      );
      // Auto-login user after registration
      await _authRepository.login(email: _registeredEmail!, password: password);
      onSuccess(accountCreatedSuccessMessage);
      return true;
    } catch (e) {
      onError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _isRegistering = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (final c in _codeControllers) {
      c.dispose();
    }
    for (final n in _codeFocusNodes) {
      n.dispose();
    }
    super.dispose();
  }
}
