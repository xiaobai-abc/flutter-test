/*
 * Created by 李卓原 on 2018/9/13.
 * email: zhuoyuan93@gmail.com
 *
 */
import 'package:flutter/material.dart';

class Order {
  final int id;
  final String item;
  final double amount;

  Order({required this.id, required this.item, required this.amount});
}

class TestHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Column(
        children: [
          Expanded(
            child: OrderViewState(),
          )
        ],
      ),
    );
  }
}

class OrderViewState extends StatefulWidget {
  @override
  _OrderViewState createState() => new _OrderViewState();
}

class _OrderViewState extends State<OrderViewState> {
  List<Order> list = [
    Order(id: 1, item: "商品A", amount: 100.0),
    Order(id: 2, item: "商品B", amount: 200.0),
    Order(id: 3, item: "商品C", amount: 150.0),
    Order(id: 4, item: "商品D", amount: 300.0),
  ]; //列表要展示的数据
  ScrollController _scrollController = ScrollController(); //listview的控制器
  int _page = 1; //加载的页数
  bool isLoading = false; //是否正在加载数据

  @override
  void initState() {
    super.initState();
    getData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('滑动到了最底部');
        _getMore();
      }
    });
  }

  /**
   * 初始化list数据 加延时模仿网络请求
   */
  Future getData() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        list = List.generate(
            15, (i) => Order(id: list.length + i, item: "商品A", amount: 100.0));
      });
    });
  }

  Widget _renderRow(BuildContext context, int index) {
    if (index < list.length) {
      return OrderItem(order: list[index]);
    }
    return _getMoreWidget();
  }

  /**
   * 下拉刷新方法,为list重新赋值
   */
  Future<Null> _onRefresh() async {
    await Future.delayed(Duration(seconds: 3), () {
      print('refresh');
      setState(() {
        list = List.generate(
            20, (i) => Order(id: list.length + i, item: "商品A", amount: 100.0));
      });
    });
  }

  /**
   * 上拉加载更多
   */
  Future _getMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      await Future.delayed(Duration(seconds: 1), () {
        print('加载更多');
        setState(() {
          list.addAll(List.generate(5,
              (i) => Order(id: list.length + i, item: "加载更多", amount: 100.0)));
          _page++;
          isLoading = false;
        });
      });
    }
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

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        itemBuilder: _renderRow,
        itemCount: list.length + 1,
        controller: _scrollController,
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
