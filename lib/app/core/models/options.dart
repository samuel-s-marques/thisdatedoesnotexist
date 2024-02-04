import 'package:dio/dio.dart';

class HttpOptions extends Options {
  HttpOptions({this.cache = true, super.headers});

  bool cache;
}