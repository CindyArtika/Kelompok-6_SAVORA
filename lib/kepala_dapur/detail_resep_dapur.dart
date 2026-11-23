
import 'package:flutter/material.dart';

/// Halaman detail resep khusus Kepala Dapur.
/// Halaman ini hanya untuk MELIHAT resep, tanpa tambah/edit/hapus.
///
/// Format data resep yang diterima:
/// {
///   'name': 'Es Kopi Susu',
///   'category': 'Coffee',
///   'price': '18000',
///   'imageUrl': 'https://...',
///   'imageAsset': 'assets/images/...',
///   'description': 'Perpaduan espresso dan susu...',
///   'isPackagedPastry': false,
///   'ingredients': [
///     {'name': 'Biji kopi', 'quantity': '18 gram'},
///     {'name': 'Susu UHT', 'quantity': '120 ml'},
///   ],
///   'steps': [
///     'Siapkan gelas dan seluruh bahan.',
///     'Seduh espresso.',
///   ],
/// }

class DetailResepDapur extends StatelessWidget {
  final Map<String, dynamic> resep;

  const DetailResepDapur({
    super.key,
    required this.resep,
  });

  static const Color _primary = Color(0xFF174A36);
  static const Color _background = Color(0xFFF5F8F4);
  static const Color _text = Color(0xFF203229);
  static const Color _muted = Color(0xFF7A8980);

  String _textValue(String key, [String fallback = '-']) {
    final value = resep[key];

    if (value == null || value.toString().trim().isEmpty) {
      return fallback;
    }

    return value.toString();
  }

  List<Map<String, dynamic>> get _ingredients {
    final raw = resep['ingredients'];

    if (raw is! List) return [];

    return raw
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  List<String> get _steps {
    final raw = resep['steps'];

    if (raw is! List) return [];

    return raw.map((item) => item.toString()).toList();
  }

  @override
  Widget build(BuildContext context) {
    final name = _textValue('name', 'Detail Resep');
    final imageUrl = _textValue('imageUrl', '');
    final imageAsset = _textValue('imageAsset', '');
    final isPastry = resep['isPackagedPastry'] == true;

    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Kembali',
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Resep',
          style: TextStyle(
            color: _primary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: false,
      ),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        children: [
          // GAMBAR MENU
          _buildHero(imageUrl, imageAsset),
          const SizedBox(height: 20),

          // NAMA MENU
          Text(
            name,
            style: const TextStyle(
              color: _text,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          // KATEGORI DAN HARGA
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoChip(
                Icons.local_drink_outlined,
                _textValue('category', 'Minuman'),
              ),
              _infoChip(
                Icons.sell_outlined,
                _formatPrice(_textValue('price', '')),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // DESKRIPSI MENU
          Text(
            _textValue(
              'description',
              'Belum ada deskripsi untuk menu ini.',
            ),
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          // INFORMASI KHUSUS PASTRY
          if (isPastry) ...[
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _primary,
                    size: 21,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pastry ini merupakan produk kemasan siap panaskan. '
                      'Tidak memerlukan bahan tambahan maupun takaran.',
                      style: TextStyle(
                        color: _primary,
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // BAHAN DAN TAKARAN
          // Hanya ditampilkan untuk menu minuman.
          if (!isPastry) ...[
            _sectionTitle(
              icon: Icons.blender_outlined,
              title: 'Bahan dan Takaran',
              subtitle: 'Siapkan bahan sesuai ukuran berikut',
            ),

            const SizedBox(height: 12),

            if (_ingredients.isEmpty)
              _emptyInfo(
                'Data bahan dan takaran belum tersedia.',
              )
            else
              ..._ingredients.asMap().entries.map(
                (entry) => _ingredientTile(
                  entry.value,
                  entry.key,
                ),
              ),

            const SizedBox(height: 24),
          ],

          // LANGKAH PEMBUATAN ATAU PENYAJIAN
          const SizedBox(height: 24),

          _sectionTitle(
            icon: Icons.menu_book_rounded,
            title: isPastry
                ? 'Cara Penyajian'
                : 'Langkah Pembuatan',
            subtitle: isPastry
                ? 'Panduan penyajian dan pemanasan pastry'
                : 'Ikuti urutan pembuatan minuman',
          ),

          const SizedBox(height: 12),

          if (_steps.isEmpty)
            _emptyInfo(
              'Data langkah penyajian belum tersedia.',
            )
          else
            ..._steps.asMap().entries.map(
              (entry) => _stepTile(
                entry.key + 1,
                entry.value,
              ),
            ),

          const SizedBox(height: 20),

          // INFORMASI HAK AKSES
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.visibility_outlined,
                  color: _primary,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Halaman ini merupakan panduan resep untuk Kepala Dapur. '
                    'Perubahan resep hanya dapat dilakukan melalui akun Admin.',
                    style: TextStyle(
                      color: _primary,
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
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

  // GAMBAR HERO
  Widget _buildHero(String imageUrl, String imageAsset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 210,
        width: double.infinity,
        child: imageAsset.isNotEmpty
            ? Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Gagal memuat asset: $imageAsset - $error',
                  );
                  return _imageFallback();
                },
              )
            : imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint(
                        'Gagal memuat gambar network: $error',
                      );
                      return _imageFallback();
                    },
                  )
                : _imageFallback(),
      ),
    );
  }

  // GAMBAR PENGGANTI JIKA GAMBAR GAGAL DIMUAT
  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE4EEE4),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_cafe_rounded,
        color: _primary,
        size: 72,
      ),
    );
  }

  // CHIP INFORMASI
  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1E9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _primary,
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: _primary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // JUDUL BAGIAN
  Widget _sectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EFE5),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: _primary,
            size: 21,
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // KARTU BAHAN
  Widget _ingredientTile(
    Map<String, dynamic> ingredient,
    int index,
  ) {
    final name = (ingredient['name'] ?? 'Bahan').toString();

    final quantity = (
      ingredient['quantity'] ??
      ingredient['amount'] ??
      '-'
    ).toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF2E9),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: _primary,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                color: _text,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Text(
            quantity,
            style: const TextStyle(
              color: _primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // KARTU LANGKAH
  Widget _stepTile(int number, String step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                step,
                style: const TextStyle(
                  color: _text,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // INFORMASI KOSONG
  Widget _emptyInfo(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: _muted,
          fontSize: 12,
          height: 1.5,
        ),
      ),
    );
  }

  // FORMAT HARGA
  String _formatPrice(String value) {
    if (value.isEmpty || value == '-') {
      return 'Harga belum diatur';
    }

    if (value.startsWith('Rp')) {
      return value;
    }

    return 'Rp $value';
  }
}
