import 'package:flutter/material.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const ArivuCodeApp());
}

class ArivuCodeApp extends StatelessWidget {
  const ArivuCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ArivuCode',
      theme: ThemeData.dark(),
      home: const LoginScreen(),
    );
  }
}
