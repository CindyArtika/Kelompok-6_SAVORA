import 'package:flutter/material.dart';
import 'pengguna/login.dart';

void main() {
  runApp(const SavoraApp());
}

class SavoraApp extends StatelessWidget {
  const SavoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAVORA',
      home: const LoginScreen(),
    );
  }
}