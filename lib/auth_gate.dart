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

  // Menandai bahwa IntroSplashScreen sudah pernah dilewati
  // selama aplikasi ini berjalan.
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

        if (user == null) {
          return const LoggedOutFlow();
        }

        // Jika aplikasi dibuka dengan sesi login yang masih aktif,
        // intro dianggap sudah dilewati. Saat logout nanti langsung SplashScreen.
        AuthGate.introCompleted = true;

        return UserRoleRouter(user: user);
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

  const UserRoleRouter({super.key, required this.user});

  @override
  State<UserRoleRouter> createState() => _UserRoleRouterState();
}

class _UserRoleRouterState extends State<UserRoleRouter> {
  late Future<Map<String, dynamic>?> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = FirestoreService().getUserData(widget.user.uid);
  }

  @override
  void didUpdateWidget(covariant UserRoleRouter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.user.uid != widget.user.uid) {
      _userDataFuture = FirestoreService().getUserData(widget.user.uid);
    }
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
          return const Scaffold(
            body: Center(
              child: Text('Gagal memuat data akun.'),
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

        final role = data['role']?.toString().trim().toLowerCase();

        switch (role) {
          case 'owner':
            return const OwnerHome();

          case 'admin':
            return const AdminHome();

          case 'kepala_dapur':
            return const DapurHome();

          default:
            return const Scaffold(
              body: Center(
                child: Text('Role akun tidak valid.'),
              ),
            );
        }
      },
    );
  }
}
