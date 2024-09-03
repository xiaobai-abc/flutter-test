import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../http/index.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

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
        const Center(
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
  const FormBlock({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _FormBlockState createState() => _FormBlockState();
}

class _FormBlockState extends State<FormBlock> {
  final usernameController = TextEditingController(text: '17666662384');
  final passwordController = TextEditingController(text: 'fat880718');

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
              controller: passwordController,
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
  final httpManager = HttpManager();

  final snackBar = const SnackBar(content: Text(""));
  SubmitButton({
    super.key,
    // required this.onSubmit,
    required this.usernameController,
    required this.passwordController,
  });
  // 提交功能
  Future<void> _submit(BuildContext context) async {
    const url = "/store/login";
    final data = {
      "phone": usernameController.text,
      "password": passwordController.text
    };

    if (data["phone"]!.isNotEmpty && data["password"]!.isNotEmpty) {
      httpManager.post(url, data: data).then((onValue) async {
        final resp = onValue.data;
        if (resp["code"] == 1) {
          final token = resp['data']['token'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('token', token);
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          Fluttertoast.showToast(msg: onValue.data["message"]);
        }
      }).catchError((err) {
        Logger().e(err);
      });
    } else {
      if (data["username"]!.isEmpty) {
        print("Username 为空");
      }
      if (data["password"]!.isEmpty) {
        print("Password 为空");
      }
      _showErrorDialog(context, "账号或密码不能为空");
    }
  }

  // 显示错误对话框
  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // title: const Text('错误'),
        content: Text(message),
        actions: [
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
