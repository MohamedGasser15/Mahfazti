import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:my_wallet/core/extensions/context_extensions.dart';
import 'package:my_wallet/core/services/iap_subscription_service.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/themes/app_icons.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/widgets/app_back_button.dart';
import 'package:my_wallet/features/subscription/data/models/pricing_plan.dart';

/// Full-page plans & subscriptions screen.
///
/// Currently renders the local [kMockPricingPlans] catalog. The UI is ready to
/// be fed by `GET /api/Plans` once the subscription flow is wired end-to-end.
class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key});

  /// Pushes this screen with native platform transitions.
  static Future<void> open(BuildContext context) {
    if (Platform.isIOS) {
      return Navigator.push<void>(
        context,
        CupertinoPageRoute(builder: (_) => const PlansScreen()),
      );
    }
    return Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const PlansScreen()),
    );
  }

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  static const Color _gold = Color(0xFFF59E0B);

  final ScrollController _scrollController = ScrollController();
  final IapSubscriptionService _iapService = IapSubscriptionService();
  StreamSubscription<IapPurchaseEvent>? _iapEventSub;

  bool _isYearly = false;

  PricingPlan get _freePlan =>
      kMockPricingPlans.firstWhere((plan) => plan.isFree);

  PricingPlan get _proPlan => kMockPricingPlans.firstWhere(
    (plan) => !plan.isFree && plan.isYearly == _isYearly,
    orElse: () => kMockPricingPlans.firstWhere((plan) => !plan.isFree),
  );

  ProductDetails? get _activeIapProduct =>
      _isYearly ? _iapService.yearlyProduct : _iapService.monthlyProduct;

  @override
  void initState() {
    super.initState();
    _iapService.addListener(_onIapStateChanged);
    _iapEventSub = _iapService.events.listen(_onIapEvent);
    _iapService.initialize();
  }

  void _onIapStateChanged() {
    if (mounted) setState(() {});
  }

  void _onIapEvent(IapPurchaseEvent event) {
    if (!mounted) return;
    switch (event.type) {
      case IapPurchaseEventType.purchased:
        HapticFeedback.heavyImpact();
        MessageService.showSuccess(
          context: context,
          message: context.l10n.subscriptionSuccess,
        );
        break;
      case IapPurchaseEventType.restored:
        HapticFeedback.mediumImpact();
        MessageService.showSuccess(
          context: context,
          message: context.l10n.subscriptionSuccess,
        );
        break;
      case IapPurchaseEventType.canceled:
        break;
      case IapPurchaseEventType.error:
        HapticFeedback.vibrate();
        MessageService.showError(
          context: context,
          message: event.message ?? context.l10n.subscriptionFailed,
        );
        break;
    }
  }

  @override
  void dispose() {
    _iapService.removeListener(_onIapStateChanged);
    _iapEventSub?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onBillingChanged(bool isYearly) {
    if (_isYearly == isYearly) return;
    HapticFeedback.selectionClick();
    setState(() => _isYearly = isYearly);
  }

  Future<void> _onSubscribePressed() async {
    HapticFeedback.lightImpact();

    if (_iapService.isPro) {
      MessageService.showInfo(
        context: context,
        message: context.l10n.currentPlan,
      );
      return;
    }

    final product = _activeIapProduct;
    if (product != null) {
      await _iapService.buySubscription(product);
      return;
    }

    if (!_iapService.isAvailable) {
      MessageService.showWarning(
        context: context,
        message: context.l10n.storeUnavailable,
      );
      return;
    }

    // Try fetching products if not loaded yet
    await _iapService.fetchProducts();
    final refreshedProduct = _activeIapProduct;
    if (refreshedProduct != null) {
      await _iapService.buySubscription(refreshedProduct);
      return;
    }

    // When running via Flutter CLI instead of Xcode directly,
    // StoreKit configuration is not attached by the runner.
    // Fall back to local simulated testing in debug mode.
    final targetProductId = _isYearly
        ? IapSubscriptionService.yearlySubscriptionId
        : IapSubscriptionService.monthlySubscriptionId;

    if (kDebugMode) {
      await _iapService.simulateLocalPurchase(targetProductId);
    } else {
      if (!mounted) return;
      MessageService.showWarning(
        context: context,
        message: context.l10n.storeUnavailable,
      );
    }
  }

  Future<void> _onRestorePressed() async {
    HapticFeedback.selectionClick();
    MessageService.showInfo(
      context: context,
      message: context.l10n.restoringPurchases,
    );
    await _iapService.restorePurchases();
  }

  Future<void> _onCancelSubscriptionPressed() async {
    HapticFeedback.lightImpact();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.cancelSubscription),
        content: Text(context.l10n.cancelSubscriptionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
            child: Text(context.l10n.cancelSubscription),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final canceled = await _iapService.cancelSubscription();
      if (!mounted) return;
      if (canceled) {
        MessageService.showSuccess(
          context: context,
          message: context.l10n.subscriptionCanceled,
        );
      } else {
        MessageService.showError(
          context: context,
          message: context.l10n.subscriptionFailed,
        );
      }
    }
  }

  String _formatPrice(PricingPlan plan) {
    final price = plan.priceEgp;
    if (price == price.roundToDouble()) return price.toStringAsFixed(0);
    return price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Directionality.of(context) == TextDirection.rtl;

    final bgColor = isDarkMode
        ? const Color(0xFF09090B)
        : const Color(0xFFF8F8FA);
    final primaryTextColor = isDarkMode
        ? Colors.white
        : const Color(0xFF09090B);
    final secondaryTextColor = isDarkMode
        ? const Color(0xFFA1A1AA)
        : const Color(0xFF71717A);
    final cardBg = isDarkMode ? const Color(0xFF141418) : Colors.white;
    final borderColor = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        clipBehavior: Clip.none,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 52,
        leadingWidth: 58,
        leading: const AppGlassBackButton(),
        centerTitle: true,
        title: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            final progress = ((offset - 16.0) / 38.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            final curve = Curves.easeOutCubic.transform(progress);

            // Travels in from the leading side along the diagonal trajectory.
            final incomingX = isAr
                ? (1.0 - curve) * 60.0
                : -(1.0 - curve) * 60.0;
            final incomingY = (1.0 - curve) * 12.0;
            final incomingScale = 0.85 + 0.15 * curve;

            return Transform.translate(
              offset: Offset(incomingX, incomingY),
              child: Transform.scale(
                scale: incomingScale,
                child: Opacity(
                  opacity: progress,
                  child: Text(
                    context.l10n.plansAndSubscriptions,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        flexibleSpace: AnimatedBuilder(
          animation: _scrollController,
          builder: (context, child) {
            final offset = _scrollController.hasClients
                ? _scrollController.offset
                : 0.0;
            final progress = ((offset - 10.0) / 35.0).clamp(0.0, 1.0);
            if (progress <= 0.0) return const SizedBox.shrink();
            return ClipRect(
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(
                  sigmaX: 20.0 * progress,
                  sigmaY: 20.0 * progress,
                ),
                child: Container(
                  color: bgColor.withValues(alpha: 0.82 * progress),
                ),
              ),
            );
          },
        ),
      ),
      body: ResponsiveWrapper(
        child: ListView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            // iOS authentic large title that collapses into the AppBar.
            AnimatedBuilder(
              animation: _scrollController,
              builder: (context, child) {
                final offset = _scrollController.hasClients
                    ? _scrollController.offset
                    : 0.0;
                final t = (offset / 55.0).clamp(0.0, 1.0);
                final curve = Curves.easeOutCubic.transform(t);
                final deltaX = isAr ? -curve * 90.0 : curve * 90.0;
                final deltaY = offset > 0 ? -offset * 0.35 : 0.0;
                final scale = 1.0 - curve * 0.35;
                final opacity = (1.0 - (offset - 15.0) / 40.0).clamp(0.0, 1.0);

                return Transform.translate(
                  offset: Offset(deltaX, deltaY),
                  child: Transform.scale(
                    scale: scale,
                    alignment: isAr
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Opacity(opacity: opacity, child: child),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: 2,
                  end: 2,
                  top: 2,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.plansAndSubscriptions,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                        height: 1.15,
                        color: primaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      context.l10n.plansAndSubscriptionsSubtitle,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Monthly / yearly segmented control
            _buildBillingToggle(
              isDarkMode: isDarkMode,
              cardBg: cardBg,
              borderColor: borderColor,
              secondaryTextColor: secondaryTextColor,
            ),
            const SizedBox(height: 18),

            // Hero Pro plan
            _buildProCard(isDarkMode: isDarkMode),
            const SizedBox(height: 16),

            // Free plan
            _buildFreeCard(
              isDarkMode: isDarkMode,
              cardBg: cardBg,
              borderColor: borderColor,
              primaryTextColor: primaryTextColor,
              secondaryTextColor: secondaryTextColor,
            ),

            const SizedBox(height: 22),
            _buildFooter(secondaryTextColor),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingToggle({
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
    required Color secondaryTextColor,
  }) {
    final thumbColor = isDarkMode ? Colors.white : const Color(0xFF09090B);
    final selectedTextColor = isDarkMode
        ? const Color(0xFF09090B)
        : Colors.white;
    final unselectedTextColor = secondaryTextColor;
    // Use the theme body style so the app font is preserved.
    final baseTextStyle =
        Theme.of(context).textTheme.bodyMedium ?? const TextStyle();

    Widget segment({
      required String label,
      required bool isSelected,
      required VoidCallback onTap,
      Widget? badge,
    }) {
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      style: baseTextStyle.copyWith(
                        fontSize: 13.5,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        letterSpacing: -0.2,
                        color: isSelected
                            ? selectedTextColor
                            : unselectedTextColor,
                      ),
                      child: Text(label),
                    ),
                    if (badge != null) ...[const SizedBox(width: 6), badge],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget yearlyBadge() {
      final badgeTextColor = isDarkMode ? _gold : const Color(0xFFB45309);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: _isYearly
              ? _gold.withValues(alpha: isDarkMode ? 0.22 : 0.14)
              : _gold.withValues(alpha: isDarkMode ? 0.12 : 0.09),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          context.l10n.save35,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.1,
            color: badgeTextColor,
          ),
        ),
      );
    }

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            alignment: _isYearly
                ? AlignmentDirectional.centerEnd
                : AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: thumbColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDarkMode ? 0.35 : 0.14,
                      ),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              segment(
                label: context.l10n.monthly,
                isSelected: !_isYearly,
                onTap: () => _onBillingChanged(false),
              ),
              segment(
                label: context.l10n.yearly,
                isSelected: _isYearly,
                onTap: () => _onBillingChanged(true),
                badge: yearlyBadge(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProCard({required bool isDarkMode}) {
    final plan = _proPlan;
    final activeIap = _activeIapProduct;
    final languageCode = context.l10n.localeName;
    const white = Colors.white;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? const [Color(0xFF2C2C37), Color(0xFF191920), Color(0xFF0D0D11)]
              : const [Color(0xFF353542), Color(0xFF1F1F28), Color(0xFF121217)],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: isDarkMode
              ? white.withValues(alpha: 0.10)
              : _gold.withValues(alpha: 0.24),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.55 : 0.12),
            blurRadius: isDarkMode ? 30 : 22,
            offset: Offset(0, isDarkMode ? 16 : 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Ambient gold aura — top end
          Positioned(
            top: -70,
            right: -50,
            child: IgnorePointer(
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gold.withValues(alpha: 0.22),
                      _gold.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Soft white sheen — bottom start
          Positioned(
            bottom: -90,
            left: -60,
            child: IgnorePointer(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      white.withValues(alpha: 0.06),
                      white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.30),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          AppIcons.plans(isIOS: Platform.isIOS),
                          size: 15,
                          color: _gold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        context.l10n.mahfaztiPro.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: white.withValues(alpha: 0.72),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _gold.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        context.l10n.mostPopular,
                        style: const TextStyle(
                          color: _gold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    // Fade through: the old content clears first, then the new
                    // one settles in — avoids the two prices ghosting together.
                    switchInCurve: const Interval(
                      0.3,
                      1.0,
                      curve: Curves.easeOutCubic,
                    ),
                    switchOutCurve: const Interval(
                      0.7,
                      1.0,
                      curve: Curves.easeInCubic,
                    ),
                    layoutBuilder: (currentChild, previousChildren) {
                      // Keep the card height tied to the incoming plan only;
                      // the outgoing content fades over it instead of holding
                      // the layout open and resizing again at the end.
                      return Stack(
                        alignment: Alignment.topCenter,
                        clipBehavior: Clip.hardEdge,
                        children: <Widget>[
                          ...previousChildren.map(
                            (child) => Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: child,
                            ),
                          ),
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.035),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      key: ValueKey('pro_content_${plan.id}'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.description(languageCode),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: white.withValues(alpha: 0.66),
                            fontSize: 12.5,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: AlignmentDirectional.centerStart,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      activeIap != null
                                          ? activeIap.price
                                          : _formatPrice(plan),
                                      style: const TextStyle(
                                        color: white,
                                        fontSize: 44,
                                        height: 1.0,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -1.6,
                                      ),
                                    ),
                                    if (activeIap == null) ...[
                                      const SizedBox(width: 7),
                                      Text(
                                        'EGP',
                                        style: TextStyle(
                                          color: white.withValues(alpha: 0.62),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(width: 6),
                                    Text(
                                      _isYearly
                                          ? context.l10n.perYear
                                          : context.l10n.perMonth,
                                      style: TextStyle(
                                        color: white.withValues(alpha: 0.52),
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (_isYearly)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    context.l10n.save35,
                                    style: const TextStyle(
                                      color: _gold,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: white.withValues(alpha: 0.10),
                        ),
                        const SizedBox(height: 16),
                        for (final feature in plan.features(languageCode))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  width: 19,
                                  height: 19,
                                  decoration: BoxDecoration(
                                    color: _gold.withValues(alpha: 0.16),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Icon(
                                      AppIcons.check(isIOS: Platform.isIOS),
                                      size: 11,
                                      color: _gold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      color: white.withValues(alpha: 0.88),
                                      fontSize: 13,
                                      height: 1.45,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _iapService.isPurchasing
                        ? null
                        : _onSubscribePressed,
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _iapService.isPurchasing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF09090B),
                                ),
                              ),
                            )
                          : Text(
                              _iapService.isPro
                                  ? context.l10n.currentPlan
                                  : context.l10n.subscribeNow,
                              style: const TextStyle(
                                color: Color(0xFF09090B),
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                    ),
                  ),
                ),
                if (_iapService.isPro) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: _iapService.isLoading
                        ? null
                        : _onCancelSubscriptionPressed,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                    label: Text(
                      context.l10n.cancelSubscription,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCard({
    required bool isDarkMode,
    required Color cardBg,
    required Color borderColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
  }) {
    final plan = _freePlan;
    final languageCode = context.l10n.localeName;
    final pillBg = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFF4F4F5);
    final dividerColor = isDarkMode
        ? const Color(0xFF27272A)
        : const Color(0xFFF1F1F5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: isDarkMode
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isDarkMode
                        ? const Color(0xFF3F3F46)
                        : const Color(0xFFE4E4E7),
                    width: 0.8,
                  ),
                ),
                child: Center(
                  child: Icon(
                    AppIcons.wallet(isIOS: Platform.isIOS),
                    size: 17,
                    color: primaryTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  plan.name(languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.free,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            plan.description(languageCode),
            style: TextStyle(
              color: secondaryTextColor,
              fontSize: 12.5,
              height: 1.45,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          Divider(height: 1, thickness: 1, color: dividerColor),
          const SizedBox(height: 14),
          for (final feature in plan.features(languageCode))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 1),
                    width: 19,
                    height: 19,
                    decoration: BoxDecoration(
                      color: pillBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        AppIcons.check(isIOS: Platform.isIOS),
                        size: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(
                        color: primaryTextColor,
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Container(
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: pillBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDarkMode
                    ? const Color(0xFF3F3F46)
                    : const Color(0xFFE4E4E7),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  AppIcons.check(isIOS: Platform.isIOS),
                  size: 14,
                  color: secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Text(
                  _iapService.isPro
                      ? (languageCode == 'ar'
                            ? 'الباقة الأساسية'
                            : 'Basic Plan')
                      : context.l10n.currentPlan,
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(Color secondaryTextColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Platform.isIOS ? CupertinoIcons.lock : Icons.lock_outline_rounded,
              size: 13,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 6),
            Text(
              context.l10n.cancelAnytime,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (Platform.isIOS) ...[
          const SizedBox(height: 12),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _iapService.isRestoring ? null : _onRestorePressed,
            child: Text(
              _iapService.isRestoring
                  ? context.l10n.restoringPurchases
                  : context.l10n.restorePurchases,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
