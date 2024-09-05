import 'package:logger/logger.dart';

class Save {
  Logger logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
    ),
  );

  Save() {}

  void testLogger() {
    logger.v('v');
    logger.d('d');
    logger.i('i');
    logger.w('w');
    logger.e('e');
    logger.wtf('wtf');
  }
}

 // list.add(LineText(
    //     type: LineText.TYPE_BARCODE,
    //     content: 'A12312112',
    //     size: 10,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));
    // list.add(LineText(
    //     type: LineText.TYPE_QRCODE,
    //     content: 'qrcode i',
    //     size: 10,
    //     align: LineText.ALIGN_CENTER,
    //     linefeed: 1));
    // list.add(LineText(linefeed: 1));

