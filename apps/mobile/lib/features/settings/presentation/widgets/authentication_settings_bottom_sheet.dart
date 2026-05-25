// features/settings/presentation/widgets/authentication_settings_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:my_wallet/core/services/biometric_service.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart'; // لإتاحة context.l10n

class AuthenticationSettingsBottomSheet extends StatefulWidget {
  const AuthenticationSettingsBottomSheet({super.key});

  @override
  State<AuthenticationSettingsBottomSheet> createState() => 
      _AuthenticationSettingsBottomSheetState();
}

class _AuthenticationSettingsBottomSheetState 
    extends State<AuthenticationSettingsBottomSheet> {
  bool _biometricEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final hasSupport = await BiometricService.hasBiometricSupport();
    final isEnabled = await BiometricService.isBiometricEnabled();
    
    setState(() {
      _biometricEnabled = hasSupport && isEnabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      if (value) {
        final authenticated = await BiometricService.authenticate();
        if (authenticated) {
          await BiometricService.enableBiometric();
          setState(() {
            _biometricEnabled = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.biometricEnabledSuccess),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.biometricAuthenticationFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        await BiometricService.disableBiometric();
        setState(() {
          _biometricEnabled = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.biometricDisabledSuccess),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.errorWithDetails(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _changePin() async {
    Navigator.pop(context);
    // TODO: Navigate to change PIN screen
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Text(
            context.l10n.authenticationSettings,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Biometric Switch
          ListTile(
            leading: const Icon(Icons.fingerprint),
            title: Text(context.l10n.useBiometricAuthentication),
            subtitle: Text(context.l10n.biometricAuthenticationSubtitle),
            trailing: _isLoading
                ? const CircularProgressIndicator()
                : Switch(
                    value: _biometricEnabled,
                    onChanged: _toggleBiometric,
                  ),
          ),
          
          // Change PIN
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text(context.l10n.changePasscode),
            subtitle: Text(context.l10n.updateYour6DigitPasscode),
            onTap: _changePin,
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          ),
          
          const SizedBox(height: 16),
          
          // Close Button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}