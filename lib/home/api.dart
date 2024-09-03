import '../http/index.dart';
import 'type/order.dart';
import 'package:logger/logger.dart';

Future<dynamic> fetchOrderList(int status) async {
  final httpManager = HttpManager();
  // final Order a = {} as Order;

  final onValue =
      await httpManager.get("/store/order/list", params: {"status": status});
  // var resultList = Order.fromJson();
  var resultList = onValue.data['data']['data'] as List<Order>;
  Logger(printer: PrettyPrinter(methodCount: 0)).d(resultList);
  Logger(printer: PrettyPrinter(methodCount: 0)).d(resultList is List);
  Logger(printer: PrettyPrinter(methodCount: 0)).d(resultList is Map);

  Logger(printer: PrettyPrinter(methodCount: 0)).v(">>>>>>>>>>>>>>>>>>>>>>>>>");
  return 1;

  //     .then((onValue) {
  //   if (onValue.data["code"] == 1) {
  //     var resultList = onValue.data['data']['data'];
  //     Logger(printer: PrettyPrinter(methodCount: 0)).d(resultList);
  //     Logger(printer: PrettyPrinter(methodCount: 0))
  //         .v(">>>>>>>>>>>>>>>>>>>>>>>>>");
  //     // setState(() {
  //     orders = resultList;
  //     // });
  //   } else {
  //     // Navigator.of(context).pop();
  //     // 返回登录页
  //     // 提示
  //     Fluttertoast.showToast(msg: onValue.data["message"]);
  //     Navigator.of(context).pushReplacementNamed('/login');
  //   }
  // }).catchError((onError) {
  //   Logger().e(onError);
  //   Logger().e("onError >>>>>>>>>>>>>>>>>>");
  // });
}
