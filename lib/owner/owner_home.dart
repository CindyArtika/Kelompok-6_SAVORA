import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubes_pemmob/splash_screen.dart';

class OwnerHome extends StatefulWidget {
  const OwnerHome({super.key});

  @override
  State<OwnerHome> createState() => _OwnerHomeState();
}

class _OwnerHomeState extends State<OwnerHome> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);
  static const Color lightGreen = Color(0xFFE1F0DE);

  int _selectedIndex = 0;

  final List<String> _menuNames = [
    'Beranda',
    'Bahan',
    'Resep',
    'Pengadaan',
    'Laba & Rugi',
  ];

  final List<IconData> _menuIcons = [
    Icons.home_rounded,
    Icons.inventory_2_outlined,
    Icons.menu_book_outlined,
    Icons.shopping_bag_outlined,
    Icons.trending_up_rounded,
  ];

  final List<Map<String, dynamic>> bahanMenipis = [
    {
      'nama': 'Fresh Milk Pasteurisasi 1L',
      'sisa': '4.5 L',
      'minimum': '15 L',
      'persen': 0.30,
      'warna': const Color(0xFFFF5B5B),
      'gambar': Icons.local_drink,
    },

    {
      'nama': 'Sirup Vanilla 750ml',
      'sisa': '1 Btl',
      'minimum': '4 Btl',
      'persen': 0.25,
      'warna': Colors.orange,
      'gambar': Icons.liquor,
    },
  ];

 Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const SplashScreen(),
      ),
      (route) => false,
    );
  } catch (e) {
    if (mounted) {
      _showMessage('Gagal logout. Silakan coba lagi.');
    }
  }
}

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun Owner?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await _logout();
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

  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _selectedIndex == 0 ? _buildDashboard() : _buildOtherPage(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ================= DASHBOARD =================

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 8),
                _buildSummary(),
                const SizedBox(height: 22),
                _buildCriticalStock(),
                const SizedBox(height: 28),
                _buildSectionTitle(
                  'Bahan Menipis',
                  'Lihat Semua',
                  onTap: () => _changeTab(1),
                ),
                const SizedBox(height: 14),
                ...bahanMenipis.map(_buildStockCard),
                const SizedBox(height: 18),
                _buildProfitCard(),
                const SizedBox(height: 28),
                const Text(
                  'Kelola Operasional',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 14),
                _buildQuickActions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

        Widget _buildHeader() {
          return Container(
            margin: const EdgeInsets.fromLTRB(0, 10, 0, 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCEBD5),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.asset(
                      'assets/images/Logo_savora.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.store,
                          size: 30,
                          color: primary,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SAVORA Owner',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF59B477),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Outlet Buka',
                            style: TextStyle(
                              color: primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _headerIcon(Icons.notifications_none, showDot: true),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Menu Owner',
                  onSelected: (value) {
                    if (value == 'logout') {
                      _showLogoutDialog();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.red),
                          SizedBox(width: 10),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  child: const CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFDCE8DF),
                    child: CircleAvatar(
                      radius: 19,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: primary,
                        size: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

  Widget _headerIcon(IconData icon, {bool showDot = false}) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF0EC),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primary, size: 25),
        ),
        if (showDot)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  // ================= GREETING =================

  Widget _buildGreeting() {
    return SizedBox(
      height: 220,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Dekorasi hijau di belakang coffee
          Positioned(
            right: -20,
            top: 0,
            width: 220,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFDDEEDD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(110),
                  bottomLeft: Radius.circular(110),
                  topRight: Radius.circular(80),
                  bottomRight: Radius.circular(80),
                ),
              ),
            ),
          ),

          // Gambar coffee
          Positioned(
            right: -20,
            top: 8,
            width: 245,
            height: 215,
            child: Image.asset(
              'assets/images/coffee_header.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.coffee, size: 120, color: primary);
              },
            ),
          ),

          // Greeting
          Positioned(
            left: 0,
            top: 32,
            right: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat siang,',
                  style: TextStyle(
                    color: Color(0xFF506D5F),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Halo, Budi ',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Yuk, mulai aktivitas hari ini!',
                  style: TextStyle(fontSize: 13, color: muted, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SUMMARY =================

  Widget _buildSummary() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.account_balance_wallet,
            iconColor: primary,
            iconBackground: const Color(0xFFBFE4C8),
            title: 'Valuasi Stok',
            value: 'Rp 24,8 Jt',
            footer: '↑ 12%',
            footerColor: const Color(0xFF388957),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.warning_amber_outlined,
            iconColor: const Color(0xFFD94747),
            iconBackground: const Color(0xFFFFDADA),
            title: 'Perlu Restock',
            value: '3 Bahan',
            footer: '→ Lihat',
            footerColor: const Color(0xFFB94A45),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _summaryCard(
            icon: Icons.delete_outline,
            iconColor: const Color(0xFF596477),
            iconBackground: const Color(0xFFE3E7EB),
            title: 'Waste Hari Ini',
            value: 'Rp 88rb',
            footer: '↓ 8%',
            footerColor: const Color(0xFF388957),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBackground,
    required String title,
    required String value,
    required String footer,
    required Color footerColor,
  }) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 25),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: title == 'Perlu Restock'
                    ? const Color(0xFFD94747)
                    : textColor,
              ),
            ),
          ),
          const Spacer(),
          Text(
            footer,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: footerColor,
            ),
          ),
        ],
      ),
    );
  }

  // ================= CRITICAL STOCK =================

  Widget _buildCriticalStock() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          
          
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '3 Bahan Kritis',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Susu, Biji Kopi, Sirup Vanilla',
                  style: TextStyle(color: Color(0xFFD9E4DD), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => _changeTab(3),
            style: ElevatedButton.styleFrom(
              foregroundColor: primary,
              backgroundColor: const Color(0xFFE4F4DF),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 4),
                Text('Buat PO', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }


              Widget _buildSectionTitle(
                String title,
                String action, {
                required VoidCallback onTap,
              }) {
                return Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: textColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onTap,
                      child: Row(
                        children: [
                          Text(
                            action,
                            style: const TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: primary),
                        ],
                      ),
                    ),
                  ],
                );
              }

  // ================= STOCK CARD =================

  Widget _buildStockCard(Map<String, dynamic> bahan) {
    final double persen = bahan['persen'] as double;

    final Color warnaPersen = persen <= 0.25
        ? Colors.orange
        : const Color(0xFFD94747);

    final Color backgroundPersen = persen <= 0.25
        ? const Color(0xFFFFE8CF)
        : const Color(0xFFFFDCDC);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 74,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F0),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              bahan['gambar'] as IconData,
              color: const Color(0xFF718477),
              size: 36,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bahan['nama'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Sisa ${bahan['sisa']} / Min. ${bahan['minimum']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFB94A45),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: persen,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFF3E8E8),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      bahan['warna'] as Color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: backgroundPersen,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(
              '${(persen * 100).round()}%',
              style: TextStyle(
                color: warnaPersen,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PROFIT CARD =================

  Widget _buildProfitCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE5F3DE),
        border: Border.all(color: const Color(0xFFD0E7C8)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Estimasi Laba Hari Ini',
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Rp 1.112.000',
                    style: TextStyle(
                      color: primary,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '(55.6%)',
                  style: TextStyle(
                    color: Color(0xFF57966B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () => _changeTab(4),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= QUICK ACTIONS =================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            icon: Icons.qr_code_scanner,
            label: 'Opname',
            onTap: () {
              _showMessage('Fitur Opname akan dibuka.');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.shopping_cart,
            label: 'Catat Waste',
            onTap: () {
              _showMessage('Fitur Catat Waste akan dibuka.');
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _quickAction(
            icon: Icons.inventory_2,
            label: 'Katalog',
            onTap: () => _changeTab(1),
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: primary, size: 32),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= BOTTOM NAVIGATION =================

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _changeTab,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: primary,
        unselectedItemColor: const Color(0xFF737B77),
        selectedFontSize: 11,
        unselectedFontSize: 11,
        showUnselectedLabels: true,
        elevation: 0,
        items: List.generate(
          _menuNames.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_menuIcons[index], size: 24),
            activeIcon: Icon(_menuIcons[index], size: 25),
            label: _menuNames[index],
          ),
        ),
      ),
    );
  }

  // ================= OTHER PAGES =================

  Widget _buildOtherPage() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Icon(
                    _menuIcons[_selectedIndex],
                    size: 45,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _menuNames[_selectedIndex],
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Halaman ini akan segera tersedia.',
                  style: TextStyle(fontSize: 14, color: muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= SNACKBAR =================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primary,
      ),
    );
  }
}
