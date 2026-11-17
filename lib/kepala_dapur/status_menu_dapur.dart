import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatusMenuDapur extends StatefulWidget {
  final List<Map<String, String>> menus;
  final void Function(Map<String, String> menu, String newStatus)
      onStatusChanged;

  // Hubungkan callback ini ke halaman detail resep yang sudah kamu buat.
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
  static const Color background = Color(0xFFF3F7F4);
  static const Color green = Color(0xFF21834B);
  static const Color greenBg = Color(0xFFE4F5E9);
  static const Color red = Color(0xFFC74638);
  static const Color redBg = Color(0xFFFFE8E5);

  final TextEditingController _searchController = TextEditingController();

  String _selectedFilter = 'Semua';
  String _searchQuery = '';

  final List<String> _filters = ['Semua', 'Tersedia', 'Habis'];

  List<Map<String, String>> get _filteredMenus {
    return widget.menus.where((menu) {
      final statusMatch = _selectedFilter == 'Semua' ||
          menu['status'] == _selectedFilter;

      final name = (menu['name'] ?? '').toLowerCase();
      final searchMatch = name.contains(_searchQuery.toLowerCase());

      return statusMatch && searchMatch;
    }).toList();
  }

  int get _totalTersedia =>
      widget.menus.where((menu) => menu['status'] == 'Tersedia').length;

  int get _totalHabis =>
      widget.menus.where((menu) => menu['status'] == 'Habis').length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _buildFilter(),
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
  }

  // HEADER HALAMAN
  Widget _pageHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.local_cafe_rounded,
              color: primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Menu',
                  style: TextStyle(
                    color: primary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Pantau ketersediaan menu minuman.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PENCARIAN MENU
  Widget _buildSearchField() {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE7EEE9)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: muted, size: 23),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _searchQuery = value.trim());
              },
              style: const TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                hintText: 'Cari menu minuman...',
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

  // RINGKASAN JUMLAH MENU
  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            icon: Icons.local_cafe_rounded,
            title: 'Tersedia',
            total: _totalTersedia,
            color: green,
            bgColor: const Color(0xFFE5F5EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            icon: Icons.block_rounded,
            title: 'Habis',
            total: _totalHabis,
            color: red,
            bgColor: const Color(0xFFFFE9E6),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: color, size: 22),
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

  // FILTER SEMUA, TERSEDIA, HABIS
  Widget _buildFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Filter Menu',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _filters.map((filter) {
              final isSelected = _selectedFilter == filter;

              return Padding(
                padding: const EdgeInsets.only(right: 9),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedFilter = filter);
                  },
                  selectedColor: primary,
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? primary
                        : const Color(0xFFE2EAE4),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 8,
                  ),
                  showCheckmark: false,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // KARTU MENU - TEKAN KARTU/PANAH UNTUK MEMBUKA DETAIL
  Widget _menuCard(Map<String, String> menu) {
    final isAvailable = menu['status'] == 'Tersedia';
    final statusColor = isAvailable ? green : red;
    final statusBgColor = isAvailable ? greenBg : redBg;

    return InkWell(
      onTap: () => _showMenuDetail(menu),
      borderRadius: BorderRadius.circular(19),
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(19),
          boxShadow: [
            BoxShadow(
              color: primary.withValues(alpha: 0.045),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3E9),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.local_cafe_rounded,
                color: primary,
                size: 27,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable
                              ? Icons.check_circle_rounded
                              : Icons.cancel_rounded,
                          size: 12,
                          color: statusColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          menu['status'] ?? 'Tidak diketahui',
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F6F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                color: primary,
                size: 23,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // POPUP DETAIL MENU DARI BAWAH
  void _showMenuDetail(Map<String, String> menu) {
    final pageContext = context;
    final isAvailable = menu['status'] == 'Tersedia';
    final statusColor = isAvailable ? green : red;
    final statusBgColor = isAvailable ? greenBg : redBg;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.57,
          minChildSize: 0.42,
          maxChildSize: 0.88,
          expand: false,
          builder: (context, scrollController) {
            return Container(
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
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF3E9),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.local_cafe_rounded,
                          color: primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu['name'] ?? 'Menu',
                              style: const TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _statusBadge(
                              menu['status'] ?? 'Tidak diketahui',
                              statusColor,
                              statusBgColor,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded, color: muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _detailInfoTile(
                    icon: Icons.inventory_2_outlined,
                    title: 'Status ketersediaan',
                    subtitle: isAvailable
                        ? 'Menu sedang tersedia untuk dipesan.'
                        : 'Menu sedang habis dan tidak dapat dipesan.',
                    trailing: Icon(
                      isAvailable
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _detailInfoTile(
                    icon: Icons.menu_book_rounded,
                    title: 'Resep minuman',
                    subtitle: 'Lihat bahan, takaran, dan langkah pembuatan.',
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: primary,
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      if (widget.onViewRecipe != null) {
                        widget.onViewRecipe!(menu);
                      } else {
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Hubungkan tombol ini ke halaman detail resep.',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _confirmMenuStatusChange(pageContext, menu);
                      },
                      icon: const Icon(Icons.edit_rounded, size: 18),
                      label: Text(
                        isAvailable ? 'Ubah Menjadi Habis' : 'Ubah Menjadi Tersedia',
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
            );
          },
        );
      },
    );
  }

  Widget _statusBadge(String status, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _detailInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: const Color(0xFFF3F7F4),
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.all(15),
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
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  // KONFIRMASI DAN SIMPAN PERUBAHAN STATUS KE FIRESTORE
  Future<void> _confirmMenuStatusChange(
    BuildContext context,
    Map<String, String> menu,
  ) async {
    final menuName = menu['name'] ?? 'Menu';
    final newStatus =
        menu['status'] == 'Tersedia' ? 'Habis' : 'Tersedia';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Konfirmasi Status Menu',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: primary,
            ),
          ),
          content: Text(
            'Apakah kamu yakin ingin mengubah status $menuName menjadi $newStatus?',
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: textColor,
            ),
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
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Ya, Ubah Status'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    try {
      // Simpan pemberitahuan perubahan status untuk Kasir.
      await FirebaseFirestore.instance
          .collection('notifikasi_kasir')
          .add({
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

      if (!context.mounted) return;

      widget.onStatusChanged(menu, newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          backgroundColor: primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(
            'Status $menuName berhasil diperbarui menjadi $newStatus dan sudah tercatat di log Kasir.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: const Text(
            'Gagal menyimpan perubahan status ke log Kasir. Status menu belum diperbarui.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  // TAMPILAN JIKA HASIL PENCARIAN/FILTER KOSONG
  Widget _buildEmptyState() {
    final hasSearch = _searchQuery.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 38,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Column(
        children: [
          Icon(
            Icons.local_cafe_outlined,
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
            hasSearch
                ? 'Tidak ada menu yang cocok dengan "$_searchQuery".'
                : 'Belum ada menu dengan status $_selectedFilter.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: muted,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
