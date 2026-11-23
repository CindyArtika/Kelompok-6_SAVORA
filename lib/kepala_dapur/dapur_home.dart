import 'package:flutter/material.dart';
import 'package:tubes_pemmob/kepala_dapur/stock_bahan_dapur.dart';
import 'package:tubes_pemmob/kepala_dapur/status_menu_dapur.dart';
import 'package:tubes_pemmob/widgets/savora_loading.dart';
import 'package:tubes_pemmob/kepala_dapur/notification_dapur.dart';
import 'package:tubes_pemmob/kepala_dapur/profile_dapur.dart';
import 'package:tubes_pemmob/kepala_dapur/detail_resep_dapur.dart';
import 'package:tubes_pemmob/services/menu_firestore_service.dart';
import 'package:tubes_pemmob/services/stock_firestore_service.dart';
import 'package:tubes_pemmob/kepala_dapur/menu_status_data.dart';
import 'package:tubes_pemmob/kepala_dapur/data_resep_dapur.dart';

class DapurHome extends StatefulWidget {
  const DapurHome({super.key});

  @override
  State<DapurHome> createState() => _DapurHomeState();
}

class _DapurHomeState extends State<DapurHome> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF2F6F2);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  int _selectedIndex = 0;
  bool _isLoading = true;
  int _currentBannerIndex = 0;
  late final PageController _bannerController;
  bool _bannerForward = true;

  // DATA STATUS MENU UNTUK HALAMAN STATUS MENU
  // Status dapat diubah oleh Kepala Dapur melalui halaman Status Menu.
  final List<Map<String, String>> _menus = menuStatusSavora;

  // DATA RESEP MINUMAN UNTUK HALAMAN DETAIL RESEP
  // Ini adalah contoh takaran awal; sesuaikan dengan resep operasional SAVORA.

  final List<String> _menuNames = ['Beranda', 'Stok Bahan', 'Status Menu'];

  final List<IconData> _menuIcons = [
    Icons.home_rounded,
    Icons.inventory_2_rounded,
    Icons.local_cafe_rounded,
  ];

  @override
  void dispose() {
    _bannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bannerController = PageController();
    MenuFirestoreService.initializeMenus().catchError((error) {
      debugPrint('Gagal menyiapkan data menu: $error');
    });
    _initializeDashboard();
    _startBannerAutoSlide();
  }

  // LOADING AWAL DASHBOARD
  Future<void> _initializeDashboard() async {
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // PINDAH TAB
  void _changeTab(int index) {
    if (index < 0 || index >= _menuNames.length) return;

    setState(() {
      _selectedIndex = index;
    });

    debugPrint('Navigasi aktif: ${_menuNames[index]}');
  }
  // LOGOUT

  // MEMBUKA NOTIFIKASI
  void _openNotification() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationDapur()),
    );
  }

  // MEMBUKA PROFIL
  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileDapur()),
    );
  }

  void _startBannerAutoSlide() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 3));

      if (!mounted) return false;

      if (!_bannerController.hasClients) {
        return true;
      }

      int nextIndex;

      if (_bannerForward) {
        nextIndex = _currentBannerIndex + 1;

        if (nextIndex >= 2) {
          nextIndex = 2;
          _bannerForward = false;
        }
      } else {
        nextIndex = _currentBannerIndex - 1;

        if (nextIndex <= 0) {
          nextIndex = 0;
          _bannerForward = true;
        }
      }

      await _bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );

      return mounted;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SavoraLoading(
        title: 'Menyiapkan SAVORA Kepala Dapur',
        subtitle: 'Menyiapkan dashboard operasional...',
      );
    }

    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _buildDashboard(),

            const StokBahanDapur(),
            StatusMenuDapur(
              menus: _menus,
              // Ketika status menu diubah
              onStatusChanged: (menu, newStatus) {
                setState(() {
                  menu['status'] = newStatus;
                });
              },

              onViewRecipe: (menu) {
                final namaMenu = menu['name'] ?? '';

                // Ambil resep berdasarkan nama menu.
                final dataResep = resepMenuSavora[namaMenu];

                if (dataResep == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Resep $namaMenu belum tersedia.'),
                    ),
                  );
                  return;
                }

                // Gabungkan data resep dengan gambar menu dari daftar menu.
                final resep = <String, dynamic>{
                  ...dataResep,
                  'imageAsset': menu['image'] ?? '',
                };

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailResepDapur(
                      resep: resep,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(),
                const SizedBox(height: 16),
                StreamBuilder(
                  stream: StockFirestoreService.watchStocks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Data stok belum dapat dimuat.'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final stocks = snapshot.data!.docs
                        .map((doc) => StockFirestoreService.normalize(doc.data()))
                        .toList();
                    return Column(
                      children: [
                        _buildSummary(stocks),
                        const SizedBox(height: 8),
                        _buildCriticalStock(stocks),
                        const SizedBox(height: 18),
                        _buildPastryOverview(stocks),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),
                _buildInformationCard(),
                const SizedBox(height: 20),
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
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store_rounded, color: primary, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SAVORA Kepala Dapur',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF39A65B),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Operasional Dapur',
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
          GestureDetector(
            onTap: _openNotification,
            child: ValueListenableBuilder<int>(
              valueListenable: dapurUnreadCount,
              builder: (context, unreadCount, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _headerIcon(Icons.notifications_none_rounded),
                    if (unreadCount > 0)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          width: 11,
                          height: 11,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(width: 8),
          GestureDetector(
            onTap: _openProfile,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2EB),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDCE9DE), width: 1.5),
              ),
              child: const Icon(Icons.person_rounded, color: primary, size: 25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFFEAF2EB),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: primary, size: 24),
    );
  }

  // ================= GREETING =================

  Widget _buildGreeting() {
    final banners = [
      {
        'label': 'SAVORA MANAGEMENT',
        'title': 'Selamat Datang,',
        'heading': 'Kepala Dapur',
        'description': 'Kelola stok bahan, pantau menu, dan pastikan operasional dapur berjalan lancar.',
        'image': 'assets/images/coffee_header.png',
        'color': const Color(0xFFE4F0DE),
      },
      {
        'label': 'STOK BAHAN',
        'title': 'Pantau Stok,',
        'heading': 'Tetap Terkendali',
        'description': 'Periksa ketersediaan bahan dan segera tangani stok yang mulai menipis.',
        'image': 'assets/images/Stock_Bahan.png',
        'color': const Color(0xFFE5F0E8),
      },
      {
        'label': 'STATUS MENU',
        'title': 'Pastikan Menu,',
        'heading': 'Selalu Tersedia',
        'description': 'Perbarui status menu sesuai kondisi bahan agar pelayanan tetap lancar.',
        'image': 'assets/images/Status_Menu.png',
        'color': const Color(0xFFE8F0E5),
      },
    ];

    // Lanjutkan kode PageView.builder kamu yang sebelumnya di sini

    return Column(
      children: [
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: banners.length,
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final banner = banners[index];

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: LinearGradient(
                    colors: [banner['color'] as Color, const Color(0xFFF4F8EF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.07),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -25,
                      top: -35,
                      child: Container(
                        width: 170,
                        height: 170,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      bottom: -45,
                      child: Container(
                        width: 145,
                        height: 145,
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.06),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // GAMBAR BANNER

                    // GAMBAR BANNER - FULL SISI KANAN
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      width: 205,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(26),
                          bottomRight: Radius.circular(26),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              banner['image'] as String,
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              errorBuilder: (context, error, stackTrace) {
                                return const SizedBox.shrink();
                              },
                            ),

                            // MEMBUAT PERALIHAN GAMBAR LEBIH HALUS
                            DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    banner['color'] as Color,
                                    (banner['color'] as Color).withValues(
                                      alpha: 0.0,
                                    ),
                                  ],
                                  stops: const [0.0, 0.55],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // TEKS BANNER
                    Positioned(
                      left: 20,
                      top: 20,
                      right: 125,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              banner['label'] as String,
                              style: const TextStyle(
                                color: primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            banner['title'] as String,
                            style: const TextStyle(
                              color: Color(0xFF426B55),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            banner['heading'] as String,
                            maxLines: 2,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 23,
                              height: 1.1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            banner['description'] as String,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF456452),
                              fontSize: 10,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // INDIKATOR 3 BANNER
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final isActive = _currentBannerIndex == index;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: isActive ? primary : primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ================= RINGKASAN DAPUR =================

  Widget _buildSummary(List<Map<String, dynamic>> stocks) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF39885A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Ringkasan Dapur',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  icon: Icons.inventory_2_outlined,
                  title: 'Total Bahan',
                  value: stocks.length.toString(),
                  subtitle: 'Jenis bahan',
                  color: const Color(0xFFEAF4EA),
                  iconColor: const Color(0xFF26764A),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _summaryItem(
                  icon: Icons.warning_amber_rounded,
                  title: 'Stok Kritis',
                  value: stocks.where((item) => item['status'] == 'Kritis').length.toString(),
                  subtitle: 'Perlu perhatian',
                  color: const Color(0xFFFFF1DF),
                  iconColor: const Color(0xFFFF7900),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: StreamBuilder(
                  stream: MenuFirestoreService.watchMenus(),
                  builder: (context, menuSnapshot) {
                    final totalHabis = menuSnapshot.hasData
                        ? menuSnapshot.data!.docs.where(
                            (doc) => doc.data()['status'] == 'Habis',
                          ).length
                        : 0;
                    return _summaryItem(
                      icon: Icons.local_drink_outlined,
                      title: 'Menu Habis',
                      value: totalHabis.toString(),
                      subtitle: 'Tidak tersedia',
                      color: const Color(0xFFF1EAFE),
                      iconColor: const Color(0xFF8651D6),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(11, 12, 8, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -28,
            child: Container(
              width: 75,
              height: 55,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(height: 11),
              Text(
                title,
                maxLines: 2,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
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
        ],
      ),
    );
  }

  // ================= STOK KRITIS =================

  Widget _buildCriticalStock(List<Map<String, dynamic>> stocks) {
    final displayedStocks = stocks.where((item) => item['category'] == 'Bahan Minuman' && (item['status'] == 'Kritis' || item['status'] == 'Menipis')).take(3).toList();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFF39885A),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Colors.white,
                  size: 23,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok Bahan Minuman',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Persediaan bahan untuk pembuatan minuman',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _changeTab(1),
                child: const Text(
                  'Lihat Semua ›',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayedStocks.asMap().entries.map((entry) {
            final item = entry.value;

            return Column(
              children: [
                _stockItem(
                  item['name'].toString(),
                  item['stock'].toString(),
                  item['status'].toString(),
                  image: item['image']?.toString() ?? '',
                ),
                if (entry.key != displayedStocks.length - 1)
                  const Divider(
                    color: Color(0xFFF0F2EF),
                    height: 1,
                    indent: 55,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _stockItem(
    String name,
    String stock,
    String status, {
    IconData icon = Icons.inventory_2_rounded,
    String image = '',
  }) {
    final bool critical = status == 'Kritis' || status == 'Habis';
    final bool available = status == 'Tersedia';
    final Color statusBg = critical
        ? const Color(0xFFFFE3E1)
        : available
        ? const Color(0xFFE5F3E8)
        : const Color(0xFFFFF0D8);
    final Color statusFg = critical
        ? const Color(0xFFE33D32)
        : available
        ? const Color(0xFF26764A)
        : const Color(0xFFD28A18);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: icon == Icons.bakery_dining_rounded
                  ? const Color(0xFFFFF0E2)
                  : critical
                  ? const Color(0xFFFFF0E2)
                  : available
                  ? const Color(0xFFEAF3E9)
                  : const Color(0xFFFFF5E5),
              borderRadius: BorderRadius.circular(15),
            ),
            child: image.isNotEmpty
                ? Image.asset(
                    image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      icon,
                      color: icon == Icons.bakery_dining_rounded
                          ? const Color(0xFFB87538)
                          : const Color(0xFF398354),
                      size: 25,
                    ),
                  )
                : Icon(
                    icon,
                    color: icon == Icons.bakery_dining_rounded
                        ? const Color(0xFFB87538)
                        : const Color(0xFF398354),
                    size: 25,
                  ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Sisa stok: $stock',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusFg,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 5),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF9BA49D),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ================= STOK BAHAN PASTRY =================

  Widget _buildPastryOverview(List<Map<String, dynamic>> stocks) {
    final displayedPastry = stocks.where((item) => item['category'] == 'Pastry').take(3).toList();

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bakery_dining_rounded,
                  color: Color(0xFFB87538),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok Bahan Pastry',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Persediaan dessert dan pastry kemasan',
                      style: TextStyle(color: muted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => _changeTab(1),
                child: const Text(
                  'Lihat Semua ›',
                  style: TextStyle(
                    color: primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...displayedPastry.asMap().entries.map((entry) {
            final item = entry.value;
            return Column(
              children: [
                _stockItem(
                  item['name'].toString(),
                  item['stock'].toString(),
                  item['status'].toString(),
                  icon: Icons.bakery_dining_rounded,
                  image: item['image']?.toString() ?? '',
                ),
                if (entry.key != displayedPastry.length - 1)
                  const Divider(
                    color: Color(0xFFF0F2EF),
                    height: 1,
                    indent: 55,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ================= STATUS MENU =================

  // ================= INFORMASI =================

  Widget _buildInformationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF236D3E), Color(0xFF12432D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            color: Color(0xFFFFE47A),
            size: 36,
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Dapur',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 7),
                Text(
                  'Periksa stok bahan, minuman, dessert, dan pastry secara rutin. '
                  'Pastikan produk yang habis segera diperbarui statusnya.',
                  style: TextStyle(
                    color: Color(0xFFD9E9DC),
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white,
            size: 27,
          ),
        ],
      ),
    );
  }

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
}

// ================= PAINTER NAVBAR =================

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
