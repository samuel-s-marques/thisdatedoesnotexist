import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/env/env.dart';
import 'package:thisdatedoesnotexist/app/core/models/base_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/preferences_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/util.dart';

abstract class HomeService {
  Future<ServiceReturn> getAvailableSwipes();
  Future<ServiceReturn> getPreferences();
  Future<ServiceReturn> savePreferences(Preferences preferences);
  Future<ServiceReturn> getTodayCards(Preferences preferences);
  Future<ServiceReturn> saveSwipe({required String targetId, required String direction});
}

class HomeServiceImpl implements HomeService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = Env.server;
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<ServiceReturn> getAvailableSwipes() async {
    final Return response = await _repository.get(
      '$_server/api/users/swipes',
      options: HttpOptions(cache: false),
    );

    if (response.statusCode == 200) {
      return ServiceReturn(
        success: true,
        data: response.data,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> getPreferences() async {
    final Return response = await _repository.get(
      '$_server/api/preferences',
      options: HttpOptions(
        cache: false,
      ),
    );

    if (response.statusCode == 200) {
      final Map<dynamic, dynamic> data = response.data;
      final List<dynamic> sexes = data['sexes'] ?? [];
      final List<dynamic> relationshipGoals = data['relationship_goals'] ?? [];
      final List<dynamic> politicalViews = data['political_views'] ?? [];
      final List<dynamic> bodyTypes = data['body_types'] ?? [];
      final List<dynamic> religions = data['religions'] ?? [];
      final double minAge = checkDouble(data['min_age'] ?? 18);
      final double maxAge = checkDouble(data['max_age'] ?? 70);

      final Preferences preferences = Preferences(
        sexes: sexes.map((sex) => BaseModel.fromMap(sex)).toList(),
        relationshipGoals: relationshipGoals.map((goal) => BaseModel.fromMap(goal)).toList(),
        politicalViews: politicalViews.map((view) => BaseModel.fromMap(view)).toList(),
        bodyTypes: bodyTypes.map((type) => BaseModel.fromMap(type)).toList(),
        religions: religions.map((religion) => BaseModel.fromMap(religion)).toList(),
        minAge: minAge,
        maxAge: maxAge,
      );

      return ServiceReturn(
        success: true,
        data: preferences,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> getTodayCards(Preferences preferences) async {
    final int minAge = preferences.minAge.round();
    final int maxAge = preferences.maxAge.round();
    final List<BaseModel> politicalViewsPreferences = preferences.politicalViews;
    final List<BaseModel> relationshipGoalsPreferences = preferences.relationshipGoals;
    final List<BaseModel> bodyTypesPreferences = preferences.bodyTypes;
    final List<BaseModel> sexesPreferences = preferences.sexes;
    final List<BaseModel> religionsPreferences = preferences.religions;

    String url = '$_server/api/characters?min_age=$minAge&max_age=$maxAge';

    if (politicalViewsPreferences.isNotEmpty) {
      final List<String?> politicalViews = politicalViewsPreferences.map((e) => e.name).toList();
      url += '&political_view=${politicalViews.join(',')}';
    }

    if (relationshipGoalsPreferences.isNotEmpty) {
      final List<String?> relationshipGoals = relationshipGoalsPreferences.map((e) => e.name).toList();
      url += '&relationship_goal=${relationshipGoals.join(',')}';
    }

    if (bodyTypesPreferences.isNotEmpty) {
      final List<String?> bodytypes = bodyTypesPreferences.map((e) => e.name).toList();
      url += '&body_type=${bodytypes.join(',')}';
    }

    if (sexesPreferences.isNotEmpty) {
      final List<String?> sexes = sexesPreferences.map((e) => e.name).toList();
      url += '&sex=${sexes.join(',')}';
    }

    if (religionsPreferences.isNotEmpty) {
      final List<String?> religions = religionsPreferences.map((e) => e.name).toList();
      url += '&religion=${religions.join(',')}';
    }

    final Return response = await _repository.get(
      url,
      options: HttpOptions(cache: false),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'];

      return ServiceReturn(
        success: true,
        data: data,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> savePreferences(Preferences preferences) async {
    final Return response = await _repository.put(
      '$_server/api/preferences',
      preferences.toMap(),
      options: HttpOptions(),
    );

    if (response.statusCode == 201) {
      return ServiceReturn(success: true);
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> saveSwipe({required String targetId, required String direction}) async {
    final Return response = await _repository.post(
      '$_server/api/swipes',
      {
        'target_id': targetId,
        'swiper_id': await storage.read(key: 'uid'),
        'direction': direction,
      },
      options: HttpOptions(),
    );

    if (response.statusCode == 201) {
      return ServiceReturn(success: true);
    }

    return ServiceReturn(success: false);
  }
}
