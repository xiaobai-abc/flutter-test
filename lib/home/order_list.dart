import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'theme_color.dart';
import 'type/order.dart';
import 'api.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderView extends StatefulWidget {
  final int id; // 添加 id 属性

  const OrderView({super.key, required this.id}); // 接收 id 的构造函数

  @override
  OrderViewState createState() => OrderViewState();
}

class OrderViewState extends State<OrderView> {
  OrderTheme orderTheme = OrderTheme();

  List<Order> orders = [];

  final ScrollController _scrollController = ScrollController(); //listview的控制
  int page = 1;
  bool isLoading = false;

  @override
  void didUpdateWidget(OrderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 id 发生变化，则重新获取数据
    if (oldWidget.id != widget.id) {
      Logger().i("更新 ${widget.id}");
    }
  }

  @override
  void initState() {
    super.initState();
    Logger().i("初始化 ${widget.id}");
    onGetData();
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     _loadMore();
    //   }
    // });
  }

  void onGetData() async {
    fetchOrderList(widget.id).then((value) {});
  }

  Future _loadMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      Logger().i("_loadMore");

      // await Future.delayed(const Duration(seconds: 1), () {
      //   print('加载更多');
      //   setState(() {
      //     orders.addAll(List.generate(
      //         5,
      //         (i) => Order(
      //             id: orders.length + i,
      //             item: "商品A",
      //             amount: 100.0,
      //             time: '2022-12-12 12:12:12')));
      //     page++;
      //     isLoading = false;
      //   });
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 设置整体 Padding
      child: Container(
        width: double.infinity,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView.builder(
            // controller: _scrollController,
            itemCount: orders.length + 1,
            itemBuilder: (context, index) {
              if (index < orders.length) {
                return OrderItem(order: orders[index]);
              }
              return _getMoreWidget();
            },
            controller: _scrollController,
          ),
        ),
      ),
    );
  }

  Future<Null> _onRefresh() async {
    print('下拉刷新');
    await Future.delayed(const Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        // orders =
        //  List.generate(
        //     20,
        //     (i) => Order(
        //         id: 1,
        //         item: "asdasd",
        //         amount: 1.0,
        //         time: '2022-12-12 12:12:12'));
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget _getMoreWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '加载中...',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  OrderTheme orderTheme = OrderTheme();

  final Order order;

  OrderItem({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0), // 每个订单项之间的间距
      padding: const EdgeInsets.all(16.0), // 内部 padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6.0,
            offset: Offset(0, 2), // 阴影位置
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          width: 1.0, color: orderTheme.borderColor))),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("订单号:${order.number}"),
                    Text("时间:${order.created_at}"),
                  ],
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 17.0, bottom: 18.0),
                child: Text("asd")
                // Column(
                //   children: order.order_items.map((index) {
                //     return Row(
                //       children: [
                //         Image.network(
                //           "https://api-jiufu.meseelink.com/storage/images/24/0902/10/G9jo96e26eYKhNo650ThoYenGzq5qZ364mg6Lsbq.jpg",
                //           width: 100.0,
                //           height: 100.0,
                //         ),
                //         const SizedBox(width: 20.0),
                //         Column(
                //           children: [
                //             Text(order.created_at),
                //             Text("数量：${order.amount}"),
                //             Text("数量：${order.amount}"),
                //           ],
                //         )
                //       ],
                //     );
                //   }).toList(),
                // ),
                ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: orderTheme.borderColor),
                      top: BorderSide(color: orderTheme.borderColor))),
              child: const Padding(
                padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Text("asd"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6.0, horizontal: 24.0), // 添加垂直内边距
                      // minimumSize: const Size(75, 30),
                      side: BorderSide(width: 1, color: orderTheme.activeColor),
                    ),
                    child: Text(
                      "备菜",
                      style: TextStyle(color: orderTheme.activeColor)
                          .copyWith(fontSize: 14.0),
                    ),
                    onPressed: () {},
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
