import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Ukuran menyesuaikan layar emulator
    final horizontalPadding = screenWidth < 400 ? 20.0 : 30.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),

          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ),

            child: Column(
              children: [

                const SizedBox(height: 22),

                Container(
                  width: screenWidth < 400 ? 105 : 130,
                  height: screenWidth < 400 ? 105 : 130,

                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F4F5),
                    borderRadius: BorderRadius.circular(28),
                  ),

                  child: Center(
                    child: Image.asset(
                      'assets/images/Logo_savora.png',

                      width: screenWidth < 400 ? 75 : 90,
                      height: screenWidth < 400 ? 75 : 90,

                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 7,
                  ),

                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFAE9),
                    borderRadius: BorderRadius.circular(30),
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 9,
                        height: 9,

                        decoration: const BoxDecoration(
                          color: Color(0xFF059669),
                          shape: BoxShape.circle,
                        ),
                      ),

                      const SizedBox(width: 8),

                      const Text(
                        'CULINARY EXPERIENCE',

                        style: TextStyle(
                          color: Color(0xFF075C45),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Selamat Datang di SAVORA',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFF191C1E),
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Masuk untuk menikmati makanan dan\n'
                  'minuman favoritmu.',

                  textAlign: TextAlign.center,

                  style: TextStyle(
                    color: Color(0xFF545C72),
                    fontSize: 16,
                    height: 1.45,
                  ),
                ),

                const SizedBox(height: 26),

                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    22,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white,

                    borderRadius: BorderRadius.circular(28),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Email',

                        style: TextStyle(
                          color: Color(0xFF191C1E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 9),

                      _buildTextField(
                        controller: emailController,

                        hintText: 'Masukkan email kamu',

                        icon: Icons.email_outlined,

                        keyboardType:
                            TextInputType.emailAddress,
                      ),

                      const SizedBox(height: 20),
                      const Text(
                        'Password',

                        style: TextStyle(
                          color: Color(0xFF191C1E),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 9),

                      _buildTextField(
                        controller: passwordController,

                        hintText: 'Masukkan password',

                        icon: Icons.lock_outline,

                        obscureText:
                            !isPasswordVisible,

                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible =
                                  !isPasswordVisible;
                            });
                          },

                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,

                            color:
                                const Color(0xFF545C72),

                            size: 24,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Align(
                        alignment:
                            Alignment.centerRight,

                        child: GestureDetector(
                          onTap: () {
                            // Nanti kita buat halaman
                            // Lupa Password
                          },

                          child: const Text(
                            'Lupa Password?',

                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 56,

                        child: ElevatedButton(
                          onPressed: () {
                            // Login nanti kita hubungkan
                            // ke database
                          },

                          style:
                              ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF059669),

                            foregroundColor:
                                Colors.white,

                            elevation: 0,

                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                18,
                              ),
                            ),
                          ),

                          child: const Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Text(
                                'Masuk',

                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.w600,
                                ),
                              ),

                              SizedBox(width: 10),

                              Icon(
                                Icons.arrow_forward,
                                size: 25,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 19),

                      // =================================================
                      // DIVIDER
                      // =================================================

                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              color: Color(0xFFD7DADD),
                              thickness: 1,
                            ),
                          ),

                          const Padding(
                            padding:
                                EdgeInsets.symmetric(
                              horizontal: 12,
                            ),

                            child: Text(
                              'atau masuk dengan',

                              style: TextStyle(
                                color:
                                    Color(0xFF545C72),
                                fontSize: 14,
                              ),
                            ),
                          ),

                          const Expanded(
                            child: Divider(
                              color: Color(0xFFD7DADD),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child:
                                _buildSocialButton(
                              icon:
                                  'assets/images/google-icon.png',

                              text: 'Google',
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child:
                                _buildSocialButton(
                              icon:
                                  'assets/images/apple-icon.png',

                              text: 'Apple',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                RichText(
                  textAlign: TextAlign.center,

                  text: const TextSpan(
                    style: TextStyle(
                      color: Color(0xFF545C72),
                      fontSize: 16,
                    ),

                    children: [
                      TextSpan(
                        text: 'Belum punya akun? ',
                      ),

                      TextSpan(
                        text: 'Daftar',

                        style: TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),
              ],
            ),
          ),
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

    TextInputType? keyboardType,
  }) {
    return SizedBox(
      height: 56,

      child: TextField(
        controller: controller,

        obscureText: obscureText,

        keyboardType: keyboardType,

        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF191C1E),
        ),

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: const TextStyle(
            color: Color(0xFF7A8681),
            fontSize: 16,
          ),

          prefixIcon: Icon(
            icon,

            color: const Color(0xFF545C72),

            size: 23,
          ),

          suffixIcon: suffixIcon,

          filled: true,

          fillColor: const Color(0xFFF2F4F6),

          contentPadding:
              const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 16,
          ),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(18),

            borderSide: const BorderSide(
              color: Color(0xFF059669),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,

    required String text,
  }) {
    return SizedBox(
      height: 56,

      child: ElevatedButton(
        onPressed: () {
          // Login Google / Apple
          // akan kita buat nanti
        },

        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFFF2F4F6),

          foregroundColor:
              const Color(0xFF191C1E),

          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),

          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
        ),

        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Image.asset(
              icon,

              width: 22,
              height: 22,

              fit: BoxFit.contain,
            ),

            const SizedBox(width: 8),

            Flexible(
              child: Text(
                text,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}