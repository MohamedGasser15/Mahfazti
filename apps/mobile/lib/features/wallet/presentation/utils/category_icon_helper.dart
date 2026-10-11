import 'package:flutter/material.dart';

class CategoryMeta {
  final IconData icon;
  final Color color;

  const CategoryMeta({
    required this.icon,
    required this.color,
  });
}

class CategoryIconHelper {
  CategoryIconHelper._();

  static final Map<int, IconData> _customIcons = {};
  static final Map<int, Color> _customColors = {};

  static void setCustomIcon(int catId, IconData icon, [Color? color]) {
    _customIcons[catId] = icon;
    if (color != null) _customColors[catId] = color;
  }

  static CategoryMeta getMeta(int? catId, String? name) {
    if (catId != null && _customIcons.containsKey(catId)) {
      return CategoryMeta(
        icon: _customIcons[catId]!,
        color: _customColors[catId] ?? const Color(0xFF6366F1),
      );
    }

    final lower = (name ?? '').toLowerCase().trim();

    // Food & Dining / مطاعم وأكل
    if (catId == 1 ||
        lower.contains('food') ||
        lower.contains('restaurant') ||
        lower.contains('dining') ||
        lower.contains('طعام') ||
        lower.contains('مطاعم') ||
        lower.contains('اكل') ||
        lower.contains('أكل')) {
      return const CategoryMeta(
        icon: Icons.restaurant_rounded,
        color: Color(0xFFF97316), // Orange
      );
    }

    // Shopping & Retail / تسوق ومشتريات
    if (catId == 2 ||
        lower.contains('shop') ||
        lower.contains('store') ||
        lower.contains('retail') ||
        lower.contains('تسوق') ||
        lower.contains('مستلزمات') ||
        lower.contains('شراء')) {
      return const CategoryMeta(
        icon: Icons.shopping_bag_rounded,
        color: Color(0xFFEC4899), // Pink
      );
    }

    // Bills & Utilities / فواتير ومرافق
    if (catId == 3 ||
        lower.contains('bill') ||
        lower.contains('utilit') ||
        lower.contains('electricity') ||
        lower.contains('water') ||
        lower.contains('فواتير') ||
        lower.contains('خدمات') ||
        lower.contains('كهرباء') ||
        lower.contains('مياه') ||
        lower.contains('غاز')) {
      return const CategoryMeta(
        icon: Icons.receipt_long_rounded,
        color: Color(0xFFEAB308), // Amber
      );
    }

    // Transportation & Car / مواصلات وسيارات
    if (lower.contains('trans') ||
        lower.contains('car') ||
        lower.contains('uber') ||
        lower.contains('taxi') ||
        lower.contains('gas') ||
        lower.contains('fuel') ||
        lower.contains('مواصلات') ||
        lower.contains('سيارة') ||
        lower.contains('بنزين')) {
      return const CategoryMeta(
        icon: Icons.directions_car_rounded,
        color: Color(0xFF3B82F6), // Blue
      );
    }

    // Health & Medical / صحة وطب وعلاج
    if (lower.contains('health') ||
        lower.contains('med') ||
        lower.contains('doctor') ||
        lower.contains('pharmacy') ||
        lower.contains('صحة') ||
        lower.contains('طبي') ||
        lower.contains('علاج') ||
        lower.contains('صيدلية')) {
      return const CategoryMeta(
        icon: Icons.medical_services_rounded,
        color: Color(0xFFEF4444), // Red
      );
    }

    // Salary / Income / راتب ودخل
    if (lower.contains('salary') ||
        lower.contains('income') ||
        lower.contains('wage') ||
        lower.contains('راتب') ||
        lower.contains('مرتب') ||
        lower.contains('دخل')) {
      return const CategoryMeta(
        icon: Icons.payments_rounded,
        color: Color(0xFF10B981), // Emerald
      );
    }

    // Education & Learning / تعليم ودراسة
    if (lower.contains('edu') ||
        lower.contains('school') ||
        lower.contains('course') ||
        lower.contains('book') ||
        lower.contains('تعليم') ||
        lower.contains('دراسة') ||
        lower.contains('كتب') ||
        lower.contains('جامعة')) {
      return const CategoryMeta(
        icon: Icons.school_rounded,
        color: Color(0xFF8B5CF6), // Purple
      );
    }

    // Entertainment & Fun / ترفيه وخروجات
    if (lower.contains('entertain') ||
        lower.contains('game') ||
        lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('ترفيه') ||
        lower.contains('سينما') ||
        lower.contains('ألعاب') ||
        lower.contains('خروجات')) {
      return const CategoryMeta(
        icon: Icons.sports_esports_rounded,
        color: Color(0xFFA855F7), // Purple / Magenta
      );
    }

    // Coffee & Cafes / قهوة وكافيهات
    if (lower.contains('coffee') ||
        lower.contains('cafe') ||
        lower.contains('قهوة') ||
        lower.contains('كافيه') ||
        lower.contains('مقهى') ||
        lower.contains('ستاربكس')) {
      return const CategoryMeta(
        icon: Icons.local_cafe_rounded,
        color: Color(0xFFB45309), // Brown / Amber
      );
    }

    // Groceries & Supermarket / بقالة وسوبرماركت
    if (lower.contains('grocer') ||
        lower.contains('market') ||
        lower.contains('supermarket') ||
        lower.contains('بقالة') ||
        lower.contains('سوبرماركت') ||
        lower.contains('تموين') ||
        lower.contains('خضار')) {
      return const CategoryMeta(
        icon: Icons.local_grocery_store_rounded,
        color: Color(0xFF16A34A), // Green
      );
    }

    // Sports & Fitness / جيم ورياضة
    if (lower.contains('gym') ||
        lower.contains('sport') ||
        lower.contains('fitness') ||
        lower.contains('جيم') ||
        lower.contains('رياضة') ||
        lower.contains('تمارين') ||
        lower.contains('نادي')) {
      return const CategoryMeta(
        icon: Icons.fitness_center_rounded,
        color: Color(0xFF0284C7), // Sky Blue
      );
    }

    // Travel & Flights / سفر وطيران وفنادق
    if (lower.contains('travel') ||
        lower.contains('trip') ||
        lower.contains('flight') ||
        lower.contains('hotel') ||
        lower.contains('سفر') ||
        lower.contains('رحلات') ||
        lower.contains('طيران') ||
        lower.contains('فندق')) {
      return const CategoryMeta(
        icon: Icons.flight_takeoff_rounded,
        color: Color(0xFF0D9488), // Teal
      );
    }

    // Subscriptions & Streaming / اشتراكات وباقات
    if (lower.contains('subscript') ||
        lower.contains('netflix') ||
        lower.contains('spotify') ||
        lower.contains('internet') ||
        lower.contains('اشتراك') ||
        lower.contains('اشتراكات') ||
        lower.contains('باقة') ||
        lower.contains('نت')) {
      return const CategoryMeta(
        icon: Icons.subscriptions_rounded,
        color: Color(0xFFE11D48), // Rose
      );
    }

    // Investments & Savings / استثمار وادخار
    if (lower.contains('invest') ||
        lower.contains('saving') ||
        lower.contains('gold') ||
        lower.contains('stock') ||
        lower.contains('crypto') ||
        lower.contains('استثمار') ||
        lower.contains('ادخار') ||
        lower.contains('ذهب') ||
        lower.contains('أسهم')) {
      return const CategoryMeta(
        icon: Icons.trending_up_rounded,
        color: Color(0xFF059669), // Emerald
      );
    }

    // Gifts & Donations / هدايا وتبرعات
    if (lower.contains('gift') ||
        lower.contains('charity') ||
        lower.contains('donation') ||
        lower.contains('هدية') ||
        lower.contains('هدايا') ||
        lower.contains('تبرع') ||
        lower.contains('صدقة') ||
        lower.contains('زكاة')) {
      return const CategoryMeta(
        icon: Icons.card_giftcard_rounded,
        color: Color(0xFFD946EF), // Fuchsia
      );
    }

    // Home & Furniture / أثاث وديكور ومنزل
    if (lower.contains('home') ||
        lower.contains('furnitur') ||
        lower.contains('rent') ||
        lower.contains('منزل') ||
        lower.contains('بيت') ||
        lower.contains('إيجار') ||
        lower.contains('اثاث') ||
        lower.contains('أثاث')) {
      return const CategoryMeta(
        icon: Icons.home_rounded,
        color: Color(0xFF6366F1), // Indigo
      );
    }

    // Electronics & Tech / أجهزة وإلكترونيات
    if (lower.contains('tech') ||
        lower.contains('electronic') ||
        lower.contains('gadget') ||
        lower.contains('phone') ||
        lower.contains('laptop') ||
        lower.contains('إلكترونيات') ||
        lower.contains('أجهزة') ||
        lower.contains('موبايل') ||
        lower.contains('هاتف')) {
      return const CategoryMeta(
        icon: Icons.devices_rounded,
        color: Color(0xFF4F46E5), // Indigo
      );
    }

    // Pets / حيوانات أليفة
    if (lower.contains('pet') ||
        lower.contains('vet') ||
        lower.contains('cat') ||
        lower.contains('dog') ||
        lower.contains('حيوان') ||
        lower.contains('قطط') ||
        lower.contains('بيطري')) {
      return const CategoryMeta(
        icon: Icons.pets_rounded,
        color: Color(0xFFCA8A04), // Yellow-amber
      );
    }

    // Freelance / Work / عمل حر
    if (lower.contains('freelance') ||
        lower.contains('work') ||
        lower.contains('job') ||
        lower.contains('عمل') ||
        lower.contains('شغل') ||
        lower.contains('حر')) {
      return const CategoryMeta(
        icon: Icons.work_rounded,
        color: Color(0xFF06B6D4), // Cyan
      );
    }

    // Default Fallback
    return const CategoryMeta(
      icon: Icons.category_rounded,
      color: Color(0xFF64748B), // Slate
    );
  }

  static IconData getIcon(int? catId, String? name) =>
      getMeta(catId, name).icon;

  static Color getColor(int? catId, String? name) =>
      getMeta(catId, name).color;
}
