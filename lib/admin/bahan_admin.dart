import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tubes_pemmob/services/firestore_services.dart';

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

  final FirestoreService _firestoreService = FirestoreService();

  StreamSubscription? _bahanSubscription;
  bool _sedangMemuat = true;

  @override
  void initState() {
    super.initState();
    _dengarkanDataBahan();
  }

  
  void _dengarkanDataBahan() {
    _bahanSubscription = _firestoreService.streamBahan().listen(
      (snapshot) {
        if (!mounted) return;

        setState(() {
          _bahan
            ..clear()
            ..addAll(snapshot.docs.map((doc) {
              return {
                ..._firestoreService.konversiDataBahan(doc.data()),
                'id': doc.id,
              };
            }));

          _sedangMemuat = false;
        });
      },
      onError: (error) {
        debugPrint('Gagal mengambil data bahan: $error');

        if (!mounted) return;

        setState(() {
          _sedangMemuat = false;
        });

        _showMessage('Gagal memuat data bahan dari Firestore.');
      },
    );
  }

  final List<Map<String, dynamic>> _bahan = [];

  @override
  void dispose() {
    _bahanSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // MENGHITUNG STATUS STOK
  double _nilaiStok(Map<String, dynamic> item, String key) {
    return (item[key] as num?)?.toDouble() ?? 0;
  }

  bool _stokKrisis(Map<String, dynamic> item) {
    return _nilaiStok(item, 'stok') <=
        _nilaiStok(item, 'criticalThreshold');
  }

  bool _stokMenipis(Map<String, dynamic> item) {
    final stok = _nilaiStok(item, 'stok');
    final kritis = _nilaiStok(item, 'criticalThreshold');
    final minimum = _nilaiStok(item, 'minimum');

    return stok > kritis && stok <= minimum;
  }

  bool _stokAman(Map<String, dynamic> item) {
    return _nilaiStok(item, 'stok') >
        _nilaiStok(item, 'minimum');
  }

  int get _jumlahKrisis =>
      _bahan.where(_stokKrisis).length;

  int get _jumlahMenipis =>
      _bahan.where(_stokMenipis).length;

  int get _jumlahAman =>
      _bahan.where(_stokAman).length;

  // PENCARIAN DAN FILTER BAHAN
  List<Map<String, dynamic>> get _filteredBahan {
    return _bahan.where((item) {
      final nama = item['nama'].toString().toLowerCase();
      final kategori = item['kategori'].toString().toLowerCase();

      final kategoriUtama =
          (item['kategoriUtama'] ?? '').toString().toLowerCase();

      final query = _searchQuery.toLowerCase();

      final cocokSearch =
          nama.contains(query) ||
          kategori.contains(query) ||
          kategoriUtama.contains(query);

      final krisis = _stokKrisis(item);
      final menipis = _stokMenipis(item);
      final aman = _stokAman(item);

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
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => FormBahanPage(item: item),
      ),
    );

    if (result == null || !mounted) return;

    try {
      final id = item?['id']?.toString();

      if (id == null || id.isEmpty) {
        // Simpan bahan baru ke Firestore
        await _firestoreService.tambahBahan(result);

        if (!mounted) return;
        _showMessage('Bahan berhasil ditambahkan.');
      } else {
        // Perbarui dokumen bahan yang sudah ada
        await _firestoreService.updateBahan(id, result);

        if (!mounted) return;
        _showMessage('Data bahan berhasil diperbarui.');
      }

      // Daftar bahan akan diperbarui otomatis oleh streamBahan().
    } catch (e, stackTrace) {
      debugPrint('GAGAL MENYIMPAN BAHAN: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      _showMessage('Gagal menyimpan: $e');
    }
  }


  // DIALOG TAMBAH STOK BAHAN
  Future<void> _showTambahStokDialog(
    Map<String, dynamic> item,
  ) async {
    final jumlahController = TextEditingController();
    final catatanController = TextEditingController();

    final nama = item['nama']?.toString() ?? '';
    final satuan = item['satuan']?.toString() ?? '';
    final id = item['id']?.toString() ?? '';

    if (id.isEmpty) {
      _showMessage('ID bahan tidak ditemukan.');
      return;
    }

    final jumlahStok = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Tambah Stok Bahan',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Stok saat ini: '
                  '${_formatNumber((item['stok'] as num?) ?? 0)} $satuan',
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Jumlah stok masuk',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: jumlahController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Contoh: 10',
                    suffixText: satuan,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Catatan (opsional)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                TextField(
                  controller: catatanController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Pembelian dari supplier',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final jumlah = double.tryParse(
                  jumlahController.text.trim().replaceAll(',', '.'),
                );

                if (jumlah == null || jumlah <= 0) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Masukkan jumlah stok yang valid.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, jumlah);
              },
              child: const Text('Simpan Stok'),
            ),
          ],
        );
      },
    );

    final catatan = catatanController.text.trim();

    // Tunggu animasi penutupan dialog selesai.
    await Future.delayed(const Duration(milliseconds: 300));

    jumlahController.dispose();
    catatanController.dispose();

    if (jumlahStok == null || !mounted) return;

    try {
      await _firestoreService.tambahStokBahan(
        id: id,
        jumlah: jumlahStok,
        catatan: catatan,
      );

      if (!mounted) return;

      _showMessage(
        'Stok $nama berhasil ditambahkan.',
      );
    } catch (e, stackTrace) {
      debugPrint('GAGAL MENAMBAH STOK: $e');
      debugPrint('STACK TRACE: $stackTrace');

      if (!mounted) return;

      _showMessage('Gagal menambahkan stok: $e');
    }
  }

  Future<void> _deleteBahan(int index) async {
    final item = _bahan[index];
    final name = item['nama'];
    final id = item['id']?.toString();

    if (id == null || id.isEmpty) {
      _showMessage('ID bahan tidak ditemukan.');
      return;
    }

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

    if (confirm != true || !mounted) return;

    try {
      await _firestoreService.hapusBahan(id);

      if (!mounted) return;
      _showMessage('Bahan berhasil dihapus.');
    } catch (e) {
      debugPrint('Gagal menghapus bahan: $e');

      if (!mounted) return;
      _showMessage('Gagal menghapus bahan dari Firestore.');
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

            if (_sedangMemuat)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(
                  child: CircularProgressIndicator(
                    color: primary,
                  ),
                ),
              )
            else if (_filteredBahan.isEmpty)
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
    final krisis = _stokKrisis(item);
    final menipis = _stokMenipis(item);

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

    
    // TARGET STOK AMAN = 2 KALI BATAS MINIMUM
    final targetStokAman = minimum * 2;

    // MENGHITUNG PERSENTASE STOK
    final ratio = targetStokAman <= 0
        ? 0.0
        : stok / targetStokAman;

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
                      : imagePath.startsWith('assets/')
                          ? Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imageFallback(),
                            )
                          : Image.file(
                              File(imagePath),
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imageFallback(),
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
                      item['kategori']?.toString() ?? '',
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
                    valueColor: AlwaysStoppedAnimation<Color>(
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

          // TOMBOL TAMBAH STOK
          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showTambahStokDialog(item),
              icon: const Icon(
                Icons.add_circle_outline_rounded,
                size: 17,
              ),
              label: const Text(
                'Tambah Stok',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(
                  color: Color(0xFFD5E4D9),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
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
class FormBahanPage extends StatefulWidget {
  final Map<String, dynamic>? item;

  const FormBahanPage({
    super.key,
    this.item,
  });

  @override
  State<FormBahanPage> createState() => _FormBahanPageState();
}

class _FormBahanPageState extends State<FormBahanPage> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);
  static const Color borderColor = Color(0xFFE5ECE6);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController namaController;
  late final TextEditingController stokController;
  late final TextEditingController hargaController;
  late final TextEditingController minimumController;

  // KATEGORI SESUAI FIRESTORE TIM
  final List<String> kategoriList = [
    'Bahan Minuman',
    'Pastry',
    'Bahan Operasional',
  ];

  // PILIHAN SATUAN
  final List<String> satuanList = [
    'Kg',
    'Gram',
    'Liter',
    'Ml',
    'Botol',
    'Pcs',
    'Box',
    'Pack',
    'Sachet',
    'Kotak',
    'Karton',
  ];

  String? kategoriTerpilih;
  String? satuanTerpilih;

  double minimumStok = 0;
  double jumlahStok = 0;
  XFile? gambarTerpilih;

  final ImagePicker _picker = ImagePicker();

    Future<String> _simpanGambarPermanen(XFile gambar) async {
    // Ambil direktori penyimpanan permanen aplikasi
    final directory = await getApplicationDocumentsDirectory();

    // Buat folder khusus untuk gambar bahan
    final folder = Directory('${directory.path}/gambar_bahan');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // Ambil ekstensi gambar
    String extension = '.jpg';

    final titikTerakhir = gambar.path.lastIndexOf('.');
    if (titikTerakhir != -1) {
      extension = gambar.path.substring(titikTerakhir);
    }

    // Buat nama file unik
    final namaFile =
        'bahan_${DateTime.now().microsecondsSinceEpoch}$extension';

    // Salin gambar dari cache ke penyimpanan permanen
    final fileBaru = await File(gambar.path).copy(
      '${folder.path}/$namaFile',
    );

    return fileBaru.path;
  }

  bool get isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();

    final item = widget.item;

    namaController = TextEditingController(
      text: item?['nama']?.toString() ?? '',
    );

    jumlahStok = (item?['stok'] as num?)?.toDouble() ?? 0;

    stokController = TextEditingController(
      text: _formatJumlah(jumlahStok),
    );

    hargaController = TextEditingController(
      text: _formatRupiah(
        (item?['harga'] as num?)?.toInt() ?? 0,
      ),
    );

    // Inisialisasi batas minimum
    minimumStok = (item?['minimum'] as num?)?.toDouble() ?? 0;

    minimumController = TextEditingController(
      text: item != null ? _formatJumlah(minimumStok) : '',
    );

    if (item != null) {
      kategoriTerpilih = item['kategori']?.toString();
      satuanTerpilih = item['satuan']?.toString();
    }
  }

  @override
  void dispose() {
    namaController.dispose();
    stokController.dispose();
    hargaController.dispose();
    minimumController.dispose();
    super.dispose();
  }

  String _formatJumlah(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toString().replaceAll('.', ',');
  }

  String _formatRupiah(int value) {
    final angka = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < angka.length; i++) {
      buffer.write(angka[i]);

      final sisa = angka.length - i - 1;
      if (sisa > 0 && sisa % 3 == 0) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  int _parseRupiah(String value) {
    return int.tryParse(value.replaceAll('.', '').replaceAll(',', '')) ?? 0;
  }

  void _pilihKategori(String? value) {
    if (value == null) return;

    setState(() {
      kategoriTerpilih = value;
    });
  }

  void _ubahStok(double perubahan) {
    setState(() {
      jumlahStok = (jumlahStok + perubahan).clamp(0, 999999).toDouble();
      stokController.text = _formatJumlah(jumlahStok);
      stokController.selection = TextSelection.collapsed(
        offset: stokController.text.length,
      );
    });
  }

  Widget _label(String text, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (required)
            const Text(
              ' *',
              style: TextStyle(color: Colors.red),
            ),
        ],
      ),
    );
  }

  InputDecoration _decoration({
    String? hint,
    Widget? prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primary, width: 1.4),
      ),
    );
  }
  // MEMILIH GAMBAR DARI GALERI HP
  Future<void> _pilihGambar() async {
    final XFile? gambar = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (gambar != null && mounted) {
      setState(() {
        gambarTerpilih = gambar;
      });
    }
  }

  // PREVIEW GAMBAR BAHAN
  Widget _inputGambar() {
    final gambarLama = widget.item?['gambar']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Foto Bahan'),
        GestureDetector(
          onTap: _pilihGambar,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF2EC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            clipBehavior: Clip.antiAlias,
            child: gambarTerpilih != null
                ? Image.file(
                    File(gambarTerpilih!.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                  )
                : gambarLama.isNotEmpty
                    ? (gambarLama.startsWith('assets/')
                        ? Image.asset(
                            gambarLama,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) =>
                                _placeholderGambar(),
                          )
                        : Image.file(
                            File(gambarLama),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, _, _) =>
                                _placeholderGambar(),
                          ))
                    : _placeholderGambar(),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _pilihGambar,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(
              gambarTerpilih != null || gambarLama.isNotEmpty
                  ? 'Ganti Gambar'
                  : 'Pilih dari Galeri',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primary,
              side: const BorderSide(color: primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const Text(
          'Pilih foto bahan dari galeri HP.',
          style: TextStyle(color: muted, fontSize: 11),
        ),
      ],
    );
  }

  Widget _placeholderGambar() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 42,
            color: primary,
          ),
          SizedBox(height: 8),
          Text(
            'Belum ada gambar bahan',
            style: TextStyle(
              color: muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputNama() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Nama Bahan'),
        TextFormField(
          controller: namaController,
          onChanged: (_) {
            setState(() {});
          },
          textCapitalization: TextCapitalization.words,
          decoration: _decoration(
            hint: 'Contoh: Fresh Milk Pasteurisasi',
            prefix: const Icon(
              Icons.inventory_2_outlined,
              color: primary,
              size: 20,
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Nama bahan wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

    Widget _inputKategori() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('Kategori'),
          DropdownButtonFormField<String>(
            initialValue: kategoriList.contains(kategoriTerpilih)
                ? kategoriTerpilih
                : null,
            isExpanded: true,
            decoration: _decoration(
              hint: 'Pilih kategori bahan',
              prefix: const Icon(
                Icons.category_outlined,
                color: primary,
                size: 20,
              ),
            ),
            items: kategoriList.map((kategori) {
              return DropdownMenuItem(
                value: kategori,
                child: Text(kategori),
              );
            }).toList(),
            onChanged: _pilihKategori,
            validator: (value) {
              if (value == null) {
                return 'Pilih kategori bahan';
              }
              return null;
            },
          ),
        ],
      );
    }

  Widget _inputStok() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Jumlah Stok'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: stokController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _decoration(
                  hint: '0',
                ),
                onChanged: (value) {
                  final parsed = double.tryParse(
                    value.replaceAll(',', '.'),
                  );

                  if (parsed != null && parsed >= 0) {
                    jumlahStok = parsed;
                  }
                },
                validator: (value) {
                  final parsed = double.tryParse(
                    (value ?? '').replaceAll(',', '.'),
                  );

                  if (parsed == null || parsed < 0) {
                    return 'Masukkan jumlah stok yang valid';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 8),
            _tombolStok(
              icon: Icons.remove,
              onTap: () => _ubahStok(-1),
            ),
            const SizedBox(width: 6),
            _tombolStok(
              icon: Icons.add,
              onTap: () => _ubahStok(1),
              filled: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _tombolStok({
    required IconData icon,
    required VoidCallback onTap,
    bool filled = false,
  }) {
    return Material(
      color: filled ? primary : const Color(0xFFE8F0E9),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 43,
          height: 53,
          child: Icon(
            icon,
            color: filled ? Colors.white : primary,
          ),
        ),
      ),
    );
  }

  Widget _inputSatuan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Satuan'),
        DropdownButtonFormField<String>(
          initialValue: satuanList.contains(satuanTerpilih)
              ? satuanTerpilih
              : null,
          isExpanded: true,
          decoration: _decoration(
            hint: 'Pilih satuan',
            prefix: const Icon(
              Icons.straighten_rounded,
              color: primary,
              size: 20,
            ),
          ),
          items: satuanList.map((satuan) {
            return DropdownMenuItem(
              value: satuan,
              child: Text(satuan),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => satuanTerpilih = value);
          },
          validator: (value) {
            if (value == null) return 'Pilih satuan bahan';
            return null;
          },
        ),
      ],
    );
  }

  Widget _inputMinimum() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Batas Minimum Stok'),
        TextFormField(
          controller: minimumController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: _decoration(
            hint: 'Masukkan batas minimum stok',
            prefix: const Icon(
              Icons.warning_amber_outlined,
              color: primary,
              size: 20,
            ),
          ),
          onChanged: (value) {
            minimumStok =
                double.tryParse(value.replaceAll(',', '.')) ?? 0;
            setState(() {});
          },
          validator: (value) {
            final minimum = double.tryParse(
              (value ?? '').replaceAll(',', '.'),
            );

            if (minimum == null || minimum <= 0) {
              return 'Masukkan batas minimum lebih dari 0';
            }

            return null;
          },
        ),
        const SizedBox(height: 6),
        const Text(
          'Batas kritis dihitung otomatis sebesar 50% dari batas minimum.',
          style: TextStyle(color: muted, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Text(
          'Batas kritis: ${_formatJumlah(minimumStok * 0.5)}',
          style: const TextStyle(
            color: primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _inputHarga() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Harga per Satuan'),
        TextFormField(
          controller: hargaController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            _RupiahInputFormatter(),
          ],
          decoration: _decoration(
            hint: '0',
            prefix: const Padding(
              padding: EdgeInsets.only(left: 14, right: 10),
              child: Center(
                widthFactor: 1,
                child: Text(
                  'Rp',
                  style: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Harga wajib diisi';
            }
            return null;
          },
        ),
      ],
    );
  }

    Future<void> _simpanBahan() async {

    if (!_formKey.currentState!.validate()) return;

    try {
      final stok = double.parse(
        stokController.text.replaceAll(',', '.'),
      );

      final harga = _parseRupiah(hargaController.text);

      // Gunakan gambar lama jika tidak memilih gambar baru
      String gambarPath =
          widget.item?['gambar']?.toString() ?? '';

      // Jika memilih gambar baru, salin ke penyimpanan permanen
      if (gambarTerpilih != null) {
        gambarPath = await _simpanGambarPermanen(gambarTerpilih!);
      }

      if (!mounted) return;

      Navigator.pop(context, {
        'nama': namaController.text.trim(),
        'kategori': kategoriTerpilih,
        'stok': stok,
        'satuan': satuanTerpilih,
        'minimum': minimumStok,
        'harga': harga,
        'gambar': gambarPath,
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan bahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: background,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primary,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Edit Bahan' : 'Tambah Bahan',
          style: const TextStyle(
            color: textColor,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFE5F0E6),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    color: primary,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informasi Bahan',
                          style: TextStyle(
                            color: primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lengkapi informasi bahan baku untuk persediaan SAVORA.',
                          style: TextStyle(
                            color: muted,
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _inputGambar(),
            const SizedBox(height: 22),
            _inputNama(),
            const SizedBox(height: 19),
            _inputKategori(),
            const SizedBox(height: 19),

            // KOLOM NONAKTIF JIKA SUBKATEGORI SALAH
            Column(
              children: [
                _inputStok(),
                const SizedBox(height: 19),

                _inputSatuan(),
                const SizedBox(height: 19),

                _inputMinimum(),
                const SizedBox(height: 19),

                _inputHarga(),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _simpanBahan,
                icon: const Icon(Icons.save_outlined),
                label: Text(
                  isEdit ? 'Simpan Perubahan' : 'Simpan Bahan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final angka = int.tryParse(digits);
    if (angka == null) return oldValue;

    final formatted = _format(angka);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }

  String _format(int value) {
    final angka = value.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < angka.length; i++) {
      buffer.write(angka[i]);

      final sisa = angka.length - i - 1;
      if (sisa > 0 && sisa % 3 == 0) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }
}