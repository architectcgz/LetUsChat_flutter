import 'package:hive/hive.dart';

import '../models/group.dart';

class LocalGroupRepo {
  final Box<Group> box;

  LocalGroupRepo({required this.box});

  Future<void> addGroup(Group group) async {
    await box.put(group.groupId, group);
  }

  Group? getGroup(String groupId) {
    return box.get(groupId);
  }

  List<Group> getAllGroups() {
    return box.values.toList();
  }

  Future<void> updateGroup(Group updatedGroup) async {
    if (box.containsKey(updatedGroup.groupId)) {
      await box.put(updatedGroup.groupId, updatedGroup);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    await box.delete(groupId);
  }

  Future<void> clearAllGroups() async {
    await box.clear();
  }
}