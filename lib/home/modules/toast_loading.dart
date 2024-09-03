import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LoadingExample {
  void showLoadingDialog(BuildContext context) {
    //  Navigator.of(context).pop(); // 关闭对话框
    showDialog(
      context: context,
      barrierDismissible: false, // 点击外部是否可以关闭对话框
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center, // 水平居中
                  children: [
                    SizedBox(
                      width: 24.0,
                      height: 24.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0, // 增加指示器粗细
                      ),
                    ), // 加载指示器
                    SizedBox(width: 20), // 间距
                    Align(
                      alignment: Alignment.center, // 垂直居中
                      child: Text("加载中..."), // 加载文本
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
