import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/service_return_model.dart';
import 'package:thisdatedoesnotexist/app/core/models/user_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';

abstract class ChatService {
  Future<ServiceReturn> getChat(String id);
  Future<ServiceReturn> getChatSettings();
  Future<ServiceReturn> getMessages(
    String id,
    int page,
    void Function(int) updateAvailablePages,
  );
}

class ChatServiceImpl implements ChatService {
  final Repository _repository = Modular.get<Repository>();
  final String _server = const String.fromEnvironment('SERVER');
  FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<ServiceReturn> getChat(String id) async {
    UserModel character = UserModel(uid: 'uid');
    final Return response = await _repository.get(
      '$_server/api/characters/$id',
      options: HttpOptions(),
    );

    if (response.statusCode == 200) {
      character = UserModel.fromMap(response.data);

      return ServiceReturn(
        success: true,
        data: character,
      );
    }

    return ServiceReturn(success: false);
  }

  @override
  Future<ServiceReturn> getChatSettings() async {
    final Return response = await _repository.get(
      '$_server/api/chats/settings',
      options: HttpOptions(
        cache: false,
      ),
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
  Future<ServiceReturn> getMessages(String id, int page, void Function(int p1) updateAvailablePages) async {
    final Return response = await _repository.get(
      '$_server/api/messages?uid=$id&page=$page',
      options: HttpOptions(cache: false),
    );

    if (response.statusCode == 200) {
      final int totalPages = response.data['meta']['last_page'] - page;
      final List<dynamic> data = response.data['data'];

      updateAvailablePages(totalPages);

      return ServiceReturn(
        success: true,
        data: data,
      );
    }

    return ServiceReturn(success: false);
  }
}
