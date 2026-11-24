import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tubes_pemmob/services/menu_firestore_service.dart';
import 'package:tubes_pemmob/kasir/menu_kasir.dart';
class KasirHome extends StatefulWidget {
  const KasirHome({super.key});

  @override
  State<KasirHome> createState() => _KasirHomeState();
}

class _KasirHomeState extends State<KasirHome> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF2F6F2);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    MenuFirestoreService.initializeMenus().catchError((error) {
      debugPrint('Gagal menyiapkan data menu: $error');
    });
  }

  // Empat tab Kasir, memakai gaya navbar custom milik Kepala Dapur.
  final List<String> _menuNames = ['Beranda', 'Menu', 'Transaksi', 'Riwayat'];

  final List<IconData> _menuIcons = [
    Icons.home_rounded,
    Icons.local_cafe_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
  ];

  // Data contoh untuk tampilan. Belum terhubung ke Firestore.
  final List<Map<String, String>> _recentTransactions = [
    {
      'code': 'TRX-00427',
      'items': 'Latte • Croissant',
      'total': 'Rp 48.000',
      'time': '09:36 WIB',
    },
    {
      'code': 'TRX-00426',
      'items': 'Matcha Latte',
      'total': 'Rp 32.000',
      'time': '09:20 WIB',
    },
    {
      'code': 'TRX-00425',
      'items': 'Americano • Pain au Chocolat',
      'total': 'Rp 55.000',
      'time': '09:05 WIB',
    },
  ];

  void _changeTab(int index) {
    if (index < 0 || index >= _menuNames.length) return;
    setState(() => _selectedIndex = index);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(color: primary, fontWeight: FontWeight.w800),
        ),
        content: const Text('Apakah kamu yakin ingin keluar dari akun Kasir?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal', style: TextStyle(color: muted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),

            MenuKasirPage(
              header: _buildHeader(),
            ),

            _buildPlaceholder(
              'Transaksi Penjualan',
              'Pilih menu dan proses pesanan pelanggan.',
              Icons.shopping_bag_rounded,
            ),

            _buildPlaceholder(
              'Riwayat Transaksi',
              'Lihat transaksi penjualan yang sudah dilakukan.',
              Icons.receipt_long_rounded,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // Header mengikuti gaya header DapurHome, tombol profil diganti logout.
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFE2F0DF),
              borderRadius: BorderRadius.circular(17),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SAVORA Kasir',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xFF39A65B), size: 8),
                    SizedBox(width: 6),
                    Text(
                      'Pelayanan Penjualan',
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout_rounded, color: primary),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 17),
                _buildSummary(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildRecentTransactions(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF236D3E), Color(0xFF12432D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.16),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            bottom: -24,
            child: Icon(
              Icons.local_cafe_rounded,
              size: 130,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'SAVORA POINT OF SALE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Halo, Kasir! 👋',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Siap melayani pesanan hari ini?',
                style: TextStyle(color: Color(0xFFDCE9E0), fontSize: 12),
              ),
              const SizedBox(height: 17),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _todayLabel(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            color: primary,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.shopping_cart_outlined,
                title: 'Total Transaksi',
                value: '24',
                subtitle: 'Transaksi hari ini',
                iconColor: const Color(0xFF26764A),
                cardColor: const Color(0xFFEAF4EA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                icon: Icons.payments_outlined,
                title: 'Total Pendapatan',
                value: 'Rp 1,24 jt',
                subtitle: 'Pendapatan hari ini',
                iconColor: const Color(0xFF26764A),
                cardColor: const Color(0xFFEAF4EA),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.check_circle_outline_rounded,
                title: 'Pesanan Selesai',
                value: '22',
                subtitle: 'Pesanan diproses',
                iconColor: const Color(0xFF26764A),
                cardColor: const Color(0xFFEAF4EA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _summaryCard(
                icon: Icons.local_cafe_outlined,
                title: 'Status Menu',
                value: '18 tersedia',
                subtitle: '2 menu habis',
                iconColor: const Color(0xFFB87538),
                cardColor: const Color(0xFFFFF1E5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        const Text(
          '* Angka di atas merupakan data contoh tampilan.',
          style: TextStyle(color: muted, fontSize: 9),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color iconColor,
    required Color cardColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 132),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: const Color(0xFFE8EEE8)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.045),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 39,
            height: 39,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: primary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: muted, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _quickAction(
            title: 'Buat Transaksi',
            icon: Icons.point_of_sale_rounded,
            filled: true,
            onTap: () => _changeTab(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _quickAction(
            title: 'Lihat Menu',
            icon: Icons.local_cafe_rounded,
            filled: false,
            onTap: () => _changeTab(1),
          ),
        ),
      ],
    );
  }

  Widget _quickAction({
    required String title,
    required IconData icon,
    required bool filled,
    required VoidCallback onTap,
  }) {
    return Material(
      color: filled ? primary : Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: filled ? primary : const Color(0xFFB8CDBB),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: filled ? Colors.white : primary, size: 21),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: filled ? Colors.white : primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: filled ? Colors.white : primary,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(23),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Transaksi Terbaru',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _changeTab(3),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ..._recentTransactions.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                _transactionItem(item),
                if (entry.key != _recentTransactions.length - 1)
                  const Divider(
                    color: Color(0xFFF0F2EF),
                    height: 1,
                    indent: 58,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _transactionItem(Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['code']!,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['items']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item['total']!,
                style: const TextStyle(
                  color: primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item['time']!,
                style: const TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9BA49D),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String title, String description, IconData icon) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5F0E8),
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Icon(icon, color: primary, size: 42),
                  ),
                  const SizedBox(height: 17),
                  Text(
                    title,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: muted,
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Halaman ini akan kita buat pada tahap berikutnya.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================= NAVBAR: SAMA DENGAN KEPALA DAPUR =================

  Widget _buildBottomNavigation() {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 100,
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
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _NotchedNavPainter(
                        selectedCenter: itemWidth * (_selectedIndex + 0.5),
                        color: primary,
                      ),
                    ),
                  ),
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

  Widget _buildNavItem(int index) {
    final bool isSelected = _selectedIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _changeTab(index),
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
}

// Painter navbar disalin mengikuti bentuk notch pada DapurHome.
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
    path.cubicTo(
      selectedCenter - 35,
      top,
      selectedCenter - 35,
      top + notchDepth,
      selectedCenter,
      top + notchDepth,
    );
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
