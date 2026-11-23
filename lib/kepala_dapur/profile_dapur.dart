import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileDapur extends StatefulWidget {
  const ProfileDapur({super.key});

  @override
  State<ProfileDapur> createState() => _ProfileDapurState();
}

class _ProfileDapurState extends State<ProfileDapur> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // EDIT NAMA PROFIL
  Future<void> _editProfile() async {
    final user = currentUser;
    if (user == null) return;

    final controller = TextEditingController(
      text: user.displayName ?? '',
    );

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Nama Profil'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Nama Lengkap',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              controller.text.trim(),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (result == null) return;
    if (result.isEmpty) {
      _showMessage('Nama tidak boleh kosong.');
      return;
    }

    try {
      await user.updateDisplayName(result);
      await user.reload();

      if (!mounted) return;
      setState(() {});
      _showMessage('Nama profil berhasil diperbarui.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      _showMessage('Gagal memperbarui nama: ${e.message ?? e.code}');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan saat memperbarui nama.');
    }
  }

  // UBAH PASSWORD
  Future<void> _changePassword() async {
    final user = currentUser;
    if (user == null) return;

    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keamanan Akun'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password saat ini',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password baru',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Ulangi password baru',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Perbarui'),
          ),
        ],
      ),
    );

    final oldPassword = oldController.text;
    final newPassword = newController.text;
    final confirmPassword = confirmController.text;

    oldController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (result != true) return;

    if (oldPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showMessage('Lengkapi semua kolom password.');
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Password baru minimal 6 karakter.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('Ulangan password baru tidak cocok.');
      return;
    }

    try {
      final email = user.email;
      if (email == null) {
        _showMessage('Akun ini tidak memiliki email.');
        return;
      }

      final credential = EmailAuthProvider.credential(
        email: email,
        password: oldPassword,
      );

      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (!mounted) return;
      _showMessage('Password akun berhasil diperbarui.');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        _showMessage('Password saat ini tidak sesuai.');
      } else {
        _showMessage('Gagal memperbarui password: ${e.message ?? e.code}');
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage('Terjadi kesalahan saat memperbarui password.');
    }
  }



Future<void> _logout() async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Keluar dari akun?'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun Kepala Dapur?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, false);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      );
    },
  );

  if (confirm != true) return;

  try {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // Kembali ke halaman utama AuthGate
    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);

  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal logout. Silakan coba lagi.'),
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final String name = (user?.displayName?.trim().isNotEmpty ?? false)
        ? user!.displayName!.trim()
        : 'Kepala Dapur';
    final String email = user?.email ?? '-';

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: primary),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // FOTO DAN IDENTITAS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 26),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 43,
                    backgroundColor: const Color(0xFFDCE8DF),
                    backgroundImage: user?.photoURL != null
                        ? NetworkImage(user!.photoURL!)
                        : null,
                    child: user?.photoURL == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: primary,
                            size: 48,
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE1F0E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'KEPALA DAPUR',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _sectionTitle('Informasi Akun'),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.person_outline,
              title: 'Nama Lengkap',
              value: name,
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: Icons.email_outlined,
              title: 'Email',
              value: email,
            ),
            const SizedBox(height: 10),
            _infoCard(
              icon: Icons.verified_user_outlined,
              title: 'Hak Akses',
              value: 'Kepala Dapur',
            ),

            const SizedBox(height: 24),

            _sectionTitle('Pengaturan Akun'),
            const SizedBox(height: 12),
            _menuCard(
              icon: Icons.edit_outlined,
              title: 'Edit Profil',
              subtitle: 'Ubah nama akun',
              onTap: _editProfile,
            ),
            const SizedBox(height: 10),
            _menuCard(
              icon: Icons.lock_outline,
              title: 'Ubah Password',
              subtitle: 'Perbarui password akun',
              onTap: _changePassword,
            ),

            const SizedBox(height: 24),

            // TANGGUNG JAWAB KEPALA DAPUR
            _sectionTitle('Tanggung Jawab'),
            const SizedBox(height: 12),
            _responsibilityCard(),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
            const Text(
              'SAVORA Management System',
              style: TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: primary, size: 23),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: primary, size: 23),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _responsibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        children: [
          _ResponsibilityItem(
            icon: Icons.inventory_2_outlined,
            text: 'Memantau stok bahan baku.',
          ),
          SizedBox(height: 14),
          _ResponsibilityItem(
            icon: Icons.shopping_cart_outlined,
            text: 'Mengajukan kebutuhan bahan.',
          ),
          SizedBox(height: 14),
          _ResponsibilityItem(
            icon: Icons.restaurant_menu_rounded,
            text: 'Memperbarui status ketersediaan menu.',
          ),
        ],
      ),
    );
  }
}

class _ResponsibilityItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ResponsibilityItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.check_circle_outline_rounded,
          color: Color(0xFF21834B),
          size: 19,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF758078),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
