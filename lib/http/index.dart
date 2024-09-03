import 'package:dio/dio.dart';
import 'package:jiufu/modules/error_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

class HttpManager {
  final _dio = Dio();

  HttpManager() {
    _dio.options.baseUrl = 'https://api-jiufu.meseelink.com';
    // _dio.options.baseUrl = 'http://192.168.1.106:3000';
    _dio.interceptors.add(LogInterceptor());

    _dio.interceptors.add(RequestInterceptors());
  }
  // 提供一个静态方法来获取实例
  static HttpManager get instance => HttpManager();

  // 取消请求
  static CancelToken createCancelToken() {
    return CancelToken();
  }

  // // get 请求
  // Future<Response> get(String url,
  //     {Map<String, dynamic>? params, CancelToken? cancelToken}) async {
  //   return await _dio.get(url,
  //       queryParameters: params, cancelToken: cancelToken);
  // }
  // get 请求
  Future<Response> get<T>(String url,
      {Map<String, dynamic>? params,
      CancelToken? cancelToken,
      Options? options}) async {
    Options requestOptions = options ?? Options();
    return await _dio.get<T>(url,
        queryParameters: params,
        cancelToken: cancelToken,
        options: requestOptions);
  }

  // post 请求
  Future<Response> post(String url,
      {Map<String, dynamic>? data,
      CancelToken? cancelToken,
      Options? options}) async {
    Options requestOptions = options ?? Options();
    return await _dio.post(url,
        data: data, cancelToken: cancelToken, options: requestOptions);
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

class RequestInterceptors extends Interceptor {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
    ),
  );

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // http header 头加入 Authorization
    //  options.headers["Authorization"] = "Bearer 123";
    // 请求头添加token
    // String? token = SharedPreferencesService.instance.getString("token");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString("token");
    if (token != null) options.headers["Authorization"] = "Bearer $token";
    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    _logger.e(response);
    _logger.e("响应拦截>>>>>>>>>>>>>>");

    if (response.statusCode != 200 && response.statusCode != 201) {
      handler.reject(DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse));
    } else {
      if (response.data['code'] == 401) {
        // 清除token
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove("token");
        
      }

      return handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // final exception = HttpException(err.message ?? "error message");
    Logger().d(err);
    Logger().d("进入 onERROR");
    switch (err.type) {
      case DioExceptionType.badResponse:
        {
          final response = err.response;
          final errorMessage = ErrorMessageModel.fromJson(response?.data);
          switch (errorMessage.statusCode) {
            case 401:
              break;
            case 500:
              break;
            case 404:
              break;
            case 502:
              _logger.e(errorMessage.error ??
                  errorMessage.message ??
                  "error message");
              break;
          }
        }
        break;

      case DioExceptionType.cancel:
        break;

      case DioExceptionType.connectionTimeout:
        break;

      case DioExceptionType.unknown:
        break;

      default:
        break;
    }
  }
}
