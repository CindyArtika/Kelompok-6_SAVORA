
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:tubes_pemmob/intro_splash_screen.dart';
import 'package:tubes_pemmob/widgets/savora_loading.dart';
import 'package:tubes_pemmob/services/firestore_services.dart';
import 'package:tubes_pemmob/admin/admin_home.dart';
import 'package:tubes_pemmob/owner/owner_home.dart';
import 'package:tubes_pemmob/kepala_dapur/dapur_home.dart';
import 'package:tubes_pemmob/splash_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static bool introCompleted = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SavoraLoading(
            title: 'Menyiapkan SAVORA',
            subtitle: 'Memeriksa sesi akun...',
          );
        }

        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Gagal memeriksa sesi akun.'),
            ),
          );
        }

        final user = snapshot.data;

        // BELUM LOGIN
        if (user == null) {
          return const LoggedOutFlow();
        }

        // SUDAH LOGIN
        AuthGate.introCompleted = true;

        return UserRoleRouter(
          key: ValueKey(user.uid),
          user: user,
        );
      },
    );
  }
}

class LoggedOutFlow extends StatefulWidget {
  const LoggedOutFlow({super.key});

  @override
  State<LoggedOutFlow> createState() => _LoggedOutFlowState();
}

class _LoggedOutFlowState extends State<LoggedOutFlow> {
  late bool _showIntro;

  @override
  void initState() {
    super.initState();
    _showIntro = !AuthGate.introCompleted;
  }

  void _finishIntro() {
    if (!mounted) return;

    AuthGate.introCompleted = true;

    setState(() {
      _showIntro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return IntroSplashScreen(
        onFinished: _finishIntro,
      );
    }

    return const SplashScreen();
  }
}

class UserRoleRouter extends StatefulWidget {
  final User user;

  const UserRoleRouter({
    super.key,
    required this.user,
  });

  @override
  State<UserRoleRouter> createState() => _UserRoleRouterState();
}

class _UserRoleRouterState extends State<UserRoleRouter> {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _userDataFuture =
        FirestoreService().getUserData(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SavoraLoading(
            title: 'Menyiapkan SAVORA',
            subtitle: 'Memuat data akun...',
          );
        }

        if (snapshot.hasError) {
          debugPrint('ROLE ROUTER ERROR: ${snapshot.error}');

          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 45,
                  ),
                  const SizedBox(height: 12),
                  const Text('Gagal memuat data akun.'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _loadUserData();
                      });
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final data = snapshot.data;

        if (data == null) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Data akun belum tersedia. Hubungi Owner.',
              ),
            ),
          );
        }

        final role = data['role']
            ?.toString()
            .trim()
            .toLowerCase()
            .replaceAll(' ', '_');

        debugPrint('LOGIN UID: ${widget.user.uid}');
        debugPrint('LOGIN ROLE: $role');

        switch (role) {
          case 'owner':
            return const OwnerHome();

          case 'admin':
            return const AdminHome();

          case 'kepala_dapur':
            return const DapurHome();

          default:
            return Scaffold(
              body: Center(
                child: Text(
                  'Role akun tidak valid: ${data['role']}',
                ),
              ),
            );
        }
      },
    );
  }
}
