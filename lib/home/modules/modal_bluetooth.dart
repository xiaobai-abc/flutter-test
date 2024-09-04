import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:bluetooth_print/bluetooth_print.dart';
import 'package:bluetooth_print/bluetooth_print_model.dart';

class ModalBluetooth extends StatefulWidget {
  final Function(bool) onHandCallback;
  const ModalBluetooth({super.key, required this.onHandCallback});

  @override
  ModalBluetoothState createState() => ModalBluetoothState();
}

class ModalBluetoothState extends State<ModalBluetooth> {
  BluetoothPrint bluetoothPrint = BluetoothPrint.instance;
  bool _connected = false;
  BluetoothDevice? _device;
  String tips = '没有设备连接~';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => initBluetooth());
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: !_connected
                      ? null
                      : () async {
                          setState(() {
                            tips = '断开连接中...';
                          });
                          await bluetoothPrint.disconnect();
                        },
                  child: const Text("断开连接"),
                ),
                OutlinedButton(
                  onPressed: _device == null
                      ? null
                      : () async {
                          setState(() {
                            tips = '点击连接中...';
                          });
                          await bluetoothPrint.connect(_device!);
                        },
                  child: const Text("点击连接"),
                ),
                Row(
                  children: [
                    Text(tips),
                    // const Icon(Icons.bluetooth, color: Colors.blue),
                    // Text(_connected ? '已连接' : '未连接'),
                    // Text(_device?.name ?? ''),
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
                initialData: const [],
                builder: (c, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Column(
                      children: snapshot.data!.map((d) {
                        return ListTile(
                          title: Text(d.name ?? ''),
                          subtitle: Text(d.address ?? ''),
                          trailing:
                              _device != null && _device!.address == d.address
                                  ? const Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : null,
                          onTap: () async {
                            setState(() {
                              _device = d;
                            });

                            // if (_device != null && _device!.address != null) {
                            //   setState(() {
                            //     tips = '连接中...';
                            //   });
                            //   await bluetoothPrint.connect(_device!);
                            // } else {
                            //   setState(() {
                            //     tips = '选择的设备无效';
                            //   });
                            // }
                          },
                        );
                      }).toList(),
                    );
                  } else {
                    return const Center(child: Text('没有找到设备'));
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
    Logger(printer: PrettyPrinter(methodCount: 0)).i("初始化蓝牙");
    bluetoothPrint.startScan(timeout: const Duration(seconds: 4));

    bool isConnected = await bluetoothPrint.isConnected ?? false;

    bluetoothPrint.state.listen((state) {
      Logger(printer: PrettyPrinter(methodCount: 0))
          .i('******************* 设备状态: $state');

      switch (state) {
        case BluetoothPrint.CONNECTED:
          setState(() {
            _connected = true;
            tips = '已连接~';
          });
          widget.onHandCallback(true);
          break;
        case BluetoothPrint.DISCONNECTED:
          setState(() {
            _connected = false;
            tips = '断开连接~';
          });
          widget.onHandCallback(false);
          break;
        default:
          // bluetoothPrint.disconnect();
          break;
      }
    });

    if (!mounted) return;
    widget.onHandCallback(isConnected);
    if (isConnected) {
      setState(() {
        _connected = true;
        tips = '设备已连接';
      });
    }
  }
}
