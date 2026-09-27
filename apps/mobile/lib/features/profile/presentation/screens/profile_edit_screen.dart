// features/profile/presentation/screens/profile_edit_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/features/profile/data/repositories/profile_repository.dart';

class ProfileEditScreen extends StatefulWidget {
  final VoidCallback? onProfileUpdated;

  const ProfileEditScreen({super.key, this.onProfileUpdated});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  String? _profileImageUrl;

  String _initialFullName = '';
  String _initialPhone = '';

  final ProfileRepository _profileRepository = ProfileRepository();

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _loadProfile();
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  bool get _hasChanges {
    return _fullNameController.text.trim() != _initialFullName ||
        _phoneController.text.trim() != _initialPhone;
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await _profileRepository.getProfile();
      _fullNameController.text = profile.fullName;
      _userNameController.text = profile.userName;
      _phoneController.text = profile.phoneNumber;
      _emailController.text = profile.email;
      _profileImageUrl = profile.profileImageUrl;

      _initialFullName = profile.fullName.trim();
      _initialPhone = profile.phoneNumber.trim();
    } catch (e) {
      setState(() {
        _errorMessage = context.l10n.errorWithDetails(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _resetForm() {
    HapticFeedback.lightImpact();
    _fullNameController.text = _initialFullName;
    _phoneController.text = _initialPhone;
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await _profileRepository.updateProfile(
        fullName: _fullNameController.text.trim(),
        userName: _userNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      _initialFullName = _fullNameController.text.trim();
      _initialPhone = _phoneController.text.trim();

      if (mounted) {
        HapticFeedback.lightImpact();
        MessageService.showSuccess(
          context: context,
          message: context.l10n.profileUpdatedSuccess,
        );
        widget.onProfileUpdated?.call();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.heavyImpact();
        setState(() {
          _errorMessage = '${context.l10n.failedToUpdateProfile}: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '';
    }
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _fullNameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Widget _buildCardField({
    required BuildContext context,
    required bool isDarkMode,
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefixText,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final labelColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);
    final iconBg = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5);
    final iconColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                TextFormField(
                  controller: controller,
                  enabled: enabled,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? textColor
                        : (isDarkMode ? const Color(0xFF71717A) : const Color(0xFFA1A1AA)),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    hintText: hintText,
                    hintStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDarkMode ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    prefixText: prefixText,
                    prefixStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                    ),
                  ),
                  validator: validator,
                ),
              ],
            ),
          ),
          if (enabled && controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                controller.clear();
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.cancel_rounded,
                  size: 18,
                  color: isDarkMode ? const Color(0xFF52525B) : const Color(0xFFA1A1AA),
                ),
              ),
            ),
          if (!enabled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 11,
                    color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isArabic ? 'ثابت' : 'Fixed',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: isDarkMode ? const Color(0xFF1F1F24) : const Color(0xFFF4F4F6),
    );
  }

  Widget _buildSectionCard({
    required bool isDarkMode,
    required String title,
    required List<Widget> children,
    Widget? footer,
  }) {
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, right: 6, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
              color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: isDarkMode
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            children: children,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: footer,
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final l10n = context.l10n;
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final iconBgColor = isDarkMode ? const Color(0xFF141418) : Colors.white;

    final initials = _getInitials(_fullNameController.text);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          l10n.personalDetails,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: Center(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Center(
                  child: Transform.scale(
                    scaleX: isArabic ? -1 : 1,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 15,
                      color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          if (_hasChanges)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: TextButton(
                  onPressed: _resetForm,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isArabic ? 'إلغاء' : 'Reset',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: isDarkMode ? Colors.white : const Color(0xFF09090B),
              ),
            )
          : GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: ResponsiveWrapper(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero Avatar Section
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF6366F1),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.22),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDarkMode
                                        ? const Color(0xFF141418)
                                        : const Color(0xFFF4F4F5),
                                    image: _profileImageUrl != null &&
                                            _profileImageUrl!.isNotEmpty
                                        ? DecorationImage(
                                            image: NetworkImage(_profileImageUrl!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (_profileImageUrl == null ||
                                          _profileImageUrl!.isEmpty)
                                      ? Center(
                                          child: Text(
                                            initials.isNotEmpty ? initials : '?',
                                            style: TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.5,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : const Color(0xFF09090B),
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              // Live display name
                              Text(
                                _fullNameController.text.trim().isNotEmpty
                                    ? _fullNameController.text.trim()
                                    : (isArabic ? 'الملف الشخصي' : 'User Profile'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDarkMode ? Colors.white : const Color(0xFF09090B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Error Banner
                        if (_errorMessage != null) ...[
                          Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: Color(0xFFEF4444),
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Color(0xFFEF4444),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => setState(() => _errorMessage = null),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Section 1: Personal Details
                        _buildSectionCard(
                          isDarkMode: isDarkMode,
                          title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                          children: [
                            _buildCardField(
                              context: context,
                              isDarkMode: isDarkMode,
                              controller: _fullNameController,
                              label: l10n.fullName,
                              hintText: l10n.enterFullName,
                              icon: Icons.person_outline_rounded,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterFullName;
                                }
                                if (value.trim().length < 2) {
                                  return isArabic ? 'الاسم قصير جداً' : 'Name is too short';
                                }
                                return null;
                              },
                            ),
                            _buildDivider(isDarkMode),
                            _buildCardField(
                              context: context,
                              isDarkMode: isDarkMode,
                              controller: _phoneController,
                              label: l10n.phoneNumber,
                              hintText: l10n.enterPhoneNumber,
                              keyboardType: TextInputType.phone,
                              icon: Icons.phone_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return l10n.pleaseEnterPhoneNumber;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Section 2: Account Details
                        _buildSectionCard(
                          isDarkMode: isDarkMode,
                          title: isArabic ? 'بيانات الحساب' : 'Account Details',
                          children: [
                            _buildCardField(
                              context: context,
                              isDarkMode: isDarkMode,
                              controller: _emailController,
                              label: l10n.email,
                              hintText: l10n.email,
                              icon: Icons.mail_outline_rounded,
                              enabled: false,
                            ),
                          ],
                          footer: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                size: 14,
                                color: isDarkMode
                                    ? const Color(0xFF71717A)
                                    : const Color(0xFFA1A1AA),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isArabic
                                      ? 'البريد الإلكتروني مرتبط بحسابك للأمان ولا يمكن تغييره.'
                                      : 'Email is linked to your account for security and cannot be changed.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDarkMode
                                        ? const Color(0xFF71717A)
                                        : const Color(0xFFA1A1AA),
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          12 + MediaQuery.of(context).padding.bottom,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border(
            top: BorderSide(
              color: isDarkMode ? const Color(0xFF1F1F24) : const Color(0xFFE4E4E7),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: (_isSaving || !_hasChanges) ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                disabledBackgroundColor: isDarkMode
                    ? const Color(0xFF27272A).withValues(alpha: 0.6)
                    : const Color(0xFFE4E4E7),
                disabledForegroundColor: isDarkMode
                    ? const Color(0xFF71717A)
                    : const Color(0xFFA1A1AA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.save,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}