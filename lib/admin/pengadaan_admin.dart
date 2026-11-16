import 'package:flutter/material.dart';

class PengadaanAdmin extends StatefulWidget {
  const PengadaanAdmin({super.key});

  @override
  State<PengadaanAdmin> createState() => _PengadaanAdminState();
}

class _PengadaanAdminState extends State<PengadaanAdmin> {
  static const Color primary = Color(0xFF174635);
  static const Color background = Color(0xFFF5FBF8);
  static const Color muted = Color(0xFF829188);
  static const Color borderColor = Color(0xFFE8EFEB);

  final List<_BahanPengadaan> bahan = [
    _BahanPengadaan(
      nama: 'Matcha Powder',
      kategori: 'Bubuk Minuman',
      stok: '¼ kg',
      minimum: '1 kg',
      icon: Icons.spa_rounded,
      warna: const Color(0xFFE3EFDF),
      jumlah: 2,
      satuan: 'Kg',
      keterangan:
          'Stok matcha hampir habis. Perlu pembelian untuk memenuhi kebutuhan operasional dan menjaga ketersediaan menu.',
      statusStok: 'Kritis',
    ),
    _BahanPengadaan(
      nama: 'Fresh Milk',
      kategori: 'Susu',
      stok: '4.5 L',
      minimum: '15 L',
      icon: Icons.local_drink_rounded,
      warna: const Color(0xFFE5EFF8),
      jumlah: 15,
      satuan: 'Liter',
      keterangan:
          'Persediaan susu mulai menipis. Perlu penambahan stok untuk kebutuhan pembuatan minuman.',
      statusStok: 'Menipis',
    ),
    _BahanPengadaan(
      nama: 'Sirup Vanilla',
      kategori: 'Sirup',
      stok: '0.5 L',
      minimum: '2 L',
      icon: Icons.water_drop_rounded,
      warna: const Color(0xFFFFF0DD),
      jumlah: 2,
      satuan: 'Liter',
      keterangan:
          'Stok sirup vanilla perlu ditambah agar menu berbahan vanilla tetap tersedia.',
      statusStok: 'Kritis',
    ),
    _BahanPengadaan(
      nama: 'Biji Kopi',
      kategori: 'Biji Kopi',
      stok: '3 kg',
      minimum: '5 kg',
      icon: Icons.coffee_rounded,
      warna: const Color(0xFFF2E8DD),
      jumlah: 5,
      satuan: 'Kg',
      keterangan:
          'Stok biji kopi mulai menipis. Perlu penambahan persediaan untuk memenuhi kebutuhan penyajian kopi.',
      statusStok: 'Menipis',
    ),
  ];

  late final List<TextEditingController> jumlahControllers;
  late final List<TextEditingController> alasanControllers;

  int filterAktif = 0;
  final List<String> filter = ['Semua', 'Kritis', 'Menipis'];

  @override
  void initState() {
    super.initState();
    jumlahControllers = bahan
        .map((item) => TextEditingController(text: item.jumlah.toString()))
        .toList();
    alasanControllers = bahan
        .map((item) => TextEditingController(text: item.keterangan))
        .toList();
  }

  @override
  void dispose() {
    for (final controller in jumlahControllers) {
      controller.dispose();
    }
    for (final controller in alasanControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  List<int> get bahanTerfilter {
    return List<int>.generate(bahan.length, (index) => index)
        .where((index) {
      if (filterAktif == 1) return bahan[index].statusStok == 'Kritis';
      if (filterAktif == 2) return bahan[index].statusStok == 'Menipis';
      return true;
    }).toList();
  }

  int get jumlahPerluKonfirmasi => bahan
      .where((item) => item.statusPengajuan == _StatusPengajuan.menungguAdmin)
      .length;

  int get jumlahSiapPO => bahan
      .where((item) => item.statusPengajuan == _StatusPengajuan.siapPO)
      .length;

  int get jumlahMenungguOwner => bahan
      .where((item) => item.statusPengajuan == _StatusPengajuan.menungguOwner)
      .length;

  void _tampilkanPesan(String pesan, {bool sukses = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: sukses ? primary : const Color(0xFFB94A45),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _konfirmasiPengajuan(int index) {
    final jumlah = _validasiJumlah(index);
    if (jumlah == null) return;

    if (alasanControllers[index].text.trim().isEmpty) {
      _tampilkanPesan('Keterangan pengajuan belum diisi.');
      return;
    }

    setState(() {
      bahan[index]
        ..jumlah = jumlah
        ..keterangan = alasanControllers[index].text.trim()
        ..statusPengajuan = _StatusPengajuan.siapPO;
    });
    _tampilkanPesan(
      'Pengajuan ${bahan[index].nama} berhasil dikonfirmasi.',
      sukses: true,
    );
  }

  void _ajukanPO(int index) {
    setState(() {
      bahan[index].statusPengajuan = _StatusPengajuan.menungguOwner;
    });
    _tampilkanPesan(
      'PO ${bahan[index].nama} diteruskan kepada Owner.',
      sukses: true,
    );
  }

  Future<void> _tolakPengajuan(int index) async {
    final alasanController = TextEditingController();
    final alasan = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          'Tolak Pengajuan PO',
          style: TextStyle(fontWeight: FontWeight.w800, color: primary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Berikan alasan penolakan untuk ${bahan[index].nama}.',
              style: const TextStyle(fontSize: 12, color: muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: alasanController,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan penolakan...',
                filled: true,
                fillColor: background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB94A45),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final value = alasanController.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(dialogContext, value);
            },
            child: const Text('Tolak Pengajuan'),
          ),
        ],
      ),
    );
    alasanController.dispose();

    if (!mounted || alasan == null) return;

    setState(() {
      bahan[index]
        ..alasanPenolakan = alasan
        ..statusPengajuan = _StatusPengajuan.ditolak;
    });
    _tampilkanPesan(
      'Pengajuan ${bahan[index].nama} ditolak.',
    );
  }

  double? _validasiJumlah(int index) {
    final teks = jumlahControllers[index].text.trim().replaceAll(',', '.');
    final jumlah = double.tryParse(teks);
    if (jumlah == null || jumlah <= 0) {
      _tampilkanPesan('Masukkan jumlah pembelian yang valid.');
      return null;
    }
    return jumlah;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 22),
              _buildSummary(),
              const SizedBox(height: 27),
              _buildSectionHeader(),
              const SizedBox(height: 13),
              _buildFilter(),
              const SizedBox(height: 16),
              if (bahanTerfilter.isEmpty)
                _buildEmptyState()
              else
                ...bahanTerfilter.map(
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: _buildBahanCard(index),
                  ),
                ),
              const SizedBox(height: 5),
              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE5F2E8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pengadaan',
                style: TextStyle(
                  color: primary,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Kelola pengajuan dan kebutuhan pembelian bahan',
                style: TextStyle(color: muted, fontSize: 11.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total Bahan',
            value: '${bahan.length}',
            icon: Icons.inventory_2_outlined,
            iconColor: primary,
            iconBg: const Color(0xFFE5F2E8),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _summaryCard(
            title: 'Perlu Diproses',
            value: '$jumlahPerluKonfirmasi',
            icon: Icons.fact_check_outlined,
            iconColor: const Color(0xFFD58A32),
            iconBg: const Color(0xFFFFF1DD),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: _summaryCard(
            title: 'Menunggu Owner',
            value: '$jumlahMenungguOwner',
            icon: Icons.hourglass_top_rounded,
            iconColor: const Color(0xFF60758B),
            iconBg: const Color(0xFFEAF0F6),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 116),
      padding: const EdgeInsets.fromLTRB(11, 12, 8, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF263A30),
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: muted,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Daftar Kebutuhan Bahan',
            style: TextStyle(
              color: Color(0xFF263A30),
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Text(
          '${bahanTerfilter.length} bahan',
          style: const TextStyle(
            color: muted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filter.length, (index) {
          final selected = filterAktif == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => filterAktif = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected ? primary : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selected ? primary : borderColor,
                  ),
                ),
                child: Text(
                  filter[index],
                  style: TextStyle(
                    color: selected ? Colors.white : const Color(0xFF718078),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBahanCard(int index) {
    final item = bahan[index];
    final isKritis = item.statusStok == 'Kritis';
    final statusColor = isKritis
        ? const Color(0xFFD94F49)
        : const Color(0xFFC58B32);
    final statusBg = isKritis
        ? const Color(0xFFFFEAE8)
        : const Color(0xFFFFF3DF);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.035),
            blurRadius: 13,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 53,
                height: 53,
                decoration: BoxDecoration(
                  color: item.warna,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: primary, size: 27),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nama,
                      style: const TextStyle(
                        color: Color(0xFF29372F),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.kategori,
                      style: const TextStyle(color: muted, fontSize: 10.5),
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
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusStok,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7FAF8),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _stockInfo('Stok saat ini', item.stok),
                ),
                Container(width: 1, height: 32, color: borderColor),
                const SizedBox(width: 14),
                Expanded(
                  child: _stockInfo('Stok minimum', item.minimum),
                ),
              ],
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'Rencana Pembelian',
            style: TextStyle(
              color: primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: jumlahControllers[index],
            enabled: item.statusPengajuan == _StatusPengajuan.menungguAdmin,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _inputDecoration(
              hint: 'Masukkan jumlah pembelian',
              suffix: item.satuan,
              prefixIcon: Icons.add_shopping_cart_outlined,
            ),
            style: const TextStyle(
              color: Color(0xFF29372F),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Alasan Pengajuan',
            style: TextStyle(
              color: Color(0xFF35473D),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: alasanControllers[index],
            enabled: item.statusPengajuan == _StatusPengajuan.menungguAdmin,
            maxLines: 3,
            decoration: _inputDecoration(
              hint: 'Tuliskan alasan kebutuhan pembelian...',
              prefixIcon: Icons.notes_rounded,
            ),
            style: const TextStyle(
              color: Color(0xFF526158),
              fontSize: 11.5,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          _buildStatus(item.statusPengajuan),
          if (item.statusPengajuan == _StatusPengajuan.ditolak &&
              item.alasanPenolakan != null) ...[
            const SizedBox(height: 9),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5F4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF4D9D6)),
              ),
              child: Text(
                'Alasan penolakan: ${item.alasanPenolakan}',
                style: const TextStyle(
                  color: Color(0xFF9F4842),
                  fontSize: 10.5,
                  height: 1.4,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          _buildActionButton(index),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    String? suffix,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFA3AEA8), fontSize: 11),
      suffixText: suffix,
      prefixIcon: prefixIcon == null
          ? null
          : Icon(prefixIcon, color: const Color(0xFF8A9A90), size: 18),
      filled: true,
      fillColor: const Color(0xFFF7FAF8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFEDF2EE)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: primary, width: 1.2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFFEDF2EE)),
      ),
    );
  }

  Widget _stockInfo(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: muted, fontSize: 10)),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF35473D),
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildStatus(_StatusPengajuan status) {
    final Color color;
    final Color bg;
    final IconData icon;
    final String label;

    switch (status) {
      case _StatusPengajuan.menungguAdmin:
        color = const Color(0xFFC58B32);
        bg = const Color(0xFFFFF4E2);
        icon = Icons.schedule_rounded;
        label = 'Menunggu Konfirmasi Admin';
      case _StatusPengajuan.siapPO:
        color = const Color(0xFF397B52);
        bg = const Color(0xFFE8F4EA);
        icon = Icons.check_circle_outline_rounded;
        label = 'Terkonfirmasi · Siap diajukan ke Owner';
      case _StatusPengajuan.menungguOwner:
        color = const Color(0xFF60758B);
        bg = const Color(0xFFEDF2F7);
        icon = Icons.hourglass_top_rounded;
        label = 'Menunggu Persetujuan Owner';
      case _StatusPengajuan.ditolak:
        color = const Color(0xFFB94A45);
        bg = const Color(0xFFFFECEA);
        icon = Icons.cancel_outlined;
        label = 'Pengajuan Ditolak Admin';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(int index) {
    final status = bahan[index].statusPengajuan;

    if (status == _StatusPengajuan.menungguAdmin) {
      return Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _tolakPengajuan(index),
                icon: const Icon(Icons.close_rounded, size: 17),
                label: const Text(
                  'Tolak',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFB94A45),
                  side: const BorderSide(color: Color(0xFFE8B8B4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () => _konfirmasiPengajuan(index),
                icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                label: const Text(
                  'Setujui Pengajuan',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    final bool siapDiajukan = status == _StatusPengajuan.siapPO;
    final String label;
    final IconData icon;
    final VoidCallback? action;

    if (siapDiajukan) {
      label = 'Teruskan PO kepada Owner';
      icon = Icons.send_rounded;
      action = () => _ajukanPO(index);
    } else if (status == _StatusPengajuan.menungguOwner) {
      label = 'Menunggu Persetujuan Owner';
      icon = Icons.hourglass_top_rounded;
      action = null;
    } else {
      label = 'Pengajuan Telah Ditolak';
      icon = Icons.cancel_outlined;
      action = null;
    }

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: ElevatedButton.icon(
        onPressed: action,
        icon: Icon(icon, size: 17),
        label: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          disabledBackgroundColor: const Color(0xFFE8EEEA),
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF87958D),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: muted, size: 35),
          SizedBox(height: 10),
          Text(
            'Tidak ada bahan pada kategori ini',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF526158),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDEBE1)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Halaman ini digunakan Admin untuk memeriksa kebutuhan bahan, menyetujui atau menolak pengajuan PO, serta meneruskan pengajuan yang disetujui kepada Owner.',
              style: TextStyle(
                color: Color(0xFF466B56),
                fontSize: 10.5,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StatusPengajuan {
  menungguAdmin,
  siapPO,
  menungguOwner,
  ditolak,
}

class _BahanPengadaan {
  final String nama;
  final String kategori;
  final String stok;
  final String minimum;
  final IconData icon;
  final Color warna;
  final String satuan;
  final String statusStok;

  double jumlah;
  String keterangan;
  String? alasanPenolakan;
  // Status awal setiap pengajuan adalah menunggu pemeriksaan Admin.
  _StatusPengajuan statusPengajuan = _StatusPengajuan.menungguAdmin;

  _BahanPengadaan({
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.minimum,
    required this.icon,
    required this.warna,
    required this.jumlah,
    required this.satuan,
    required this.keterangan,
    required this.statusStok,
  
  });
}
