import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class ModalBluetooth extends StatefulWidget {
  const ModalBluetooth({super.key});

  @override
  ModalBluetoothState createState() => ModalBluetoothState();
}

class ModalBluetoothState extends State<ModalBluetooth> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = '没有设备连接~~~';

  @override
  void initState() {
    super.initState();

    Logger().v("initState");

    //  WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.7, // 设置为屏幕高度的70%
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_outlined),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    // bluetoothPrint.stopScan();
                    if (_device != null) {
                      setState(() {
                        tips = '断开连接中...';
                      });
                      await bluetoothPrint.disconnect();
                    }
                  },
                  child: const Text("断开连接"),
                ),
                OutlinedButton(
                  onPressed: () async {
                    Map<String, dynamic> config = {};
                    List<LineText> list = [];
                    list.add(LineText(
                        fontZoom: 2,
                        type: LineText.TYPE_TEXT,
                        content: '中文测试',
                        // content: 'asdasdasd',
                        weight: 1,
                        align: LineText.ALIGN_CENTER,
                        linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_TEXT,
                        content: '-------------------------------',
                        weight: 0,
                        linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_TEXT,
                        content: '*******************************',
                        weight: 1,
                        linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_TEXT,
                        content: '-------------其他---------------',
                        weight: 1,
                        // align: LineText.ALIGN_LEFT,
                        linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_TEXT,
                        content: '左',
                        align: LineText.ALIGN_LEFT));
                    list.add(LineText(
                        type: LineText.TYPE_TEXT,
                        content: '右面',
                        align: LineText.ALIGN_RIGHT));
                    list.add(LineText(linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_BARCODE,
                        content: 'A12312112',
                        size: 10,
                        align: LineText.ALIGN_CENTER,
                        linefeed: 1));
                    list.add(LineText(linefeed: 1));
                    list.add(LineText(
                        type: LineText.TYPE_QRCODE,
                        content: 'qrcode i',
                        size: 10,
                        align: LineText.ALIGN_CENTER,
                        linefeed: 1));
                    list.add(LineText(linefeed: 1));

                    // List<int> imageBytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
                    // String base64Image = base64Encode(imageBytes);

                    await bluetoothPrint.printReceipt(config, list);
                  },
                  child: const Text("打印"),
                ),
                Row(
                  children: [
                    Text(tips),
                    const Icon(Icons.bluetooth, color: Colors.blue),
                    Text(_connected ? '已连接' : '未连接'),
                    Text(_device?.name ?? ''),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              // 直接包括在这里
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<BluetoothDevice>>(
                stream: bluetoothPrint.scanResults,
                initialData: [],
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Column(
                      children: snapshot.data!.map((d) {
                        return ListTile(
                          title: Text(d.name ?? ''),
                          subtitle: Text(d.address ?? ''),
                          onTap: () async {
                            setState(() {
                              _device = d;
                            });

                            if (_device != null && _device!.address != null) {
                              setState(() {
                                tips = '连接中...';
                              });
                              await bluetoothPrint.connect(_device!);
                            } else {
                              setState(() {
                                tips = '选择的设备无效';
                              });
                            }
                          },
                        );
                      }).toList(),
                    );
                  } else {
                    return Center(child: Text('没有找到设备'));
                  }
                },
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> initBluetooth() async {
    Logger().i("初始化蓝牙");
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      Logger().i('******************* 设备状态: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          Logger().i("进入连接成功");
          setState(() {
            _connected = true;
            tips = '连接成功';
          });
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = '断开连接';
          });
          break;
        default:
          // bluetoothPrint.disconnect();
          break;
      }
    });

    if (!mounted) return;

    if (isConnected) {
      setState(() {
        _connected = true;
        tips = '设备已连接';
      });
    }
  }
}
