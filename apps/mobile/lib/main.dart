import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:my_wallet/core/constants/app_routes.dart';
import 'package:my_wallet/core/services/hide_balance_service.dart';
import 'package:my_wallet/core/services/theme_service.dart';
import 'package:my_wallet/core/services/watch_service.dart';
import 'package:my_wallet/core/themes/app_theme.dart';
import 'package:my_wallet/core/utils/language_service.dart';
import 'package:my_wallet/core/utils/navigation_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/splash/presentation/screens/splash_screen.dart';
import 'package:my_wallet/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  WatchService.initialize();
  await SharedPrefs.init();
  await ThemeService.init();
  await LanguageService.init();

  runApp(const MyWalletApp());
}

class MyWalletApp extends StatefulWidget {
  const MyWalletApp({super.key});

  @override
  State<MyWalletApp> createState() => _MyWalletAppState();
}

class _MyWalletAppState extends State<MyWalletApp> {
  Locale _currentLocale = LanguageService.english;

  @override
  void initState() {
    super.initState();
    _loadInitialLocale();
    LanguageService.localeNotifier.addListener(_onLocaleChanged);
  }

  Future<void> _loadInitialLocale() async {
    final savedLocale = await LanguageService.getSavedLocale();
    if (mounted) {
      setState(() {
        _currentLocale = savedLocale;
      });
    }
  }

  void _onLocaleChanged() {
    if (mounted) {
      setState(() {
        _currentLocale = LanguageService.localeNotifier.value;
      });
    }
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
    LanguageService.saveLocale(locale);
  }

  @override
  void dispose() {
    LanguageService.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HideBalanceService()),
      ],
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeService.themeNotifier,
        builder: (context, themeMode, child) {
          return MaterialApp(
            title: 'Mahfazti',
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            locale: _currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ar', 'SA'),
            ],
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: SplashScreen(onLocaleChanged: _changeLocale),
            builder: (context, child) {
              final isRTL = _currentLocale.languageCode == 'ar';

              return Directionality(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  child: child!,
                ),
              );
            },
            onGenerateRoute: (settings) => AppRoutes.onGenerateRoute(
              settings,
              onLocaleChanged: _changeLocale,
            ),
          );
        },
      ),
    );
  }
}