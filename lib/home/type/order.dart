class OrderItem {
  final int id;
  final String goodsImage;
  final String goodsTitle; //标题
  final String goodsSkuTitle; //规格
  final String goodsSkuPrice; //价格
  final int quantity; //数量

  OrderItem({
    required this.id,
    required this.goodsImage,
    required this.goodsTitle,
    required this.goodsSkuTitle,
    required this.goodsSkuPrice,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      goodsImage: json['goods_image'],
      goodsTitle: json['goods_title'],
      goodsSkuTitle: json['goods_sku_title'],
      goodsSkuPrice: json['goods_sku_price'],
      quantity: json['quantity'],
    );
  }
}

class Order {
  final int id;
  final String amount; //商品小计
  final String freight; // 运费
  final int confirmed;
  final int status;
  final String remark;
  final String number;
  final String createdAt;
  final String payAmount; //支付钱
  final String couponAmount; //优惠活动

  List<OrderItem> orderItems;

  Order(
      {required this.createdAt,
      required this.id,
      required this.amount,
      required this.confirmed,
      required this.freight,
      required this.status,
      required this.remark,
      required this.number,
      required this.orderItems,
      required this.payAmount,
      required this.couponAmount});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      createdAt: '${json['created_at']}',
      amount: json['amount'],
      confirmed: json['confirmed'],
      freight: json['freight'],
      status: json['status'],
      remark: json['remark'],
      number: json['number'],
      payAmount: json['pay_amount'],
      couponAmount: json['coupon_amount'],
      // orderItems: json['order_items'],
      orderItems: (json['order_items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
    );
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'createdAt': createdAt,
  //     'amount': amount,
  //     'freight': freight,
  //     'status': status,
  //     'remark': remark,
  //     'number': number,
  //   };
  // }
}
