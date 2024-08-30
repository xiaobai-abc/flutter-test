import 'package:flutter/material.dart';
import './login/login_page.dart';
import './home/home_page.dart';
import 'package:logger/logger.dart';

void main() {
  var logger = Logger(
    printer: PrettyPrinter( 
      methodCount: 0,
    ),
  );
  logger.v('verbose message');
  logger.d('debug message');
  logger.i('info message');
  logger.w('warning message');
  logger.e('error message');
  logger.wtf('wft message');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: '玖富商家端',
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => LoginPage(),
          '/home': (context) => HomePage(),
        });
  }
}
