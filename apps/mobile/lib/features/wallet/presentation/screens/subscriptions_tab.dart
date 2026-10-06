import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_wallet/core/constants/currency_constants.dart';
import 'package:my_wallet/core/services/message_service.dart';
import 'package:my_wallet/core/utils/app_responsive.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionItem {
  final String id;
  final String title;
  final double amount;
  final String billingCycle; // 'monthly', 'yearly'
  final int renewalDay; // Day of month (1-31)
  final String category;
  final IconData icon;

  const SubscriptionItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.billingCycle,
    required this.renewalDay,
    required this.category,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'billingCycle': billingCycle,
        'renewalDay': renewalDay,
        'category': category,
        'iconCode': icon.codePoint,
      };

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) => SubscriptionItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
        billingCycle: json['billingCycle'] ?? 'monthly',
        renewalDay: json['renewalDay'] ?? 1,
        category: json['category'] ?? '',
        icon: json['iconCode'] != null
            // ignore: non_const_argument_for_const_parameter
            ? IconData(json['iconCode'], fontFamily: 'MaterialIcons')
            : Icons.subscriptions_rounded,
      );

  static List<SubscriptionItem> defaultSeed() {
    return const [
      SubscriptionItem(
        id: 'sub_netflix',
        title: 'Netflix Premium',
        amount: 250.0,
        billingCycle: 'monthly',
        renewalDay: 12,
        category: 'Entertainment',
        icon: Icons.movie_filter_rounded,
      ),
      SubscriptionItem(
        id: 'sub_internet',
        title: 'Home Internet Fiber (WE)',
        amount: 380.0,
        billingCycle: 'monthly',
        renewalDay: 15,
        category: 'Utilities',
        icon: Icons.wifi_rounded,
      ),
      SubscriptionItem(
        id: 'sub_gym',
        title: 'Gold\'s Gym Club',
        amount: 650.0,
        billingCycle: 'monthly',
        renewalDay: 1,
        category: 'Fitness',
        icon: Icons.fitness_center_rounded,
      ),
    ];
  }
}

class SubscriptionsTab extends StatefulWidget {
  const SubscriptionsTab({super.key});

  @override
  State<SubscriptionsTab> createState() => _SubscriptionsTabState();
}

class _SubscriptionsTabState extends State<SubscriptionsTab> {
  static const String _storageKey = 'user_subscriptions_list';
  List<SubscriptionItem> _subscriptions = [];
  bool _isLoading = true;
  String _currencyCode = 'EGP';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final code = await SharedPrefs.getCurrency();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    List<SubscriptionItem> list = [];
    if (raw != null) {
      try {
        final decoded = jsonDecode(raw) as List;
        list = decoded.map((e) => SubscriptionItem.fromJson(e)).toList();
      } catch (_) {}
    }

    // If empty or never saved, seed 3 subscriptions
    if (list.isEmpty) {
      list = List.from(SubscriptionItem.defaultSeed());
      await prefs.setString(
        _storageKey,
        jsonEncode(list.map((e) => e.toJson()).toList()),
      );
    }

    if (mounted) {
      setState(() {
        _currencyCode = code ?? 'EGP';
        _subscriptions = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_subscriptions.map((e) => e.toJson()).toList()),
    );
  }

  String _formatAmount(double amount) {
    final symbol = currencySymbols[_currencyCode] ?? _currencyCode;
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  double get _totalMonthlyCommitment {
    return _subscriptions.fold(0.0, (acc, item) {
      if (item.billingCycle == 'yearly') {
        return acc + (item.amount / 12);
      }
      return acc + item.amount;
    });
  }

  SubscriptionItem? get _nearestDueSubscription {
    if (_subscriptions.isEmpty) return null;
    final now = DateTime.now();
    final sorted = List<SubscriptionItem>.from(_subscriptions);
    sorted.sort((a, b) {
      int daysA = a.renewalDay - now.day;
      if (daysA < 0) daysA += 30;
      int daysB = b.renewalDay - now.day;
      if (daysB < 0) daysB += 30;
      return daysA.compareTo(daysB);
    });
    return sorted.first;
  }

  int _getDaysUntil(int renewalDay) {
    final now = DateTime.now();
    int diff = renewalDay - now.day;
    if (diff < 0) diff += 30;
    return diff;
  }

  void _showAddSubscriptionModal(bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final dayController = TextEditingController(text: '15');
    String cycle = 'monthly';
    IconData selectedIcon = Icons.credit_card_rounded;

    // Presets for quick 1-tap fill
    final presets = [
      {'name': 'Netflix', 'amount': '250', 'icon': Icons.movie_filter_rounded},
      {'name': 'Spotify', 'amount': '80', 'icon': Icons.music_note_rounded},
      {'name': isAr ? 'إنترنت WE' : 'WE Internet', 'amount': '380', 'icon': Icons.wifi_rounded},
      {'name': isAr ? 'جيم' : 'Gym', 'amount': '600', 'icon': Icons.fitness_center_rounded},
      {'name': 'YouTube', 'amount': '90', 'icon': Icons.play_circle_fill_rounded},
      {'name': 'iCloud', 'amount': '45', 'icon': Icons.cloud_rounded},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 22,
                right: 22,
                top: 20,
                bottom: bottomInset > 0 ? bottomInset + 16 : 32,
              ),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border.all(
                  color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    isAr ? 'إضافة اشتراك جديد' : 'New Subscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isAr
                        ? 'تتبع فواتيرك واشتراكاتك الدورية بسهولة'
                        : 'Track recurring bills and subscriptions',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Presets chips
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: presets.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final p = presets[index];
                        return InkWell(
                          onTap: () {
                            setModalState(() {
                              titleController.text = p['name'] as String;
                              amountController.text = p['amount'] as String;
                              selectedIcon = p['icon'] as IconData;
                            });
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? const Color(0xFF222228)
                                  : const Color(0xFFF4F4F5),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFE4E4E7),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(p['icon'] as IconData, size: 14, color: isDarkMode ? Colors.grey[300] : Colors.grey[700]),
                                const SizedBox(width: 6),
                                Text(
                                  p['name'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Title Input
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: titleController,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isAr ? 'اسم الاشتراك (مثال: نتفلكس)' : 'Title (e.g. Netflix)',
                        hintStyle: TextStyle(
                          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Amount & Renewal Day Row
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFE4E4E7),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextField(
                            controller: amountController,
                            keyboardType:
                                const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              ),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Text(
                                  _currencyCode,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ),
                              prefixIconConstraints:
                                  const BoxConstraints(minWidth: 44, minHeight: 0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF4F4F5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDarkMode
                                  ? const Color(0xFF27272A)
                                  : const Color(0xFFE4E4E7),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: TextField(
                            controller: dayController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: isAr ? 'يوم' : 'Day',
                              hintStyle: TextStyle(
                                color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                              ),
                              suffixText: isAr ? 'بالشهر' : 'of mo',
                              suffixStyle: TextStyle(
                                fontSize: 11,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Billing Cycle Toggle
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => cycle = 'monthly'),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: cycle == 'monthly'
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : (isDarkMode
                                      ? const Color(0xFF1E1E24)
                                      : const Color(0xFFF4F4F5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isAr ? 'شهرياً' : 'Monthly',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: cycle == 'monthly'
                                      ? (isDarkMode ? Colors.black : Colors.white)
                                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModalState(() => cycle = 'yearly'),
                          child: Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: cycle == 'yearly'
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : (isDarkMode
                                      ? const Color(0xFF1E1E24)
                                      : const Color(0xFFF4F4F5)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                isAr ? 'سنوياً' : 'Yearly',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: cycle == 'yearly'
                                      ? (isDarkMode ? Colors.black : Colors.white)
                                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final title = titleController.text.trim();
                        final amount = double.tryParse(amountController.text.trim());
                        final day = int.tryParse(dayController.text.trim()) ?? 1;

                        if (title.isEmpty || amount == null || amount <= 0) {
                          MessageService.showError(
                            context: context,
                            message: isAr
                                ? 'يرجى إدخال اسم ومبلغ الاشتراك'
                                : 'Please enter subscription title and amount',
                          );
                          return;
                        }

                        Navigator.pop(ctx);
                        HapticFeedback.mediumImpact();

                        final newItem = SubscriptionItem(
                          id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
                          title: title,
                          amount: amount,
                          billingCycle: cycle,
                          renewalDay: day.clamp(1, 31),
                          category: 'Subscriptions',
                          icon: selectedIcon,
                        );

                        setState(() {
                          _subscriptions.insert(0, newItem);
                        });
                        await _saveSubscriptions();

                        if (context.mounted) {
                          MessageService.showSuccess(
                            context: context,
                            message: isAr
                                ? 'تمت إضافة الاشتراك بنجاح'
                                : 'Subscription added successfully',
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.white : Colors.black,
                        foregroundColor: isDarkMode ? Colors.black : Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        isAr ? 'حفظ الاشتراك' : 'Save Subscription',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSubscriptionOptions(SubscriptionItem sub, bool isDarkMode) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF141418) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF2E2E36) : const Color(0xFFD4D4D8),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(sub.icon, size: 22, color: isDarkMode ? Colors.white : Colors.black),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sub.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatAmount(sub.amount)} / ${sub.billingCycle == 'yearly' ? (isAr ? 'سنوياً' : 'yr') : (isAr ? 'شهرياً' : 'mo')}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Divider(
              height: 1,
              color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF1F1F5),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: Text(
                isAr ? 'حذف هذا الاشتراك' : 'Delete Subscription',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              onTap: () async {
                Navigator.pop(ctx);
                HapticFeedback.mediumImpact();
                setState(() {
                  _subscriptions.removeWhere((item) => item.id == sub.id);
                });
                await _saveSubscriptions();
                if (mounted) {
                  MessageService.showSuccess(
                    context: context,
                    message: isAr ? 'تم حذف الاشتراك' : 'Subscription deleted',
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final bgColor = isDarkMode ? const Color(0xFF09090B) : const Color(0xFFF8F8FA);
    final borderColor = isDarkMode ? const Color(0xFF27272A) : const Color(0xFFE4E4E7);

    final nextDue = _nearestDueSubscription;
    final nextDays = nextDue != null ? _getDaysUntil(nextDue.renewalDay) : 0;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          isAr ? 'الاشتراكات والفواتير' : 'Subscriptions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: isDarkMode ? Colors.white : const Color(0xFF09090B),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showAddSubscriptionModal(isDarkMode),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 120),
              child: ResponsiveWrapper(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= 1. HERO COMMITMENTS CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.35 : 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'الالتزامات الدورية الشهرية' : 'Monthly Recurring Costs',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor, width: 0.8),
                                ),
                                child: Text(
                                  isAr
                                      ? '${_subscriptions.length} نشطة'
                                      : '${_subscriptions.length} Active',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                _formatAmount(_totalMonthlyCommitment),
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.6,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isAr ? '/ شهر' : '/ month',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                          // Nearest upcoming bill banner pill
                          if (nextDue != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1B1B22)
                                    : const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: borderColor, width: 0.8),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF59E0B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isAr
                                              ? 'الفاتورة القادمة: ${nextDue.title}'
                                              : 'Next due: ${nextDue.title}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          isAr
                                              ? (nextDays == 0
                                                  ? 'مستحقة اليوم!'
                                                  : 'بعد $nextDays يوم (يوم ${nextDue.renewalDay} بالشهر)')
                                              : (nextDays == 0
                                                  ? 'Due today!'
                                                  : 'In $nextDays days (Day ${nextDue.renewalDay})'),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFFF59E0B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _formatAmount(nextDue.amount),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ================= 2. ACTIVE SUBSCRIPTIONS HEADER =================
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              isAr ? 'الاشتراكات المثبتة' : 'Active Subscriptions',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_subscriptions.length}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showAddSubscriptionModal(isDarkMode),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              isAr ? '+ إضافة جديد' : '+ Add new',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ================= 3. GROUPED SUBSCRIPTIONS CARD =================
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF141418) : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: borderColor, width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.03),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subscriptions.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          thickness: 1,
                          color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                        ),
                        itemBuilder: (context, index) {
                          final sub = _subscriptions[index];
                          final days = _getDaysUntil(sub.renewalDay);

                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                _showSubscriptionOptions(sub, isDarkMode);
                              },
                              borderRadius: index == 0
                                  ? const BorderRadius.vertical(top: Radius.circular(22))
                                  : index == _subscriptions.length - 1
                                      ? const BorderRadius.vertical(bottom: Radius.circular(22))
                                      : BorderRadius.zero,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: (isDarkMode ? Colors.white : Colors.black)
                                            .withValues(alpha: 0.07),
                                        borderRadius: BorderRadius.circular(13),
                                      ),
                                      child: Icon(
                                        sub.icon,
                                        size: 20,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sub.title,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: isDarkMode ? Colors.white : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Text(
                                                isAr
                                                    ? (days == 0 ? 'مستحقة اليوم!' : 'بعد $days يوم')
                                                    : (days == 0 ? 'Due today!' : 'In $days days'),
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: days <= 3
                                                      ? const Color(0xFFF59E0B)
                                                      : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '•',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                isAr
                                                    ? 'يوم ${sub.renewalDay} بالشهر'
                                                    : 'Day ${sub.renewalDay}',
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          _formatAmount(sub.amount),
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDarkMode ? const Color(0xFF222228) : const Color(0xFFF4F4F5),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            sub.billingCycle == 'yearly'
                                                ? (isAr ? 'سنوياً' : 'yearly')
                                                : (isAr ? 'شهرياً' : 'monthly'),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
