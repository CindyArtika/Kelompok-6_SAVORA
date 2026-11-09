
import 'package:flutter/material.dart';

class NotificationAdmin extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const NotificationAdmin({
    super.key,
    this.onNavigate,
  });

    static int get unreadCount {
      return _NotificationAdminState.notifications
          .where((item) => item['unread'] == true)
          .length;
    }
  @override
  State<NotificationAdmin> createState() => _NotificationAdminState();
}

class _NotificationAdminState extends State<NotificationAdmin> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  String selectedFilter = 'Semua';

  static final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Pengajuan Pengadaan Baru',
      'message':
          'Admin mengajukan pengadaan bahan baku. Periksa detail pengajuan.',
      'time': '5 menit lalu',
      'type': 'pengadaan',
      'unread': true,
    },
    {
      'title': 'Stok Bahan Menipis',
      'message':
          'Fresh Milk Pasteurisasi tersisa 4.5 L. Stok sudah di bawah batas minimum.',
      'time': '30 menit lalu',
      'type': 'stok',
      'unread': true,
    },
    {
      'title': 'Laporan Harian Tersedia',
      'message':
          'Laporan penjualan hari ini sudah tersedia untuk ditinjau.',
      'time': '2 jam lalu',
      'type': 'laporan',
      'unread': false,
    },
    {
      'title': 'Pengadaan Diselesaikan',
      'message':
          'Admin telah memperbarui status pengadaan bahan baku.',
      'time': 'Kemarin',
      'type': 'pengadaan',
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'Belum dibaca') {
      return notifications
          .where((item) => item['unread'] == true)
          .toList();
    }

    return notifications;
  }

  int get unreadCount {
    return notifications.where((item) => item['unread'] == true).length;
  }

  void _markAllAsRead() {
    setState(() {
      for (final item in notifications) {
        item['unread'] = false;
      }
    });
  }

  void _openNotification(Map<String, dynamic> item) {
    setState(() {
      item['unread'] = false;
    });

    int destination = 0;

    switch (item['type']) {
      case 'stok':
        destination = 1;
        break;
      case 'pengadaan':
        destination = 3;
        break;
      case 'laporan':
        destination = 4;
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
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: primary,
          ),
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
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                  ),
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
                    itemBuilder: (context, index) {
                      return _notificationCard(
                        filteredNotifications[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String label) {
    final bool selected = selectedFilter == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 10,
        ),
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
      case 'stok':
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFC17B19);
        iconBackground = const Color(0xFFFFF1D9);
        break;
      case 'pengadaan':
        icon = Icons.inventory_2_outlined;
        iconColor = primary;
        iconBackground = const Color(0xFFE1F0E5);
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
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
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
