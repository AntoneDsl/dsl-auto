import 'package:flutter/material.dart';
import 'home_screen.dart'; // Подключаем наш главный экран

void main() {
  runApp(const DslAutoApp());
}

class DslAutoApp extends StatelessWidget {
  const DslAutoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSL AUTO',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFFF5722),
      ),
      home: const HomeScreen(),
    );
  }
}
