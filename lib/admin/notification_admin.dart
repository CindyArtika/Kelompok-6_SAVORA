import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/services/stock_firestore_service.dart';

class NotificationAdmin extends StatefulWidget {
  final ValueChanged<int>? onNavigate;

  const NotificationAdmin({super.key, this.onNavigate});

  @override
  State<NotificationAdmin> createState() => _NotificationAdminState();
}

class _NotificationAdminState extends State<NotificationAdmin> {
  static const Color primary = Color(0xFF143C2D);
  static const Color background = Color(0xFFF4F8F5);
  static const Color textColor = Color(0xFF17212D);
  static const Color muted = Color(0xFF758078);

  String selectedFilter = 'Semua';

  String _formatTime(dynamic value) {
    if (value is! Timestamp) return 'Baru saja';
    final date = value.toDate();
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _markAllAsRead(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    try {
      final ids = docs
          .where((doc) => doc.data()['isRead'] != true)
          .map((doc) => doc.id)
          .toList();
      await StockFirestoreService.markAllAdminNotificationsAsRead(ids);
    } catch (e) {
      _showMessage('Gagal memperbarui notifikasi: $e');
    }
  }

  Future<void> _openNotification(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    try {
      if (doc.data()['isRead'] != true) {
        await StockFirestoreService.markAdminNotificationAsRead(doc.id);
      }
      if (!mounted) return;
      Navigator.pop(context);
      widget.onNavigate?.call(3);
    } catch (e) {
      _showMessage('Gagal membuka notifikasi: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: StockFirestoreService.watchAdminNotifications(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Gagal memuat notifikasi.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final unreadDocs = docs
              .where((doc) => doc.data()['isRead'] != true)
              .toList();
          final filteredDocs = selectedFilter == 'Belum dibaca'
              ? unreadDocs
              : docs;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        TextButton(
                          onPressed: unreadDocs.isEmpty
                              ? null
                              : () => _markAllAsRead(docs),
                          child: const Text(
                            'Tandai semua',
                            style: TextStyle(
                              color: primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      unreadDocs.isEmpty
                          ? 'Semua notifikasi sudah dibaca.'
                          : 'Kamu memiliki ${unreadDocs.length} notifikasi belum dibaca.',
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
                child: filteredDocs.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                        itemCount: filteredDocs.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _notificationCard(filteredDocs[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _filterButton(String label) {
    final selected = selectedFilter == label;
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

  Widget _notificationCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final item = doc.data();
    final unread = item['isRead'] != true;
    return Material(
      color: unread ? const Color(0xFFEDF5EF) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openNotification(doc),
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
                  color: const Color(0xFFE1F0E5),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: primary,
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
                            (item['title'] ?? 'Notifikasi').toString(),
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
                      (item['message'] ?? '').toString(),
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _formatTime(item['createdAt']),
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
