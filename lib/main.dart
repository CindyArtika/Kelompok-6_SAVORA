
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tubes_pemmob/auth_gate.dart';
import 'package:tubes_pemmob/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SavoraApp());
}

class SavoraApp extends StatelessWidget {
  const SavoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SAVORA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4C8547),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
