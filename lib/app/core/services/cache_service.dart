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
}