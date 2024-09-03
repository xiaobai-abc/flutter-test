import 'package:flutter/material.dart';
// import 'package:logger/logger.dart';
import 'order_list.dart';
import 'type/theme_color.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyAppState();
}

class _MyAppState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  Future<int?> _show(BuildContext context) async {
    return showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isDismissible: true,
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) => const Text("adasd"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 247, 247, 247),
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 60, // 设置 AppBar 高度
        automaticallyImplyLeading: false,

        title: Padding(
          padding: const EdgeInsets.only(left: 40.0), // 左侧 Padding
          child: Row(
            children: [
              Image.asset(
                'assets/logo.png', // 替换为你的 logo 路径
                height: 32, // Logo 高度
              ),
              const SizedBox(width: 8), // Logo 和标题之间的间距
              const Text(
                'Title',
                style: TextStyle(fontSize: 20), // 设置标题样式
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              _show(context); //调用底部弹框
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF828282),
              textStyle: const TextStyle(fontSize: 14),
            ),
            icon: const Icon(Icons.print_outlined),
            label: const Text('打印机'),
          ),

          const SizedBox(width: 16), // 两个图标之间的间距
          TextButton(
            onPressed: () {
              // 点击按钮时导航到登录页面，并移除所有之前的路由
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/', (route) => false);
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF828282),
              textStyle: const TextStyle(fontSize: 14),
            ),
            child: const Text('退出登录'),
          ),
          const SizedBox(width: 40), // 设置右侧间距
        ],
      ),
      body: BodyView(),

      // Container(
      //   width: double.infinity,
      //   height: double.infinity,
      //   decoration: const BoxDecoration(
      //     // border: Border.all(color: Colors.blue, width: 2), // 设置边框颜色和宽度
      //     border: Border(top: BorderSide(color: Color(0xFFF2F2F2), width: 1.0)),
      //   ),
      //   child: ,
      // ),
    );
  }
}

// 内容
class BodyView extends StatefulWidget {
  const BodyView({super.key});
  @override
  BodyViewState createState() => BodyViewState();
}

class BodyViewState extends State<BodyView> {
  // 颜色
  final themeColor = ThemeColor();

  // 用于跟踪哪个文本被聚焦
  final List<TextBlock> _testList = [
    TextBlock(id: 1, text: "待处理", num: 10),
    TextBlock(id: 2, text: "备菜中", num: 20),
    TextBlock(id: 3, text: "已完成", num: 30),
  ];

  int _focusedId = 1;

  void _handClickTest(int id) {
    setState(() {
      // 切换该项的聚焦状态
      _focusedId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: themeColor.bgColor,
        padding:
            const EdgeInsets.only(left: 40, right: 40, top: 20, bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_testList.length, (index) {
            return TextButton(
              onPressed: () {
                _handClickTest(_testList[index].id);
              },
              child: Text(
                // (${_testList[index].num})
                _testList[index].text,
                style: TextStyle(
                  color: _focusedId == _testList[index].id
                      ? themeColor.activeColor
                      : themeColor.textColor, // 根据聚焦状态设置颜色
                  fontSize: 14,
                ),
              ),
            );
          }),
        ),
      ),
      Expanded(
        child: OrderView(id: _focusedId),
      )
    ]);
  }
}

class TextBlock {
  final int id;
  final String text;
  final int num;
  TextBlock({required this.id, required this.text, required this.num});
}
