// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get aboutUs => 'من نحن';

  @override
  String get account => 'الحساب';

  @override
  String get accountCreatedSuccess => 'تم إنشاء الحساب بنجاح!';

  @override
  String get verify => 'تأكيد';

  @override
  String get sendCode => 'إرسال الرمز';

  @override
  String get add => 'إضافة';

  @override
  String get addDeposit => 'إضافة إيداع';

  @override
  String get addTransaction => 'إضافة معاملة';

  @override
  String get addWithdrawal => 'إضافة سحب';

  @override
  String get addYourFirstTransaction => 'أضف معاملتك الأولى';

  @override
  String get advancedSettings => 'إعدادات متقدمة';

  @override
  String get all => 'الكل';

  @override
  String get allTransactionsInOnePlace => 'كل معاملاتك في مكان واحد';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get amount => 'المبلغ';

  @override
  String get amountGreaterThanZero => 'يجب أن يكون المبلغ أكبر من صفر';

  @override
  String get analytics => 'التحليلات';

  @override
  String get any => 'أي';

  @override
  String get app => 'التطبيق';

  @override
  String get appIcon => 'أيقونة التطبيق';

  @override
  String get appLanguage => 'لغة التطبيق';

  @override
  String get appTitle => 'محفظتي';

  @override
  String get apply => 'تطبيق';

  @override
  String get arabic => 'العربية';

  @override
  String get authenticationSettings => 'إعدادات المصادقة';

  @override
  String get bar => 'أعمدة';

  @override
  String get biggestSpend => 'أكبر إنفاق';

  @override
  String get biometricAuthenticationFailed => 'فشل المصادقة';

  @override
  String get biometricAuthenticationSubtitle =>
      'استخدم Face ID / بصمة الإصبع لتسجيل الدخول';

  @override
  String get biometricDisabledSuccess => 'تم إلغاء تفعيل المصادقة البيومترية';

  @override
  String get biometricEnableFailed => 'فشل تفعيل المصادقة البيومترية';

  @override
  String get biometricEnabledSuccess => 'تم تفعيل المصادقة البيومترية';

  @override
  String biometricLoginDescription(Object biometricName) {
    return 'يمكنك استخدام $biometricName لتسجيل الدخول بشكل أسرع وأكثر أماناً.';
  }

  @override
  String get budget => 'الميزانية';

  @override
  String get budgetOverview => 'نظرة عامة على الميزانية';

  @override
  String get budgetTip => 'نصيحة مالية';

  @override
  String budgetUpdated(Object amount) {
    return 'تم تحديث الميزانية إلى $amount';
  }

  @override
  String get cancel => 'إلغاء';

  @override
  String get cannotOpenStore => 'لا يمكن فتح المتجر';

  @override
  String get cannotOpenUrl => 'لا يمكن فتح الرابط';

  @override
  String get categories => 'الفئات';

  @override
  String get category => 'الفئة';

  @override
  String get categoryBills => 'الفواتير';

  @override
  String get categoryEducation => 'التعليم';

  @override
  String get categoryEntertainment => 'الترفيه';

  @override
  String get categoryFood => 'الطعام';

  @override
  String get categoryFoodDining => 'الطعام والمطاعم';

  @override
  String get categoryFreelance => 'عمل حر';

  @override
  String get categoryHealth => 'الصحة';

  @override
  String get categoryOther => 'أخرى';

  @override
  String get categorySalary => 'الراتب';

  @override
  String get categoryShopping => 'التسوق';

  @override
  String get categoryTransportation => 'المواصلات';

  @override
  String get categoryUtilities => 'المرافق';

  @override
  String get changeAppIcon => 'تغيير أيقونة التطبيق';

  @override
  String get changeAppLanguage => 'تغيير لغة التطبيق';

  @override
  String get changePasscode => 'تغيير رمز المرور';

  @override
  String get chartVisualization => 'تصوير بياني';

  @override
  String get chooseNewPasscodeDescription =>
      'اختر رمز مرور جديد مكون من 6 أرقام';

  @override
  String get clearSearch => 'مسح البحث';

  @override
  String get close => 'إغلاق';

  @override
  String get closeAccount => 'إغلاق الحساب';

  @override
  String get closeAccountConfirmation =>
      'هل أنت متأكد أنك تريد إغلاق حسابك؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get codeResent => 'تم إعادة إرسال الرمز';

  @override
  String codeResentTo(Object email) {
    return 'تم إعادة إرسال الرمز إلى $email';
  }

  @override
  String get codeVerifiedSuccess => 'تم التحقق بنجاح! جارٍ التوجيه...';

  @override
  String get complete => 'إكمال';

  @override
  String get completeRegistration => 'إكمال التسجيل';

  @override
  String confirmDeleteTransaction(Object title) {
    return 'هل أنت متأكد من حذف \"$title\"؟';
  }

  @override
  String get confirmNewPasscode => 'تأكيد رمز المرور الجديد';

  @override
  String get confirmNewPasscodeDescription =>
      'أعد إدخال رمز المرور الجديد للتأكيد';

  @override
  String get confirmPasscode => 'تأكيد رمز المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get considerSaving => 'فكر في توفير 20٪ من دخلك.';

  @override
  String get continueText => 'متابعة';

  @override
  String get controlDescription => 'احصل على تقارير دقيقة لنفقاتك وادخر بذكاء';

  @override
  String get controlYourExpenses => 'تحكم في نفقاتك';

  @override
  String get currency => 'العملة';

  @override
  String get currencyAED => 'درهم إماراتي';

  @override
  String get currencyEGP => 'جنيه مصري';

  @override
  String get currencyEUR => 'يورو';

  @override
  String get currencyKWD => 'دينار كويتي';

  @override
  String get currencySAR => 'ريال سعودي';

  @override
  String get currencySavedSuccess => 'تم حفظ العملة بنجاح';

  @override
  String get currencyUSD => 'دولار أمريكي';

  @override
  String get currentIcon => 'الأيقونة الحالية';

  @override
  String get currentPasscode => 'رمز المرور الحالي';

  @override
  String get customizeYourAppExperience => 'خصص تجربة التطبيق';

  @override
  String get dailyAverage => 'المتوسط اليومي';

  @override
  String get dark => 'داكن';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get date => 'التاريخ';

  @override
  String get daysAgo => 'يوم مضى';

  @override
  String get delete => 'حذف';

  @override
  String get deleteTransaction => 'حذف المعاملة';

  @override
  String get depositAddedSuccess => 'تم إضافة الإيداع بنجاح!';

  @override
  String get description => 'الوصف';

  @override
  String get descriptionOptional => 'الوصف (اختياري)';

  @override
  String get displayMode => 'نمط العرض';

  @override
  String get done => 'تم';

  @override
  String get dontHaveAccount => 'ليس لديك حساب؟';

  @override
  String get edit => 'تعديل';

  @override
  String get editDeposit => 'تعديل إيداع';

  @override
  String get editWithdrawal => 'تعديل سحب';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get emailAlreadyInUse => 'البريد الإلكتروني قيد الاستخدام بالفعل';

  @override
  String get emailPlaceholder => 'البريد الإلكتروني';

  @override
  String enableBiometric(Object biometricName) {
    return 'تفعيل $biometricName';
  }

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get english => 'English';

  @override
  String get enterAmount => 'الرجاء إدخال المبلغ';

  @override
  String get enterCodeSentToEmail =>
      'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك الإلكتروني';

  @override
  String get enterCodeSentToEmailForLogin =>
      'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك الإلكتروني';

  @override
  String get enterCurrentAndSetNewPasscode =>
      'أدخل رمز المرور الحالي وقم بتعيين رمز جديد';

  @override
  String get enterCurrentPasscode => 'أدخل رمز المرور الحالي';

  @override
  String get enterFullName => 'أدخل الاسم الكامل';

  @override
  String get enterNewEmail => 'أدخل البريد الإلكتروني الجديد';

  @override
  String get enterNewEmailDescription =>
      'سنرسل رمز تحقق إلى عنوان بريدك الإلكتروني الجديد.';

  @override
  String get enterNewPasscode => 'أدخل رمز المرور الجديد';

  @override
  String get enterPhoneNumber => 'أدخل رقم الهاتف';

  @override
  String get enterPin => 'أدخل رمز PIN';

  @override
  String get enterPinDescription =>
      'أدخل رمز PIN المكون من 6 أرقام للوصول إلى محفظتك';

  @override
  String get enterTitle => 'الرجاء إدخال عنوان';

  @override
  String get enterUserName => 'أدخل اسم المستخدم';

  @override
  String get enterValidAmount => 'الرجاء إدخال مبلغ صحيح';

  @override
  String get enterValidNumber => 'الرجاء إدخال رقم صحيح';

  @override
  String get enterVerificationCode => 'أدخل رمز التحقق';

  @override
  String get enterVerificationCodeSentToEmail =>
      'أدخل رمز التحقق الذي أرسلناه إلى بريدك الإلكتروني';

  @override
  String get enterYourDetails => 'أدخل بياناتك لإكمال حسابك';

  @override
  String get enterYourEmailDescription =>
      'أدخل بريدك الإلكتروني لإنشاء حساب أو تسجيل الدخول مرة أخرى';

  @override
  String get enterYourPasscode => 'أدخل رمز المرور';

  @override
  String get error => 'خطأ';

  @override
  String errorDeletingTransaction(Object error) {
    return 'خطأ: $error';
  }

  @override
  String errorLoadingData(Object error) {
    return 'فشل تحميل البيانات: $error';
  }

  @override
  String errorWithDetails(Object error) {
    return 'خطأ: $error';
  }

  @override
  String get expense => 'مصروف';

  @override
  String get expensesByCategory => 'المصروفات حسب الفئة';

  @override
  String get failed => 'فشل';

  @override
  String failedToAddTransaction(Object error) {
    return 'فشل إضافة المعاملة: $error';
  }

  @override
  String get failedToDeleteTransaction => 'فشل حذف المعاملة';

  @override
  String failedToDeleteWithError(Object error) {
    return 'فشل الحذف: $error';
  }

  @override
  String failedToLoadAnalytics(Object error) {
    return 'فشل تحميل التحليلات: $error';
  }

  @override
  String failedToLoadCategories(Object error) {
    return 'فشل تحميل الفئات: $error';
  }

  @override
  String failedToLoadInsights(Object error) {
    return 'فشل تحميل الرؤى: $error';
  }

  @override
  String failedToLoadMore(Object error) {
    return 'فشل تحميل المزيد: $error';
  }

  @override
  String failedToLoadProfile(Object error) {
    return 'فشل تحميل الملف الشخصي: $error';
  }

  @override
  String failedToLoadTransactions(Object error) {
    return 'فشل تحميل المعاملات: $error';
  }

  @override
  String get failedToResend => 'فشل إعادة الإرسال';

  @override
  String get failedToResetPasscode => 'فشل إعادة تعيين رمز المرور';

  @override
  String get failedToSaveCurrency => 'فشل حفظ العملة';

  @override
  String get failedToSendCode => 'فشل إرسال الرمز';

  @override
  String get failedToUpdateProfile => 'فشل تحديث الملف الشخصي';

  @override
  String failedToUpdateTransaction(Object error) {
    return 'فشل تحديث المعاملة: $error';
  }

  @override
  String failedWithDetails(Object error) {
    return 'فشل: $error';
  }

  @override
  String get featureComingSoon => 'الميزة قريباً!';

  @override
  String get filter => 'تصفية';

  @override
  String get filterTransactions => 'تصفية المعاملات';

  @override
  String get followUsOnInstagram => 'تابعنا على إنستغرام';

  @override
  String get followUsOnTwitter => 'تابعنا على تويتر';

  @override
  String get forgot => 'نسيت؟';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get forgotPin => 'نسيت الرمز؟';

  @override
  String get forgotPinDescription =>
      'سنرسل رمز تحقق جديد إلى بريدك الإلكتروني لإعادة تعيين الرمز.';

  @override
  String get from => 'من';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get getStarted => 'ابدأ الان';

  @override
  String get groceryShopping => 'تسوق البقالة';

  @override
  String get helpSupport => 'المساعدة والدعم';

  @override
  String get hideBalances => 'إخفاء الأرصدة';

  @override
  String get hideYourBalancesForPrivacy => 'إخفاء أرصدتك من أجل الخصوصية';

  @override
  String get home => 'الرئيسية';

  @override
  String get hoursAgo => 'ساعة مضت';

  @override
  String get income => 'دخل';

  @override
  String get incomeByCategory => 'الإيرادات حسب الفئة';

  @override
  String get incorrectPin => 'رمز PIN غير صحيح';

  @override
  String get invalidCode => 'رمز غير صحيح';

  @override
  String get invalidCodePasted => 'الرمز الملصق غير صالح، يرجى إدخال 6 أرقام';

  @override
  String get invalidPasscode => 'رمز المرور غير صحيح';

  @override
  String get invalidVerificationCode => 'رمز التحقق غير صحيح';

  @override
  String get keepDescription => 'تابع مدخراتك اليومية وشاهد تطورها مع الوقت';

  @override
  String get keepYourSavings => 'حافظ على مدخراتك';

  @override
  String get language => 'اللغة';

  @override
  String get lastMonthExpenses => 'مصاريف الشهر الماضي';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get last30Days => 'آخر 30 يوم';

  @override
  String get last90Days => 'آخر 90 يوم';

  @override
  String get customRange => 'نطاق مخصص';

  @override
  String get left => 'متبقي';

  @override
  String get light => 'فاتح';

  @override
  String get likeUsOnFacebook => 'أعجب بنا على فيسبوك';

  @override
  String get line => 'خطي';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get loginSuccess => 'تم تسجيل الدخول بنجاح!';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get logoutConfirmation => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get logoutConfirmationDescription =>
      'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get lostAccessToEmail => 'فقدت الوصول إلى بريدك الإلكتروني؟';

  @override
  String get manage => 'إدارة';

  @override
  String get manageYourMoneyEasily => 'إدارة أموالك بسهولة';

  @override
  String get minutesAgo => 'دقيقة مضت';

  @override
  String get monthlyBudget => 'الميزانية الشهرية';

  @override
  String get monthlyBudgetAmount => 'مبلغ الميزانية الشهرية';

  @override
  String get monthlyExpenses => 'المصروفات الشهرية';

  @override
  String get monthlyIncome => 'الدخل الشهري';

  @override
  String get name => 'الاسم';

  @override
  String get netSavings => 'صافي التوفير';

  @override
  String get netflixSubscription => 'اشتراك Netflix';

  @override
  String newCodeSentTo(Object email) {
    return 'تم إرسال رمز جديد إلى $email';
  }

  @override
  String get newEmailAddressHint => 'البريد الإلكتروني الجديد';

  @override
  String get newPasscode => 'رمز المرور الجديد';

  @override
  String get next => 'التالي';

  @override
  String get noCategoriesAvailable => 'لا توجد فئات متاحة';

  @override
  String get noData => 'لا توجد بيانات';

  @override
  String get noDataAvailable => 'لا توجد بيانات';

  @override
  String get noDataInPeriod => 'لا توجد بيانات في هذه الفترة';

  @override
  String get noExpensesInPeriod => 'لا توجد مصروفات في هذه الفترة';

  @override
  String get noExpensesThisMonth => 'لا توجد مصاريف هذا الشهر';

  @override
  String get noIncomeInPeriod => 'لا توجد إيرادات في هذه الفترة';

  @override
  String get noMatchingTransactions => 'لا توجد معاملات مطابقة';

  @override
  String get noTransactions => 'لا توجد معاملات بعد';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get onlinePurchase => 'شراء عبر الإنترنت';

  @override
  String get overBudget => 'تجاوز الميزانية';

  @override
  String get passcodeChangedSuccess => 'تم تغيير رمز المرور بنجاح!';

  @override
  String get passcodeChangedSuccessfully => 'تم تغيير رمز المرور بنجاح.';

  @override
  String get passcodeMustBe6Digits => 'يجب أن يتكون رمز المرور من 6 أرقام';

  @override
  String get passcodeUpdated => 'تم تحديث رمز المرور!';

  @override
  String get passcodesDoNotMatch => 'رمزا المرور غير متطابقين';

  @override
  String get password => 'كلمة المرور';

  @override
  String get pasteCode => 'لصق الرمز';

  @override
  String get paymentMethods => 'طرق الدفع';

  @override
  String get permanentlyDeleteYourAccount => 'حذف حسابك بشكل دائم';

  @override
  String get personalDetails => 'تفاصيل شخصية';

  @override
  String get phone => 'الهاتف';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get planDescription => 'اضبط ميزانيتك وتابع تقدمك نحو أهدافك المالية';

  @override
  String get planYourFuture => 'خطط لمستقبلك';

  @override
  String get pleaseConfirmNewPasscode => 'الرجاء تأكيد رمز المرور الجديد';

  @override
  String get pleaseEnterCurrentPasscode => 'الرجاء إدخال رمز المرور الحالي';

  @override
  String get pleaseEnterFullName => 'الرجاء إدخال الاسم الكامل';

  @override
  String get pleaseEnterNewPasscode => 'الرجاء إدخال رمز مرور جديد';

  @override
  String get pleaseEnterPhoneNumber => 'الرجاء إدخال رقم الهاتف';

  @override
  String get pleaseEnterUserName => 'الرجاء إدخال اسم المستخدم';

  @override
  String get pleaseFillAllFields => 'الرجاء ملء جميع الحقول';

  @override
  String get previous => 'السابق';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profileSettings => 'إعدادات الملف الشخصي';

  @override
  String get profileUpdatedSuccess => 'تم تحديث الملف الشخصي بنجاح!';

  @override
  String get quickFacts => 'حقائق سريعة';

  @override
  String get rateUsOnAppStorePlayStore =>
      'قيمنا على متجر التطبيقات / متجر Play';

  @override
  String get recentTransactions => 'المعاملات الأخيرة';

  @override
  String get recoveryEnterUsernameOrEmail =>
      'أدخل اسم المستخدم أو البريد الإلكتروني لاستعادة حسابك.';

  @override
  String get recurringInterval => 'الفاصل الزمني';

  @override
  String get recurringTransaction => 'معاملة متكررة';

  @override
  String get recurringTransactionDescription => 'كرر هذه المعاملة تلقائياً';

  @override
  String get register => 'إنشاء حساب';

  @override
  String get registrationCompletedSuccessfully => 'تم إكمال التسجيل بنجاح!';

  @override
  String get registrationFailed => 'فشل التسجيل';

  @override
  String get remainingBudget => 'الميزانية المتبقية';

  @override
  String get reports => 'التقارير';

  @override
  String get resendCode => 'أعد إرسال الرمز';

  @override
  String get resendCodeIn => 'أعد إرسال الرمز خلال';

  @override
  String resendIn(Object time) {
    return 'أعد الإرسال خلال $time';
  }

  @override
  String get resending => 'جاري إعادة الإرسال...';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get resetPasscode => 'إعادة تعيين رمز المرور';

  @override
  String get resetPasscodeDescription =>
      'سيتم إرسال رمز تحقق جديد إلى بريدك الإلكتروني.';

  @override
  String get salaryDeposit => 'إيداع الراتب';

  @override
  String get save => 'حفظ';

  @override
  String get search => 'بحث';

  @override
  String get searchTransactions => 'بحث في المعاملات...';

  @override
  String get seconds => 'ثانية';

  @override
  String get security => 'الأمان';

  @override
  String get seeAll => 'عرض الكل';

  @override
  String get selectCategory => 'اختر التصنيف';

  @override
  String get selectCurrency => 'اختر العملة';

  @override
  String get selectCurrencyDescription =>
      'اختر العملة التي تريد استخدامها في محفظتك';

  @override
  String get selectCurrencyWarning => 'الرجاء اختيار العملة';

  @override
  String get selectDisplayTheme => 'اختر سمة العرض';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get send => 'إرسال';

  @override
  String get sendVerificationCode => 'إرسال رمز التحقق';

  @override
  String get sendingVerificationCode => 'جاري إرسال رمز التحقق...';

  @override
  String get setMonthlyBudget => 'تعيين الميزانية الشهرية';

  @override
  String get setPasscodeDescription =>
      'قم بتعيين رمز مرور لحسابك. ستتمكن من تسجيل الدخول باستخدام هذا الرمز.';

  @override
  String get setPasscodeTitle => 'تعيين رمز مرور';

  @override
  String get settings => 'الإعدادات';

  @override
  String get signWithFaceIDFingerprint =>
      'التوقيع باستخدام Face ID / بصمة الإصبع';

  @override
  String get skip => 'تخطي';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get sort => 'ترتيب';

  @override
  String get spendingInsights => 'رؤى الإنفاق';

  @override
  String get spendingOverview => 'نظرة عامة على الإنفاق';

  @override
  String get spent => 'مصروف';

  @override
  String get start => 'ابدأ';

  @override
  String get system => 'النظام';

  @override
  String get termsConditions => 'الشروط والأحكام';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get time => 'الوقت';

  @override
  String get title => 'العنوان';

  @override
  String get to => 'إلى';

  @override
  String get today => 'اليوم';

  @override
  String get topCategories => 'أفضل الفئات';

  @override
  String get topSpendingCategories => 'أهم فئات الإنفاق';

  @override
  String get totalBalance => 'إجمالي الرصيد';

  @override
  String get totalExpenses => 'إجمالي المصروفات';

  @override
  String get totalIncome => 'إجمالي الدخل';

  @override
  String get trackDescription =>
      'سجل جميع مصروفاتك وإيراداتك في مكان واحد مع تفاصيل كاملة';

  @override
  String get trackEveryMove => 'تتبع كل حركة';

  @override
  String get trackSpendingHabits => 'تتبع عادات الإنفاق';

  @override
  String get transactionDeletedSuccess => 'تم حذف المعاملة بنجاح!';

  @override
  String get transactionUpdatedSuccess => 'تم تحديث المعاملة بنجاح!';

  @override
  String get transactions => 'المعاملات';

  @override
  String transactionsCount(Object count) {
    return '$count معاملة';
  }

  @override
  String transactionsCount_plural(Object count) {
    return '$count معاملات';
  }

  @override
  String get transfer => 'تحويل';

  @override
  String get tryAgain => 'حاول مرة أخرى';

  @override
  String get tryAdjustingYourSearch => 'حاول تعديل بحثك';

  @override
  String get tryReducingExpenses =>
      'حاول تقليل نفقات الترفيه وتناول الطعام خارج المنزل.';

  @override
  String get underBudget => 'داخل الميزانية';

  @override
  String get update => 'تحديث';

  @override
  String get updateYour6DigitPasscode => 'تحديث رمز المرور المكون من 6 أرقام';

  @override
  String get updateYourPersonalInformation => 'تحديث معلوماتك الشخصية';

  @override
  String get useBiometricAuthentication => 'استخدام المصادقة البيومترية';

  @override
  String useBiometricQuestion(Object biometricName) {
    return 'استخدام $biometricName؟';
  }

  @override
  String get user => 'مستخدم';

  @override
  String get userEmail => 'john.doe@email.com';

  @override
  String get userName => 'اسم المستخدم';

  @override
  String get userNotFound => 'المستخدم غير موجود';

  @override
  String get usernameOrEmail => 'اسم المستخدم أو البريد الإلكتروني';

  @override
  String verificationCodeResentTo(Object email) {
    return 'تم إعادة إرسال رمز التحقق إلى $email';
  }

  @override
  String verificationCodeSent(Object email) {
    return 'تم إرسال رمز التحقق إلى $email';
  }

  @override
  String get verifyCodeFailed => 'فشل التحقق من رمز التحقق';

  @override
  String get verifyItsYouBeforeChangingEmail =>
      'تحقق من هويتك قبل تغيير بريدك الإلكتروني';

  @override
  String get verifyNewEmail => 'تحقق من البريد الإلكتروني الجديد';

  @override
  String get verifyNewEmailDescription =>
      'أدخل الرمز المكون من 6 أرقام المرسل إلى بريدك الإلكتروني الجديد';

  @override
  String get verifyYourEmail => 'تحقق من بريدك الإلكتروني';

  @override
  String get voiceAnalysisFailed => 'فشل تحليل الصوت';

  @override
  String get vsLastMonth => 'مقابل الشهر الماضي';

  @override
  String get welcome => 'مرحباً بك في محفظتي';

  @override
  String get welcomeBack => 'مرحبًا بعودتك،';

  @override
  String get welcomeDescription =>
      'تطبيقك الشخصي لإدارة المصروفات والمدخرات بكل سهولة ومرونة';

  @override
  String get whatIsYourEmail => 'ما هو بريدك الإلكتروني؟';

  @override
  String get withdraw => 'سحب';

  @override
  String get withdrawalAddedSuccess => 'تم إضافة السحب بنجاح!';

  @override
  String get yesterday => 'أمس';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get checkInternet =>
      'يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';

  @override
  String get serverError => 'خطأ في الخادم';

  @override
  String get serverErrorDesc => 'حدث خطأ من جانبنا. يرجى المحاولة لاحقاً.';

  @override
  String get errorOccurred => 'حدث خطأ';

  @override
  String get wallet => 'المحفظة';

  @override
  String get insights => 'الإحصائيات';

  @override
  String get orContinueWith => 'أو المتابعة عن طريق';

  @override
  String get continueWithGoogle => 'متابعة عبر Google';

  @override
  String get continueWithFacebook => 'متابعة عبر Facebook';

  @override
  String get signInSubtitle => 'أهلاً بك مجدداً! يرجى إدخال بياناتك للمتابعة.';

  @override
  String get signUpSubtitle =>
      'أنشئ حساباً جديداً للبدء في إدارة أموالك بسهولة.';

  @override
  String get resetPasswordTitle => 'استعادة كلمة المرور';

  @override
  String get resetPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لتلقي رمز استعادة الحساب.';

  @override
  String get enterNewPassword => 'تعيين كلمة المرور الجديدة';

  @override
  String get setNewPasswordDescription =>
      'اختر كلمة مرور قوية لا تقل عن 8 أحرف.';

  @override
  String get passwordResetSuccess =>
      'تمت إعادة تعيين كلمة المرور بنجاح! يمكنك الآن تسجيل الدخول.';

  @override
  String get stepEmail => 'البريد الإلكتروني';

  @override
  String get stepOtp => 'رمز التحقق';

  @override
  String get stepProfile => 'كلمة المرور';

  @override
  String get changeEmail => 'تعديل البريد';

  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل';

  @override
  String get fullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';

  @override
  String get validEmailRequired => 'يرجى إدخال بريد إلكتروني صالح';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';

  @override
  String get digitCodeRequired => 'يرجى إدخال الرمز المكون من 6 أرقام';

  @override
  String get appLock => 'قفل التطبيق';

  @override
  String get appLockSubtitle => 'حماية التطبيق بالبصمة أو قفل الجهاز';

  @override
  String get appLockDeviceNotSupported =>
      'قفل الشاشة أو البصمة غير مدعوم أو غير مفعل على هذا الجهاز';

  @override
  String get appLockPrompt => 'قم بالمصادقة للوصول إلى محفظتي';

  @override
  String get appLockUnlock => 'فتح القفل';

  @override
  String get appLockLockedTitle => 'محفظتي مقفل';

  @override
  String get appLockLockedMessage =>
      'قم بتأكيد هويتك للوصول إلى بياناتك المالية';

  @override
  String get budgets => 'الميزانيات';

  @override
  String get subscriptions => 'الاشتراكات';

  @override
  String get userProfile => 'الملف الشخصي';

  @override
  String get nameTooShort => 'الاسم قصير جداً';

  @override
  String get accountDetails => 'بيانات الحساب';

  @override
  String get emailCannotBeChanged =>
      'البريد الإلكتروني مرتبط بحسابك للأمان ولا يمكن تغييره.';

  @override
  String get sessionExpired => 'انتهت صلاحية الجلسة، يرجى تسجيل الدخول مجدداً';

  @override
  String get listening => 'أستمع...';

  @override
  String get voice => 'صوت';

  @override
  String get serverConnectionFailed => 'فشل الاتصال بالسيرفر';

  @override
  String get allAccounts => 'إجمالي الحسابات';

  @override
  String get banqueMisr => 'بنك مصر';

  @override
  String get cashWallet => 'كاش (الجيب)';

  @override
  String get cash => 'نقدية';

  @override
  String get vodafoneCash => 'فودافون كاش';

  @override
  String get justNow => 'الآن';

  @override
  String get oneHourAgo => 'منذ ساعة';

  @override
  String get twoHoursAgo => 'منذ ساعتين';

  @override
  String get twoDaysAgo => 'منذ يومين';

  @override
  String get oneMonthAgo => 'منذ شهر';

  @override
  String get balance => 'الرصيد';

  @override
  String get lastMonth => 'الشهر السابق';

  @override
  String get byMonth => 'بالشهر...';

  @override
  String get selectDateRange => 'تحديد الفترة';

  @override
  String get switchWallet => 'تبديل المحفظة';

  @override
  String get switchAccount => 'تبديل الحساب';

  @override
  String get receipt => 'فاتورة';

  @override
  String get aiReceiptScanner => 'مسح الفواتير بالذكاء الاصطناعي';

  @override
  String get aiReceiptScannerDesc =>
      'صور أو ارفع أي فاتورة ورقية، والذكاء الاصطناعي هيقرأ المبلغ والتاريخ والتصنيف ويسجلها تلقائياً!';

  @override
  String get manual => 'إدخال يدوي';

  @override
  String get camera => 'فتح الكاميرا';

  @override
  String get aiCameraComingSoon => 'جاري ربط الـ AI OCR والكاميرا قريباً!';

  @override
  String get more => 'المزيد';

  @override
  String daysCount(Object count) {
    return '$count يوم';
  }

  @override
  String get selectMonth => 'اختر الشهر';

  @override
  String get myWallets => 'محافظي';

  @override
  String get main => 'الرئيسي';

  @override
  String get tapToManageWallets => 'اضغط لإدارة أو إضافة محفظة';

  @override
  String get manageWallets => 'إدارة المحافظ';

  @override
  String get autoTrackSpendingTitle => 'تتبع المصاريف تلقائياً';

  @override
  String get autoTrackSpendingSubtitle =>
      'سجّل مشترياتك ومعاملاتك من إشعارات ورسائل البنوك تلقائياً وبدقة دون الحاجة لإدخالها يدوياً كل مرة';

  @override
  String get setUpNow => 'تفعيل الآن';

  @override
  String get autoSyncComingSoon => 'سيتم تفعيل المزامنة التلقائية قريباً 🚀';

  @override
  String get addSalaryIncomeTitle => 'أضف راتبك ومصادر دخلك';

  @override
  String get addSalaryIncomeSubtitle =>
      'حدّد موعد نزول دخلك الشهري والمصادر الإضافية لتوقع صافي التدفق المالي والتخطيط لمدخراتك مبكراً';

  @override
  String get addSalary => 'إضافة دخل';

  @override
  String get organizeAccountsTitle => 'نظّم محافظك وبطاقاتك';

  @override
  String get organizeAccountsSubtitle =>
      'اجمع بطاقاتك البنكية، محافظك الإلكترونية ونقد الكاش في مكان واحد لمتابعة إجمالي ثروتك لحظة بلحظة';

  @override
  String get addAccount => 'إضافة محفظة';

  @override
  String get setMonthlyBudgetPromptTitle => 'حدد ميزانية لمصاريفك';

  @override
  String get setMonthlyBudgetPromptSubtitle =>
      'ضع سقفاً ذكياً للإنفاق على المطاعم والتسوق والفواتير لتصلك تنبيهات مبكرة قبل تجاوز الميزانية المحددة';

  @override
  String get createBudget => 'تحديد ميزانية';

  @override
  String get budgetAlertsComingSoon =>
      'قريباً: تحديد الميزانيات والتنبيهات الذكية 🎯';

  @override
  String get tapToSetMonthlyBudget => 'اضغط لتعيين الميزانية الشهرية';

  @override
  String get setBudget => 'تعيين الميزانية';

  @override
  String get notSet => 'غير محددة';

  @override
  String get overLimit => 'تجاوزت الميزانية';

  @override
  String walletsCount(Object count) {
    return '$count محافظ';
  }

  @override
  String get accounts => 'توزيع المحافظ';

  @override
  String get balanced => 'متوازن';

  @override
  String get balancedSpending => 'المصاريف متوازنة';

  @override
  String get viewCategories => 'تصفح كل الفئات';

  @override
  String get cashFlow => 'صافي التدفق';

  @override
  String savedPercent(Object percent) {
    return '+فائض $percent%';
  }

  @override
  String get deficit => '-عجز';

  @override
  String get positiveFlowMonth => 'فائض السيولة هذا الشهر';

  @override
  String get negativeFlowMonth => 'عجز في حركة الشهر';

  @override
  String get incoming => 'وارد';

  @override
  String get outgoing => 'صادر';

  @override
  String get dueToday => 'اليوم!';

  @override
  String get dueTomorrow => 'غداً';

  @override
  String dueInDays(Object days) {
    return 'بعد $days يوم';
  }

  @override
  String renewalDayNotice(Object count, Object day) {
    return 'استحقاق يوم $day • من $count اشتراكات';
  }

  @override
  String get billsAndSubscriptions => 'الالتزامات والفواتير';

  @override
  String get noUpcomingBills => 'لا توجد فواتير مستحقة قريباً';

  @override
  String get financialInsights => 'الرؤى والتحليلات المالية';

  @override
  String get fullAnalytics => 'التحليلات الكاملة';

  @override
  String get tapToAddFirstExpense => 'اضغط + أو استخدم الصوت لإضافة أول حركة';

  @override
  String get cannotTransferSameAccount => 'لا يمكن التحويل لنفس الحساب';

  @override
  String get transferSuccess => 'تم التحويل بنجاح 🚀';

  @override
  String get newTransaction => 'معاملة جديدة';

  @override
  String get transferFrom => 'تحويل من محفظة';

  @override
  String get fromWallet => 'من محفظة';

  @override
  String get transferTo => 'تحويل إلى محفظة';

  @override
  String get toWallet => 'إلى محفظة';

  @override
  String get selectWalletAccount => 'اختر المحفظة أو الحساب';

  @override
  String get walletAccount => 'المحفظة / الحساب';

  @override
  String get noteDescriptionOptional => 'ملاحظة أو وصف (اختياري)...';

  @override
  String get confirmTransfer => 'تأكيد التحويل';

  @override
  String get bankAccount => 'حساب بنكي';

  @override
  String get cashWalletType => 'كاش (نقدية)';

  @override
  String get eWalletType => 'محفظة إلكترونية';

  @override
  String get savingsVaultType => 'صندوق ادخار';

  @override
  String get addNewAccount => 'إضافة حساب جديد';

  @override
  String get accountNameHint => 'اسم الحساب (مثال: بنك مصر، CIB)';

  @override
  String get initialBalance => 'الرصيد الافتتاحي الحالي';

  @override
  String get accountType => 'نوع الحساب';

  @override
  String get pleaseEnterAccountName => 'يرجى إدخال اسم الحساب';

  @override
  String get accountAddedSuccess => 'تمت إضافة الحساب بنجاح 💳';

  @override
  String get saveAccount => 'حفظ الحساب';

  @override
  String get selectActiveWallet => 'اختر المحفظة المعروضة';

  @override
  String get manageAccounts => 'إدارة المحافظ والحسابات';

  @override
  String get manageAccountsSubtitle =>
      'تحكم في محافظك، حساباتك البنكية، والمحافظ الإلكترونية';

  @override
  String get mainAcc => 'الرئيسي';

  @override
  String get active => 'النشط';

  @override
  String setAsMainSuccess(Object name) {
    return 'تم تعيين $name كحساب رئيسي ⭐';
  }

  @override
  String get setAsMain => 'تعيين كرئيسي';

  @override
  String get selected => 'محدد';

  @override
  String get selectAction => 'تحديد';

  @override
  String get setMonthlyBudgetSpending =>
      'حدد الحد الأقصى للمصاريف المتوقعة لهذا الشهر';

  @override
  String get pleaseEnterValidAmount => 'يرجى إدخال مبلغ صحيح';

  @override
  String get saveBudget => 'حفظ الميزانية';

  @override
  String get monthlyBudgetRemoved => 'تم إلغاء الميزانية الشهرية';

  @override
  String get removeMonthlyBudget => 'إلغاء الميزانية الشهرية';

  @override
  String budgetForCategory(Object name) {
    return 'ميزانية $name';
  }

  @override
  String get setCategorySpendingLimit =>
      'حدد الحد الأقصى للمصاريف في هذا التصنيف';

  @override
  String get categoryBudgetUpdated => 'تم تحديث ميزانية التصنيف';

  @override
  String get newCategory => 'فئة جديدة';

  @override
  String get addNewCategorySubtitle => 'إضافة فئة جديدة وتحديد سقف مصاريفها';

  @override
  String get setOrEditOverallMonthlyLimit =>
      'تحديد أو تعديل الحد الإجمالي للشهر';

  @override
  String get addCategoryToTrackSubtitle =>
      'أضف فئة جديدة لتتبع مصاريفها وميزانيتها';

  @override
  String get categoryName => 'اسم الفئة';

  @override
  String get categoryNameHint => 'مثال: اشتراكات، مواصلات...';

  @override
  String get budgetLimitOptional => 'حد الميزانية (اختياري)';

  @override
  String get pleaseEnterCategoryName => 'يرجى إدخال اسم الفئة';

  @override
  String get categoryAddedSuccess => 'تمت إضافة الفئة بنجاح';

  @override
  String get addCategory => 'إضافة الفئة';

  @override
  String get deleteCategory => 'حذف الفئة';

  @override
  String confirmDeleteCategory(Object name) {
    return 'هل أنت متأكد من حذف فئة \"$name\" من الميزانية؟';
  }

  @override
  String get categoryDeletedSuccess => 'تم حذف الفئة بنجاح';

  @override
  String currentLimitAmount(Object amount) {
    return 'الحد الحالي: $amount';
  }

  @override
  String get noLimitSet => 'بدون حد ميزانية';

  @override
  String get editBudget => 'تعديل الميزانية';

  @override
  String get monthlySpendingBudget => 'ميزانية الشهر الإجمالية';

  @override
  String ofMonthlyBudget(Object amount) {
    return 'من $amount';
  }

  @override
  String get overBudgetExclamation => 'تجاوزت الميزانية!';

  @override
  String get dailySafeSpend => 'متاح يومياً (آمن)';

  @override
  String get day => 'يوم';

  @override
  String get totalSpentThisMonth => 'إجمالي المصاريف حتى الآن';

  @override
  String get setLimitToTrackSafeSpend =>
      'حدد سقفاً لمتابعة المتبقي والمصروف الآمن';

  @override
  String get categoryBudgets => 'ميزانيات التصنيفات';

  @override
  String get tapToEdit => 'اضغط للتعديل';

  @override
  String spentAmount(Object amount) {
    return 'صرفت $amount';
  }

  @override
  String limitAmount(Object amount) {
    return 'الحد: $amount';
  }

  @override
  String get limitNotSet => 'الحد: غير محدد';

  @override
  String get subscriptionsAndBills => 'الاشتراكات والفواتير';

  @override
  String get newSubscription => 'إضافة اشتراك جديد';

  @override
  String get trackRecurringBillsSubtitle =>
      'تتبع فواتيرك واشتراكاتك الدورية بسهولة';

  @override
  String get subscriptionTitleHint => 'اسم الاشتراك (مثال: نتفلكس)';

  @override
  String get subscriptionDayHint => 'يوم';

  @override
  String get ofMonthSuffix => 'بالشهر';

  @override
  String get monthly => 'شهرياً';

  @override
  String get yearly => 'سنوياً';

  @override
  String get pleaseEnterSubscriptionTitleAndAmount =>
      'يرجى إدخال اسم ومبلغ الاشتراك';

  @override
  String get subscriptionAddedSuccess => 'تمت إضافة الاشتراك بنجاح';

  @override
  String get saveSubscription => 'حفظ الاشتراك';

  @override
  String get deleteSubscription => 'حذف هذا الاشتراك';

  @override
  String get subscriptionDeletedSuccess => 'تم حذف الاشتراك';

  @override
  String get monthlyRecurringCosts => 'الالتزامات الدورية الشهرية';

  @override
  String activeSubscriptionsCount(Object count) {
    return '$count نشطة';
  }

  @override
  String get perMonth => '/ شهر';

  @override
  String nextDueBill(Object title) {
    return 'الفاتورة القادمة: $title';
  }

  @override
  String get dueTodayExclamation => 'مستحقة اليوم!';

  @override
  String dueInDaysWithDay(Object day, Object days) {
    return 'بعد $days يوم (يوم $day بالشهر)';
  }

  @override
  String get activeSubscriptions => 'الاشتراكات المثبتة';

  @override
  String get addNewSubscriptionAction => '+ إضافة جديد';

  @override
  String dayOfMonthFormatted(Object day) {
    return 'يوم $day بالشهر';
  }

  @override
  String get weInternet => 'إنترنت WE';

  @override
  String get gym => 'جيم';

  @override
  String get budgetUpdatedSuccessfully => 'تم تحديث الميزانية بنجاح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get customRangeDots => 'فترة مخصصة...';

  @override
  String get setAction => 'تحديد';

  @override
  String inDaysFormatted(Object days) {
    return 'بعد $days يوم';
  }

  @override
  String get yrUnit => 'سنوياً';

  @override
  String get moUnit => 'شهرياً';

  @override
  String get selectWalletOrAccount => 'اختر المحفظة أو الحساب';

  @override
  String get walletOrAccount => 'المحفظة / الحساب';

  @override
  String get noteOrDescriptionOptional => 'ملاحظة أو وصف (اختياري)...';

  @override
  String get selectActionKey => 'تحديد';

  @override
  String get addNewAccountOrWallet => 'إضافة محفظة / حساب جديد';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get remainingMonth => 'المتبقي للشهر';

  @override
  String get perDay => '/ يوم';

  @override
  String daysCountInParens(Object count) {
    return '($count يوم)';
  }

  @override
  String dueDayWithBillsCount(Object count, Object day) {
    return 'استحقاق يوم $day • من $count اشتراكات';
  }

  @override
  String minutesAgoPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count دقيقة',
      many: 'منذ $count دقيقة',
      few: 'منذ $count دقائق',
      two: 'منذ دقيقتين',
      one: 'منذ دقيقة',
    );
    return '$_temp0';
  }

  @override
  String hoursAgoPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count ساعة',
      many: 'منذ $count ساعة',
      few: 'منذ $count ساعات',
      two: 'منذ ساعتين',
      one: 'منذ ساعة',
    );
    return '$_temp0';
  }

  @override
  String daysAgoPlural(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'منذ $count يوم',
      many: 'منذ $count يوماً',
      few: 'منذ $count أيام',
      two: 'منذ يومين',
      one: 'منذ يوم',
    );
    return '$_temp0';
  }

  @override
  String get manageCategories => 'إدارة الفئات';

  @override
  String get manageCategoriesSubtitle => 'عرض وتعديل وتصنيف المصروفات';

  @override
  String categoryExpensesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصروف',
      many: '$count مصروفاً',
      few: '$count مصروفات',
      two: '2 مصروفات',
      one: 'مصروف واحد',
      zero: '0 مصروفات',
    );
    return '$_temp0';
  }

  @override
  String get searchCategories => 'بحث في الفئات...';

  @override
  String get noCategoriesFound => 'لم يتم العثور على فئات';
}
