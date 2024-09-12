import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'order_list.dart';
import 'type/order.dart';
import 'type/theme_color.dart';
import './modules/modal_bluetooth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';
import 'api.dart';
import 'dart:io';

class HomeData extends InheritedWidget {
  final int updateCount;
  final Function(dynamic) handelUpdateFun;

  const HomeData({
    super.key,
    required this.updateCount,
    required this.handelUpdateFun,
    required super.child,
  });

  static HomeData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HomeData>();
  }

  @override
  bool updateShouldNotify(HomeData oldWidget) {
    return updateCount != oldWidget.updateCount;
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  bool _isConnected = false; // 是否已经连接蓝牙
  bool _hasTryAgain = false; // 是否允许尝试 再次连接

  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  late WebSocket _socket;
  int updateCount = 1;

  dynamic handelUpdateFun(dynamic a) {
    setState(() {
      updateCount++;
    });
  }

  @override
  void initState() {
    super.initState();
    Logger(printer: PrettyPrinter(methodCount: 0))
        .v("初始化:>>>>>>>>>>>>>>>>>>>>>.执行");
    _hasTryAgain = true;
    initBlueToothState();
    initSocket();
  }

  void initSocket() async {
    // 更新order
    // HomeData.of(context)?.handelUpdateFun((counter ?? 1) + 1);

    try {
      _socket = await WebSocket.connect(
          "wss://api-jiufu.meseelink.com/socketurla?token=YsoqE5xfBEac&store_id=1");

      if (_socket.readyState == WebSocket.open) {
        Fluttertoast.showToast(msg: "连接成功~~~");
        Logger(printer: PrettyPrinter(methodCount: 0))
            .v("连接成功 >>>>>>>>>>>>>>>>>>>>  ");

        // ========================

        _socket.listen((data) {
          Logger(printer: PrettyPrinter(methodCount: 0))
              .v("接收到消息 >>>>>>>>>>>>>>>>>>>> $data");
          if (data != null) {
            final Order orderResult = Order.fromJson(jsonDecode(data));
            // 获取数据 执行打印
            handPrint(orderResult);
          }
        }, onError: (error) {
          Logger(printer: PrettyPrinter(methodCount: 0))
              .e("错误 >>>>>>>>>>>>>>>>>>>>>>>> $error");
        }, onDone: () {
          Logger(printer: PrettyPrinter(methodCount: 0)).e("【WebSocket】结束链接");
          trySocket();
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "连接失败~~~");

      Logger(printer: PrettyPrinter(methodCount: 0))
          .e("连接失败 >>>>>>>>>>>>>>>>>>  ${e}");
      trySocket();
    }
  }

  void trySocket() async {
    if (!_hasTryAgain) {
      // false 禁止再次尝试
      return;
    }
    // 延迟 3 秒后执行操作
    Future.delayed(const Duration(seconds: 15), () {
      Logger(printer: PrettyPrinter(methodCount: 0)).e("执行重新连接");
      initSocket();
    });
  }

  void initBlueToothState() async {
    // 先获取初始状态
    bool isConnected = await bluetoothPrint.isConnected ?? false;

    setState(() {
      _isConnected = isConnected;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _socket.close();
    _hasTryAgain = false; //拒接再次尝试
  }

  // 打印机输出
  void handPrint(Order? order) async {
    Map<String, dynamic> config = {};
    List<LineText> list = [];

    bool isConnected = await bluetoothPrint.isConnected ?? false;
    if (isConnected != _isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    }
    if (!isConnected) {
      Fluttertoast.showToast(msg: "无设备连接 取消打印");
      return;
    }

    // config['width'] = 20;
    // config['height'] = 70;
    // config['gap'] = 10;

    if (order == null) {
      Fluttertoast.showToast(
        msg: "无订单信息 取消打印",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: const Color(0xFFf17f7d),
        textColor: Colors.white,
        fontSize: 16.0,
        timeInSecForIosWeb: 1,
        webPosition: "center", // 用于网页的精确位置
      );
      return;
    }

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '玖福团膳智慧餐厅',
      weight: 2,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    // 分隔线
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '********************************\n',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    // 订单编号
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '订单编号: ${order.number}',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '下单时间: ${order.createdAt}',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '商品名称---------数量-------金额\n',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // 商品内容

    for (OrderItem item in order.orderItems) {
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: formatLine(
            item.goodsTitle, item.quantity, double.parse(item.goodsSkuPrice)),
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
      list.add(LineText(
        type: LineText.TYPE_TEXT,
        content: "${item.goodsSkuTitle} \n",
        weight: 1,
        align: LineText.ALIGN_LEFT,
        linefeed: 1,
      ));
    }

    // list.add(LineText(
    //   type: LineText.TYPE_TEXT,
    //   content: '麻婆豆腐        1      18   18',
    //   weight: 1,
    //   align: LineText.ALIGN_LEFT,
    //   linefeed: 1,
    // ));

    // 分隔线
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '\n------------------------------',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '商品小计: ${order.amount}',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '运费: ${order.freight}',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '优惠: ${order.couponAmount}',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '合计: ${order.payAmount}',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '支付方式: 在线支付',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '备注: ${order.remark}',
      weight: 2,
      align: LineText.ALIGN_LEFT,
      linefeed: 1,
    ));

    // 结语
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '\n谢谢惠顾！欢迎下次光临！',
      weight: 1,
      align: LineText.ALIGN_CENTER,
      linefeed: 1,
    ));

    // 分隔线
    // list.add(LineText(
    //   type: LineText.TYPE_TEXT,
    //   content: '********************************\n',
    //   weight: 1,
    //   align: LineText.ALIGN_CENTER,
    //   linefeed: 1,
    // ));

    // 空行
    list.add(LineText(
      type: LineText.TYPE_TEXT,
      content: '\x1B\x64\x05',
      weight: 1,
      align: LineText.ALIGN_LEFT,
      linefeed: 2,
    ));

    // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    // String base64Image = base64Encode(imageBytes);

    bluetoothPrint.printReceipt(config, list).then((onValue) {
      // Logger(printer: PrettyPrinter(methodCount: 0))
      //     .e("打印完成 >>>>>>>>>>>>>>>>>>>");
      // Fluttertoast.showToast(msg: "打印完成");

      try {
        _socket.add("${order.id}:ok");
        Fluttertoast.showToast(msg: "发送成功");
      } catch (e) {
        // Fluttertoast.showToast(msg: "订单打印失败~~~");
      }
      setState(() {
        updateCount++;
      });
    }, onError: (error) {
      //  Fluttertoast.showToast(msg: "打印完成");
      Logger(printer: PrettyPrinter(methodCount: 0))
          .e("error >>>>>>>>>>>>>>>>>>> ${error.toString()}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60, // 设置 AppBar 高度
        automaticallyImplyLeading: false,

        title: Padding(
          padding: const EdgeInsets.only(left: 40.0), // 左侧 Padding
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png', // 替换为你的 logo 路径
                height: 32, // Logo 高度
              ),
              const SizedBox(width: 8), // Logo 和标题之间的间距
              const Text(
                'Title',
                style: TextStyle(fontSize: 20), // 设置标题样式
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.print_outlined),
          ),

          const SizedBox(width: 16), // 两个图标之间的间距
          TextButton.icon(
            onPressed: () {
              _show(context); //调用底部弹框
            },
            style: TextButton.styleFrom(
              foregroundColor:
                  _isConnected ? Colors.blue : const Color(0xFF333333),
              textStyle: const TextStyle(fontSize: 14),
            ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('打印机'),
          ),

          const SizedBox(width: 16), // 两个图标之间的间距
          TextButton(
            onPressed: () {
              fetchLogout(context).then((v) {
                // 点击按钮时导航到登录页面，并移除所有之前的路由
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false);
                // 断开蓝牙
                bluetoothPrint.disconnect();
                _socket.close();
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF828282),
              textStyle: const TextStyle(fontSize: 14),
            ),
            child: const Text('退出登录'),
          ),
          const SizedBox(width: 40), // 设置右侧间距
        ],
      ),
      body: HomeData(
        updateCount: updateCount,
        handelUpdateFun: handelUpdateFun,
        child: BodyView(),
      ),
    );
  }

  Future<int?> _show(BuildContext context) async {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => ModalBluetooth(
              onHandCallback: (bool vbool) {
                Logger(printer: PrettyPrinter(methodCount: 0))
                    .e("onHandCallback: $vbool");
                setState(() {
                  _isConnected = vbool;
                });
              },
            ));
  }

  String formatLine(
    String name,
    int quantity,
    double price,
  ) {
    // 每个部分的最大字符宽度
    int quantityWidth = 5; // 数量宽度
    int priceWidth = 6; // 单价宽度
    // int totalAmountWidth = 6; // 小计宽度
    int totalWidth = 32;

    // 计算菜品名称的可用宽度
    int nameWidth = totalWidth - quantityWidth - priceWidth;
    // - totalAmountWidth;

    // 处理中文字符占两位的情况
    int nameCharCount = 0;
    StringBuffer formattedName = StringBuffer();

    for (int i = 0; i < name.length; i++) {
      String char = name[i];
      if (RegExp(r'[\u4e00-\u9fa5]').hasMatch(char)) {
        // 中文字符占两位
        nameCharCount += 2;
      } else {
        // 英文字符占一位
        nameCharCount += 1;
      }

      // 控制输出的字符数量，使之不超过可用宽度
      if (nameCharCount <= nameWidth) {
        formattedName.write(char);
      } else {
        break; // 超过宽度限制，退出循环
      }
    }

    // 补足菜品名称的空格
    formattedName.write(' ' * (nameWidth - nameCharCount));

    // 格式化其他部分
    String quantityStr = quantity.toString().padLeft(quantityWidth, ' ');
    String priceStr = price.toStringAsFixed(2).padLeft(priceWidth, ' ');
    // String totalStr = total.toStringAsFixed(2).padLeft(totalAmountWidth, ' ');

    // 拼接各部分，形成完整的行
    return formattedName.toString() + quantityStr + priceStr;
    // + totalStr;
  }
}

// 内容
class BodyView extends StatefulWidget {
  const BodyView({
    super.key,
  });

  @override
  BodyViewState createState() => BodyViewState();
}

class BodyViewState extends State<BodyView> {
  // 颜色
  final themeColor = ThemeColor();

  // 用于跟踪哪个文本被聚焦
  final List<TextBlock> _testList = [
    TextBlock(id: 1, text: "待处理", num: 10),
    TextBlock(id: 2, text: "备菜中", num: 20),
    TextBlock(id: 3, text: "已完成", num: 30),
  ];

  int _focusedId = 1;

  void _handClickTest(int id) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        // 切换该项的聚焦状态
        _focusedId = id;
        // 通过 GlobalKey 访问当前渲染的 OrderViewState 实例
        // widget.orderViewKey.currentState?.setOrderStatus(id);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 使用 of 方法获取 InheritedWidget 的实例对象
    final counter = HomeData.of(context)?.updateCount;
    return Column(children: [
      Container(
        color: themeColor.bgColor,
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_testList.length, (index) {
            return TextButton(
              onPressed: () {
                _handClickTest(_testList[index].id);
              },
              child: Text(
                // (${_testList[index].num})
                _testList[index].text,
                style: TextStyle(
                  color: _focusedId == _testList[index].id
                      ? themeColor.activeColor
                      : themeColor.textColor, // 根据聚焦状态设置颜色
                  fontSize: 14,
                ),
              ),
            );
          }),
        ),
      ),
      Expanded(
        child: OrderView(
          id: _focusedId,
          updateCount: counter ?? 1,
        ),
      )
    ]);
  }
}

class TextBlock {
  final int id;
  final String text;
  final int num;
  TextBlock({required this.id, required this.text, required this.num});
}
