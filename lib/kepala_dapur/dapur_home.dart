import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DapurHome extends StatefulWidget {
  const DapurHome({super.key});

  @override
  State<DapurHome> createState() => _DapurHomeState();
}

class _DapurHomeState extends State<DapurHome> {
  static const Color primary = Color(0xFF143C2D);
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      await FirebaseAuth.instance.signOut();
      // AuthGate otomatis menampilkan alur halaman untuk pengguna yang logout.
      // Tidak perlu navigasi manual.
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
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun Kepala Dapur?',
          ),
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
        title: const Text('SAVORA - Kepala Dapur'),
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
          'Dashboard Kepala Dapur\\nKebutuhan Bahan dan Status Menu',
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
