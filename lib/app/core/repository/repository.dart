import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';

abstract class Repository {
  Future<Return> get(String url, {HttpOptions? options});
  Future<Return> post(String url, dynamic body, {HttpOptions? options});
  Future<Return> put(String url, dynamic body, {HttpOptions? options});
  Future<Return> delete(String url, {HttpOptions? options});
  Future<Return> download(String url, String savePath, {HttpOptions? options});
}