import 'package:flutter/material.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/app_lock_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:provider/provider.dart';

class AppLockGate extends StatefulWidget {
  final Widget child;

  const AppLockGate({super.key, required this.child});

  @override
  State<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends State<AppLockGate> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final service = Provider.of<AppLockService>(context, listen: false);

    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      service.onAppPaused();
    } else if (state == AppLifecycleState.resumed) {
      service.onAppResumed(localizedReason: context.l10n.appLockPrompt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppLockService>(
      builder: (context, appLockService, _) {
        final shouldLock = appLockService.isEnabled &&
            appLockService.isLocked &&
            SharedPrefs.authToken != null;

        if (shouldLock) {
          return const AppLockScreen();
        }

        return widget.child;
      },
    );
  }
}

class AppLockScreen extends StatefulWidget {
  const AppLockScreen({super.key});

  @override
  State<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends State<AppLockScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final service = Provider.of<AppLockService>(context, listen: false);
        service.unlock(localizedReason: context.l10n.appLockPrompt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);
    final titleColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final subColor = isDarkMode ? const Color(0xFFA1A1AA) : const Color(0xFF71717A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Minimalist Monochrome Lock Icon
                Container(
                  padding: const EdgeInsets.all(3.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                    boxShadow: isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cardBg,
                      border: Border.all(color: borderColor, width: 1),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 38,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Title
                Text(
                  context.l10n.appLockLockedTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 10),

                // Subtitle
                Text(
                  context.l10n.appLockLockedMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: subColor,
                  ),
                ),

                const Spacer(flex: 3),

                // Unlock Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final service = Provider.of<AppLockService>(context, listen: false);
                      service.unlock(localizedReason: context.l10n.appLockPrompt);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode ? Colors.white : const Color(0xFF09090B),
                      foregroundColor: isDarkMode ? const Color(0xFF09090B) : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fingerprint_rounded,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          context.l10n.appLockUnlock,
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
