import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/constants/app_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/services/wallet_data_sync_service.dart';
import 'package:my_wallet/features/wallet/data/models/category_group_model.dart';

class CategoryGroupService {
  CategoryGroupService._();

  static const String _groupsKey = 'user_category_groups_v1';
  static const String _mappingKey = 'user_category_group_mapping_v1';

  static final StreamController<void> _controller =
      StreamController<void>.broadcast();

  static Stream<void> get onGroupsChanged => _controller.stream;

  static final ApiService _apiService = ApiService();

  static bool get _apiEnabled =>
      !AppConstants.useMockBackend && !AppConstants.isTestingEnvironment;

  static Future<List<CategoryGroup>> getGroups() async {
    if (_apiEnabled) {
      try {
        final response = await _apiService.get(
          ApiEndpoints.categoryGroups,
          requiresAuth: true,
        );
        final List list = response.data as List;
        final groups = list
            .map((e) => CategoryGroup.fromJson(e as Map<String, dynamic>))
            .toList();
        await _saveLocalGroups(groups);
        return groups;
      } catch (e) {
        debugPrint(
          'Error fetching category groups from API, falling back to local: $e',
        );
      }
    }
    return _getLocalGroups();
  }

  static Future<void> saveGroup(CategoryGroup group) async {
    final groups = await _getLocalGroups();
    final exists = groups.any((g) => g.id == group.id);
    final body = {
      'name': group.name,
      'colorValue': group.colorValue,
      'iconIndex': group.iconIndex,
      'displayOrder': 0,
    };

    if (_apiEnabled) {
      if (exists) {
        await _apiService.put(
          '${ApiEndpoints.categoryGroups}/${group.id}',
          body,
          requiresAuth: true,
        );
      } else {
        await _apiService.post(ApiEndpoints.categoryGroups, {
          'id': group.id,
          ...body,
        }, requiresAuth: true);
      }
    }

    final index = groups.indexWhere((g) => g.id == group.id);
    if (index >= 0) {
      groups[index] = group;
    } else {
      groups.add(group);
    }
    await _saveLocalGroups(groups);
    _notify();
  }

  static Future<void> deleteGroup(String groupId) async {
    if (_apiEnabled) {
      await _apiService.delete(
        '${ApiEndpoints.categoryGroups}/$groupId',
        requiresAuth: true,
      );
    }

    final groups = await _getLocalGroups();
    groups.removeWhere((g) => g.id == groupId);
    await _saveLocalGroups(groups);

    final mappings = await getCategoryGroupMappings();
    mappings.removeWhere((catId, gId) => gId == groupId);
    await _saveMappings(mappings);
    _notify();
  }

  static Future<Map<int, String>> getCategoryGroupMappings() async {
    if (_apiEnabled) {
      try {
        final response = await _apiService.get(
          ApiEndpoints.categoryGroupMappings,
          requiresAuth: true,
        );
        final map = response.data as Map<String, dynamic>;
        final result = map.map(
          (key, value) => MapEntry(int.parse(key), value.toString()),
        );
        await _saveMappings(result);
        return result;
      } catch (e) {
        debugPrint(
          'Error fetching category mappings from API, fallback to local: $e',
        );
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_mappingKey);
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(int.parse(key), value as String),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> assignCategoryToGroup(
    int categoryId,
    String? groupId,
  ) async {
    if (_apiEnabled) {
      await _apiService.post(ApiEndpoints.categoryGroupAssign, {
        'categoryId': categoryId,
        'groupId': groupId,
      }, requiresAuth: true);
    }

    final mappings = await getCategoryGroupMappings();
    if (groupId == null || groupId.isEmpty) {
      mappings.remove(categoryId);
    } else {
      mappings[categoryId] = groupId;
    }
    await _saveMappings(mappings);
    _notify();
  }

  static Future<void> deleteCategoryAssignment(int categoryId) async {
    await assignCategoryToGroup(categoryId, null);
  }

  static Future<void> _saveMappings(Map<int, String> mappings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringMap = mappings.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await prefs.setString(_mappingKey, jsonEncode(stringMap));
    } catch (_) {}
  }

  static Future<List<CategoryGroup>> getLocalGroups() => _getLocalGroups();

  static Future<List<CategoryGroup>> _getLocalGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getStringList(_groupsKey);
      if (raw == null || raw.isEmpty) return [];
      return raw.map((item) {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        return CategoryGroup.fromJson(decoded);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> _saveLocalGroups(List<CategoryGroup> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = groups.map((g) => jsonEncode(g.toJson())).toList();
      await prefs.setStringList(_groupsKey, encoded);
    } catch (_) {}
  }

  static void _notify() {
    _controller.add(null);
    WalletDataSyncService.notifyDataChanged();
  }
}
