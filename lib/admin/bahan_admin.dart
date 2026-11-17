import 'package:flutter/material.dart';

class BahanAdmin extends StatefulWidget {
  const BahanAdmin({super.key});

  @override
  State<BahanAdmin> createState() => _BahanAdminState();
}

class _BahanAdminState extends State<BahanAdmin> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF3F8F4);
  static const Color textColor = Color(0xFF1D2933);
  static const Color muted = Color(0xFF89958E);
  static const Color line = Color(0xFFE5ECE7);
  static const Color warning = Color(0xFFD47A08);
  static const Color warningBg = Color(0xFFFFF0D8);
  static const Color safe = Color(0xFF27833D);
  static const Color safeBg = Color(0xFFE5F5E2);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _bahan = [
    {
      'nama': 'Fresh Milk Pasteurisasi',
      'kategori': 'Dairy',
      'stok': 4.5,
      'satuan': 'Liter',
      'minimum': 10.0,
      'harga': 22000,
      'gambar': 'assets/images/bahan/fresh_milk.png',
    },
    {
      'nama': 'Biji Kopi Arabika',
      'kategori': 'Coffee',
      'stok': 8.0,
      'satuan': 'Kg',
      'minimum': 5.0,
      'harga': 145000,
      'gambar': 'assets/images/bahan/biji_kopi.png',
    },
    {
      'nama': 'Sirup Vanilla',
      'kategori': 'Syrup',
      'stok': 2.0,
      'satuan': 'Botol',
      'minimum': 5.0,
      'harga': 68000,
      'gambar': 'assets/images/bahan/sirup_vanilla.png',
    },
    {
      'nama': 'Gula Aren',
      'kategori': 'Sweetener',
      'stok': 12.0,
      'satuan': 'Kg',
      'minimum': 4.0,
      'harga': 35000,
      'gambar': 'assets/images/bahan/gula_aren.png',
    },
    {
      'nama': 'Cup Plastik 16 oz',
      'kategori': 'Packaging',
      'stok': 150.0,
      'satuan': 'Pcs',
      'minimum': 50.0,
      'harga': 850,
      'gambar': 'assets/images/bahan/cup_plastik.png',
    },
    {
      'nama': 'Saus Caramel',
      'kategori': 'Syrup',
      'stok': 4.0,
      'satuan': 'Botol',
      'minimum': 5.0,
      'harga': 75000,
      'gambar': 'assets/images/bahan/saus_caramel.png',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // MENGHITUNG STOK KRISIS
  int get _jumlahKrisis {
    return _bahan.where((e) {
      final stok = (e['stok'] as num).toDouble();
      final minimum = (e['minimum'] as num).toDouble();
      return stok <= minimum * 0.5;
    }).length;
  }

  // MENGHITUNG STOK MENIPIS
  int get _jumlahMenipis {
    return _bahan.where((e) {
      final stok = (e['stok'] as num).toDouble();
      final minimum = (e['minimum'] as num).toDouble();
      return stok > minimum * 0.5 && stok <= minimum;
    }).length;
  }

  // MENGHITUNG STOK AMAN
  int get _jumlahAman {
    return _bahan.where((e) {
      final stok = (e['stok'] as num).toDouble();
      final minimum = (e['minimum'] as num).toDouble();
      return stok > minimum;
    }).length;
  }

  // PENCARIAN DAN FILTER BAHAN
  List<Map<String, dynamic>> get _filteredBahan {
    return _bahan.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final kategori = item['kategori'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      final cocokSearch =
          nama.contains(query) || kategori.contains(query);

      final stok = (item['stok'] as num).toDouble();
      final minimum = (item['minimum'] as num).toDouble();

      final krisis = stok <= minimum * 0.5;
      final menipis = stok > minimum * 0.5 && stok <= minimum;
      final aman = stok > minimum;

      final cocokFilter = _selectedFilter == 'Semua' ||
          (_selectedFilter == 'Krisis' && krisis) ||
          (_selectedFilter == 'Menipis' && menipis) ||
          (_selectedFilter == 'Aman' && aman);

      return cocokSearch && cocokFilter;
    }).toList();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primary,
      ),
    );
  }

  Future<void> _showBahanForm({
    Map<String, dynamic>? item,
    int? index,
  }) async {
    final nama = TextEditingController(
      text: item?['nama'] ?? '',
    );

    final kategori = TextEditingController(
      text: item?['kategori'] ?? '',
    );

    final stok = TextEditingController(
      text: item?['stok']?.toString() ?? '',
    );

    final satuan = TextEditingController(
      text: item?['satuan'] ?? '',
    );

    final minimum = TextEditingController(
      text: item?['minimum']?.toString() ?? '',
    );

    final harga = TextEditingController(
      text: item?['harga']?.toString() ?? '',
    );

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        title: Text(
          item == null ? 'Tambah Bahan' : 'Edit Bahan',
          style: const TextStyle(
            color: primary,
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _formField(
                  nama,
                  'Nama bahan',
                  Icons.inventory_2_outlined,
                ),
                const SizedBox(height: 11),
                _formField(
                  kategori,
                  'Kategori',
                  Icons.category_outlined,
                ),
                const SizedBox(height: 11),
                Row(
                  children: [
                    Expanded(
                      child: _formField(
                        stok,
                        'Jumlah stok',
                        Icons.scale_outlined,
                        numeric: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _formField(
                        satuan,
                        'Satuan',
                        Icons.straighten_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                _formField(
                  minimum,
                  'Batas minimum stok',
                  Icons.warning_amber_outlined,
                  numeric: true,
                ),
                const SizedBox(height: 11),
                _formField(
                  harga,
                  'Harga per satuan (Rp)',
                  Icons.payments_outlined,
                  numeric: true,
                ),
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: muted),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final stockValue = double.tryParse(
                stok.text.replaceAll(',', '.'),
              );

              final minValue = double.tryParse(
                minimum.text.replaceAll(',', '.'),
              );

              final priceValue = int.tryParse(harga.text);

              if (nama.text.trim().isEmpty ||
                  kategori.text.trim().isEmpty ||
                  stockValue == null ||
                  satuan.text.trim().isEmpty ||
                  minValue == null ||
                  priceValue == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lengkapi semua data dengan benar.',
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, {
                'nama': nama.text.trim(),
                'kategori': kategori.text.trim(),
                'stok': stockValue,
                'satuan': satuan.text.trim(),
                'minimum': minValue,
                'harga': priceValue,
                'gambar': item?['gambar'] ?? '',
              });
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    nama.dispose();
    kategori.dispose();
    stok.dispose();
    satuan.dispose();
    minimum.dispose();
    harga.dispose();

    if (result == null || !mounted) return;

    setState(() {
      if (index == null) {
        _bahan.insert(0, result);
      } else {
        _bahan[index] = result;
      }
    });

    _showMessage(
      index == null
          ? 'Bahan berhasil ditambahkan.'
          : 'Data bahan berhasil diperbarui.',
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool numeric = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: numeric
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: primary,
          size: 20,
        ),
        labelStyle: const TextStyle(
          color: muted,
          fontSize: 13,
        ),
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  Future<void> _deleteBahan(int index) async {
    final name = _bahan[index]['nama'];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text('Hapus Bahan?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus "$name"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: muted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() {
        _bahan.removeAt(index);
      });

      _showMessage('Bahan berhasil dihapus.');
    }
  }

  void _selectFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }
    @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 105),
          children: [
            _buildHero(),

            const SizedBox(height: 8),

            _buildSummary(),

            const SizedBox(height: 12),

            _buildListHeading(),

            const SizedBox(height: 11),

            _buildSearch(),

            const SizedBox(height: 10),

            _buildFilters(),

            const SizedBox(height: 13),

            if (_filteredBahan.isEmpty)
              _buildEmptyState()
            else
              ..._filteredBahan.map((item) {
                final index = _bahan.indexOf(item);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 13),
                  child: _buildBahanCard(item, index),
                );
              }),
          ],
        ),
      ),

      // Tombol Tambah Bahan tetap di bagian bawah.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBahanForm(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(
          Icons.add_rounded,
          size: 22,
        ),
        label: const Text(
          'Tambah Bahan',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // HEADER BAHAN
    Widget _buildHero() {
      return SizedBox(
        height: 145,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Gambar bahan di sisi kanan dengan tepian yang memudar
            Positioned(
              right: -18,
              top: -15,
              bottom: -5,
              width: 205,
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const RadialGradient(
                    center: Alignment(0.45, 0.45),
                    radius: 0.85,
                    colors: [
                      Colors.black,
                      Colors.black,
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.58, 1.0],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: Image.asset(
                  'assets/images/bahan/header_bahan.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerRight,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),

            // Tulisan header dinaikkan
            Positioned(
              left: 0,
              top: 5,
              right: 115,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bahan',
                    style: TextStyle(
                      color: primary,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Kelola persediaan bahan baku SAVORA\n'
                    'dengan mudah dan terstruktur.',
                    style: TextStyle(
                      color: Color(0xFF58645D),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Container(
                    width: 62,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF83C45E),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

  // RINGKASAN STOK
  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.inventory_2_outlined,
            title: 'Total Bahan',
            value: '${_bahan.length}',
            iconColor: primary,
            iconBg: const Color(0xFFD9F3D4),
            cardBg: const Color(0xFFF8FCF8),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _summaryCard(
            icon: Icons.error_outline_rounded,
            title: 'Stok Krisis',
            value: '$_jumlahKrisis',
            iconColor: Colors.red,
            iconBg: const Color(0xFFFDE8E7),
            cardBg: const Color(0xFFFFF7F6),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _summaryCard(
            icon: Icons.warning_amber_rounded,
            title: 'Stok Menipis',
            value: '$_jumlahMenipis',
            iconColor: warning,
            iconBg: const Color(0xFFFFE7C5),
            cardBg: const Color(0xFFFFF9F1),
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: _summaryCard(
            icon: Icons.verified_user_outlined,
            title: 'Stok Aman',
            value: '$_jumlahAman',
            iconColor: primary,
            iconBg: const Color(0xFFD9F3D4),
            cardBg: const Color(0xFFF8FCF8),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required String value,
    required Color iconColor,
    required Color iconBg,
    required Color cardBg,
  }) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 104,
      ),
      padding: const EdgeInsets.fromLTRB(11, 10, 8, 9),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.07),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),

          const SizedBox(height: 6),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              maxLines: 1,
              style: const TextStyle(
                color: Color(0xFF58645D),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              color: textColor,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // JUDUL DAFTAR BAHAN
  Widget _buildListHeading() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Daftar Bahan',
          style: TextStyle(
            color: textColor,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),

        Text(
          '${_bahan.length} bahan',
          style: const TextStyle(
            color: muted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // SEARCH BAR
  Widget _buildSearch() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      decoration: InputDecoration(
        isDense: true,
        constraints: const BoxConstraints(
          minHeight: 42,
        ),
        hintText: 'Cari nama atau kategori bahan...',
        hintStyle: const TextStyle(
          color: Color(0xFF8B9690),
          fontSize: 12,
        ),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: primary,
          size: 20,
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
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
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: primary,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  // FILTER STOK
  Widget _buildFilters() {
    final filters = [
      ('Semua', _bahan.length),
      ('Krisis', _jumlahKrisis),
      ('Menipis', _jumlahMenipis),
      ('Aman', _jumlahAman),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((entry) {
          final selected = _selectedFilter == entry.$1;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                '${entry.$1} (${entry.$2})',
              ),
              selected: selected,
              onSelected: (_) {
                _selectFilter(entry.$1);
              },
              selectedColor: primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: selected
                    ? Colors.white
                    : const Color(0xFF58645D),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
              side: BorderSide(
                color: selected
                    ? primary
                    : const Color(0xFFDDE6DF),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 9,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
    // CARD SETIAP BAHAN
  Widget _buildBahanCard(
    Map<String, dynamic> item,
    int index,
  ) {
    final stok = (item['stok'] as num).toDouble();
    final minimum = (item['minimum'] as num).toDouble();

    // MENENTUKAN STATUS STOK
    final krisis = stok <= minimum * 0.5;
    final menipis = stok > minimum * 0.5 && stok <= minimum;

    final statusText = krisis
        ? 'Stok krisis'
        : menipis
            ? 'Stok menipis'
            : 'Stok aman';

    final statusColor = krisis
        ? Colors.red
        : menipis
            ? warning
            : safe;

    final statusBg = krisis
        ? const Color(0xFFFDE8E7)
        : menipis
            ? warningBg
            : safeBg;

    final ratio = minimum <= 0 ? 1.0 : stok / minimum;

    final barValue = ratio.clamp(0.0, 1.0);

    final percentText = '${(barValue * 100).round()}%';

    final satuan = item['satuan'].toString();

    final imagePath = item['gambar']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0F3F0),
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 68,
                  height: 68,
                  child: imagePath.isEmpty
                      ? _imageFallback()
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) {
                            return const SizedBox.shrink();
                          },
                        ),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['nama'].toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      item['kategori'].toString(),
                      style: const TextStyle(
                        color: muted,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 11,
                              ),
                              children: [
                                const TextSpan(
                                  text: 'Stok: ',
                                ),

                                TextSpan(
                                  text:
                                      '${_formatNumber(stok)} $satuan',
                                  style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 5),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: statusBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                krisis
                                    ? Icons.error_outline_rounded
                                    : menipis
                                        ? Icons.warning_amber_rounded
                                        : Icons.check_rounded,
                                size: 10,
                                color: statusColor,
                              ),

                              const SizedBox(width: 3),

                              Text(
                                statusText,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 140,
                ),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Color(0xFF7B8981),
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showBahanForm(
                      item: item,
                      index: index,
                    );
                  } else if (value == 'hapus') {
                    _deleteBahan(index);
                  }
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: primary,
                        ),
                        SizedBox(width: 9),
                        Text('Edit bahan'),
                      ],
                    ),
                  ),

                  PopupMenuItem(
                    value: 'hapus',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: Colors.red,
                        ),
                        SizedBox(width: 9),
                        Text('Hapus bahan'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Minimum: ${_formatNumber(minimum)} $satuan',
              style: const TextStyle(
                color: muted,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // PROGRESS BAR STOK
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: barValue,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE9ECE9),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(
                      krisis
                          ? Colors.red
                          : menipis
                              ? const Color(0xFFE98B12)
                              : const Color(0xFF42B51D),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Text(
                percentText,
                style: const TextStyle(
                  color: Color(0xFF53615A),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // GAMBAR PENGGANTI JIKA FOTO BELUM TERSEDIA
  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFEAF2EC),
      child: const Icon(
        Icons.inventory_2_outlined,
        color: primary,
        size: 34,
      ),
    );
  }

  // FORMAT ANGKA STOK
  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1).replaceAll('.', ',');
  }

  // TAMPILAN JIKA BAHAN TIDAK DITEMUKAN
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 38,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: line),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            color: Color(0xFFB7C5BA),
            size: 48,
          ),

          SizedBox(height: 12),

          Text(
            'Bahan tidak ditemukan',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Coba ubah kata kunci atau filter pencarian.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}