import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';

abstract class DataService {
  Future<ServiceReturn> getRelationshipGoals();
  Future<ServiceReturn> getSexes();
  Future<ServiceReturn> getPoliticalViews();
  Future<ServiceReturn> getReligions();
  Future<ServiceReturn> getBodyTypes();
  Future<ServiceReturn> getHobbies();
  Future<ServiceReturn> getPronouns();
  Future<ServiceReturn> getOccupations();
}

class DataServiceImpl implements DataService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = const String.fromEnvironment('SERVER');
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<ServiceReturn> getBodyTypes() async {
    final Return response = await _repository.get(
      '$_server/api/body-types',
      options: HttpOptions(),
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
  Future<ServiceReturn> getPoliticalViews() async {
    final Return response = await _repository.get(
      '$_server/api/political-views',
      options: HttpOptions(),
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
  Future<ServiceReturn> getRelationshipGoals() async {
    final Return response = await _repository.get(
      '$_server/api/relationship-goals',
      options: HttpOptions(),
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
  Future<ServiceReturn> getReligions() async {
    final Return response = await _repository.get(
      '$_server/api/religions',
      options: HttpOptions(),
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
  Future<ServiceReturn> getSexes() async {
    final Return response = await _repository.get(
      '$_server/api/sexes',
      options: HttpOptions(),
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
  Future<ServiceReturn> getHobbies() async {
    final Return response = await _repository.get(
      '$_server/api/hobbies',
      options: HttpOptions(),
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
  Future<ServiceReturn> getOccupations() async {
    final Return response = await _repository.get(
      '$_server/api/occupations',
      options: HttpOptions(),
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
  Future<ServiceReturn> getPronouns() async {
    final Return response = await _repository.get(
      '$_server/api/pronouns',
      options: HttpOptions(),
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
}
