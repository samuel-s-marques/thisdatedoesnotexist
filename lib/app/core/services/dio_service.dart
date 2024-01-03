import 'package:dio/dio.dart';
import 'package:thisdatedoesnotexist/app/core/services/cache_service.dart';

class DioOptions extends Options {
  DioOptions({this.cache = true, super.headers});

  bool cache;
}

class DioService {
  factory DioService() {
    return _instance;
  }

  DioService._internal();
  static final Dio _dio = Dio();
  static Dio get dio => _dio;
  static final DioService _instance = DioService._internal();
  final CacheService cache = CacheService();

  Future<Response<dynamic>> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.post(path, data: data, options: options);
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> get(
    String path, {
    DioOptions? options,
  }) async {
    try {
      if (options?.cache == true) {
        final dynamic cacheData = await cache.getData(path);

        if (cacheData != null) {
          return Response(
            data: cacheData,
            requestOptions: RequestOptions(),
            statusCode: 200,
          );
        } else {
          final Response<dynamic> response = await _dio.get(path, options: options);

          if (response.statusCode == 200) {
            await cache.saveData(path, response.data);
          }

          return response;
        }
      }

      return await _dio.get(path, options: options);
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> put(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    try {
      return await _dio.put(path, data: data);
    } on DioException catch (e) {
      return e.response!;
    }
  }

  Future<Response<dynamic>> delete(
    String path, {
    Options? options,
  }) async {
    try {
      return await _dio.delete(path, options: options);
    } on DioException catch (e) {
      return e.response!;
    }
  }
}
