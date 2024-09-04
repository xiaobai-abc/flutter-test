import 'package:flutter/material.dart';
import './login/login_page.dart';
import './home/home_page.dart';

void main() {
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
        initialRoute: '/home',
        routes: {
          '/login': (context) => LoginPage(),
          '/home': (context) => HomePage(),
        });
  }
}
