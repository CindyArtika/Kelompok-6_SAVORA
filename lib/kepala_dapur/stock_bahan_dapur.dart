
import 'package:flutter/material.dart';

class StokBahanDapur extends StatefulWidget {
  const StokBahanDapur({super.key});

  @override
  State<StokBahanDapur> createState() => _StokBahanDapurState();
}

class _StokBahanDapurState extends State<StokBahanDapur> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);
  static const Color lightGreen = Color(0xFFE5F0E3);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatus = 'Semua';

  final List<String> _categories = [
    'Semua',
    'Bahan Minuman',
    'Pastry',
  ];

  final List<String> _statuses = [
    'Semua',
    'Kritis',
    'Menipis',
    'Aman',
  ];

  // DATA BAHAN
  // Data ini masih contoh lokal.
  final List<Map<String, dynamic>> _stocks = [
    {
      'name': 'Susu UHT',
      'stock': '2 Liter',
      'category': 'Susu',
      'status': 'Kritis',
      'updated': '2 jam lalu',
      'color': 0xFFE4F4FA,
    },
    {
      'name': 'Biji Kopi',
      'stock': '500 Gram',
      'category': 'Kopi',
      'status': 'Kritis',
      'updated': '3 jam lalu',
      'color': 0xFFF8EADD,
    },
    {
      'name': 'Gula Aren',
      'stock': '1 Botol',
      'category': 'Gula',
      'status': 'Menipis',
      'updated': '5 jam lalu',
      'color': 0xFFFFF0DB,
    },
    {
      'name': 'Bubuk Matcha',
      'stock': '750 Gram',
      'category': 'Lainnya',
      'status': 'Aman',
      'updated': '6 jam lalu',
      'color': 0xFFEAF3D9,
    },
    {
      'name': 'Sirup Caramel',
      'stock': '300 ml',
      'category': 'Lainnya',
      'status': 'Menipis',
      'updated': '8 jam lalu',
      'color': 0xFFFFEDDA,
    },
    {
      'name': 'Bubuk Cokelat',
      'stock': '1 Kg',
      'category': 'Lainnya',
      'status': 'Aman',
      'updated': '10 jam lalu',
      'color': 0xFFF1E6DD,
    },
    {
      'name': 'Krimer',
      'stock': '300 Gram',
      'category': 'Susu',
      'status': 'Kritis',
      'updated': '12 jam lalu',
      'color': 0xFFF4EDE3,
    },
    {
      'name': 'Gula Pasir',
      'stock': '5 Kg',
      'category': 'Gula',
      'status': 'Aman',
      'updated': '1 hari lalu',
      'color': 0xFFFFF5E7,
    },

    // STOK DESSERT & PASTRY KEMASAN
    {
      'name': 'Butter Croissant',
      'stock': '8 pcs',
      'category': 'Pastry',
      'status': 'Aman',
      'updated': 'Baru ditambahkan',
      'color': 0xFFFFF0E2,
    },
    {
      'name': 'Chocolate Danish',
      'stock': '5 pcs',
      'category': 'Pastry',
      'status': 'Menipis',
      'updated': 'Baru ditambahkan',
      'color': 0xFFF8EADD,
    },
    {
      'name': 'Cinnamon Roll',
      'stock': '0 pcs',
      'category': 'Pastry',
      'status': 'Kritis',
      'updated': 'Baru ditambahkan',
      'color': 0xFFFFE9D9,
    },
  ];

  // RIWAYAT PENGAJUAN STOK
  // Sementara disimpan dalam state lokal.
  final List<Map<String, dynamic>> _requests = [];

  List<Map<String, dynamic>> get _filteredStocks {
    return _stocks.where((item) {
      final name = item['name'].toString().toLowerCase();

      final matchesSearch =
          name.contains(_searchQuery.toLowerCase());

      final matchesCategory =
          _selectedCategory == 'Semua' ||
          (_selectedCategory == 'Bahan Minuman' &&
              item['category'] != 'Pastry') ||
          (_selectedCategory == 'Pastry' &&
              item['category'] == 'Pastry');

      final matchesStatus =
          _selectedStatus == 'Semua' ||
          item['status'] == _selectedStatus;

      return matchesSearch &&
          matchesCategory &&
          matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= HALAMAN UTAMA =================

  @override
  Widget build(BuildContext context) {
    return Container(
      color: background,
      child: Column(
        children: [
          _buildHeader(),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              children: [
                _buildSearch(),

                const SizedBox(height: 16),

                _buildStockSummary(),

                const SizedBox(height: 22),

                _buildCategories(),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Bahan',
                      style: TextStyle(
                        color: primary,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${_filteredStocks.length} bahan',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (_filteredStocks.isEmpty)
                  _buildEmptyState()
                else
                  ..._filteredStocks.map(_stockCard),

                if (_requests.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _buildRequestHistory(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF143C2D), Color(0xFF285A43)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
              ),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stok Bahan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pantau persediaan bahan minuman dan pastry dapur.',
                  style: TextStyle(
                    color: Color(0xFFDCE9E0),
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFDCE9E0),
            size: 22,
          ),
        ],
      ),
    );
  }

  // ================= RINGKASAN STOK =================

  Widget _buildStockSummary() {
    final total = _stocks.length;
    final critical =
        _stocks.where((item) => item['status'] == 'Kritis').length;
    final low =
        _stocks.where((item) => item['status'] == 'Menipis').length;
    final safe =
        _stocks.where((item) => item['status'] == 'Aman').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Persediaan',
          style: TextStyle(
            color: primary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                label: 'Total Bahan',
                value: total.toString(),
                icon: Icons.inventory_2_outlined,
                color: primary,
                backgroundColor: const Color(0xFFE8F0EA),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _summaryCard(
                label: 'Menipis',
                value: low.toString(),
                icon: Icons.trending_down_rounded,
                color: const Color(0xFFE58B00),
                backgroundColor: const Color(0xFFFFF3DE),
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: _summaryCard(
                label: 'Kritis',
                value: critical.toString(),
                icon: Icons.warning_amber_rounded,
                color: const Color(0xFFD92D2D),
                backgroundColor: const Color(0xFFFFE9E9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '$safe bahan dalam kondisi aman',
          style: const TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: primary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: muted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari nama bahan...',
                hintStyle: const TextStyle(
                  color: muted,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primary,
                  size: 25,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: muted,
                        ),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 17),
              ),
            ),
          ),
        ),

        const SizedBox(width: 10),

        GestureDetector(
          onTap: _showStatusFilter,
          child: Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.tune_rounded,
                  color: primary,
                  size: 25,
                ),
                if (_selectedStatus != 'Semua')
                  Positioned(
                    right: 11,
                    top: 10,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE54848),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ================= KATEGORI =================

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final selected =
              _selectedCategory == category;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 9),
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: selected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: selected
                      ? primary
                      : const Color(0xFFDCE8DC),
                ),
                boxShadow: selected
                    ? []
                    : [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(
                    category == 'Pastry'
                        ? Icons.bakery_dining_rounded
                        : category == 'Bahan Minuman'
                            ? Icons.local_cafe_rounded
                            : Icons.grid_view_rounded,
                    size: 18,
                    color: selected ? Colors.white : primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category,
                    style: TextStyle(
                      color: selected
                          ? Colors.white
                          : primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= FILTER STATUS =================

  Future<void> _showStatusFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        String tempStatus = _selectedStatus;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                22, 20, 22, 28,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Status Stok',
                    style: TextStyle(
                      color: primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  ..._statuses.map((status) {
                    return RadioListTile<String>(
                      value: status,
                      // ignore: deprecated_member_use
                      groupValue: tempStatus,
                      activeColor: primary,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        status,
                        style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // ignore: deprecated_member_use
                      onChanged: (value) {
                        setSheetState(() {
                          tempStatus = value!;
                        });
                      },
                    );
                  }),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                          tempStatus,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Terapkan Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        _selectedStatus = result;
      });
    }
  }

  // ================= CARD BAHAN =================

  Widget _stockCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final color = _statusColor(status);
    final bg = _statusBackground(status);

    return GestureDetector(
      onTap: () => _showStockDetail(item),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.055),
              blurRadius: 13,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 78,
              height: 78,
              decoration: BoxDecoration(
                color: Color(item['color'] as int),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                item['category'] == 'Pastry'
                    ? Icons.bakery_dining_rounded
                    : Icons.inventory_2_rounded,
                color: primary,
                size: 38,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      const Icon(
                        Icons.inventory_2_outlined,
                        color: primary,
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Stok: ${item['stock']}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: primary,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Diperbarui ${item['updated']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.circle,
                        color: color,
                        size: 9,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _showStockMenu(item),
                  icon: const Icon(
                    Icons.more_vert,
                    color: muted,
                    size: 21,
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: primary,
                  size: 25,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Kritis':
        return const Color(0xFFD92D2D);
      case 'Menipis':
        return const Color(0xFFE58B00);
      default:
        return const Color(0xFF21834B);
    }
  }

  Color _statusBackground(String status) {
    switch (status) {
      case 'Kritis':
        return const Color(0xFFFFE3E3);
      case 'Menipis':
        return const Color(0xFFFFF1D6);
      default:
        return const Color(0xFFE1F3E3);
    }
  }

  // ================= MENU TITIK TIGA =================

  void _showStockMenu(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (sheetContext) {
        final canRequest =
            item['status'] == 'Kritis' ||
            item['status'] == 'Menipis';

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.info_outline,
                    color: primary,
                  ),
                  title: const Text('Lihat Detail Bahan'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _showStockDetail(item);
                  },
                ),
                if (canRequest)
                  ListTile(
                    leading: const Icon(
                      Icons.add_circle_outline,
                      color: primary,
                    ),
                    title: const Text('Ajukan Kebutuhan Stok'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _ajukanBahan(item);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= DETAIL BAHAN =================

  void _showStockDetail(Map<String, dynamic> item) {
    final status = item['status'] as String;

    final canRequest =
        status == 'Kritis' || status == 'Menipis';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                Row(
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: Color(item['color'] as int),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(
                        item['category'] == 'Pastry'
                            ? Icons.bakery_dining_rounded
                            : Icons.inventory_2_rounded,
                        color: primary,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'],
                            style: const TextStyle(
                              color: primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['category'],
                            style: const TextStyle(
                              color: muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                _detailRow('Jumlah Stok', item['stock']),
                _detailRow('Kategori', item['category']),
                _detailRow('Status', status),
                _detailRow('Terakhir Diperbarui', item['updated']),

                const SizedBox(height: 20),

                if (canRequest)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _ajukanBahan(item);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Ajukan Kebutuhan Stok'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  )
                else
                  const Text(
                    'Stok bahan masih aman. Belum diperlukan pengajuan.',
                    style: TextStyle(
                      color: Color(0xFF21834B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: muted,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ================= AJUKAN STOK =================

  Future<void> _ajukanBahan(
    Map<String, dynamic> item,
  ) async {
    if (item['status'] != 'Kritis' &&
        item['status'] != 'Menipis') {
      return;
    }

    final quantityController = TextEditingController();
    final noteController = TextEditingController();

    final satuan =
        item['stock'].toString().split(' ').last;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Ajukan Kebutuhan Stok',
            style: TextStyle(
              color: primary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'],
                  style: const TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Stok saat ini: ${item['stock']}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 17),

                TextField(
                  controller: quantityController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Jumlah yang dibutuhkan',
                    suffixText: satuan,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Catatan (opsional)',
                    hintText: 'Contoh: Dibutuhkan untuk operasional...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: muted),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final quantity =
                    quantityController.text.trim();

                final parsed = double.tryParse(
                  quantity.replaceAll(',', '.'),
                );

                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Masukkan jumlah kebutuhan yang valid.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, {
                  'quantity': quantity,
                  'note': noteController.text.trim(),
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Kirim Pengajuan'),
            ),
          ],
        );
      },
    );

    quantityController.dispose();
    noteController.dispose();

    if (result == null || !mounted) return;

    setState(() {
      _requests.insert(0, {
        'name': item['name'],
        'stock': item['stock'],
        'quantity': '${result['quantity']} $satuan',
        'note': result['note']!,
        'status': 'Menunggu Diproses Admin',
        'date': DateTime.now(),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Pengajuan ${item['name']} berhasil dibuat.',
        ),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ================= RIWAYAT PENGAJUAN =================

  Widget _buildRequestHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Riwayat Pengajuan',
          style: TextStyle(
            color: primary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 10),

        ..._requests.map((request) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(17),
              border: Border.all(
                color: const Color(0xFFE8EEE8),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: primary,
                      size: 20,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        request['name'],
                        style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFE58B00),
                      size: 16,
                    ),
                  ],
                ),

                const SizedBox(height: 9),

                Text(
                  'Jumlah: ${request['quantity']}',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),

                if ((request['note'] as String).isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    'Catatan: ${request['note']}',
                    style: const TextStyle(
                      color: muted,
                      fontSize: 11,
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1D6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    request['status'],
                    style: const TextStyle(
                      color: Color(0xFFE58B00),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: primary,
              size: 38,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'Bahan Tidak Ditemukan',
            style: TextStyle(
              color: primary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Coba gunakan kata kunci atau filter lainnya.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
