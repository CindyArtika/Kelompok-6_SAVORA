import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/services/menu_firestore_service.dart';

class StatusMenuDapur extends StatefulWidget {
  final List<Map<String, String>> menus;
  final void Function(Map<String, String> menu, String newStatus)
  onStatusChanged;
  
  final void Function(Map<String, String> menu)? onViewRecipe;
  
  const StatusMenuDapur({
    super.key,
    required this.menus,
    required this.onStatusChanged,
    this.onViewRecipe,
  });

  @override
  State<StatusMenuDapur> createState() => _StatusMenuDapurState();
}

class _StatusMenuDapurState extends State<StatusMenuDapur> {
  static const Color primary = Color(0xFF143C2D);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);
  static const Color background = Color(0xFFF4F8F5);
  static const Color green = Color(0xFF21834B);
  static const Color greenBg = Color(0xFFE4F5E9);
  static const Color red = Color(0xFFC74638);
  static const Color redBg = Color(0xFFFFE8E5);

  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _liveMenus = [];
  String _selectedCategory = 'Semua';
  String _selectedSubcategory = 'Semua';
final List<String> _drinkSubcategories = [
  'Semua',
  'Coffee',
  'Non-Coffee',
  'Tea',
  'Fruit-Based',
];
  String _selectedStatus = 'Semua';
  String _searchQuery = '';

  final List<String> _categories = ['Semua', 'Minuman', 'Pastry'];
  final List<String> _statuses = ['Semua', 'Tersedia', 'Habis'];


List<Map<String, String>> get _filteredMenus {
  return _liveMenus.where((menu) {
    final categoryMatch = _selectedCategory == 'Semua' ||
        menu['category'] == _selectedCategory;

    final subcategoryMatch =
        _selectedCategory != 'Minuman' ||
        _selectedSubcategory == 'Semua' ||
        menu['subcategory'] == _selectedSubcategory;

    final statusMatch = _selectedStatus == 'Semua' ||
        menu['status'] == _selectedStatus;

    final searchMatch = (menu['name'] ?? '')
        .toLowerCase()
        .contains(_searchQuery.toLowerCase());

    return categoryMatch &&
        subcategoryMatch &&
        statusMatch &&
        searchMatch;
  }).toList();
}


  int get _totalTersedia =>
      _liveMenus.where((m) => m['status'] == 'Tersedia').length;
  int get _totalHabis =>
      _liveMenus.where((m) => m['status'] == 'Habis').length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
@override
void initState() {
  super.initState();
  _runSubcategoryMigration();
}

Future<void> _runSubcategoryMigration() async {
  try {
    final count =
        await MenuFirestoreService.migrateSubcategories();

    debugPrint('Migrasi subkategori berhasil: $count menu diperbarui');
  } catch (e) {
    debugPrint('Migrasi subkategori gagal: $e');
  }
}
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: MenuFirestoreService.watchMenus(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat status menu.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        _liveMenus = snapshot.data!.docs.map((doc) {
          final data = doc.data();
          return data.map((key, value) => MapEntry(key, value?.toString() ?? ''));
        }).toList();
        final filteredMenus = _filteredMenus;
        return Column(
      children: [
        _pageHeader(),
        Expanded(
          child: Container(
            color: background,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
              children: [
                _buildSearchField(),
                const SizedBox(height: 18),
                _buildSummary(),
                const SizedBox(height: 22),
                _buildFilters(),
                const SizedBox(height: 16),
                const SizedBox(height: 16),
                if (filteredMenus.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredMenus.map(_menuCard),
              ],
            ),
          ),
        ),
      ],
        );
      },
    );
  }

  Widget _pageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Menu',
                  style: TextStyle(
                    color: primary,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Pantau ketersediaan seluruh menu SAVORA.',
                  style: TextStyle(color: muted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F0E3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEE9)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: muted, size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value.trim()),
              style: const TextStyle(color: textColor, fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Cari nama menu...',
                hintStyle: TextStyle(color: muted, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              icon: const Icon(Icons.close_rounded, color: muted, size: 19),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.check_circle_rounded,
            title: 'Tersedia',
            total: _totalTersedia,
            color: green,
            bgColor: greenBg,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.cancel_rounded,
            title: 'Habis',
            total: _totalHabis,
            color: red,
            bgColor: redBg,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String title,
    required int total,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$total Menu',
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
Widget _buildFilters() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _filterDropdown(
              title: 'Kategori Menu',
              selectedValue: _selectedCategory,
              values: _categories,
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedSubcategory = 'Semua';
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _filterDropdown(
              title: 'Status Menu',
              selectedValue: _selectedStatus,
              values: _statuses,
              onChanged: (value) {
                setState(() => _selectedStatus = value);
              },
            ),
          ),
        ],
      ),

      if (_selectedCategory == 'Minuman') ...[
        const SizedBox(height: 17),
        const Text(
          'Jenis Minuman',
          style: TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        _buildDrinkSubcategoryFilters(),
      ],
    ],
  );
}

Widget _buildDrinkSubcategoryFilters() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: _drinkSubcategories.map((subcategory) {
        final selected = _selectedSubcategory == subcategory;

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedSubcategory = subcategory;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? primary
                      : const Color(0xFFE2EAE4),
                ),
              ),
              child: Text(
                subcategory,
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


  Widget _filterDropdown({
    required String title,
    required String selectedValue,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2EAE4)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: primary,
                size: 21,
              ),
              style: const TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              items: values.map((value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuCard(Map<String, String> menu) {
    final isAvailable = menu['status'] == 'Tersedia';
    final statusColor = isAvailable ? green : red;
    final statusBg = isAvailable ? greenBg : redBg;
    final imagePath = menu['image'] ?? '';

    return InkWell(
      onTap: () => _showMenuDetail(menu),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 66,
                height: 66,
                child: imagePath.isEmpty
                    ? _imageFallback()
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _imageFallback(),
                      ),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    menu['name'] ?? 'Menu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    menu['category'] ?? '',
                    style: const TextStyle(color: muted, fontSize: 10),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      menu['status'] ?? 'Tersedia',
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: primary, size: 23),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFEAF3E9),
    alignment: Alignment.center,
    child: const Icon(Icons.local_cafe_rounded, color: primary, size: 27),
  );

 
void _showMenuDetail(Map<String, String> menu) {
  final isAvailable = menu['status'] == 'Tersedia';
  final statusColor = isAvailable ? green : red;
  final statusBg = isAvailable ? greenBg : redBg;
  final imagePath = menu['image'] ?? '';

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.48,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: ListView(
          controller: scrollController,
          children: [
            // HANDLE POPUP
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCE5DE),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // GAMBAR MENU
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: imagePath.isEmpty
                      ? _imageFallback()
                      : Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _imageFallback(),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // NAMA MENU
            Text(
              menu['name'] ?? 'Menu',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: primary,
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 5),

            // KATEGORI
            Center(
              child: Text(
                menu['category'] ?? '',
                style: const TextStyle(
                  color: muted,
                  fontSize: 12,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // BADGE STATUS SAAT INI
            Center(
              child: _statusBadge(
                menu['status'] ?? 'Tersedia',
                statusColor,
                statusBg,
              ),
            ),

            const SizedBox(height: 22),

            // DETAIL RESEP
            _detailTile(
              icon: Icons.menu_book_rounded,
              title: 'Detail Resep',
              subtitle: 'Lihat bahan, takaran, dan langkah pembuatan menu.',
              onTap: () {
                Navigator.pop(sheetContext);

                if (widget.onViewRecipe != null) {
                  widget.onViewRecipe!(menu);
                } else {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text('Detail resep belum dihubungkan.'),
                    ),
                  );
                }
              },
            ),

            const SizedBox(height: 20),

            // TOMBOL UBAH STATUS
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(sheetContext);
                  _confirmMenuStatusChange(menu);
                },
                icon: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                ),
                label: Text(
                  isAvailable
                      ? 'Ubah Menjadi Habis'
                      : 'Ubah Menjadi Tersedia',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
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


  Widget _statusBadge(String status, Color color, Color bgColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
    ),
  );

  Widget _detailTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: primary, size: 21),
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
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmMenuStatusChange(Map<String, String> menu) async {
    final menuName = menu['name'] ?? 'Menu';
    final newStatus = menu['status'] == 'Tersedia' ? 'Habis' : 'Tersedia';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Status Menu',
          style: TextStyle(fontWeight: FontWeight.w800, color: primary),
        ),
        content: Text(
          'Apakah kamu yakin ingin mengubah status $menuName menjadi $newStatus?',
          style: const TextStyle(fontSize: 14, height: 1.5, color: textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal', style: TextStyle(color: muted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ya, Ubah Status'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // 1. Simpan status menu terlebih dahulu ke Firestore.
    try {
      await MenuFirestoreService.updateStatus(
        name: menuName,
        status: newStatus,
        category: menu['category'],
        image: menu['image'],
      );
    } catch (e) {
      debugPrint('Gagal memperbarui status menu di Firestore: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          content: Text('Status gagal disimpan: $e'),
        ),
      );
      return;
    }

    // Status sudah berhasil disimpan. Perbarui tampilan Kepala Dapur.
    if (!mounted) return;
    setState(() => menu['status'] = newStatus);
    widget.onStatusChanged(menu, newStatus);

    // 2. Simpan notifikasi secara terpisah agar kegagalan notifikasi
    // tidak membuat status menu dianggap gagal.
    try {
      await FirebaseFirestore.instance.collection('notifikasi_kasir').add({
        'judul': 'Perubahan Ketersediaan Menu',
        'namaMenu': menuName,
        'status': newStatus,
        'pesan': newStatus == 'Habis'
            ? '$menuName sedang habis dan tidak tersedia untuk dipesan.'
            : '$menuName sudah tersedia dan dapat dipesan kembali.',
        'targetRole': 'kasir',
        'dibaca': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: primary,
          content: Text(
            'Status $menuName berhasil diperbarui menjadi $newStatus.',
          ),
        ),
      );
    } catch (e) {
      debugPrint('Status tersimpan, tetapi notifikasi Kasir gagal: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange.shade800,
          content: Text(
            'Status menu berhasil diperbarui, tetapi notifikasi Kasir gagal: $e',
          ),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 38),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 43,
            color: muted.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          const Text(
            'Menu Tidak Ditemukan',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada menu yang cocok dengan "$_searchQuery".'
                : 'Belum ada menu dengan filter yang dipilih.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}
