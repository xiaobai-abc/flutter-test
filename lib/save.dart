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
