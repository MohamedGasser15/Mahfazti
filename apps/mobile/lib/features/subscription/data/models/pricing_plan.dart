/// Subscription plan model.
///
/// Mirrors the backend `PricingPlanDto` (`GET /api/Plans`) so the local mock
/// catalog below can later be replaced by the API response without touching
/// the presentation layer.
class PricingPlan {
  final String id;
  final String nameEn;
  final String nameAr;
  final double priceEgp;
  final String billingCycle; // Monthly, Yearly
  final String descriptionEn;
  final String descriptionAr;
  final List<String> featuresEn;
  final List<String> featuresAr;
  final bool isPopular;
  final int maxWallets;
  final int maxAiRequestsPerMonth;
  final bool canExportReports;
  final bool canUseMultiCurrency;

  const PricingPlan({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.priceEgp,
    required this.billingCycle,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.featuresEn,
    required this.featuresAr,
    this.isPopular = false,
    this.maxWallets = 1,
    this.maxAiRequestsPerMonth = 15,
    this.canExportReports = false,
    this.canUseMultiCurrency = false,
  });

  bool get isFree => priceEgp <= 0;

  bool get isYearly => billingCycle.toLowerCase() == 'yearly';

  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  String description(String languageCode) =>
      languageCode == 'ar' ? descriptionAr : descriptionEn;

  List<String> features(String languageCode) =>
      languageCode == 'ar' ? featuresAr : featuresEn;
}

/// Local catalog used while the subscription flow is not wired to the API yet.
/// Values match the backend `SubscriptionSeeder` defaults.
const List<PricingPlan> kMockPricingPlans = [
  PricingPlan(
    id: 'plan-free',
    nameEn: 'Free Basic',
    nameAr: 'الباقة المجانية',
    priceEgp: 0,
    billingCycle: 'Monthly',
    descriptionEn: 'Essential features for personal budget tracking',
    descriptionAr:
        'الميزات الأساسية والمثالية لتتبع الميزانية الشخصية والمصروفات اليومية',
    featuresEn: [
      '1 Cash Wallet',
      '15 AI Voice Expenses / Month',
      'Basic Categories',
      'Standard Analytics',
    ],
    featuresAr: [
      'محفظة نقدية واحدة',
      '15 معاملة صوتية بالذكاء الاصطناعي شهرياً',
      'تصنيفات أساسية ومخصصة',
      'تحليلات وتقارير مالية قياسية',
    ],
    maxWallets: 1,
    maxAiRequestsPerMonth: 15,
  ),
  PricingPlan(
    id: 'plan-pro-monthly',
    nameEn: 'Mahfazti Pro (Monthly)',
    nameAr: 'باقة المحترفين (شهري)',
    priceEgp: 89,
    billingCycle: 'Monthly',
    descriptionEn: 'For power users needing multiple wallets & unlimited AI',
    descriptionAr:
        'للمستخدمين المتقدمين الباحثين عن محافظ وحسابات غير محدودة وذكاء اصطناعي فائق',
    featuresEn: [
      'Unlimited Multi-Wallets & Banks',
      'Unlimited Voice AI Recognition',
      'Export PDF & Excel Reports',
      'Multi-Currency Exchange Sync',
      'Priority Customer Support',
    ],
    featuresAr: [
      'محافظ وحسابات بنكية غير محدودة',
      'تسجيل المصروفات بالصوت بالذكاء الاصطناعي بلا حدود',
      'تصدير تقارير PDF و Excel احترافية',
      'دعم ومزامنة تعدد العملات والأسعار الحية',
      'دعم فني متميز وأولوية في الاستجابة',
    ],
    isPopular: true,
    maxWallets: 999,
    maxAiRequestsPerMonth: 999999,
    canExportReports: true,
    canUseMultiCurrency: true,
  ),
  PricingPlan(
    id: 'plan-pro-yearly',
    nameEn: 'Mahfazti Pro (Annual)',
    nameAr: 'باقة المحترفين (سنوي - وفر 35%)',
    priceEgp: 699,
    billingCycle: 'Yearly',
    descriptionEn: 'Best value for year-round financial freedom',
    descriptionAr:
        'أفضل قيمة وأعلى توفير للتحكم المالي الذكي على مدار العام بالكامل',
    featuresEn: [
      'All Monthly Pro Features Included',
      '2 Months Free (Save 35%)',
      'Early access to new AI models',
      'Family sharing (up to 3 members)',
    ],
    featuresAr: [
      'جميع مميزات باقة المحترفين الشهرية',
      'شهران مجاناً (توفير 35% من القيمة)',
      'وصول مبكر لنماذج وميزات الذكاء الاصطناعي الجديدة',
      'مشاركة عائلية للمحفظة (حتى 3 مستخدمين)',
    ],
    maxWallets: 999,
    maxAiRequestsPerMonth: 999999,
    canExportReports: true,
    canUseMultiCurrency: true,
  ),
];
