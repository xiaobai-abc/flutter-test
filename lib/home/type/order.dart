class OrderItems {
  final int id;
  final String goods_title; //标题
  final String goods_sku_title; //规格
  final String goods_sku_price; //价格
  final int quantity; //数量

  OrderItems({
    required this.id,
    required this.goods_title,
    required this.goods_sku_title,
    required this.goods_sku_price,
    required this.quantity,
  });
}

class Order {
  final int id;
  final String amount;
  final String freight;
  final int status;
  final String remark;
  final String number;
  final String created_at;

  // final List<OrderItems> order_items;

  Order({
    required this.created_at,
    required this.id,
    required this.amount,
    required this.freight,
    required this.status,
    required this.remark,
    required this.number,
    // required this.order_items,
  });

  // 从 JSON 转换为 User 对象
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'], created_at: '${json['created_at']}',
      amount: json['amount'],
      freight: json['freight'],
      status: json['status'],
      remark: json['remark'],
      number: json['number'],
      // order_items: json['order_items'],
    );
  }

  // 将 User 对象转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created_at': created_at,
      'amount': amount,
      'freight': freight,
      'status': status,
      'remark': remark,
      'number': number,
    };
  }
}
