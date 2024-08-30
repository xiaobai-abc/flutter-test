import 'package:dio/dio.dart';

class HttpManager {
  final _dio = Dio();

  HttpManager() {
    _dio.options.baseUrl = 'http://192.168.1.106:3000/api';
    _dio.interceptors.add(LogInterceptor());
  }
  // 提供一个静态方法来获取实例
  static HttpManager get instance => HttpManager();

  // 取消请求
  static CancelToken createCancelToken() {
    return CancelToken();
  }

  // get 请求
  Future<Response> get(String url,
      {Map<String, dynamic>? params, CancelToken? cancelToken}) async {
    return await _dio.get(url,
        queryParameters: params, cancelToken: cancelToken);
  }

  // post 请求
  Future<Response> post(String url,
      {Map<String, dynamic>? data, CancelToken? cancelToken}) async {
    return await _dio.post(url, data: data, cancelToken: cancelToken);
  }

  // put 请求
  Future<Response> put(String url,
      {required Map<String, dynamic> data,
      required CancelToken cancelToken}) async {
    return await _dio.put(url, data: data, cancelToken: cancelToken);
  }

  // delete 请求
  Future<Response> delete(String url,
      {required CancelToken cancelToken}) async {
    return await _dio.delete(url, cancelToken: cancelToken);
  }

  // 取消请求
  void cancelRequests(CancelToken cancelToken) {
    cancelToken.cancel("请求已被取消");
  }
}
