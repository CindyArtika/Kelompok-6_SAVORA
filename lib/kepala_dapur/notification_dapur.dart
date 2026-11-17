
import 'package:flutter/material.dart';

// Dipakai bersama oleh halaman Beranda dan halaman Notifikasi.
final ValueNotifier<int> dapurUnreadCount = ValueNotifier<int>(3);

class NotificationDapur extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const NotificationDapur({
    super.key,
    this.onNavigate,
  });

  @override
  State<NotificationDapur> createState() => _NotificationDapurState();
}

class _NotificationDapurState extends State<NotificationDapur> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  String selectedFilter = 'Semua';

  // Data notifikasi contoh Kepala Dapur.
  static final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Stok Bahan Kritis',
      'message':
          'Stok Susu UHT tersisa 2 Liter. Periksa stok dan ajukan kebutuhan bahan jika diperlukan.',
      'time': '5 menit lalu',
      'type': 'stok',
      'unread': true,
    },
    {
      'title': 'Pengajuan Diproses Admin',
      'message':
          'Pengajuan kebutuhan Biji Kopi sudah ditinjau Admin dan sedang diproses menjadi Purchase Order (PO).',
      'time': '30 menit lalu',
      'type': 'pengajuan',
      'unread': true,
    },
    {
      'title': 'PO Disetujui Owner',
      'message':
          'Purchase Order untuk bahan Gula Aren telah disetujui Owner. Bahan dapat dipantau sampai diterima.',
      'time': '1 jam lalu',
      'type': 'persetujuan',
      'unread': true,
    },
    {
      'title': 'PO Menunggu Persetujuan Owner',
      'message':
          'Admin telah membuat PO untuk Krimer. Pengadaan sedang menunggu keputusan Owner.',
      'time': '3 jam lalu',
      'type': 'pengadaan',
      'unread': false,
    },
    {
      'title': 'Stok Bahan Diperbarui',
      'message':
          'Stok Biji Kopi telah diperbarui setelah bahan diterima. Silakan periksa jumlah stok terbaru.',
      'time': 'Kemarin',
      'type': 'stok',
      'unread': false,
    },
  ];

  int get unreadCount =>
      notifications.where((item) => item['unread'] == true).length;

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 'Belum dibaca') {
      return notifications
          .where((item) => item['unread'] == true)
          .toList();
    }

    return notifications;
  }

  // Sinkronkan jumlah belum dibaca ke ikon lonceng di Beranda.
    void _updateUnreadBadge() {
      dapurUnreadCount.value = unreadCount;
    }

    @override
    void initState() {
      super.initState();
      _updateUnreadBadge();
    }

  void _markAllAsRead() {
    setState(() {
      for (final item in notifications) {
        item['unread'] = false;
      }
    });

    _updateUnreadBadge();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah dibaca.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openNotification(Map<String, dynamic> item) {
    setState(() {
      item['unread'] = false;
    });

    _updateUnreadBadge();

    int destination = 0;

    switch (item['type']) {
      case 'stok':
      case 'persetujuan':
      case 'pengadaan':
      case 'pengajuan':
        destination = 1;
        break;
      case 'menu':
        destination = 2;
        break;
    }

    Navigator.pop(context);
    widget.onNavigate?.call(destination);
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'stok':
        return Icons.warning_amber_rounded;
      case 'persetujuan':
        return Icons.check_circle_outline_rounded;
      case 'menu':
        return Icons.restaurant_menu_rounded;
      case 'pengadaan':
      case 'pengajuan':
        return Icons.inventory_2_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _iconColorForType(String type) {
    switch (type) {
      case 'stok':
        return const Color(0xFFC17B19);
      case 'persetujuan':
        return const Color(0xFF21834B);
      case 'menu':
        return const Color(0xFF8052B5);
      case 'pengadaan':
      case 'pengajuan':
        return const Color(0xFF4776B8);
      default:
        return primary;
    }
  }

  Color _iconBackgroundForType(String type) {
    switch (type) {
      case 'stok':
        return const Color(0xFFFFF1D9);
      case 'persetujuan':
        return const Color(0xFFE4F5E9);
      case 'menu':
        return const Color(0xFFF0E9FA);
      case 'pengadaan':
      case 'pengajuan':
        return const Color(0xFFEAEFF8);
      default:
        return const Color(0xFFEAF0EC);
    }
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
    final String type = item['type'] as String;

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
                  color: _iconBackgroundForType(type),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  _iconForType(type),
                  color: _iconColorForType(type),
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
                            item['title'] as String,
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
                      item['message'] as String,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['time'] as String,
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
