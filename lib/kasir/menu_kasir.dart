
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/services/menu_firestore_service.dart';

class MenuKasirPage extends StatefulWidget {
  final Widget header;

  const MenuKasirPage({
    super.key,
    required this.header,
  });

  @override
  State<MenuKasirPage> createState() => _MenuKasirPageState();
}

class _MenuKasirPageState extends State<MenuKasirPage> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF2F6F2);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  String _menuSearch = '';
  String _menuCategory = 'Semua';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        widget.header,
        Expanded(
          child: Container(
            color: background,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: MenuFirestoreService.watchMenus(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text(
                      'Gagal memuat daftar menu. Periksa koneksi.',
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: primary),
                  );
                }

                final docs = snapshot.data?.docs ?? [];

                final menus = docs.map((doc) => doc.data()).toList()
                  ..sort(
                    (a, b) => (a['name'] ?? '')
                        .toString()
                        .compareTo((b['name'] ?? '').toString()),
                  );

                final filtered = menus.where((menu) {
                  final name =
                      (menu['name'] ?? '').toString().toLowerCase();
                  final category =
                      (menu['category'] ?? '').toString();

                  final matchesSearch =
                      name.contains(_menuSearch.toLowerCase());

                  final matchesCategory =
                      _menuCategory == 'Semua' ||
                      category == _menuCategory;

                  return matchesSearch && matchesCategory;
                }).toList();

                final tersedia = menus
                    .where((m) => m['status'] == 'Tersedia')
                    .length;

                final habis = menus
                    .where((m) => m['status'] == 'Habis')
                    .length;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                  children: [
                    const Text(
                      'Daftar Menu',
                      style: TextStyle(
                        color: primary,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 4),

                    const Text(
                      'Pilih menu yang tersedia untuk pesanan pelanggan.',
                      style: TextStyle(color: muted, fontSize: 11),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _menuCountCard(
                            'Tersedia',
                            tersedia,
                            const Color(0xFFEAF4EA),
                            const Color(0xFF26764A),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _menuCountCard(
                            'Habis',
                            habis,
                            const Color(0xFFFFEEEE),
                            const Color(0xFFC34B4B),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      onChanged: (value) {
                        setState(() => _menuSearch = value);
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari nama menu...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: muted,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5ECE6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Color(0xFFE5ECE6),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      children: ['Semua', 'Minuman', 'Pastry']
                          .map((category) {
                        final selected = _menuCategory == category;

                        return ChoiceChip(
                          label: Text(category),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _menuCategory = category;
                            });
                          },
                          selectedColor: const Color(0xFFDCEBDD),
                          labelStyle: TextStyle(
                            color: selected ? primary : muted,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                          side: BorderSide(
                            color: selected
                                ? const Color(0xFFB9D0BC)
                                : const Color(0xFFE5ECE6),
                          ),
                          backgroundColor: Colors.white,
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    if (filtered.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            'Menu tidak ditemukan.',
                            style: TextStyle(color: muted),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filtered.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 11,
                          mainAxisSpacing: 11,
                          childAspectRatio: 0.78,
                        ),
                        itemBuilder: (context, index) {
                          return _kasirMenuCard(filtered[index]);
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _menuCountCard(
    String label,
    int count,
    Color bg,
    Color foreground,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EEE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              label == 'Tersedia'
                  ? Icons.check_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: foreground,
              size: 19,
            ),
          ),

          const SizedBox(width: 9),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$count',
                style: const TextStyle(
                  color: primary,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),

              Text(
                label,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kasirMenuCard(Map<String, dynamic> menu) {
    final name = (menu['name'] ?? 'Menu').toString();
    final image = (menu['image'] ?? '').toString();
    final status = (menu['status'] ?? 'Habis').toString();
    final available = status == 'Tersedia';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EEE8)),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.035),
            blurRadius: 9,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                image.isNotEmpty
                    ? Image.asset(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFFEAF3E9),
                            child: const Icon(
                              Icons.local_cafe_rounded,
                              color: primary,
                              size: 42,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: const Color(0xFFEAF3E9),
                        child: const Icon(
                          Icons.local_cafe_rounded,
                          color: primary,
                          size: 42,
                        ),
                      ),

                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: available
                          ? const Color(0xFFE5F4E8)
                          : const Color(0xFFFFE8E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: available
                            ? const Color(0xFF26764A)
                            : const Color(0xFFC34B4B),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                if (!available)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.28),
                      child: const Center(
                        child: Text(
                          'SEDANG HABIS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  (menu['category'] ?? '').toString(),
                  style: const TextStyle(
                    color: muted,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: available
                        ? const Color(0xFFEAF4EA)
                        : const Color(0xFFF1F1F1),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    available ? 'Bisa dipesan' : 'Tidak tersedia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: available ? primary : muted,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
