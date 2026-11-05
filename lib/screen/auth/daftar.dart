
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubes_pemmob/screen/auth/login.dart';

class DaftarScreen extends StatefulWidget {
  const DaftarScreen({super.key});

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();

  bool passwordVisible = false;
  bool konfirmasiVisible = false;
  bool setuju = false;
  bool loading = false;

  final Color primaryColor = const Color(0xFF4C8547);
  final Color backgroundColor = const Color(0xFFF5F8F3);

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    hpController.dispose();
    passwordController.dispose();
    konfirmasiController.dispose();
    super.dispose();
  }

  void tampilkanPesan(String pesan) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> daftar() async {
    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final hp = hpController.text.trim();
    final password = passwordController.text;
    final konfirmasi = konfirmasiController.text;

    if (nama.isEmpty ||
        email.isEmpty ||
        hp.isEmpty ||
        password.isEmpty ||
        konfirmasi.isEmpty) {
      tampilkanPesan('Semua kolom wajib diisi.');
      return;
    }

    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      tampilkanPesan('Format email tidak valid.');
      return;
    }

    if (!RegExp(r'^08[0-9]{8,13}$').hasMatch(hp)) {
      tampilkanPesan(
        'Nomor HP harus diawali 08 dan berisi 10–15 digit.',
      );
      return;
    }

    if (password.length < 8) {
      tampilkanPesan('Password minimal 8 karakter.');
      return;
    }

    if (password != konfirmasi) {
      tampilkanPesan('Password dan konfirmasi password tidak cocok.');
      return;
    }

    if (!setuju) {
      tampilkanPesan('Harap menyetujui Syarat & Ketentuan.');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

        await credential.user?.updateDisplayName(nama);

        // Firebase otomatis membuat sesi login setelah registrasi.
        // Sign out dulu agar pengguna bisa masuk melalui halaman Login.
        await FirebaseAuth.instance.signOut();

            if (!mounted) return;
            tampilkanPesan('Akun berhasil dibuat!');
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
              (route) => false,
            );
      // Navigasi ke halaman utama dapat ditambahkan di sini.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String pesan;

      switch (e.code) {
        case 'email-already-in-use':
          pesan = 'Email sudah terdaftar.';
          break;
        case 'invalid-email':
          pesan = 'Format email tidak valid.';
          break;
        case 'weak-password':
          pesan = 'Password terlalu lemah.';
          break;
        case 'network-request-failed':
          pesan = 'Periksa koneksi internet kamu.';
          break;
        case 'operation-not-allowed':
          pesan = 'Aktifkan Email/Password di Firebase.';
          break;
        default:
          pesan = e.message ?? 'Pendaftaran gagal. Coba lagi.';
      }

      tampilkanPesan(pesan);
    } catch (_) {
      if (!mounted) return;
      tampilkanPesan('Terjadi kesalahan. Silakan coba lagi.');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget inputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isPassword = false,
    bool? visible,
    VoidCallback? toggleVisible,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D493B),
          ),
        ),
        const SizedBox(height: 9),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword && !(visible ?? false),
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF263326),
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: 21,
            ),
            suffixIcon: isPassword
                ? IconButton(
                    onPressed: toggleVisible,
                    icon: Icon(
                      visible == true
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF8D998A),
                      size: 20,
                    ),
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF7F9F6),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            hintStyle: const TextStyle(
              color: Color(0xFF9AA49A),
              fontSize: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE4EAE1),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFFE4EAE1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget pesanValidasi(String pesan) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 17,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              pesan,
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                children: [
                  // Logo SAVORA
                  Container(
                    width: 120,
                    height: 120,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/Logo_savora.png',
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'SAVORA MANAGEMENT',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Buat Akun Baru',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF263326),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Daftarkan akun Admin atau Owner\n'
                    'untuk mulai mengelola SAVORA.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7D887B),
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Card form pendaftaran
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFEAF0E7),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Akun',
                            style: TextStyle(
                              color: Color(0xFF263326),
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'Lengkapi data berikut untuk membuat akun.',
                            style: TextStyle(
                              color: Color(0xFF879184),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 24),

                          inputField(
                            label: 'Nama Lengkap',
                            hint: 'Masukkan nama lengkap',
                            icon: Icons.person_outline,
                            controller: namaController,
                          ),

                          const SizedBox(height: 18),

                          inputField(
                            label: 'Email',
                            hint: 'Masukkan email kamu',
                            icon: Icons.email_outlined,
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),

                          inputField(
                            label: 'Nomor HP',
                            hint: 'Masukkan nomor HP (08xx)',
                            icon: Icons.phone_outlined,
                            controller: hpController,
                            keyboardType: TextInputType.phone,
                          ),

                          const SizedBox(height: 18),

                          inputField(
                            label: 'Password',
                            hint: 'Buat password',
                            icon: Icons.lock_outline,
                            controller: passwordController,
                            isPassword: true,
                            visible: passwordVisible,
                            toggleVisible: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),

                          const SizedBox(height: 18),

                          inputField(
                            label: 'Konfirmasi Password',
                            hint: 'Konfirmasi password',
                            icon: Icons.lock_reset_outlined,
                            controller: konfirmasiController,
                            isPassword: true,
                            visible: konfirmasiVisible,
                            toggleVisible: () {
                              setState(() {
                                konfirmasiVisible = !konfirmasiVisible;
                              });
                            },
                          ),

                          const SizedBox(height: 22),

                          // Persetujuan
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: setuju,
                                  activeColor: primaryColor,
                                  onChanged: (value) {
                                    setState(() {
                                      setuju = value ?? false;
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 10),

                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment.center,
                                  children: [
                                    const Text(
                                      'Saya menyetujui ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4C5851),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const DaftarScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Syarat & Ketentuan',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const Text(
                                      ' dan ',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4C5851),
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: () {
                                        tampilkanPesan(
                                          'Halaman Kebijakan Privasi belum dibuat.',
                                        );
                                      },
                                      child: Text(
                                        'Kebijakan Privasi',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: primaryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),

                                    const Text(
                                      '.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF4C5851),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (!setuju)
                            pesanValidasi(
                              'Harap menyetujui Syarat & Ketentuan.',
                            ),

                          const SizedBox(height: 24),

                          // Tombol daftar
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: loading ? null : daftar,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor:
                                    primaryColor.withValues(alpha: 0.6),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Daftar',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigasi ke halaman login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah punya akun? ',
                        style: TextStyle(
                          color: Color(0xFF7D887B),
                          fontSize: 13,
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context, MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ));
                        },
                        child: Text(
                          'Masuk',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
