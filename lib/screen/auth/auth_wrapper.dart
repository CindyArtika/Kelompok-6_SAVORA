
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tubes_pemmob/screen/auth/login.dart';
import 'package:tubes_pemmob/owner/owner_home.dart';
import 'package:tubes_pemmob/screen/auth/navbar.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late final Stream<User?> _authState;

  static const String ownerEmail = 'owner123@gmail.com';

  @override
  void initState() {
    super.initState();
    _authState = FirebaseAuth.instance.authStateChanges();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authState,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Status login gagal dimuat.'),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        debugPrint('EMAIL LOGIN: ${user?.email}');
        debugPrint('EMAIL OWNER: $ownerEmail');
        if (user == null) {
          return const LoginScreen();
        }

        if (user.email?.trim().toLowerCase() == ownerEmail) {
          return const OwnerHome();
        }

        return const Navbar();
      },
    );
  }
}
