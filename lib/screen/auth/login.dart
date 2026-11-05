
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tubes_pemmob/screen/auth/daftar.dart';
import 'package:tubes_pemmob/owner/owner_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _isPasswordVisible = false;

  final Color primaryColor = const Color(0xFF4C8547);
  final Color backgroundColor = const Color(0xFFF5F8F3);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

              Future<void> _login() async {
          if (!_formKey.currentState!.validate()) return;

          setState(() {
            _isLoading = true;
          });

          try {
            final credential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

            debugPrint('LOGIN BERHASIL: ${credential.user?.email}');

            if (!mounted) return;

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const OwnerHome(),
              ),
              (route) => false,
            );
          } on FirebaseAuthException catch (e) {
            String message = 'Terjadi kesalahan saat login.';

            if (e.code == 'user-not-found') {
              message = 'Akun tidak ditemukan.';
            } else if (e.code == 'wrong-password') {
              message = 'Password yang dimasukkan salah.';
            } else if (e.code == 'invalid-email') {
              message = 'Format email tidak valid.';
            } else if (e.code == 'invalid-credential') {
              message = 'Email atau password salah.';
            } else if (e.code == 'too-many-requests') {
              message = 'Terlalu banyak percobaan. Coba lagi nanti.';
            }

            _showMessage(message);
          } catch (e) {
            debugPrint('LOGIN ERROR: $e');
            _showMessage('Login gagal. Silakan coba kembali.');
          } finally {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          }
        }
          Future<void> _signInWithGoogle() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize();

      final GoogleSignInAccount googleUser =
          await googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      _showMessage('Login dengan Google gagal. Silakan coba kembali.');
        } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage('Masukkan email terlebih dahulu.');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showMessage('Link reset password telah dikirim ke email.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage('Email tidak terdaftar.');
      } else if (e.code == 'invalid-email') {
        _showMessage('Format email tidak valid.');
      } else {
        _showMessage('Gagal mengirim link reset password.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText tidak boleh kosong';
        }

        if (hintText == 'Email' &&
            !RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$')
                .hasMatch(value.trim())) {
          return 'Masukkan email yang valid';
        }

        return null;
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          icon,
          color: primaryColor,
          size: 21,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFF7F9F6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF9AA49A),
          fontSize: 14,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Colors.redAccent,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String iconPath,
    required String text,
    required VoidCallback onPressed,
    IconData fallbackIcon = Icons.g_mobiledata,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: Colors.white,
        side: const BorderSide(
          color: Color(0xFFE2E8DF),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            width: 22,
            height: 22,
            errorBuilder: (context, error, stackTrace) {
              return Icon(
                fallbackIcon,
                size: 24,
                color: Colors.black87,
              );
            },
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF344034),
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
                  // Logo dan identitas aplikasi
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
                    'Selamat Datang!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF263326),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Yuk, mulai aktivitas hari ini!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF7D887B),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Form login
                  Container(
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
                            'Masuk ke Akun',
                            style: TextStyle(
                              color: Color(0xFF263326),
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 7),

                          const Text(
                            'Silakan masukkan akun Admin atau Owner.',
                            style: TextStyle(
                              color: Color(0xFF879184),
                              fontSize: 13,
                            ),
                          ),

                          const SizedBox(height: 25),

                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF3D493B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 9),

                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),

                          const SizedBox(height: 18),

                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF3D493B),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 9),

                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            icon: Icons.lock_outline,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible;
                                });
                              },
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF8D998A),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _resetPassword,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Lupa Password?',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Tombol login
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
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
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Pemisah
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE7ECE4),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'atau masuk dengan',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: Color(0xFFE7ECE4),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          _buildSocialButton(
                            iconPath: 'assets/images/google-icon.png',
                            text: _isGoogleLoading
                                ? 'Menghubungkan...'
                                : 'Google',
                            onPressed: _isGoogleLoading
                                ? () {}
                                : _signInWithGoogle,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Navigasi ke halaman daftar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum punya akun? ',
                        style: TextStyle(
                          color: Color(0xFF7D887B),
                          fontSize: 13,
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
                          'Daftar',
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
