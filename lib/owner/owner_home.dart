import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  static const Color primary = Color(0xFF143C2D);
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate akan otomatis menampilkan alur halaman untuk pengguna
      // yang sudah logout. Tidak perlu Navigator.pop() atau navigasi manual.
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal logout. Silakan coba lagi.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Apakah kamu yakin ingin keluar dari akun Owner?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _isLoggingOut
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _logout();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SAVORA - Owner'),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: _isLoggingOut ? null : _showLogoutDialog,
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Dashboard Owner\\nPemantauan dan Persetujuan',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
