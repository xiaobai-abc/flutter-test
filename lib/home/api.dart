import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../http/index.dart';
import 'type/order.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<List<Order>> fetchOrderList(
    int status, int page, BuildContext context) async {
  final httpManager = HttpManager();

  // await httpManager.get("/store/order/list", params: {"status": status});
  return await httpManager.get("/store/order/list",
      params: {"status": status, "page": page}).then((onValue) {
    if (onValue.data["code"] == 1) {
      // 确保 resultList 是 List 类型，并进行类型转换
      var resultList = onValue.data['data']['data'] as List<dynamic>;

      // 将 resultList 转换为 Order 类型的列表
      List<Order> orders =
          resultList.map((json) => Order.fromJson(json)).toList();
      return orders;
    } else {
      // Navigator.of(context).pop();
      // 返回登录页
      // 提示
      Fluttertoast.showToast(msg: onValue.data["message"]);
      Navigator.of(context).pushReplacementNamed('/login');
      return [];
    }
  });
}

// 点击备菜
Future fetchOrderHandler({
  required int id,
  required int status,
  required BuildContext context,
}) async {
  final httpManager = HttpManager();
  return httpManager.post("/store/order/handle",
      data: {"order_id": id, "status": status}).then((onValue) {
    Logger(printer: PrettyPrinter(methodCount: 0)).i(onValue);

    if (onValue.data["code"] == 1) {
    } else {}
  });
}
