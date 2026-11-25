import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/services/stock_firestore_service.dart';

class _AjukanBahanDialog extends StatefulWidget {
  final String namaBahan;
  final String stokSaatIni;
  final String satuan;
  final String? initialQuantity;
  final String? initialNote;
  final bool isEditing;

  const _AjukanBahanDialog({
    required this.namaBahan,
    required this.stokSaatIni,
    required this.satuan,
    this.initialQuantity,
    this.initialNote,
    this.isEditing = false,
  });

  @override
  State<_AjukanBahanDialog> createState() =>
      _AjukanBahanDialogState();
}

class _AjukanBahanDialogState
    extends State<_AjukanBahanDialog> {
  final TextEditingController quantityController =
      TextEditingController();

  final TextEditingController noteController =
      TextEditingController();

  static const Color primary = Color(0xFF143C2D);
  static const Color muted = Color(0xFF758078);

  @override
  void initState() {
    super.initState();
    quantityController.text = widget.initialQuantity ?? '';
    noteController.text = widget.initialNote ?? '';
  }

  @override
  void dispose() {
    quantityController.dispose();
    noteController.dispose();
    super.dispose();
  }

  void _submit() {
    final quantity = quantityController.text.trim();
    final parsed = double.tryParse(
      quantity.replaceAll(',', '.'),
    );

    if (parsed == null || parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan jumlah kebutuhan yang valid.',
          ),
        ),
      );
      return;
    }

    Navigator.of(context).pop({
      'quantity': quantity,
      'note': noteController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Text(
        widget.isEditing ? 'Edit Pengajuan' : 'Ajukan Kebutuhan Stok',
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
              widget.namaBahan,
              style: const TextStyle(
                color: primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Stok saat ini: ${widget.stokSaatIni}',
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
                suffixText: widget.satuan,
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
                hintText:
                    'Contoh: Dibutuhkan untuk operasional...',
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
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Batal',
            style: TextStyle(color: muted),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(widget.isEditing ? 'Simpan Perubahan' : 'Kirim Pengajuan'),
        ),
      ],
    );
  }
}

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
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  String _selectedStatus = 'Semua';
  String _selectedRequestStatus = 'Semua';
  int _selectedTab = 0; // 0 = Stok Bahan, 1 = Riwayat Pengajuan

  final List<String> _categories = [
    'Semua',
    'Bahan Minuman',
    'Pastry',
    'Bahan Operasional',
  ];

  final List<String> _statuses = ['Semua', 'Kritis', 'Menipis', 'Aman'];

  // Data contoh lokal. Sesuaikan jumlah stok dan status dengan data sebenarnya.
  // Path gambar mengikuti isi ZIP yang kamu kirim, dengan asumsi folder
  // images disimpan di dalam assets/images/.

  List<Map<String, dynamic>> _stocks = [];

  List<Map<String, dynamic>> get _filteredStocks {
    return _stocks.where((item) {
      final name = item['name'].toString().toLowerCase();
      final matchesSearch = name.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'Semua' ||
          item['category'] == _selectedCategory;
      final matchesStatus =
          _selectedStatus == 'Semua' || item['status'] == _selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
    
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: StockFirestoreService.watchStocks(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat data stok bahan.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        _stocks = snapshot.data!.docs
            .map((doc) => StockFirestoreService.normalize(doc.data()))
            .toList();
        return Container(
          color: background,
          child: Column(
            children: [
              _buildHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: _buildSearch(),
              ),
              _buildTopTabs(),
              Expanded(
                child: _selectedTab == 0
                    ? _buildStockTab()
                    : _buildRequestTab(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0xFFE5ECE6)),
        ),
        child: Row(
          children: [
            _topTabButton('Stok Bahan', Icons.inventory_2_outlined, 0),
            _topTabButton('Riwayat Pengajuan', Icons.receipt_long_outlined, 1),
          ],
        ),
      ),
    );
  }

  Widget _topTabButton(String label, IconData icon, int index) {
    final selected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 7),
          decoration: BoxDecoration(
            color: selected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 17, color: selected ? Colors.white : primary),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white : primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildStockSummary(),
        const SizedBox(height: 16),
        _buildCategories(),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              style: const TextStyle(color: muted, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_filteredStocks.isEmpty)
          _buildEmptyState()
        else
          ..._filteredStocks.map(_stockCard),
      ],
    );
  }

  Widget _buildRequestTab() {
    return StreamBuilder(
      stream: StockFirestoreService.watchMyStockRequests(),
      builder: (context, requestSnapshot) {
        if (requestSnapshot.hasError) {
          return const Center(
            child: Text('Riwayat pengajuan gagal dimuat.'),
          );
        }
        if (!requestSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final allRequests = requestSnapshot.data!.docs
            .map((doc) => <String, dynamic>{...doc.data(), '_requestId': doc.id})
            .toList();
        final requests = allRequests.where((request) {
          final name = (request['namaBahan'] ?? '').toString().toLowerCase();
          final matchesSearch = name.contains(_searchQuery.toLowerCase());
          final status = (request['status'] ?? '').toString().toLowerCase();
          final selected = _selectedRequestStatus;
          final matchesStatus = selected == 'Semua' ||
              (selected == 'Menunggu' && status.contains('menunggu')) ||
              (selected == 'Disetujui' &&
                  (status.contains('disetujui') || status.contains('selesai') || status.contains('po dibuat'))) ||
              (selected == 'Ditolak' && status.contains('ditolak'));
          return matchesSearch && matchesStatus;
        }).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _buildRequestFilters(),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Riwayat Pengajuan',
                  style: TextStyle(
                    color: primary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${requests.length} pengajuan',
                  style: const TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (requests.isEmpty)
              _buildEmptyRequests()
            else
              _buildRequestHistory(requests),
          ],
        );
      },
    );
  }

  Widget _buildRequestFilters() {
    const filters = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedRequestStatus == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRequestStatus = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: selected ? primary : const Color(0xFFE5ECE6),
                  ),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyRequests() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 55),
      child: Column(
        children: const [
          Icon(Icons.receipt_long_outlined, size: 46, color: Color(0xFF9AA79D)),
          SizedBox(height: 12),
          Text(
            'Belum Ada Pengajuan',
            style: TextStyle(
              color: primary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Pengajuan kebutuhan bahan akan muncul di sini.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted, fontSize: 11),
          ),
        ],
      ),
    );
  }

 Widget _buildHeader() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Persediaan Dapur',
                style: TextStyle(
                  color: primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Kelola dan pantau seluruh stok bahan SAVORA.',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.inventory_2_rounded,
            color: primary,
            size: 24,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildStockSummary() {
    final critical = _stocks.where((e) => e['status'] == 'Kritis').length;
    final low = _stocks.where((e) => e['status'] == 'Menipis').length;
    final safe = _stocks.where((e) => e['status'] == 'Aman').length;

    Widget item(String label, int value, Color dotColor) {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              '$value',
              style: const TextStyle(
                color: primary,
                fontSize: 17,
                height: 1.1,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5EF),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFDCE8DC)),
      ),
      child: Row(
        children: [
          item('Aman', safe, const Color(0xFF35A853)),
          Container(width: 1, height: 32, color: const Color(0xFFD4DED5)),
          item('Menipis', low, const Color(0xFFF2A900)),
          Container(width: 1, height: 32, color: const Color(0xFFD4DED5)),
          item('Kritis', critical, const Color(0xFFE54848)),
        ],
      ),
    );
  }

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
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: _selectedTab == 0
                    ? 'Cari nama bahan...'
                    : 'Cari pengajuan...',
                hintStyle: const TextStyle(color: muted, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: primary,
                  size: 25,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.close_rounded, color: muted),
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 17),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _selectedTab == 0
              ? _showStatusFilter
              : _showRequestStatusFilter,
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
                const Icon(Icons.tune_rounded, color: primary, size: 25),
                if ((_selectedTab == 0 && _selectedStatus != 'Semua') ||
                    (_selectedTab == 1 && _selectedRequestStatus != 'Semua'))
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

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kategori Bahan',
              style: TextStyle(
                color: primary,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Text(
              '4 kategori',
              style: TextStyle(color: muted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 9),
        Row(
          children: _categories.map((category) {
            final selected = _selectedCategory == category;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: category == _categories.last ? 0 : 7,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? primary : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected ? primary : const Color(0xFFE3EBE3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(
                            alpha: selected ? 0.09 : 0.025,
                          ),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected ? Colors.white : primary,
                        fontSize: 9.5,
                        height: 1.15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _showStatusFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        String tempStatus = _selectedStatus;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
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
                  ..._statuses.map(
                    (status) => RadioListTile<String>(
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
                        if (value != null) {
                          setSheetState(() => tempStatus = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(sheetContext, tempStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
      setState(() => _selectedStatus = result);
    }
  }

  Future<void> _showRequestStatusFilter() async {
    const statuses = ['Semua', 'Menunggu', 'Disetujui', 'Ditolak'];
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (sheetContext) {
        String tempStatus = _selectedRequestStatus;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Status Pengajuan',
                  style: TextStyle(
                    color: primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                ...statuses.map((status) => RadioListTile<String>(
                  value: status,
                  // ignore: deprecated_member_use
                  groupValue: tempStatus,
                  activeColor: primary,
                  contentPadding: EdgeInsets.zero,
                  title: Text(status),
                  // ignore: deprecated_member_use
                  onChanged: (value) {
                    if (value != null) setSheetState(() => tempStatus = value);
                  },
                )),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(sheetContext, tempStatus),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Terapkan Filter'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _selectedRequestStatus = result);
    }
  }

  Widget _stockCard(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final color = _statusColor(status);
    final statusBg = _statusBackground(status);

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
            _stockImage(item, width: 78, height: 78, radius: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] as String,
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
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Diperbarui ${item['updated']}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, color: color, size: 8),
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

  Widget _stockImage(
    Map<String, dynamic> item, {
    required double width,
    required double height,
    required double radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color(item['color'] as int),
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        item['image'] as String,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: muted,
              size: 28,
            ),
          );
        },
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

  void _showStockMenu(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        final canRequest =
            item['status'] == 'Kritis' || item['status'] == 'Menipis';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline, color: primary),
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
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
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

  void _showStockDetail(Map<String, dynamic> item) {
    final status = item['status'] as String;
    final canRequest = status == 'Kritis' || status == 'Menipis';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
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
                    _stockImage(item, width: 70, height: 70, radius: 18),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              color: primary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            item['category'] as String,
                            style: const TextStyle(color: muted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                _detailRow('Jumlah Stok', item['stock'] as String),
                _detailRow('Kategori', item['category'] as String),
                _detailRow('Status', status),
                _detailRow(
                  'Terakhir Diperbarui',
                  item['updated'] as String,
                ),
                const SizedBox(height: 20),
                if (canRequest)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await Future.delayed(const Duration(milliseconds: 300));
                        if (!mounted) return;
                        _ajukanBahan(item);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Ajukan Kebutuhan Stok'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
              style: const TextStyle(color: muted, fontSize: 12),
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

  
  Future<void> _ajukanBahan(Map<String, dynamic> item) async {
    if (item['status'] != 'Kritis' &&
        item['status'] != 'Menipis') {
      return;
    }

    final stockParts =
        (item['stock'] as String).trim().split(RegExp(r'\s+'));
    final satuan =
        stockParts.length > 1 ? stockParts.last : 'Unit';

    final result = await showDialog<Map<String, String>>(
      context: context,
      useRootNavigator: true,
      builder: (_) => _AjukanBahanDialog(
        namaBahan: item['name'].toString(),
        stokSaatIni: item['stock'].toString(),
        satuan: satuan,
      ),
    );

    if (!mounted || result == null) return;

    try {
      final currentQty =
          (item['stockQty'] as num?)?.toDouble() ?? 0;

      await StockFirestoreService.createStockRequest(
        name: item['name'].toString(),
        unit: satuan,
        quantity: double.parse(
          result['quantity']!.replaceAll(',', '.'),
        ),
        note: result['note']!,
        currentStock: currentQty,
        category: item['category']?.toString() ?? '',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengajuan ${item['name']} berhasil dibuat.'),
          backgroundColor: primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pengajuan gagal disimpan: $e')),
      );
    }
  }

  Future<void> _editStockRequest(Map<String, dynamic> request) async {
    final requestId = (request['_requestId'] ?? '').toString();

    if (requestId.isEmpty ||
        request['status'] != 'Menunggu Konfirmasi Admin') {
      return;
    }

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (_) => _AjukanBahanDialog(
        namaBahan: (request['namaBahan'] ?? '').toString(),
        stokSaatIni: '${request['stokSaatPengajuan'] ?? 0} ${request['satuan'] ?? ''}',
        satuan: (request['satuan'] ?? 'Unit').toString(),
        initialQuantity: (request['jumlahDiajukan'] ?? '').toString(),
        initialNote: (request['catatan'] ?? '').toString(),
        isEditing: true,
      ),
    );
    if (!mounted || result == null) return;

    try {
      await StockFirestoreService.updateStockRequest(
        requestId: requestId,
        quantity: double.parse(result['quantity']!.replaceAll(',', '.')),
        note: result['note'] ?? '',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil diperbarui.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengedit pengajuan: $e')),
      );
    }
  }

  Future<void> _cancelStockRequest(Map<String, dynamic> request) async {
    final requestId = (request['_requestId'] ?? '').toString();

    if (requestId.isEmpty ||
        request['status'] != 'Menunggu Konfirmasi Admin') {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Pengajuan?'),
        content: Text(
          'Pengajuan ${(request['namaBahan'] ?? 'bahan ini').toString()} akan ditandai sebagai dibatalkan. Tindakan ini tidak dapat diurungkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD92D2D),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await StockFirestoreService.cancelStockRequest(requestId: requestId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan berhasil dibatalkan.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan pengajuan: $e')),
      );
    }
  }

  Widget _buildRequestHistory(List<Map<String, dynamic>> requests) {
    final filtered = requests.where((request) {
      final status = (request['status'] ?? '').toString().toLowerCase();
      switch (_selectedRequestStatus) {
        case 'Menunggu':
          return status.contains('menunggu');
        case 'Disetujui':
          return status.contains('disetujui') || status.contains('selesai') ||
              status.contains('barang diterima') || status.contains('po dibuat');
        case 'Ditolak':
          return status.contains('ditolak');
        default:
          return true;
      }
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 35),
        child: Text(
          'Tidak ada pengajuan dengan status $_selectedRequestStatus.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      );
    }

    return Column(
      children: filtered.map((request) {
        final namaBahan =
            (request['namaBahan'] ?? request['name'] ?? 'Bahan tidak diketahui').toString();
        final jumlah = (request['jumlahDiajukan'] ?? request['quantity'] ?? '-').toString();
        final satuan = (request['satuan'] ?? request['unit'] ?? '').toString();
        final catatan = (request['catatan'] ?? request['note'] ?? '').toString();
        final status =
            (request['status'] ?? 'Status tidak diketahui').toString();
        final createdAt = request['createdAt'];
        final rejected = status.toLowerCase().contains('ditolak');
        final approved = status.toLowerCase().contains('disetujui') ||
            status.toLowerCase().contains('selesai') ||
            status.toLowerCase().contains('barang diterima') ||
            status.toLowerCase().contains('po dibuat');
        final statusColor = rejected
            ? const Color(0xFFD92D2D)
            : approved
                ? const Color(0xFF21834B)
                : const Color(0xFFE58B00);
        final statusBg = rejected
            ? const Color(0xFFFFE3E3)
            : approved
                ? const Color(0xFFE1F3E3)
                : const Color(0xFFFFF1D6);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EEE8)),
            boxShadow: [
              BoxShadow(
                color: primary.withValues(alpha: 0.035),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaBahan,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$jumlah $satuan',
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (createdAt is Timestamp) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 12, color: muted),
                          const SizedBox(width: 5),
                          Text(
                            _formatRequestDate(createdAt),
                            style: const TextStyle(color: muted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                    if (catatan.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        catatan,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: muted, fontSize: 10),
                      ),
                    ],
                    if (status == 'Menunggu Konfirmasi Admin') ...[
                      const SizedBox(height: 9),
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _editStockRequest(request),
                            icon: const Icon(Icons.edit_outlined, size: 14),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primary,
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              side: const BorderSide(color: Color(0xFFDCE8DC)),
                              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 7),
                          TextButton.icon(
                            onPressed: () => _cancelStockRequest(request),
                            icon: const Icon(Icons.close_rounded, size: 14),
                            label: const Text('Batalkan'),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFD92D2D),
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatRequestDate(Timestamp timestamp) {
    final date = timestamp.toDate().toLocal();
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year • $hour:$minute';
  }

Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: const BoxDecoration(
              color: Color(0xFFE5F0E3),
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
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
