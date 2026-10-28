
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DaftarScreen extends StatefulWidget {
  const DaftarScreen({super.key});

  @override
  State<DaftarScreen> createState() => _DaftarScreenState();
}

class _DaftarScreenState extends State<DaftarScreen> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final hpController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();

  bool passwordVisible = false;
  bool konfirmasiVisible = false;
  bool setuju = false;
  bool loading = false;

  final Color hijau = const Color(0xFF079B70);
  final Color abu = const Color(0xFFF1F3F5);
  final Color teksAbu = const Color(0xFF758078);

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan)),
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
      tampilkanPesan('Nomor HP harus diawali 08 dan berisi 10–15 digit.');
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

      if (!mounted) return;

      tampilkanPesan('Akun berhasil dibuat!');

      // Ganti dengan navigasi ke halaman utama jika diperlukan.
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
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF202124),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 58,
          decoration: BoxDecoration(
            color: abu,
            borderRadius: BorderRadius.circular(22),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: isPassword && !(visible ?? false),
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: teksAbu, size: 25),
              suffixIcon: isPassword
                  ? IconButton(
                      onPressed: toggleVisible,
                      icon: Icon(
                        visible == true
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: teksAbu,
                      ),
                    )
                  : null,
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB8C9BD),
                fontSize: 16,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 17,
                horizontal: 10,
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
            color: Color(0xFFFF4141),
            size: 19,
          ),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              pesan,
              style: const TextStyle(
                color: Color(0xFFFF4141),
                fontSize: 14,
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
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 25),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: hijau,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.medical_services,
                      color: Colors.white,
                      size: 43,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Buat Akun SAVORA',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                  color: Color(0xFF191B1D),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Daftar sekarang dan nikmati pengalaman\n'
                'memesan yang lebih mudah.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: teksAbu,
                ),
              ),
              const SizedBox(height: 35),

              // Form pendaftaran
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    inputField(
                      label: 'Nama Lengkap',
                      hint: 'Masukkan nama lengkap',
                      icon: Icons.person_outline,
                      controller: namaController,
                    ),
                    const SizedBox(height: 22),
                    inputField(
                      label: 'Email',
                      hint: 'Masukkan email kamu',
                      icon: Icons.mail_outline,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 22),
                    inputField(
                      label: 'Nomor HP',
                      hint: 'Masukkan nomor HP (08xx)',
                      icon: Icons.phone_outlined,
                      controller: hpController,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 22),
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
                    const SizedBox(height: 22),
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
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: setuju,
                            activeColor: hijau,
                            onChanged: (value) {
                              setState(() => setuju = value ?? false);
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              const Text(
                                'Saya menyetujui ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4C5851),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => tampilkanPesan(
                                  'Halaman Syarat & Ketentuan belum dibuat.',
                                ),
                                child: Text(
                                  'Syarat & Ketentuan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: hijau,
                                  ),
                                ),
                              ),
                              const Text(
                                ' dan ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4C5851),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => tampilkanPesan(
                                  'Halaman Kebijakan Privasi belum dibuat.',
                                ),
                                child: Text(
                                  'Kebijakan Privasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: hijau,
                                  ),
                                ),
                              ),
                              const Text(
                                '.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4C5851),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (!setuju) pesanValidasi(
                      'Harap menyetujui Syarat & Ketentuan.',
                    ),

                    const SizedBox(height: 26),

                    // Tombol daftar
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: ElevatedButton(
                        onPressed: loading ? null : daftar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hijau,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Icon(Icons.arrow_forward, size: 25),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Link ke halaman login
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Sudah punya akun? ',
                    style: TextStyle(
                      fontSize: 17,
                      color: teksAbu,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: hijau,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
