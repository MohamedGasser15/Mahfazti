import 'package:flutter/material.dart';
import 'package:my_wallet/features/wallet/data/models/wallet_models.dart';
import 'package:my_wallet/features/wallet/presentation/utils/category_icon_helper.dart';

/// The main category tab for the wealth analytics screen.
enum WealthTab {
  netWorth,
  assets,
  debt;

  String label({required bool isAr}) {
    switch (this) {
      case WealthTab.netWorth:
        return isAr ? 'صافي الثروة' : 'Net worth';
      case WealthTab.assets:
        return isAr ? 'الأصول' : 'Assets';
      case WealthTab.debt:
        return isAr ? 'الديون' : 'Debt';
    }
  }
}

/// The time period filter for wealth curves.
enum WealthPeriod {
  oneMonth(30),
  threeMonths(90),
  oneYear(365),
  all(null);

  const WealthPeriod(this.days);
  final int? days;

  String label({required bool isAr}) {
    switch (this) {
      case WealthPeriod.oneMonth:
        return isAr ? 'شهر' : '1M';
      case WealthPeriod.threeMonths:
        return isAr ? '3 أشهر' : '3M';
      case WealthPeriod.oneYear:
        return isAr ? 'سنة' : '1Y';
      case WealthPeriod.all:
        return isAr ? 'الكل' : 'All';
    }
  }
}

/// An individual asset or debt item displayed in the breakdown.
class WealthItem {
  final String id;
  final String name;
  final String? nameEn;
  final String type;
  final double balance;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? subtitleEn;

  const WealthItem({
    required this.id,
    required this.name,
    this.nameEn,
    required this.type,
    required this.balance,
    required this.icon,
    required this.color,
    this.subtitle,
    this.subtitleEn,
  });

  String displayName({required bool isAr}) =>
      isAr ? name : (nameEn ?? name);

  String? displaySubtitle({required bool isAr}) =>
      isAr ? subtitle : (subtitleEn ?? subtitle);
}

/// The time window used by the analytics screen.
enum AnalyticsPeriod {
  last7(7),
  last30(30),
  last90(90),
  custom(null);

  const AnalyticsPeriod(this.days);

  /// Number of days for the preset periods, `null` for a custom range.
  final int? days;
}

/// A single category row/slice ready to be rendered by either platform.
class AnalyticsCategorySlice {
  const AnalyticsCategorySlice({
    required this.categoryId,
    required this.name,
    required this.total,
    required this.count,
    required this.color,
    required this.icon,
    required this.share,
  });

  final int? categoryId;
  final String name;
  final double total;
  final int count;
  final Color color;
  final IconData icon;

  /// Percentage of the whole (0..1).
  final double share;
}

/// Maps the API category summaries into visual slices, sorted from the biggest.
///
/// When [maxSlices] is set, the overflow is merged into a single "other" slice
/// so charts never render more than [maxSlices] slices.
List<AnalyticsCategorySlice> buildCategorySlices(
  List<CategorySummary> categories, {
  required bool isAr,
  int? maxSlices,
  String otherLabel = 'Other',
}) {
  final sorted = [...categories]..sort((a, b) => b.total.compareTo(a.total));
  final total = sorted.fold<double>(0, (sum, item) => sum + item.total);
  if (total <= 0) return const [];

  final slices = <AnalyticsCategorySlice>[];
  var otherTotal = 0.0;
  var otherCount = 0;

  for (var index = 0; index < sorted.length; index++) {
    final item = sorted[index];
    if (maxSlices != null && index >= maxSlices - 1) {
      otherTotal += item.total;
      otherCount += item.count;
      continue;
    }

    final meta = CategoryIconHelper.getMeta(
      item.categoryId,
      item.categoryNameEn,
    );
    slices.add(
      AnalyticsCategorySlice(
        categoryId: item.categoryId,
        name: isAr ? item.categoryNameAr : item.categoryNameEn,
        total: item.total,
        count: item.count,
        color: meta.color,
        icon: meta.icon,
        share: item.total / total,
      ),
    );
  }

  if (otherTotal > 0) {
    slices.add(
      AnalyticsCategorySlice(
        categoryId: null,
        name: otherLabel,
        total: otherTotal,
        count: otherCount,
        color: const Color(0xFF71717A),
        icon: Icons.more_horiz_rounded,
        share: otherTotal / total,
      ),
    );
  }

  return slices;
}
