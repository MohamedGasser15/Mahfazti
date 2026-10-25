import 'package:flutter/foundation.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/features/wallet/presentation/screens/bank_picker_screen.dart';

/// Repository that syncs banks and financial institutions from the backend API,
/// with offline-first fallback to local catalog.
class BankRepository {
  static final BankRepository _instance = BankRepository._internal();
  factory BankRepository() => _instance;
  BankRepository._internal();

  List<EgyptianBank>? _cachedBanks;

  /// Returns currently cached banks or the bundled catalog immediately (zero latency).
  List<EgyptianBank> get cachedBanks => _cachedBanks ?? kAllEgyptianBanks;

  /// Fetches the latest bank directory from the backend API (`GET /api/banks`).
  /// Updates cache and falls back gracefully to local catalog if offline.
  Future<List<EgyptianBank>> getBanks({bool forceRefresh = false}) async {
    if (_cachedBanks != null && !forceRefresh) {
      return _cachedBanks!;
    }

    try {
      final response = await ApiService().get(
        ApiEndpoints.banks,
        requiresAuth: false,
      );

      if (response.statusCode == 200 && response.data != null) {
        final dynamic body = response.data;
        final dynamic dataList =
            body is Map<String, dynamic> ? body['data'] : body;

        if (dataList is List && dataList.isNotEmpty) {
          final fetched = dataList.map((item) {
            final map = item as Map<String, dynamic>;
            final id = (map['id'] ?? '').toString();

            // Match with bundled local asset if exists
            final localBank = kAllEgyptianBanks
                .where((b) => b.id.toLowerCase() == id.toLowerCase())
                .firstOrNull;

            final website = map['website']?.toString();
            var logoUrl = map['logoUrl']?.toString();
            if (logoUrl == null || logoUrl.isEmpty || logoUrl.contains('google.com/s2/favicons')) {
              logoUrl = 'https://mahfazati.runasp.net/images/banks/$id.png';
            }

            return EgyptianBank(
              id: id,
              nameAr: (map['nameAr'] ?? map['name'] ?? id).toString(),
              nameEn: (map['nameEn'] ?? map['name'] ?? id).toString(),
              shortName: (map['shortName'] ?? '').toString(),
              logoAsset: localBank?.logoAsset ?? 'assets/icons/banks/$id.png',
              logoUrl: logoUrl,
              website: website,
              swiftCode: map['swiftCode']?.toString(),
              isPopular: map['isPopular'] == true,
              category: _mapCategory(map['category']?.toString()),
            );
          }).toList();

          if (fetched.isNotEmpty) {
            _cachedBanks = fetched;
            return fetched;
          }
        }
      }
    } catch (e) {
      debugPrint('BankRepository: using offline catalog ($e)');
    }

    return kAllEgyptianBanks;
  }

  static BankCategory _mapCategory(String? cat) {
    switch (cat?.toLowerCase()) {
      case 'fintech':
        return BankCategory.fintech;
      case 'international':
        return BankCategory.international;
      default:
        return BankCategory.egyptian;
    }
  }
}
