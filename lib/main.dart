import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mobile2/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:mobile2/theme/them_constants.dart';
import 'package:mobile2/theme/theme_manager.dart';

void main() {
  runApp(const MyApp());
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Construck app',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      home: const MyHomePage(title: 'Shabika App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Login();
  }
}
