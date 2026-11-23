import 'package:flutter/material.dart';

class NotificationOwner extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const NotificationOwner({super.key, this.onNavigate});

  static int get unreadCount => _NotificationOwnerState.notifications
      .where((item) => item['unread'] == true)
      .length;

  @override
  State<NotificationOwner> createState() => _NotificationOwnerState();
}

class _NotificationOwnerState extends State<NotificationOwner> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  String selectedFilter = 'Semua';

  // Data contoh khusus Owner; nantinya dapat dihubungkan ke Firestore.
  static final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Pengajuan Persetujuan Baru',
      'message': 'Admin mengirim pengajuan pembelian bahan baku. Silakan periksa dan berikan persetujuan.',
      'time': '5 menit lalu',
      'type': 'persetujuan',
      'unread': true,
    },
    {
      'title': 'Stok Bahan Mencapai Batas Minimum',
      'message': 'Beberapa bahan baku memiliki stok rendah. Periksa kondisi persediaan outlet.',
      'time': '30 menit lalu',
      'type': 'stok',
      'unread': true,
    },
    {
      'title': 'Laporan Penjualan Tersedia',
      'message': 'Laporan penjualan hari ini sudah tersedia dan dapat ditinjau.',
      'time': '2 jam lalu',
      'type': 'laporan',
      'unread': false,
    },
    {
      'title': 'Pengajuan Berhasil Disetujui',
      'message': 'Pengajuan pembelian bahan baku yang sebelumnya ditinjau telah disetujui.',
      'time': 'Kemarin',
      'type': 'persetujuan',
      'unread': false,
    },
    {
      'title': 'Aktivitas Pengguna Baru',
      'message': 'Akun pengguna baru telah terdaftar. Periksa daftar pengguna untuk melihat detailnya.',
      'time': 'Kemarin',
      'type': 'pengguna',
      'unread': false,
    },
    {
      'title': 'Ringkasan Kinerja Outlet',
      'message': 'Ringkasan aktivitas dan kinerja outlet untuk periode terbaru sudah tersedia.',
      'time': '2 hari lalu',
      'type': 'laporan',
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'Belum dibaca') {
      return notifications.where((item) => item['unread'] == true).toList();
    }
    return notifications;
  }

  int get unreadCount =>
      notifications.where((item) => item['unread'] == true).length;

  void _markAllAsRead() {
    setState(() {
      for (final item in notifications) {
        item['unread'] = false;
      }
    });
  }

  void _openNotification(Map<String, dynamic> item) {
    setState(() => item['unread'] = false);

    // Indeks tab Owner: 0 Beranda, 1 Persetujuan, 2 Laporan,
    // 3 Pengguna, 4 Pengaturan.
    int destination = 0;
    switch (item['type']) {
      case 'persetujuan':
        destination = 1;
        break;
      case 'laporan':
        destination = 2;
        break;
      case 'pengguna':
        destination = 3;
        break;
      case 'stok':
        destination = 0;
        break;
    }

    Navigator.pop(context);
    widget.onNavigate?.call(destination);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: primary),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: unreadCount == 0 ? null : _markAllAsRead,
            child: const Text(
              'Tandai semua',
              style: TextStyle(
                color: primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aktivitas Terbaru',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  unreadCount == 0
                      ? 'Semua notifikasi sudah dibaca.'
                      : 'Kamu memiliki $unreadCount notifikasi belum dibaca.',
                  style: const TextStyle(color: muted, fontSize: 12),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _filterButton('Semua'),
                    const SizedBox(width: 10),
                    _filterButton('Belum dibaca'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: filteredNotifications.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: filteredNotifications.length,
                    separatorBuilder: (_, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _notificationCard(filteredNotifications[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label) {
    final bool selected = selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primary : const Color(0xFFE2E9E3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : muted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final bool unread = item['unread'] == true;
    final String type = item['type'];

    final IconData icon;
    final Color iconColor;
    final Color iconBackground;
    switch (type) {
      case 'persetujuan':
        icon = Icons.fact_check_outlined;
        iconColor = primary;
        iconBackground = const Color(0xFFE1F0E5);
        break;
      case 'stok':
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFC17B19);
        iconBackground = const Color(0xFFFFF1D9);
        break;
      case 'pengguna':
        icon = Icons.people_alt_outlined;
        iconColor = const Color(0xFF8061A8);
        iconBackground = const Color(0xFFF0EAF8);
        break;
      default:
        icon = Icons.insert_chart_outlined;
        iconColor = const Color(0xFF526FAD);
        iconBackground = const Color(0xFFE8EDFA);
    }

    return Material(
      color: unread ? const Color(0xFFEDF5EF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNotification(item),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread
                  ? const Color(0xFFD5E6D8)
                  : const Color(0xFFE8ECE8),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'],
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      item['message'],
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['time'],
                      style: const TextStyle(
                        color: muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 55,
            color: Color(0xFFB7C5BA),
          ),
          SizedBox(height: 12),
          Text(
            'Tidak ada notifikasi',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Notifikasi baru akan muncul di sini.',
            style: TextStyle(color: muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
