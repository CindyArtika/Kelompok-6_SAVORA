import 'package:flutter/material.dart';
import 'package:tubes_pemmob/widgets/savora_loading.dart';
import 'package:tubes_pemmob/owner/notification_owner.dart';
import 'package:tubes_pemmob/owner/profile_owner.dart';

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
  bool _isLoading = true;

  // Data contoh stok kritis. Nantinya dapat diganti dengan data Firestore.
  final List<Map<String, String>> _criticalStocks = [
    {'name': 'Susu UHT', 'stock': '2 Liter'},
    {'name': 'Biji Kopi', 'stock': '500 Gram'},
    {'name': 'Gula Aren', 'stock': '1 Botol'},
    {'name': 'Krimer', 'stock': '300 Gram'},
  ];

  final List<String> _menuNames = [
    'Beranda',
    'Persetujuan',
    'Laporan',
    'Pengguna',
    'Pengaturan',
  ];

  final List<IconData> _menuIcons = [
    Icons.home_rounded,
    Icons.fact_check_outlined,
    Icons.bar_chart_rounded,
    Icons.people_outline_rounded,
    Icons.settings_outlined,
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


  void _changeTab(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Loading hanya muncul saat dashboard pertama kali dibuka.
    if (_isLoading) {
      return const SavoraLoading(
        title: 'Menyiapkan SAVORA Owner',
        subtitle: 'Menyiapkan dashboard pemilik outlet...',
      );
    }

    // Tombol Back perangkat mengikuti perilaku normal Android.
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: _selectedIndex == 0
            ? _buildDashboard()
            : _buildOtherPage(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  // ================= DASHBOARD OWNER =================

  Widget _buildDashboard() {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 18),

                _buildSummary(),
                const SizedBox(height: 18),

                _buildStockTrend(),
                const SizedBox(height: 18),

                _buildCriticalStock(),
                const SizedBox(height: 18),

                _buildLatestPO(),
                const SizedBox(height: 24),

                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),

                _buildActivityCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Stok susu UHT diperbarui',
                  subtitle: 'Kepala Dapur memperbarui data stok',
                  time: 'Hari ini',
                  color: const Color(0xFFE4F5E9),
                  iconColor: const Color(0xFF21834B),
                ),
                const SizedBox(height: 10),

                _buildActivityCard(
                  icon: Icons.shopping_cart_outlined,
                  title: 'PO baru dibuat',
                  subtitle: 'Admin membuat permintaan pengadaan',
                  time: 'Hari ini',
                  color: const Color(0xFFFFF1DE),
                  iconColor: const Color(0xFFC17B19),
                ),
                const SizedBox(height: 10),

                _buildActivityCard(
                  icon: Icons.check_circle_outline,
                  title: 'Persetujuan PO',
                  subtitle: 'Owner menyetujui pengadaan bahan',
                  time: 'Kemarin',
                  color: const Color(0xFFEAEFF8),
                  iconColor: const Color(0xFF4776B8),
                ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
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
                        color: Color(0xFF78B77A),
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
          GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationOwner(
                    onNavigate: (index) {
                      if (!mounted) return;
                      _changeTab(index);
                    },
                  ),
                ),
              );

              if (mounted) {
                setState(() {});
              }
            },
            child: _headerIcon(
              Icons.notifications_none,
              showDot: NotificationOwner.unreadCount > 0,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileOwner(),
                ),
              );
            },
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

  Widget _headerIcon(
    IconData icon, {
    bool showDot = false,
  }) {
    return Stack(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFEAF0EC),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primary,
            size: 25,
          ),
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
      height: 205,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -18,
            top: 8,
            width: 205,
            height: 190,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFDDEEDD),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                  bottomLeft: Radius.circular(100),
                  topRight: Radius.circular(75),
                  bottomRight: Radius.circular(75),
                ),
              ),
            ),
          ),
          Positioned(
            right: -12,
            top: 8,
            width: 205,
            height: 190,
            child: Image.asset(
              'assets/images/coffee_header.png',
              fit: BoxFit.contain,
              alignment: Alignment.centerRight,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.coffee,
                  size: 115,
                  color: primary,
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            top: 35,
            right: 105,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat datang,',
                  style: TextStyle(
                    color: Color(0xFF506D5F),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  'Owner SAVORA',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: primary,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(height: 9),
                const Text(
                  'Pantau stok dan kelola\npengadaan bahan dengan mudah.',
                  style: TextStyle(
                    fontSize: 12,
                    color: muted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= RINGKASAN OUTLET =================

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                color: primary,
                size: 23,
              ),
              SizedBox(width: 9),
              Text(
                'Ringkasan Outlet',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _ownerMetric(
                  icon: Icons.inventory_2_outlined,
                  title: 'Total Bahan Baku',
                  value: '28',
                  subtitle: 'Jenis bahan',
                  color: const Color(0xFFE4F5E9),
                  iconColor: const Color(0xFF21834B),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ownerMetric(
                  icon: Icons.warning_amber_rounded,
                  title: 'Stok Kritis',
                  value: '4',
                  subtitle: 'Perlu diperhatikan',
                  color: const Color(0xFFFFF1DE),
                  iconColor: const Color(0xFFC17B19),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _ownerMetric(
                  icon: Icons.assignment_outlined,
                  title: 'PO Menunggu',
                  value: '2',
                  subtitle: 'Belum disetujui',
                  color: const Color(0xFFF0E9FA),
                  iconColor: const Color(0xFF8052B5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ownerMetric({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 145),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            maxLines: 2,
            style: const TextStyle(
              color: muted,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ================= TREN STOK BAHAN =================

  Widget _buildStockTrend() {
    const days = [
      'Sen',
      'Sel',
      'Rab',
      'Kam',
      'Jum',
      'Sab',
      'Min',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: primary,
                size: 23,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Tren Stok Kritis 7 Hari',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Mingguan',
                style: TextStyle(
                  color: primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 155,
            width: double.infinity,
            child: CustomPaint(
              painter: _StockChartPainter(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) {
              return Text(
                day,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFEDF0ED)),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: muted,
                size: 15,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Jumlah bahan dengan stok kritis setiap hari.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= DAFTAR STOK KRITIS =================

 Widget _buildCriticalStock() {
  final displayedStocks = _criticalStocks.take(2).toList();

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
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
        Row(
          children: [
            const Expanded(
              child: Text(
                'Daftar Stok Kritis',
                style: TextStyle(
                  color: textColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => _changeTab(1),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: primary,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...displayedStocks.asMap().entries.map((entry) {
          final item = entry.value;
          return Column(
            children: [
              _stockItem(item['name']!, item['stock']!),
              if (entry.key != displayedStocks.length - 1)
                const Divider(color: Color(0xFFEDF0ED)),
            ],
          );
        }),
      ],
    ),
  );
}

  Widget _stockItem(String name, String stock) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFFC17B19),
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sisa stok: $stock',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8E5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Kritis',
              style: TextStyle(
                color: Color(0xFFC74638),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= PERMINTAAN PO TERBARU =================

  Widget _buildLatestPO() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
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
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Permintaan PO Terbaru',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _changeTab(1),
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _poItem(
            'PO-001',
            'Pengadaan Susu UHT',
            'Admin',
          ),
          const Divider(color: Color(0xFFEDF0ED)),
          _poItem(
            'PO-002',
            'Pengadaan Biji Kopi',
            'Admin',
          ),
        ],
      ),
    );
  }

  Widget _poItem(
    String code,
    String description,
    String requester,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAEFF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xFF4776B8),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  code,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Dibuat oleh $requester',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1DE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Menunggu',
              style: TextStyle(
                color: Color(0xFFC17B19),
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= AKTIVITAS TERBARU =================

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ================= HALAMAN LAIN =================

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
                  'Halaman ini akan kita buat berikutnya.',
                  style: TextStyle(
                    fontSize: 14,
                    color: muted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= BOTTOM NAVIGATION =================

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

                if (velocity < -200 &&
                    _selectedIndex < _menuNames.length - 1) {
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
                        selectedCenter:
                            itemWidth * (_selectedIndex + 0.5),
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
                        (index) => Expanded(
                          child: _buildNavItem(index),
                        ),
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
                        color: Color(0xFFACD684),
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

  // ================= NAVIGATION ITEM =================

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
              Icon(
                _menuIcons[index],
                color: Colors.white,
                size: 23,
              )
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

// ================= PAINTER GRAFIK STOK =================

class _StockChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const values = [4.0, 3.0, 5.0, 4.0, 2.0, 3.0, 2.0];

    final chartWidth = size.width - 15;
    final chartHeight = size.height - 15;

    final gridPaint = Paint()
      ..color = const Color(0xFFE9EEE9)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = const Color(0xFF188344)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x6639B66B),
          Color(0x0039B66B),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, chartWidth, chartHeight),
      );

    for (int i = 0; i < 4; i++) {
      final y = chartHeight * i / 3;

      canvas.drawLine(
        Offset(0, y),
        Offset(chartWidth, y),
        gridPaint,
      );
    }

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = chartWidth * i / (values.length - 1);
      final y = chartHeight - (values[i] / 6) * chartHeight;

      points.add(Offset(x, y));
    }

    final linePath = Path()
      ..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final controlX = (previous.dx + current.dx) / 2;

      linePath.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, chartHeight)
      ..lineTo(points.first.dx, chartHeight)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    for (final point in points) {
      canvas.drawCircle(
        point,
        4.5,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        point,
        3.2,
        Paint()..color = const Color(0xFF188344),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StockChartPainter oldDelegate) {
    return false;
  }
}

// ================= PAINTER BOTTOM NAVIGATION =================

class _NotchedNavPainter extends CustomPainter {
  final double selectedCenter;
  final Color color;

  _NotchedNavPainter({
    required this.selectedCenter,
    required this.color,
  });

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

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.22),
      10,
      true,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NotchedNavPainter oldDelegate) {
    return oldDelegate.selectedCenter != selectedCenter ||
        oldDelegate.color != color;
  }
}

class AllCriticalStockPage extends StatelessWidget {
  final List<Map<String, String>> stocks;

  const AllCriticalStockPage({
    super.key,
    required this.stocks,
  });

  static const Color primary = Color(0xFF143C2D);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F5),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Daftar Stok Kritis',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${stocks.length} bahan membutuhkan perhatian',
            style: const TextStyle(
              color: muted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ...stocks.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1DE),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xFFC17B19),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name'] ?? '-',
                          style: const TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Sisa stok: ${item['stock'] ?? '-'}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8E5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Kritis',
                      style: TextStyle(
                        color: Color(0xFFC74638),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
