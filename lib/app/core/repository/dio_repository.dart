import 'package:dio/dio.dart';
import 'package:thisdatedoesnotexist/app/core/models/options.dart';
import 'package:thisdatedoesnotexist/app/core/models/return_model.dart';
import 'package:thisdatedoesnotexist/app/core/repository/repository.dart';
import 'package:thisdatedoesnotexist/app/core/services/cache_service.dart';

class DioRepository implements Repository {
  static final Dio _dio = Dio();
  static Dio get dio => _dio;
  final CacheService cache = CacheService();

  @override
  Future<Return> delete(String url, {HttpOptions? options}) async {
    try {
      final Response<dynamic> response = await dio.delete(url, options: options);

      return Return(
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      return Return(
        statusCode: e.response?.statusCode ?? 400,
        data: e.response,
      );
    }
  }

  @override
  Future<Return> get(String url, {HttpOptions? options}) async {
    try {
      if (options?.cache == true) {
        final dynamic cacheData = await cache.getData(url);

        if (cacheData != null) {
          return Return(
            data: cacheData,
            statusCode: 200,
          );
        } else {
          final Response<dynamic> response = await dio.get(url, options: options);

          if (response.statusCode == 200) {
            await cache.saveData(url, response.data);
          }

          return Return(
            statusCode: response.statusCode,
            data: response.data,
          );
        }
      }

      final Response<dynamic> response = await dio.get(url, options: options);

      return Return(
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      return Return(
        statusCode: e.response?.statusCode ?? 400,
        data: e.response,
      );
    }
  }

  @override
  Future<Return> post(String url, Map<String, dynamic> body, {HttpOptions? options}) async {
    try {
      final Response<dynamic> response = await dio.post(url, data: body, options: options);

      return Return(
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      return Return(
        statusCode: e.response?.statusCode ?? 400,
        data: e.response,
      );
    }
  }

  @override
  Future<Return> put(String url, Map<String, dynamic> body, {HttpOptions? options}) async {
    try {
      final Response<dynamic> response = await dio.put(url, data: body, options: options);

      return Return(
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      return Return(
        statusCode: e.response?.statusCode ?? 400,
        data: e.response,
      );
    }
  }

  @override
  Future<Return> download(String url, savePath, {HttpOptions? options}) async {
    try {
      final Response<dynamic> response = await dio.download(url, savePath, options: options);

      return Return(
        statusCode: response.statusCode,
        data: response.data,
      );
    } on DioException catch (e) {
      return Return(
        statusCode: e.response?.statusCode ?? 400,
        data: e.response,
      );
    }
  }
}
