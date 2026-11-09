import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubes_pemmob/widgets/savora_loading.dart';
import 'package:tubes_pemmob/admin/notification_admin.dart';
import 'package:tubes_pemmob/admin/profile_admin.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);
  static const Color lightGreen = Color(0xFFE1F0DE);

  int _selectedIndex = 0;
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  // ================= INITIALIZATION =================

  Future<void> _initializeDashboard() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ================= NOTIFICATION =================

  Future<void> _openNotification() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationAdmin(onNavigate: _changeTab),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ================= LOGOUT =================

Future<void> _logout() async {
  try {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // AuthGate otomatis menampilkan IntroSplashScreen.
  } catch (e) {
    if (!mounted) return;
    _showMessage('Gagal logout. Silakan coba lagi.');
  }
}

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Apakah kamu yakin ingin keluar dari akun Admin?',
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

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SavoraLoading(
        title: 'Menyiapkan SAVORA Admin',
        subtitle: 'Menyiapkan dashboard operasional...',
      );
    }

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

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  return const Icon(Icons.store, size: 30, color: primary);
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
                  'SAVORA Admin',
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
                      decoration: BoxDecoration(
                        color: lightGreen,
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

          // Tombol Notifikasi Admin
          GestureDetector(
            onTap: _openNotification,
            child: _headerIcon(
              Icons.notifications_none,
              showDot: NotificationAdmin.unreadCount > 0,
            ),
          ),

          const SizedBox(width: 8),
          // Tombol Profil Admin
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileAdmin()),
              );
            },
            child: const CircleAvatar(
              radius: 22,
              backgroundColor: Color(0xFFDCE8DF),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: primary, size: 25),
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: _showLogoutDialog,
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, color: primary),
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
                  'Halo, Budi',
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
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 100, // sebelumnya 120
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final itemWidth = width / _menuNames.length;

            return GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;

                if (velocity < -200 && _selectedIndex < _menuNames.length - 1) {
                  _changeTab(_selectedIndex + 1);
                } else if (velocity > 200 && _selectedIndex > 0) {
                  _changeTab(_selectedIndex - 1);
                }
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // BACKGROUND NAVIGATION
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchedNavPainter(
                        selectedCenter: itemWidth * (_selectedIndex + 0.5),
                        color: primary,
                      ),
                    ),
                  ),

                  // NAVIGATION ITEMS
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 29,
                    bottom: 0,
                    child: Row(
                      children: List.generate(
                        _menuNames.length,
                        (index) => Expanded(child: _buildNavItem(index)),
                      ),
                    ),
                  ),

                  // FLOATING ACTIVE ICON
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    left: itemWidth * (_selectedIndex + 0.5) - 35,
                    top: 0,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 172, 214, 132),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          _menuIcons[_selectedIndex],
                          color: primary,
                          size: 27,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // NAVIGATION ITEM

  Widget _buildNavItem(int index) {
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _changeTab(index);
      },
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isSelected)
              Icon(_menuIcons[index], color: Colors.white, size: 23)
            else
              const SizedBox(height: 23),

            const SizedBox(height: 5),

            if (isSelected)
              AnimatedOpacity(
                duration: const Duration(milliseconds: 250),
                opacity: 1,
                child: Text(
                  _menuNames[index],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
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

class _NotchedNavPainter extends CustomPainter {
  final double selectedCenter;
  final Color color;

  _NotchedNavPainter({required this.selectedCenter, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    const double top = 30;
    const double notchWidth = 70;
    const double notchDepth = 38;

    path.moveTo(0, top);
    path.lineTo(selectedCenter - notchWidth, top);

    // Cekungan kiri
    path.cubicTo(
      selectedCenter - 35,
      top,
      selectedCenter - 35,
      top + notchDepth,
      selectedCenter,
      top + notchDepth,
    );

    // Cekungan kanan
    path.cubicTo(
      selectedCenter + 35,
      top + notchDepth,
      selectedCenter + 35,
      top,
      selectedCenter + notchWidth,
      top,
    );

    path.lineTo(size.width, top);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.22), 10, true);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedNavPainter oldDelegate) {
    return oldDelegate.selectedCenter != selectedCenter ||
        oldDelegate.color != color;
  }
}
