import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get sendCode;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'Add Deposit'**
  String get addDeposit;

  /// No description provided for @addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransaction;

  /// No description provided for @addWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Add Withdrawal'**
  String get addWithdrawal;

  /// No description provided for @addYourFirstTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add your first transaction'**
  String get addYourFirstTransaction;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @allTransactionsInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'All your transactions in one place'**
  String get allTransactionsInOnePlace;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @amountGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Amount must be greater than 0'**
  String get amountGreaterThanZero;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @any.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get any;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @appIcon.
  ///
  /// In en, this message translates to:
  /// **'App Icon'**
  String get appIcon;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahfazti'**
  String get appTitle;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @authenticationSettings.
  ///
  /// In en, this message translates to:
  /// **'Authentication Settings'**
  String get authenticationSettings;

  /// No description provided for @bar.
  ///
  /// In en, this message translates to:
  /// **'Bar'**
  String get bar;

  /// No description provided for @biggestSpend.
  ///
  /// In en, this message translates to:
  /// **'Biggest spend'**
  String get biggestSpend;

  /// No description provided for @biometricAuthenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get biometricAuthenticationFailed;

  /// No description provided for @biometricAuthenticationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Face ID / Fingerprint to log in'**
  String get biometricAuthenticationSubtitle;

  /// No description provided for @biometricDisabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication disabled'**
  String get biometricDisabledSuccess;

  /// No description provided for @biometricEnableFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not enable biometric authentication'**
  String get biometricEnableFailed;

  /// No description provided for @biometricEnabledSuccess.
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication enabled'**
  String get biometricEnabledSuccess;

  /// No description provided for @biometricLoginDescription.
  ///
  /// In en, this message translates to:
  /// **'You can use {biometricName} for faster and more secure login.'**
  String biometricLoginDescription(Object biometricName);

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @budgetOverview.
  ///
  /// In en, this message translates to:
  /// **'Budget Overview'**
  String get budgetOverview;

  /// No description provided for @budgetTip.
  ///
  /// In en, this message translates to:
  /// **'Budget Tip'**
  String get budgetTip;

  /// No description provided for @budgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Budget updated to {amount}'**
  String budgetUpdated(Object amount);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cannotOpenStore.
  ///
  /// In en, this message translates to:
  /// **'Cannot open store'**
  String get cannotOpenStore;

  /// No description provided for @cannotOpenUrl.
  ///
  /// In en, this message translates to:
  /// **'Cannot open URL'**
  String get cannotOpenUrl;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryBills;

  /// No description provided for @categoryEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get categoryEducation;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get categoryFood;

  /// No description provided for @categoryFoodDining.
  ///
  /// In en, this message translates to:
  /// **'Food & Dining'**
  String get categoryFoodDining;

  /// No description provided for @categoryFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get categoryFreelance;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @categorySalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get categorySalary;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryTransportation.
  ///
  /// In en, this message translates to:
  /// **'Transportation'**
  String get categoryTransportation;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @changeAppIcon.
  ///
  /// In en, this message translates to:
  /// **'Change App Icon'**
  String get changeAppIcon;

  /// No description provided for @changeAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change app language'**
  String get changeAppLanguage;

  /// No description provided for @changePasscode.
  ///
  /// In en, this message translates to:
  /// **'Change Passcode'**
  String get changePasscode;

  /// No description provided for @chartVisualization.
  ///
  /// In en, this message translates to:
  /// **'Chart Visualization'**
  String get chartVisualization;

  /// No description provided for @chooseNewPasscodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a new 6-digit passcode'**
  String get chooseNewPasscodeDescription;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @closeAccount.
  ///
  /// In en, this message translates to:
  /// **'Close Account'**
  String get closeAccount;

  /// No description provided for @closeAccountConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to close your account? This action cannot be undone.'**
  String get closeAccountConfirmation;

  /// No description provided for @codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent'**
  String get codeResent;

  /// No description provided for @codeResentTo.
  ///
  /// In en, this message translates to:
  /// **'Code resent to {email}'**
  String codeResentTo(Object email);

  /// No description provided for @codeVerifiedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verified successfully! Redirecting...'**
  String get codeVerifiedSuccess;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @confirmDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{title}\"?'**
  String confirmDeleteTransaction(Object title);

  /// No description provided for @confirmNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm new passcode'**
  String get confirmNewPasscode;

  /// No description provided for @confirmNewPasscodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your new passcode to confirm'**
  String get confirmNewPasscodeDescription;

  /// No description provided for @confirmPasscode.
  ///
  /// In en, this message translates to:
  /// **'Confirm passcode'**
  String get confirmPasscode;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @considerSaving.
  ///
  /// In en, this message translates to:
  /// **'Consider saving 20% of your income.'**
  String get considerSaving;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @controlDescription.
  ///
  /// In en, this message translates to:
  /// **'Get accurate reports of your expenses and save smartly'**
  String get controlDescription;

  /// No description provided for @controlYourExpenses.
  ///
  /// In en, this message translates to:
  /// **'Control Your Expenses'**
  String get controlYourExpenses;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @currencyAED.
  ///
  /// In en, this message translates to:
  /// **'UAE Dirham'**
  String get currencyAED;

  /// No description provided for @currencyEGP.
  ///
  /// In en, this message translates to:
  /// **'Egyptian Pound'**
  String get currencyEGP;

  /// No description provided for @currencyEUR.
  ///
  /// In en, this message translates to:
  /// **'Euro'**
  String get currencyEUR;

  /// No description provided for @currencyKWD.
  ///
  /// In en, this message translates to:
  /// **'Kuwaiti Dinar'**
  String get currencyKWD;

  /// No description provided for @currencySAR.
  ///
  /// In en, this message translates to:
  /// **'Saudi Riyal'**
  String get currencySAR;

  /// No description provided for @currencySavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Currency saved successfully'**
  String get currencySavedSuccess;

  /// No description provided for @currencyUSD.
  ///
  /// In en, this message translates to:
  /// **'US Dollar'**
  String get currencyUSD;

  /// No description provided for @currentIcon.
  ///
  /// In en, this message translates to:
  /// **'Current Icon'**
  String get currentIcon;

  /// No description provided for @currentPasscode.
  ///
  /// In en, this message translates to:
  /// **'Current passcode'**
  String get currentPasscode;

  /// No description provided for @customizeYourAppExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your app experience'**
  String get customizeYourAppExperience;

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily Avg'**
  String get dailyAverage;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgo;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get deleteTransaction;

  /// No description provided for @depositAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Deposit added successfully!'**
  String get depositAddedSuccess;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// No description provided for @displayMode.
  ///
  /// In en, this message translates to:
  /// **'Display Mode'**
  String get displayMode;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editDeposit.
  ///
  /// In en, this message translates to:
  /// **'Edit Deposit'**
  String get editDeposit;

  /// No description provided for @editWithdrawal.
  ///
  /// In en, this message translates to:
  /// **'Edit Withdrawal'**
  String get editWithdrawal;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAlreadyInUse.
  ///
  /// In en, this message translates to:
  /// **'Email already in use'**
  String get emailAlreadyInUse;

  /// No description provided for @emailPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get emailPlaceholder;

  /// No description provided for @enableBiometric.
  ///
  /// In en, this message translates to:
  /// **'Enable {biometricName}'**
  String enableBiometric(Object biometricName);

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End date'**
  String get endDate;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get enterAmount;

  /// No description provided for @enterCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get enterCodeSentToEmail;

  /// No description provided for @enterCodeSentToEmailForLogin.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get enterCodeSentToEmailForLogin;

  /// No description provided for @enterCurrentAndSetNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter your current passcode and set a new one'**
  String get enterCurrentAndSetNewPasscode;

  /// No description provided for @enterCurrentPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter current passcode'**
  String get enterCurrentPasscode;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter full name'**
  String get enterFullName;

  /// No description provided for @enterNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter new email'**
  String get enterNewEmail;

  /// No description provided for @enterNewEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a verification code to your new email address.'**
  String get enterNewEmailDescription;

  /// No description provided for @enterNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter new passcode'**
  String get enterNewPasscode;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @enterPin.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPin;

  /// No description provided for @enterPinDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your 6-digit PIN to access your wallet'**
  String get enterPinDescription;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title'**
  String get enterTitle;

  /// No description provided for @enterUserName.
  ///
  /// In en, this message translates to:
  /// **'Enter username'**
  String get enterUserName;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @enterVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get enterVerificationCode;

  /// No description provided for @enterVerificationCodeSentToEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code we sent to your email'**
  String get enterVerificationCodeSentToEmail;

  /// No description provided for @enterYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Enter your details to complete your account'**
  String get enterYourDetails;

  /// No description provided for @enterYourEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email to create an account or log in again'**
  String get enterYourEmailDescription;

  /// No description provided for @enterYourPasscode.
  ///
  /// In en, this message translates to:
  /// **'Enter your passcode'**
  String get enterYourPasscode;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorDeletingTransaction.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorDeletingTransaction(Object error);

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data: {error}'**
  String errorLoadingData(Object error);

  /// No description provided for @errorWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithDetails(Object error);

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @expensesByCategory.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get expensesByCategory;

  /// No description provided for @failed.
  ///
  /// In en, this message translates to:
  /// **'failed'**
  String get failed;

  /// No description provided for @failedToAddTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to add transaction: {error}'**
  String failedToAddTransaction(Object error);

  /// No description provided for @failedToDeleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete transaction'**
  String get failedToDeleteTransaction;

  /// No description provided for @failedToDeleteWithError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDeleteWithError(Object error);

  /// No description provided for @failedToLoadAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Failed to load analytics: {error}'**
  String failedToLoadAnalytics(Object error);

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories: {error}'**
  String failedToLoadCategories(Object error);

  /// No description provided for @failedToLoadInsights.
  ///
  /// In en, this message translates to:
  /// **'Failed to load insights: {error}'**
  String failedToLoadInsights(Object error);

  /// No description provided for @failedToLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Failed to load more: {error}'**
  String failedToLoadMore(Object error);

  /// No description provided for @failedToLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile: {error}'**
  String failedToLoadProfile(Object error);

  /// No description provided for @failedToLoadTransactions.
  ///
  /// In en, this message translates to:
  /// **'Failed to load transactions: {error}'**
  String failedToLoadTransactions(Object error);

  /// No description provided for @failedToResend.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend'**
  String get failedToResend;

  /// No description provided for @failedToResetPasscode.
  ///
  /// In en, this message translates to:
  /// **'Failed to reset passcode'**
  String get failedToResetPasscode;

  /// No description provided for @failedToSaveCurrency.
  ///
  /// In en, this message translates to:
  /// **'Failed to save currency'**
  String get failedToSaveCurrency;

  /// No description provided for @failedToSendCode.
  ///
  /// In en, this message translates to:
  /// **'Failed to send code'**
  String get failedToSendCode;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @failedToUpdateTransaction.
  ///
  /// In en, this message translates to:
  /// **'Failed to update transaction: {error}'**
  String failedToUpdateTransaction(Object error);

  /// No description provided for @failedWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Failed: {error}'**
  String failedWithDetails(Object error);

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Feature coming soon!'**
  String get featureComingSoon;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @filterTransactions.
  ///
  /// In en, this message translates to:
  /// **'Filter Transactions'**
  String get filterTransactions;

  /// No description provided for @followUsOnInstagram.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Instagram'**
  String get followUsOnInstagram;

  /// No description provided for @followUsOnTwitter.
  ///
  /// In en, this message translates to:
  /// **'Follow us on Twitter'**
  String get followUsOnTwitter;

  /// No description provided for @forgot.
  ///
  /// In en, this message translates to:
  /// **'Forgot?'**
  String get forgot;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPin.
  ///
  /// In en, this message translates to:
  /// **'Forgot PIN?'**
  String get forgotPin;

  /// No description provided for @forgotPinDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a new verification code to your email to reset your PIN.'**
  String get forgotPinDescription;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @groceryShopping.
  ///
  /// In en, this message translates to:
  /// **'Grocery Shopping'**
  String get groceryShopping;

  /// No description provided for @helpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpSupport;

  /// No description provided for @hideBalances.
  ///
  /// In en, this message translates to:
  /// **'Hide Balances'**
  String get hideBalances;

  /// No description provided for @hideYourBalancesForPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Hide your balances for privacy'**
  String get hideYourBalancesForPrivacy;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgo;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @incomeByCategory.
  ///
  /// In en, this message translates to:
  /// **'Income by Category'**
  String get incomeByCategory;

  /// No description provided for @incorrectPin.
  ///
  /// In en, this message translates to:
  /// **'Incorrect PIN'**
  String get incorrectPin;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code'**
  String get invalidCode;

  /// No description provided for @invalidCodePasted.
  ///
  /// In en, this message translates to:
  /// **'Invalid pasted code, please enter 6 digits'**
  String get invalidCodePasted;

  /// No description provided for @invalidPasscode.
  ///
  /// In en, this message translates to:
  /// **'Invalid passcode'**
  String get invalidPasscode;

  /// No description provided for @invalidVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid verification code'**
  String get invalidVerificationCode;

  /// No description provided for @keepDescription.
  ///
  /// In en, this message translates to:
  /// **'Follow your daily savings and watch them grow over time'**
  String get keepDescription;

  /// No description provided for @keepYourSavings.
  ///
  /// In en, this message translates to:
  /// **'Keep Your Savings'**
  String get keepYourSavings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @lastMonthExpenses.
  ///
  /// In en, this message translates to:
  /// **'Last month expenses'**
  String get lastMonthExpenses;

  /// No description provided for @last7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// No description provided for @last90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// No description provided for @customRange.
  ///
  /// In en, this message translates to:
  /// **'Custom range'**
  String get customRange;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @likeUsOnFacebook.
  ///
  /// In en, this message translates to:
  /// **'Like us on Facebook'**
  String get likeUsOnFacebook;

  /// No description provided for @line.
  ///
  /// In en, this message translates to:
  /// **'Line'**
  String get line;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmation;

  /// No description provided for @logoutConfirmationDescription.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirmationDescription;

  /// No description provided for @lostAccessToEmail.
  ///
  /// In en, this message translates to:
  /// **'Lost access to your email?'**
  String get lostAccessToEmail;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @manageYourMoneyEasily.
  ///
  /// In en, this message translates to:
  /// **'Manage your money easily'**
  String get manageYourMoneyEasily;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgo;

  /// No description provided for @monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get monthlyBudget;

  /// No description provided for @monthlyBudgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget Amount'**
  String get monthlyBudgetAmount;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Monthly Expenses'**
  String get monthlyExpenses;

  /// No description provided for @monthlyIncome.
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @netSavings.
  ///
  /// In en, this message translates to:
  /// **'Net Savings'**
  String get netSavings;

  /// No description provided for @netflixSubscription.
  ///
  /// In en, this message translates to:
  /// **'Netflix Subscription'**
  String get netflixSubscription;

  /// No description provided for @newCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'New code sent to {email}'**
  String newCodeSentTo(Object email);

  /// No description provided for @newEmailAddressHint.
  ///
  /// In en, this message translates to:
  /// **'New email address'**
  String get newEmailAddressHint;

  /// No description provided for @newPasscode.
  ///
  /// In en, this message translates to:
  /// **'New passcode'**
  String get newPasscode;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories available'**
  String get noCategoriesAvailable;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @noDataInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data in this period'**
  String get noDataInPeriod;

  /// No description provided for @noExpensesInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No expenses in this period'**
  String get noExpensesInPeriod;

  /// No description provided for @noExpensesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No expenses this month'**
  String get noExpensesThisMonth;

  /// No description provided for @noIncomeInPeriod.
  ///
  /// In en, this message translates to:
  /// **'No income in this period'**
  String get noIncomeInPeriod;

  /// No description provided for @noMatchingTransactions.
  ///
  /// In en, this message translates to:
  /// **'No matching transactions'**
  String get noMatchingTransactions;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactions;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @onlinePurchase.
  ///
  /// In en, this message translates to:
  /// **'Online Purchase'**
  String get onlinePurchase;

  /// No description provided for @overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over Budget'**
  String get overBudget;

  /// No description provided for @passcodeChangedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Passcode changed successfully!'**
  String get passcodeChangedSuccess;

  /// No description provided for @passcodeChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your passcode has been changed successfully.'**
  String get passcodeChangedSuccessfully;

  /// No description provided for @passcodeMustBe6Digits.
  ///
  /// In en, this message translates to:
  /// **'Passcode must be 6 digits'**
  String get passcodeMustBe6Digits;

  /// No description provided for @passcodeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Passcode updated!'**
  String get passcodeUpdated;

  /// No description provided for @passcodesDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passcodes do not match'**
  String get passcodesDoNotMatch;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @pasteCode.
  ///
  /// In en, this message translates to:
  /// **'Paste code'**
  String get pasteCode;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @permanentlyDeleteYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get permanentlyDeleteYourAccount;

  /// No description provided for @personalDetails.
  ///
  /// In en, this message translates to:
  /// **'Personal Details'**
  String get personalDetails;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @planDescription.
  ///
  /// In en, this message translates to:
  /// **'Set your budget and track your progress towards your financial goals'**
  String get planDescription;

  /// No description provided for @planYourFuture.
  ///
  /// In en, this message translates to:
  /// **'Plan Your Future'**
  String get planYourFuture;

  /// No description provided for @pleaseConfirmNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your new passcode'**
  String get pleaseConfirmNewPasscode;

  /// No description provided for @pleaseEnterCurrentPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please enter your current passcode'**
  String get pleaseEnterCurrentPasscode;

  /// No description provided for @pleaseEnterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get pleaseEnterFullName;

  /// No description provided for @pleaseEnterNewPasscode.
  ///
  /// In en, this message translates to:
  /// **'Please enter a new passcode'**
  String get pleaseEnterNewPasscode;

  /// No description provided for @pleaseEnterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter your phone number'**
  String get pleaseEnterPhoneNumber;

  /// No description provided for @pleaseEnterUserName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get pleaseEnterUserName;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profileSettings.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get profileSettings;

  /// No description provided for @profileUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccess;

  /// No description provided for @quickFacts.
  ///
  /// In en, this message translates to:
  /// **'Quick Facts'**
  String get quickFacts;

  /// No description provided for @rateUsOnAppStorePlayStore.
  ///
  /// In en, this message translates to:
  /// **'Rate us on App Store/Play Store'**
  String get rateUsOnAppStorePlayStore;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @recoveryEnterUsernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter your username or email address to recover your account.'**
  String get recoveryEnterUsernameOrEmail;

  /// No description provided for @recurringInterval.
  ///
  /// In en, this message translates to:
  /// **'Interval'**
  String get recurringInterval;

  /// No description provided for @recurringTransaction.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transaction'**
  String get recurringTransaction;

  /// No description provided for @recurringTransactionDescription.
  ///
  /// In en, this message translates to:
  /// **'Repeat this transaction automatically'**
  String get recurringTransactionDescription;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registrationCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Registration completed successfully!'**
  String get registrationCompletedSuccessfully;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed'**
  String get registrationFailed;

  /// No description provided for @remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining Budget'**
  String get remainingBudget;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In en, this message translates to:
  /// **'Resend code in'**
  String get resendCodeIn;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {time}'**
  String resendIn(Object time);

  /// No description provided for @resending.
  ///
  /// In en, this message translates to:
  /// **'Resending...'**
  String get resending;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetPasscode.
  ///
  /// In en, this message translates to:
  /// **'Reset Passcode'**
  String get resetPasscode;

  /// No description provided for @resetPasscodeDescription.
  ///
  /// In en, this message translates to:
  /// **'A new verification code will be sent to your email.'**
  String get resetPasscodeDescription;

  /// No description provided for @salaryDeposit.
  ///
  /// In en, this message translates to:
  /// **'Salary Deposit'**
  String get salaryDeposit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search transactions...'**
  String get searchTransactions;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get security;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @selectCurrencyDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the currency you want to use in your wallet'**
  String get selectCurrencyDescription;

  /// No description provided for @selectCurrencyWarning.
  ///
  /// In en, this message translates to:
  /// **'Please select a currency'**
  String get selectCurrencyWarning;

  /// No description provided for @selectDisplayTheme.
  ///
  /// In en, this message translates to:
  /// **'Select display theme'**
  String get selectDisplayTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @sendVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Send verification code'**
  String get sendVerificationCode;

  /// No description provided for @sendingVerificationCode.
  ///
  /// In en, this message translates to:
  /// **'Sending verification code...'**
  String get sendingVerificationCode;

  /// No description provided for @setMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Monthly Budget'**
  String get setMonthlyBudget;

  /// No description provided for @setPasscodeDescription.
  ///
  /// In en, this message translates to:
  /// **'Set a passcode for your account. You will be able to log in with this passcode.'**
  String get setPasscodeDescription;

  /// No description provided for @setPasscodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a passcode'**
  String get setPasscodeTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @signWithFaceIDFingerprint.
  ///
  /// In en, this message translates to:
  /// **'Sign with Face ID/Fingerprint'**
  String get signWithFaceIDFingerprint;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @spendingInsights.
  ///
  /// In en, this message translates to:
  /// **'Spending Insights'**
  String get spendingInsights;

  /// No description provided for @spendingOverview.
  ///
  /// In en, this message translates to:
  /// **'Spending Overview'**
  String get spendingOverview;

  /// No description provided for @spent.
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @termsConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsConditions;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @topCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Categories'**
  String get topCategories;

  /// No description provided for @topSpendingCategories.
  ///
  /// In en, this message translates to:
  /// **'Top Spending Categories'**
  String get topSpendingCategories;

  /// No description provided for @totalBalance.
  ///
  /// In en, this message translates to:
  /// **'Total Balance'**
  String get totalBalance;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @trackDescription.
  ///
  /// In en, this message translates to:
  /// **'Record all your expenses and income in one place with full details'**
  String get trackDescription;

  /// No description provided for @trackEveryMove.
  ///
  /// In en, this message translates to:
  /// **'Track Every Move'**
  String get trackEveryMove;

  /// No description provided for @trackSpendingHabits.
  ///
  /// In en, this message translates to:
  /// **'Track your spending habits'**
  String get trackSpendingHabits;

  /// No description provided for @transactionDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted successfully!'**
  String get transactionDeletedSuccess;

  /// No description provided for @transactionUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated successfully!'**
  String get transactionUpdatedSuccess;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @transactionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transaction'**
  String transactionsCount(Object count);

  /// No description provided for @transactionsCount_plural.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionsCount_plural(Object count);

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tryAdjustingYourSearch.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search'**
  String get tryAdjustingYourSearch;

  /// No description provided for @tryReducingExpenses.
  ///
  /// In en, this message translates to:
  /// **'Try reducing entertainment and dining expenses.'**
  String get tryReducingExpenses;

  /// No description provided for @underBudget.
  ///
  /// In en, this message translates to:
  /// **'Under Budget'**
  String get underBudget;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @updateYour6DigitPasscode.
  ///
  /// In en, this message translates to:
  /// **'Update your 6-digit passcode'**
  String get updateYour6DigitPasscode;

  /// No description provided for @updateYourPersonalInformation.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updateYourPersonalInformation;

  /// No description provided for @useBiometricAuthentication.
  ///
  /// In en, this message translates to:
  /// **'Use biometric authentication'**
  String get useBiometricAuthentication;

  /// No description provided for @useBiometricQuestion.
  ///
  /// In en, this message translates to:
  /// **'Use {biometricName}?'**
  String useBiometricQuestion(Object biometricName);

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @userEmail.
  ///
  /// In en, this message translates to:
  /// **'john.doe@email.com'**
  String get userEmail;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get userName;

  /// No description provided for @userNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// No description provided for @usernameOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or email'**
  String get usernameOrEmail;

  /// No description provided for @verificationCodeResentTo.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent to {email}'**
  String verificationCodeResentTo(Object email);

  /// No description provided for @verificationCodeSent.
  ///
  /// In en, this message translates to:
  /// **'Verification code sent to {email}'**
  String verificationCodeSent(Object email);

  /// No description provided for @verifyCodeFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to verify the code'**
  String get verifyCodeFailed;

  /// No description provided for @verifyItsYouBeforeChangingEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify it\'s you before changing your email'**
  String get verifyItsYouBeforeChangingEmail;

  /// No description provided for @verifyNewEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify new email'**
  String get verifyNewEmail;

  /// No description provided for @verifyNewEmailDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your new email'**
  String get verifyNewEmailDescription;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify your email'**
  String get verifyYourEmail;

  /// No description provided for @voiceAnalysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Voice analysis failed'**
  String get voiceAnalysisFailed;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs Last Month'**
  String get vsLastMonth;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Mahfazti'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// No description provided for @welcomeDescription.
  ///
  /// In en, this message translates to:
  /// **'Your personal app for managing expenses and savings easily and flexibly'**
  String get welcomeDescription;

  /// No description provided for @whatIsYourEmail.
  ///
  /// In en, this message translates to:
  /// **'What is your email?'**
  String get whatIsYourEmail;

  /// No description provided for @withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get withdraw;

  /// No description provided for @withdrawalAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal added successfully!'**
  String get withdrawalAddedSuccess;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternet;

  /// No description provided for @checkInternet.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get checkInternet;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server Error'**
  String get serverError;

  /// No description provided for @serverErrorDesc.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again later.'**
  String get serverErrorDesc;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An Error Occurred'**
  String get errorOccurred;

  /// No description provided for @wallet.
  ///
  /// In en, this message translates to:
  /// **'WALLET'**
  String get wallet;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'INSIGHTS'**
  String get insights;

  /// No description provided for @orContinueWith.
  ///
  /// In en, this message translates to:
  /// **'or continue with'**
  String get orContinueWith;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @signInSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back! Please enter your details to sign in.'**
  String get signInSubtitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create an account to start managing your money easily.'**
  String get signUpSubtitle;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to receive a recovery code.'**
  String get resetPasswordSubtitle;

  /// No description provided for @enterNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter New Password'**
  String get enterNewPassword;

  /// No description provided for @setNewPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose a strong password with at least 8 characters.'**
  String get setNewPasswordDescription;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully! Please sign in.'**
  String get passwordResetSuccess;

  /// No description provided for @stepEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get stepEmail;

  /// No description provided for @stepOtp.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get stepOtp;

  /// No description provided for @stepProfile.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get stepProfile;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters'**
  String get passwordMinLength;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @validEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get validEmailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @digitCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get digitCodeRequired;

  /// No description provided for @appLock.
  ///
  /// In en, this message translates to:
  /// **'App Lock'**
  String get appLock;

  /// No description provided for @appLockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect with biometric or device lock'**
  String get appLockSubtitle;

  /// No description provided for @appLockDeviceNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Device lock is not supported or set up on this device'**
  String get appLockDeviceNotSupported;

  /// No description provided for @appLockPrompt.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access Mahfazti'**
  String get appLockPrompt;

  /// No description provided for @appLockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get appLockUnlock;

  /// No description provided for @appLockLockedTitle.
  ///
  /// In en, this message translates to:
  /// **'Mahfazti is Locked'**
  String get appLockLockedTitle;

  /// No description provided for @appLockLockedMessage.
  ///
  /// In en, this message translates to:
  /// **'Authenticate to access your wallet and transactions'**
  String get appLockLockedMessage;

  /// No description provided for @budgets.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @subscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get subscriptions;

  /// No description provided for @userProfile.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfile;

  /// No description provided for @nameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name is too short'**
  String get nameTooShort;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account Details'**
  String get accountDetails;

  /// No description provided for @emailCannotBeChanged.
  ///
  /// In en, this message translates to:
  /// **'Email is linked to your account for security and cannot be changed.'**
  String get emailCannotBeChanged;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please log in again.'**
  String get sessionExpired;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @voice.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voice;

  /// No description provided for @serverConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server'**
  String get serverConnectionFailed;

  /// No description provided for @allAccounts.
  ///
  /// In en, this message translates to:
  /// **'All Accounts'**
  String get allAccounts;

  /// No description provided for @banqueMisr.
  ///
  /// In en, this message translates to:
  /// **'Banque Misr'**
  String get banqueMisr;

  /// No description provided for @cashWallet.
  ///
  /// In en, this message translates to:
  /// **'Cash Wallet'**
  String get cashWallet;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @vodafoneCash.
  ///
  /// In en, this message translates to:
  /// **'Vodafone Cash'**
  String get vodafoneCash;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @oneHourAgo.
  ///
  /// In en, this message translates to:
  /// **'1h ago'**
  String get oneHourAgo;

  /// No description provided for @twoHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'2h ago'**
  String get twoHoursAgo;

  /// No description provided for @twoDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'2d ago'**
  String get twoDaysAgo;

  /// No description provided for @oneMonthAgo.
  ///
  /// In en, this message translates to:
  /// **'1mo ago'**
  String get oneMonthAgo;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'By Month...'**
  String get byMonth;

  /// No description provided for @selectDateRange.
  ///
  /// In en, this message translates to:
  /// **'Select date range'**
  String get selectDateRange;

  /// No description provided for @switchWallet.
  ///
  /// In en, this message translates to:
  /// **'Switch wallet'**
  String get switchWallet;

  /// No description provided for @switchAccount.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get switchAccount;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @aiReceiptScanner.
  ///
  /// In en, this message translates to:
  /// **'AI Receipt Scanner'**
  String get aiReceiptScanner;

  /// No description provided for @aiReceiptScannerDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan or upload any paper receipt, and AI will automatically extract amount, date, and category!'**
  String get aiReceiptScannerDesc;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @aiCameraComingSoon.
  ///
  /// In en, this message translates to:
  /// **'AI Camera OCR will be available soon!'**
  String get aiCameraComingSoon;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(Object count);

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @myWallets.
  ///
  /// In en, this message translates to:
  /// **'My Wallets'**
  String get myWallets;

  /// No description provided for @main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get main;

  /// No description provided for @tapToManageWallets.
  ///
  /// In en, this message translates to:
  /// **'Tap to manage wallets'**
  String get tapToManageWallets;

  /// No description provided for @manageWallets.
  ///
  /// In en, this message translates to:
  /// **'Manage wallets'**
  String get manageWallets;

  /// No description provided for @autoTrackSpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Track spending automatically'**
  String get autoTrackSpendingTitle;

  /// No description provided for @autoTrackSpendingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Log your purchases and transactions automatically from bank SMS and notifications accurately.'**
  String get autoTrackSpendingSubtitle;

  /// No description provided for @setUpNow.
  ///
  /// In en, this message translates to:
  /// **'Set Up'**
  String get setUpNow;

  /// No description provided for @autoSyncComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Automatic sync will be available soon! 🚀'**
  String get autoSyncComingSoon;

  /// No description provided for @addSalaryIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add your salary & income'**
  String get addSalaryIncomeTitle;

  /// No description provided for @addSalaryIncomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set the date of your monthly income to forecast cash flow and plan your savings early.'**
  String get addSalaryIncomeSubtitle;

  /// No description provided for @addSalary.
  ///
  /// In en, this message translates to:
  /// **'Add Salary'**
  String get addSalary;

  /// No description provided for @organizeAccountsTitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your accounts'**
  String get organizeAccountsTitle;

  /// No description provided for @organizeAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Combine your bank cards, e-wallets, and cash in one place to monitor your total wealth in real time.'**
  String get organizeAccountsSubtitle;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add Account'**
  String get addAccount;

  /// No description provided for @setMonthlyBudgetPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly budget'**
  String get setMonthlyBudgetPromptTitle;

  /// No description provided for @setMonthlyBudgetPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set a smart spending ceiling for dining, shopping, and bills to get early alerts before exceeding budget.'**
  String get setMonthlyBudgetPromptSubtitle;

  /// No description provided for @createBudget.
  ///
  /// In en, this message translates to:
  /// **'Create Budget'**
  String get createBudget;

  /// No description provided for @budgetAlertsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon: Smart budgets & alerts 🎯'**
  String get budgetAlertsComingSoon;

  /// No description provided for @tapToSetMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Tap to set monthly budget'**
  String get tapToSetMonthlyBudget;

  /// No description provided for @setBudget.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get setBudget;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @overLimit.
  ///
  /// In en, this message translates to:
  /// **'Over limit'**
  String get overLimit;

  /// No description provided for @walletsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} wallets'**
  String walletsCount(Object count);

  /// No description provided for @accounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get accounts;

  /// No description provided for @balanced.
  ///
  /// In en, this message translates to:
  /// **'Balanced'**
  String get balanced;

  /// No description provided for @balancedSpending.
  ///
  /// In en, this message translates to:
  /// **'Balanced spending'**
  String get balancedSpending;

  /// No description provided for @viewCategories.
  ///
  /// In en, this message translates to:
  /// **'View categories'**
  String get viewCategories;

  /// No description provided for @cashFlow.
  ///
  /// In en, this message translates to:
  /// **'Cash Flow'**
  String get cashFlow;

  /// No description provided for @savedPercent.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% saved'**
  String savedPercent(Object percent);

  /// No description provided for @deficit.
  ///
  /// In en, this message translates to:
  /// **'-Deficit'**
  String get deficit;

  /// No description provided for @positiveFlowMonth.
  ///
  /// In en, this message translates to:
  /// **'Liquidity surplus this month'**
  String get positiveFlowMonth;

  /// No description provided for @negativeFlowMonth.
  ///
  /// In en, this message translates to:
  /// **'Deficit in monthly cash flow'**
  String get negativeFlowMonth;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get outgoing;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Today!'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String dueInDays(Object days);

  /// No description provided for @renewalDayNotice.
  ///
  /// In en, this message translates to:
  /// **'Due on day {day} • out of {count} subscriptions'**
  String renewalDayNotice(Object count, Object day);

  /// No description provided for @billsAndSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Bills & Subscriptions'**
  String get billsAndSubscriptions;

  /// No description provided for @noUpcomingBills.
  ///
  /// In en, this message translates to:
  /// **'No upcoming bills due'**
  String get noUpcomingBills;

  /// No description provided for @financialInsights.
  ///
  /// In en, this message translates to:
  /// **'Financial Insights'**
  String get financialInsights;

  /// No description provided for @fullAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Full analytics'**
  String get fullAnalytics;

  /// No description provided for @tapToAddFirstExpense.
  ///
  /// In en, this message translates to:
  /// **'Tap + or use voice to add your first expense'**
  String get tapToAddFirstExpense;

  /// No description provided for @cannotTransferSameAccount.
  ///
  /// In en, this message translates to:
  /// **'Cannot transfer to the same account'**
  String get cannotTransferSameAccount;

  /// No description provided for @transferSuccess.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully 🚀'**
  String get transferSuccess;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New Transaction'**
  String get newTransaction;

  /// No description provided for @transferFrom.
  ///
  /// In en, this message translates to:
  /// **'Transfer From'**
  String get transferFrom;

  /// No description provided for @fromWallet.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromWallet;

  /// No description provided for @transferTo.
  ///
  /// In en, this message translates to:
  /// **'Transfer To'**
  String get transferTo;

  /// No description provided for @toWallet.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toWallet;

  /// No description provided for @selectWalletAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet / Account'**
  String get selectWalletAccount;

  /// No description provided for @walletAccount.
  ///
  /// In en, this message translates to:
  /// **'Wallet / Account'**
  String get walletAccount;

  /// No description provided for @noteDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Note / Description (optional)...'**
  String get noteDescriptionOptional;

  /// No description provided for @confirmTransfer.
  ///
  /// In en, this message translates to:
  /// **'Confirm Transfer'**
  String get confirmTransfer;

  /// No description provided for @bankAccount.
  ///
  /// In en, this message translates to:
  /// **'Bank Account'**
  String get bankAccount;

  /// No description provided for @cashWalletType.
  ///
  /// In en, this message translates to:
  /// **'Cash Wallet'**
  String get cashWalletType;

  /// No description provided for @eWalletType.
  ///
  /// In en, this message translates to:
  /// **'E-Wallet'**
  String get eWalletType;

  /// No description provided for @savingsVaultType.
  ///
  /// In en, this message translates to:
  /// **'Savings Vault'**
  String get savingsVaultType;

  /// No description provided for @addNewAccount.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccount;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'Account Name (e.g. Banque Misr)'**
  String get accountNameHint;

  /// No description provided for @initialBalance.
  ///
  /// In en, this message translates to:
  /// **'Initial Balance'**
  String get initialBalance;

  /// No description provided for @accountType.
  ///
  /// In en, this message translates to:
  /// **'Account Type'**
  String get accountType;

  /// No description provided for @pleaseEnterAccountName.
  ///
  /// In en, this message translates to:
  /// **'Please enter account name'**
  String get pleaseEnterAccountName;

  /// No description provided for @accountAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account added successfully 💳'**
  String get accountAddedSuccess;

  /// No description provided for @saveAccount.
  ///
  /// In en, this message translates to:
  /// **'Save Account'**
  String get saveAccount;

  /// No description provided for @selectActiveWallet.
  ///
  /// In en, this message translates to:
  /// **'Select Active Wallet'**
  String get selectActiveWallet;

  /// No description provided for @manageAccounts.
  ///
  /// In en, this message translates to:
  /// **'Manage Accounts'**
  String get manageAccounts;

  /// No description provided for @manageAccountsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your cash, bank, and digital wallets'**
  String get manageAccountsSubtitle;

  /// No description provided for @mainAcc.
  ///
  /// In en, this message translates to:
  /// **'Main Acc'**
  String get mainAcc;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @setAsMainSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} set as main account ⭐'**
  String setAsMainSuccess(Object name);

  /// No description provided for @setAsMain.
  ///
  /// In en, this message translates to:
  /// **'Set as Main'**
  String get setAsMain;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @selectAction.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectAction;

  /// No description provided for @setMonthlyBudgetSpending.
  ///
  /// In en, this message translates to:
  /// **'Set your spending target for this month'**
  String get setMonthlyBudgetSpending;

  /// No description provided for @pleaseEnterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get pleaseEnterValidAmount;

  /// No description provided for @saveBudget.
  ///
  /// In en, this message translates to:
  /// **'Save Budget'**
  String get saveBudget;

  /// No description provided for @monthlyBudgetRemoved.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget removed'**
  String get monthlyBudgetRemoved;

  /// No description provided for @removeMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Remove Monthly Budget'**
  String get removeMonthlyBudget;

  /// No description provided for @budgetForCategory.
  ///
  /// In en, this message translates to:
  /// **'Budget for {name}'**
  String budgetForCategory(Object name);

  /// No description provided for @setCategorySpendingLimit.
  ///
  /// In en, this message translates to:
  /// **'Set spending limit for this category'**
  String get setCategorySpendingLimit;

  /// No description provided for @categoryBudgetUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category budget updated'**
  String get categoryBudgetUpdated;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New Category'**
  String get newCategory;

  /// No description provided for @addNewCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new category with a budget limit'**
  String get addNewCategorySubtitle;

  /// No description provided for @setOrEditOverallMonthlyLimit.
  ///
  /// In en, this message translates to:
  /// **'Set or edit overall monthly limit'**
  String get setOrEditOverallMonthlyLimit;

  /// No description provided for @addCategoryToTrackSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add a new category to track its spending & budget'**
  String get addCategoryToTrackSubtitle;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categoryName;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Subscriptions, Transport'**
  String get categoryNameHint;

  /// No description provided for @budgetLimitOptional.
  ///
  /// In en, this message translates to:
  /// **'Budget Limit (optional)'**
  String get budgetLimitOptional;

  /// No description provided for @pleaseEnterCategoryName.
  ///
  /// In en, this message translates to:
  /// **'Please enter category name'**
  String get pleaseEnterCategoryName;

  /// No description provided for @categoryAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category added successfully'**
  String get categoryAddedSuccess;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get addCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get deleteCategory;

  /// No description provided for @confirmDeleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete category \"{name}\" from budget?'**
  String confirmDeleteCategory(Object name);

  /// No description provided for @categoryDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Category deleted successfully'**
  String get categoryDeletedSuccess;

  /// No description provided for @currentLimitAmount.
  ///
  /// In en, this message translates to:
  /// **'Current limit: {amount}'**
  String currentLimitAmount(Object amount);

  /// No description provided for @noLimitSet.
  ///
  /// In en, this message translates to:
  /// **'No limit set'**
  String get noLimitSet;

  /// No description provided for @editBudget.
  ///
  /// In en, this message translates to:
  /// **'Edit Budget'**
  String get editBudget;

  /// No description provided for @monthlySpendingBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Spending Budget'**
  String get monthlySpendingBudget;

  /// No description provided for @ofMonthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'of {amount}'**
  String ofMonthlyBudget(Object amount);

  /// No description provided for @overBudgetExclamation.
  ///
  /// In en, this message translates to:
  /// **'Over budget!'**
  String get overBudgetExclamation;

  /// No description provided for @dailySafeSpend.
  ///
  /// In en, this message translates to:
  /// **'Daily Safe Spend'**
  String get dailySafeSpend;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @totalSpentThisMonth.
  ///
  /// In en, this message translates to:
  /// **'total spent this month'**
  String get totalSpentThisMonth;

  /// No description provided for @setLimitToTrackSafeSpend.
  ///
  /// In en, this message translates to:
  /// **'Set a limit to track remaining & safe spend'**
  String get setLimitToTrackSafeSpend;

  /// No description provided for @categoryBudgets.
  ///
  /// In en, this message translates to:
  /// **'Category Budgets'**
  String get categoryBudgets;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get tapToEdit;

  /// No description provided for @spentAmount.
  ///
  /// In en, this message translates to:
  /// **'Spent {amount}'**
  String spentAmount(Object amount);

  /// No description provided for @limitAmount.
  ///
  /// In en, this message translates to:
  /// **'Limit: {amount}'**
  String limitAmount(Object amount);

  /// No description provided for @limitNotSet.
  ///
  /// In en, this message translates to:
  /// **'Limit: Not set'**
  String get limitNotSet;

  /// No description provided for @subscriptionsAndBills.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions & Bills'**
  String get subscriptionsAndBills;

  /// No description provided for @newSubscription.
  ///
  /// In en, this message translates to:
  /// **'New Subscription'**
  String get newSubscription;

  /// No description provided for @trackRecurringBillsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Easily track your recurring bills & subs'**
  String get trackRecurringBillsSubtitle;

  /// No description provided for @subscriptionTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Title (e.g. Netflix)'**
  String get subscriptionTitleHint;

  /// No description provided for @subscriptionDayHint.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get subscriptionDayHint;

  /// No description provided for @ofMonthSuffix.
  ///
  /// In en, this message translates to:
  /// **'of mo'**
  String get ofMonthSuffix;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @pleaseEnterSubscriptionTitleAndAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter title and amount'**
  String get pleaseEnterSubscriptionTitleAndAmount;

  /// No description provided for @subscriptionAddedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription added successfully'**
  String get subscriptionAddedSuccess;

  /// No description provided for @saveSubscription.
  ///
  /// In en, this message translates to:
  /// **'Save Subscription'**
  String get saveSubscription;

  /// No description provided for @deleteSubscription.
  ///
  /// In en, this message translates to:
  /// **'Delete Subscription'**
  String get deleteSubscription;

  /// No description provided for @subscriptionDeletedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Subscription deleted'**
  String get subscriptionDeletedSuccess;

  /// No description provided for @monthlyRecurringCosts.
  ///
  /// In en, this message translates to:
  /// **'Monthly Recurring Costs'**
  String get monthlyRecurringCosts;

  /// No description provided for @activeSubscriptionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} active'**
  String activeSubscriptionsCount(Object count);

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ month'**
  String get perMonth;

  /// No description provided for @nextDueBill.
  ///
  /// In en, this message translates to:
  /// **'Next due: {title}'**
  String nextDueBill(Object title);

  /// No description provided for @dueTodayExclamation.
  ///
  /// In en, this message translates to:
  /// **'Due today!'**
  String get dueTodayExclamation;

  /// No description provided for @dueInDaysWithDay.
  ///
  /// In en, this message translates to:
  /// **'In {days} days (day {day} of mo)'**
  String dueInDaysWithDay(Object day, Object days);

  /// No description provided for @activeSubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Active Subscriptions'**
  String get activeSubscriptions;

  /// No description provided for @addNewSubscriptionAction.
  ///
  /// In en, this message translates to:
  /// **'+ Add new'**
  String get addNewSubscriptionAction;

  /// No description provided for @dayOfMonthFormatted.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of month'**
  String dayOfMonthFormatted(Object day);

  /// No description provided for @weInternet.
  ///
  /// In en, this message translates to:
  /// **'WE Internet'**
  String get weInternet;

  /// No description provided for @gym.
  ///
  /// In en, this message translates to:
  /// **'Gym'**
  String get gym;

  /// No description provided for @budgetUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Budget updated successfully'**
  String get budgetUpdatedSuccessfully;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @customRangeDots.
  ///
  /// In en, this message translates to:
  /// **'Custom Range...'**
  String get customRangeDots;

  /// No description provided for @setAction.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get setAction;

  /// No description provided for @inDaysFormatted.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String inDaysFormatted(Object days);

  /// No description provided for @yrUnit.
  ///
  /// In en, this message translates to:
  /// **'yr'**
  String get yrUnit;

  /// No description provided for @moUnit.
  ///
  /// In en, this message translates to:
  /// **'mo'**
  String get moUnit;

  /// No description provided for @selectWalletOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Select Wallet / Account'**
  String get selectWalletOrAccount;

  /// No description provided for @walletOrAccount.
  ///
  /// In en, this message translates to:
  /// **'Wallet / Account'**
  String get walletOrAccount;

  /// No description provided for @noteOrDescriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Note / Description (optional)...'**
  String get noteOrDescriptionOptional;

  /// No description provided for @selectActionKey.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get selectActionKey;

  /// No description provided for @addNewAccountOrWallet.
  ///
  /// In en, this message translates to:
  /// **'Add New Account'**
  String get addNewAccountOrWallet;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @remainingMonth.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remainingMonth;

  /// No description provided for @perDay.
  ///
  /// In en, this message translates to:
  /// **'/ day'**
  String get perDay;

  /// No description provided for @daysCountInParens.
  ///
  /// In en, this message translates to:
  /// **'({count} days)'**
  String daysCountInParens(Object count);

  /// No description provided for @dueDayWithBillsCount.
  ///
  /// In en, this message translates to:
  /// **'Due day {day} • {count} bills'**
  String dueDayWithBillsCount(Object count, Object day);

  /// No description provided for @minutesAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1m ago} other{{count}m ago}}'**
  String minutesAgoPlural(num count);

  /// No description provided for @hoursAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1h ago} =2{2h ago} other{{count}h ago}}'**
  String hoursAgoPlural(num count);

  /// No description provided for @daysAgoPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1d ago} =2{2d ago} other{{count}d ago}}'**
  String daysAgoPlural(num count);

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategories;

  /// No description provided for @manageCategoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage expense categories'**
  String get manageCategoriesSubtitle;

  /// No description provided for @categoryExpensesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 expenses} =1{1 expense} other{{count} expenses}}'**
  String categoryExpensesCount(num count);

  /// No description provided for @searchCategories.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get searchCategories;

  /// No description provided for @noCategoriesFound.
  ///
  /// In en, this message translates to:
  /// **'No categories found'**
  String get noCategoriesFound;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
