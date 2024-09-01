import 'package:flutter/material.dart';

class Order {
  final int id;
  final String item;
  final double amount;

  Order({required this.id, required this.item, required this.amount});
}

class OrderViewState extends StatefulWidget {
  const OrderViewState({super.key});

  @override
  _OrderViewState createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderViewState> {
  List<Order> orders = [
    Order(id: 1, item: "商品A", amount: 100.0),
    Order(id: 2, item: "商品B", amount: 200.0),
    Order(id: 3, item: "商品C", amount: 150.0),
    Order(id: 4, item: "商品D", amount: 300.0),
  ];
  ScrollController _scrollController = ScrollController(); //listview的控制
  int _page = 1;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMore();
      }
    });
  }

  Future _loadMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(const Duration(seconds: 1), () {
        print('加载更多');
        setState(() {
          orders.addAll(List.generate(5,
              (i) => Order(id: orders.length + i, item: "商品A", amount: 100.0)));
          _page++;
          isLoading = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0), // 设置整体 Padding
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1.0),
        ),
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
    await Future.delayed(Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        orders =
            List.generate(20, (i) => Order(id: 1, item: "asdasd", amount: 1.0));
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
          children: <Widget>[
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
  final Order order;

  const OrderItem({super.key, required this.order});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("订单 ID: ${order.id}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8.0), // 垂直间距
          Text("商品名称: ${order.item}", style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8.0), // 垂直间距
          Text("金额: ¥${order.amount.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16, color: Colors.green)),
        ],
      ),
    );
  }
}
