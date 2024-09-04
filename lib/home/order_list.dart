import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'type/theme_color.dart';
import 'type/order.dart';
import 'api.dart';
import 'modules/toast_loading.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderView extends StatefulWidget {
  final int id; // 添加 id 属性

  const OrderView({super.key, required this.id}); // 接收 id 的构造函数

  @override
  OrderViewState createState() => OrderViewState();
}

class OrderViewState extends State<OrderView> {
  OrderTheme orderTheme = OrderTheme();
  final ScrollController _scrollController = ScrollController();

  List<Order> orders = [];
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMoreData = true;
  bool canLoadMore = true;

  @override
  void didUpdateWidget(OrderView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 id 发生变化，则重新获取数据
    if (oldWidget.id != widget.id) {
      setState(() {
        currentPage = 1;
        isLoadingMore = false;
        hasMoreData = true;
        canLoadMore = true;
        orders = [];
      });
      onGetData();
    }
  }

  @override
  void initState() {
    super.initState();
    Logger(printer: PrettyPrinter(methodCount: 0))
        .i("initState >>>>>>>>>>>>>>>>>>>>>>>>>> ${widget.id}");
    onGetData();
  }

  void onGetData() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });
    // 第一层获取数据
    fetchOrderList(widget.id, currentPage, context).then((value) {
      setState(() {
        if (value.length < 10) {
          hasMoreData = false;
        }
        orders = value;
        isLoadingMore = false;
      });

      Logger(printer: PrettyPrinter(methodCount: 0))
          .i("获取数据成功 >>>>>>>>>>>>>>>>>>>>>");
    });
  }

  // 加载更多订单
  void loadMoreOrders() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    List<Order>? moreOrders =
        await fetchOrderList(widget.id, currentPage + 1, context);

    setState(() {
      if (moreOrders.length < 10) {
        currentPage++;
        hasMoreData = false;
      }
      orders.addAll(moreOrders);
      isLoadingMore = false;
      canLoadMore = true;
    });
  }

  // 检查是否到达列表底部
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        canLoadMore) {
      canLoadMore = false;
      Logger(printer: PrettyPrinter(methodCount: 0))
          .i("到底了 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      loadMoreOrders();
    }

    // if (_scrollController.position.pixels >=
    //     _scrollController.position.maxScrollExtent - 100) {

    //   //
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 设置整体 Padding
      child: SizedBox(
        width: double.infinity,
        child: ListView.builder(
          controller: _scrollController..addListener(_onScroll),
          itemCount: orders.length + 1,
          itemBuilder: (context, index) {
            if (index < orders.length) {
              return OrderItemWidget(
                order: orders[index],
                onHandlerFuncton: () {
                  Logger(printer: PrettyPrinter(methodCount: 0))
                      .i("点击了 >>>>>>>>>>>>>>>>>>>>>>>>>> ${orders[index].id}");
                  setState(() {
                    currentPage = 1;
                    hasMoreData = true;
                    orders = [];
                  });
                  onGetData();
                },
              );
            }
            return _getMoreWidget();
          },
        ),

        //  RefreshIndicator(
        //   onRefresh: _onRefresh,
        //   child: ,
        // ),
      ),
    );
  }

  // Future<Null> _onRefresh() async {
  //   Logger(printer: PrettyPrinter(methodCount: 0)).i("'下拉刷新 >>>>>>>>>>>>>'");
  // }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isLoadingMore) ...[
              const Text(
                '加载中...',
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(width: 10.0),
              const SizedBox(
                width: 16.0,
                height: 16.0,
                child: CircularProgressIndicator(
                  strokeWidth: 1.0,
                ),
              )
            ],
            if (!hasMoreData) ...[
              const Text("没有更多了", style: TextStyle(fontSize: 16.0)),
            ]
          ],
        ),
      ),
    );
  }
}

class OrderItemWidget extends StatelessWidget {
  final OrderTheme orderTheme = OrderTheme();
  final Order order;
  // 父级的方法
  final void Function()? onHandlerFuncton;

  OrderItemWidget({super.key, required this.order, this.onHandlerFuncton});

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
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("订单号:${order.number}"),
                  Text("创建时间:${order.createdAt}"),
                ],
              ),
            ),
            Divider(
              color: orderTheme.borderColor,
              thickness: 1.0,
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 17.0, bottom: 18.0),
              child: Column(
                children: order.orderItems.map((OrderItem orderItem) {
                  return Row(
                    children: [
                      Image.network(
                        orderItem.goodsImage,
                        width: 100.0,
                        height: 100.0,
                      ),
                      const SizedBox(width: 20.0),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            orderItem.goodsTitle,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: orderTheme.titleColor,
                            ),
                          ),
                          const SizedBox(height: 12.0),
                          Text(
                            "规格: ${orderItem.goodsSkuTitle}",
                            style: TextStyle(
                                fontSize: 13.0, color: orderTheme.specColor),
                          ),
                          const SizedBox(height: 8.0),
                          Text("数量: ${orderItem.quantity}",
                              style: TextStyle(
                                  fontSize: 13.0, color: orderTheme.specColor)),
                        ],
                      )
                    ],
                  );
                }).toList(),
              ),
            ),
            Divider(
              color: orderTheme.borderColor, // 线的颜色
              thickness: 1.0, // 线的粗细
              height: 0,
            ),
            SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Text(order.remark),
              ),
            ),
            Divider(
              color: orderTheme.borderColor, // 线的颜色
              thickness: 1.0, // 线的粗细
              height: 0,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (order.confirmed == 1)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 24.0), // 添加垂直内边距
                        side:
                            BorderSide(width: 1, color: orderTheme.activeColor),
                      ),
                      child: Text(
                        "备菜",
                        style: TextStyle(color: orderTheme.activeColor)
                            .copyWith(fontSize: 14.0),
                      ),
                      onPressed: () {
                        // 点击备菜
                        LoadingExample().showLoadingDialog(context);

                        fetchOrderHandler(
                                id: order.id, status: 2, context: context)
                            .then((resp) {
                          Logger(printer: PrettyPrinter(methodCount: 0))
                              .i("点击备菜 >>>>>>>>>>>> ${resp.toString()}");

                          if (resp != null) {
                            Fluttertoast.showToast(msg: "备菜成功~");
                            onHandlerFuncton!();
                          }

                          Logger(printer: PrettyPrinter(methodCount: 0))
                              .i("点击备菜 >>>>>>>>>>>> 处理结束");

                          Navigator.of(context).pop();
                        });
                      },
                    ),
                  if (order.confirmed == 2)
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 6.0, horizontal: 24.0),
                        side:
                            BorderSide(width: 1, color: orderTheme.activeColor),
                      ),
                      child: Text(
                        "出菜",
                        style: TextStyle(color: orderTheme.activeColor)
                            .copyWith(fontSize: 14.0),
                      ),
                      onPressed: () {
                        // 出菜
                        LoadingExample().showLoadingDialog(context);
                        fetchOrderHandler(
                                id: order.id, status: 3, context: context)
                            .then((resp) {
                          Logger(printer: PrettyPrinter(methodCount: 0))
                              .i("点击出菜 >>>>>>>>>>>> ${resp.toString()}");

                          if (resp != null) {
                            Fluttertoast.showToast(msg: "出菜成功~");
                            onHandlerFuncton!();
                          }

                          Logger(printer: PrettyPrinter(methodCount: 0))
                              .i("点击出菜 >>>>>>>>>>>>  处理结束");
                          Navigator.of(context).pop();
                        });
                      },
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
