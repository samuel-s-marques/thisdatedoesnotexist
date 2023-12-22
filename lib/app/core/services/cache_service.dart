import 'package:hive/hive.dart';

class CacheService {
  Future<void> saveData(String key, dynamic data) async {
    final Box<dynamic> box = Hive.box('thisdatedoesnotexist');
    await box.put(key, data);
  }

  Future<dynamic> getData(String key) async {
    final Box<dynamic> box = Hive.box('thisdatedoesnotexist');
    return box.get(key);
  }

  Future<void> deleteData(String key) async {
    final Box<dynamic> box = Hive.box('thisdatedoesnotexist');
    await box.delete(key);
  }

  Future<void> clearData() async {
    final Box<dynamic> box = Hive.box('thisdatedoesnotexist');
    await box.clear();
  }
}
