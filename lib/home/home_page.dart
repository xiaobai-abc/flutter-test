import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Page'),
      ),
      body: Center(
        child: ElevatedButton(
          child: Text('Go Back to Home Page'),
          onPressed: () {
            // 使用 Navigator.pop 返回到第一个页面
            // Navigator.pop(context);
          },
        ),
      ),
    );
  }
}
