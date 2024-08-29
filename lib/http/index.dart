import 'package:dio/dio.dart';

class HttpManager {
  static Dio _dio;

  static Dio getInstance() {
    if (_dio == null) {
      _dio = Dio();
      // 配置 Dio 实例
      _dio.options.baseUrl = 'https://api.example.com/';
      _dio.interceptors.add(LogInterceptor());
    }
    return _dio;
  }

  // get 请求
  static Future<Response> get(String url,
      {Map<String, dynamic> params, CancelToken cancelToken}) async {
    return await _dio.get(url,
        queryParameters: params, cancelToken: cancelToken);
  }

  // post 请求
  static Future<Response> post(String url,
      {Map<String, dynamic> data, CancelToken cancelToken}) async {
    return await _dio.post(url, data: data, cancelToken: cancelToken);
  }

  // put 请求
  static Future<Response> put(String url,
      {Map<String, dynamic> data, CancelToken cancelToken}) async {
    return await _dio.put(url, data: data, cancelToken: cancelToken);
  }

  // delete 请求
  static Future<Response> delete(String url, {CancelToken cancelToken}) async {
    return await _dio.delete(url, cancelToken: cancelToken);
  }

  // 取消请求
  static void cancelRequests(CancelToken cancelToken) {
    cancelToken.cancel("请求已被取消");
  }
}
