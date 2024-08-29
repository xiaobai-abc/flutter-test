import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:http/http.dart' as http; // 导入 http 库以发送网络请求

import 'dart:convert'; // 用于 json 编码和解码

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        Positioned.fill(
          child: Image.network(
              'http://jiufu-admin.meseelink.com/storage/images/background.jpg',
              fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.white,
            );
          }),
        ),
        Center(
          //  ElevatedButton(
          //   child: Text('Go to home page'),
          //   onPressed: () {
          //     // 使用 Navigator.push 跳转到第二个页面
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (context) => HomePage()),
          //     );
          //   },
          // )
          child: FormBlock(),
        ),
      ],
    ));
  }
}

class FormBlock extends StatefulWidget {
  @override
  _FormBlockState createState() => _FormBlockState();
}

class _FormBlockState extends State<FormBlock> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('账号密码登录',
            style:
                TextStyle(color: Color.fromRGBO(0, 0, 0, 1.0), fontSize: 20)),
        const SizedBox(height: 20),
        Container(
          // 上 46 下30 左右26
          padding: const EdgeInsets.only(
            top: 46.0, // 顶部填充
            bottom: 60.0, // 底部填充
            left: 26, // 左侧填充
            right: 26, // 右侧填充
          ),
          width: 440,
          // margin: const EdgeInsets.symmetric(horizontal: 30.0), // 左右边距
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              // obscureText: true,
              controller: usernameController,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*')),
              ],
              decoration: const InputDecoration(
                  labelText: "账号", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 28),
            TextField(
              obscureText: true,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*')),
              ],
              decoration: const InputDecoration(
                  labelText: "密码", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 40),
            SubmitButton(
              usernameController: usernameController,
              passwordController: passwordController,
            ),
          ]),
        )
      ],
    );
  }
}

class SubmitButton extends StatelessWidget {
  // final VoidCallback onSubmit;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  SubmitButton({
    // required this.onSubmit,
    required this.usernameController,
    required this.passwordController,
  });
  // 提交功能
  Future<void> _submit(BuildContext context) async {
    // 跳转到第二个页面
    print(">>>>>>>>>>>>>>>>>>>>>>:run _submit");
    print("username: ${usernameController.text}");
    print("password: ${passwordController.text}");
  }

  // 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('错误'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _submit(context), // 点击按钮时调用提交功能

      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(224, 37, 31, 1.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0), // 设置圆角
        ),
        fixedSize: const Size.fromWidth(10000),
        padding: const EdgeInsets.symmetric(vertical: 16), // 按钮内边距
      ),
      child: const Text(
        '立即登陆',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
