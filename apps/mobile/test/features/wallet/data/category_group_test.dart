import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_wallet/features/wallet/data/models/category_group_model.dart';
import 'package:my_wallet/features/wallet/data/repositories/category_group_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CategoryGroup Model', () {
    test('toJson and fromJson work symmetrically', () {
      final now = DateTime.now();
      final group = CategoryGroup(
        id: 'group_1',
        name: 'Essentials',
        colorValue: 0xFF3B82F6,
        iconIndex: 2,
        createdAt: now,
      );

      final json = group.toJson();
      final fromJson = CategoryGroup.fromJson(json);

      expect(fromJson.id, 'group_1');
      expect(fromJson.name, 'Essentials');
      expect(fromJson.colorValue, 0xFF3B82F6);
      expect(fromJson.iconIndex, 2);
      expect(fromJson.createdAt.millisecondsSinceEpoch, now.millisecondsSinceEpoch);
    });

    test('copyWith updates properties properly', () {
      final group = CategoryGroup(
        id: 'group_1',
        name: 'Old Name',
        colorValue: 0xFF3B82F6,
        iconIndex: 1,
        createdAt: DateTime.now(),
      );

      final updated = group.copyWith(
        name: 'New Name',
        colorValue: 0xFF10B981,
      );

      expect(updated.id, 'group_1');
      expect(updated.name, 'New Name');
      expect(updated.colorValue, 0xFF10B981);
      expect(updated.iconIndex, 1);
    });
  });

  group('CategoryGroupService', () {
    test('saveGroup and getGroups persist correctly', () async {
      expect(await CategoryGroupService.getGroups(), isEmpty);

      final group1 = CategoryGroup(
        id: 'g1',
        name: 'Daily',
        colorValue: 0xFF3B82F6,
        iconIndex: 0,
        createdAt: DateTime.now(),
      );
      await CategoryGroupService.saveGroup(group1);

      final groups = await CategoryGroupService.getGroups();
      expect(groups.length, 1);
      expect(groups.first.name, 'Daily');

      // Update existing
      final updatedGroup1 = group1.copyWith(name: 'Daily Essentials');
      await CategoryGroupService.saveGroup(updatedGroup1);

      final updatedList = await CategoryGroupService.getGroups();
      expect(updatedList.length, 1);
      expect(updatedList.first.name, 'Daily Essentials');
    });

    test('deleteGroup removes group and unassigns categories', () async {
      final group = CategoryGroup(
        id: 'g1',
        name: 'Daily',
        colorValue: 0xFF3B82F6,
        iconIndex: 0,
        createdAt: DateTime.now(),
      );
      await CategoryGroupService.saveGroup(group);
      await CategoryGroupService.assignCategoryToGroup(10, 'g1');

      var map = await CategoryGroupService.getCategoryGroupMappings();
      expect(map[10], 'g1');

      await CategoryGroupService.deleteGroup('g1');

      expect(await CategoryGroupService.getGroups(), isEmpty);
      map = await CategoryGroupService.getCategoryGroupMappings();
      expect(map[10], isNull);
    });

    test('assignCategoryToGroup with null groupId unassigns category', () async {
      await CategoryGroupService.assignCategoryToGroup(5, 'g1');
      var map = await CategoryGroupService.getCategoryGroupMappings();
      expect(map[5], 'g1');

      await CategoryGroupService.assignCategoryToGroup(5, null);
      map = await CategoryGroupService.getCategoryGroupMappings();
      expect(map[5], isNull);
    });
  });
}
