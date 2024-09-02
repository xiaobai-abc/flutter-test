import 'package:flutter/material.dart';

class ThemeColor {
  final Color activeColor = const Color(0xFFE60012);
  final Color textColor = const Color(0xFF4f4f4f);
  final Color bgColor = const Color(0xFFFFFFFF);
  final Color borderColor = const Color(0xFFBDBDBD);
}

class OrderTheme extends ThemeColor {
  // 订单标题
  final Color titleColor = const Color(0xFF333333);
  // 订单规格
  final Color specColor = const Color(0xFF828282);
  // 订单备注
  Color get remarkColor => textColor; // 使用 getter 来返回父类的 textColor
  // late final Color remarkColor;

  // OrderTheme(this.remarkColor) {
  //   remarkColor = textColor;
  // }
}
