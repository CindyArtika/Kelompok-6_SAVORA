
import 'package:flutter/material.dart';

class SavoraLoading extends StatefulWidget {
  final String title;
  final String subtitle;

  const SavoraLoading({
    super.key,
    this.title = 'Menyiapkan halaman',
    this.subtitle = 'Mohon tunggu sebentar...',
  });

  @override
  State<SavoraLoading> createState() => _SavoraLoadingState();
}

class _SavoraLoadingState extends State<SavoraLoading>
    with SingleTickerProviderStateMixin {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF8FAF8);

  late AnimationController _controller;
  late Animation<double> _rotation;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _rotation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _fade = Tween<double>(
      begin: 0.35,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 170,
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Lingkaran dekorasi
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEAF2E9),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.08),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                    ),

                    // Logo SAVORA
                    Container(
                      width: 100,
                      height: 100,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: Image.asset(
                        'assets/images/Logo_savora.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Animasi titik mengelilingi logo
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotation.value * 2 * 3.1415926535,
                          child: child,
                        );
                      },
                      child: Stack(
                        children: [
                          Positioned(
                            top: 5,
                            left: 80,
                            child: FadeTransition(
                              opacity: _fade,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 18,
                            right: 8,
                            child: Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Color(0xFF9BC49A),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                widget.subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF87928A),
                ),
              ),

              const SizedBox(height: 25),

              // Garis loading
              SizedBox(
                width: 150,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: const LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: Color(0xFFE1EAE1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF143C2D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
