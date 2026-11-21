
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/kepala_dapur/menu_status_data.dart';

/// Sumber status ketersediaan menu bersama untuk Kepala Dapur dan Kasir.
class MenuFirestoreService {
  MenuFirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = 'menus';

  static String documentId(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  /// Membuat dokumen menu hanya jika belum ada.
  static Future<void> initializeMenus() async {
    for (final menu in menuStatusSavora) {
      final name = menu['name'] ?? '';

      if (name.isEmpty) continue;

      final ref = _db
          .collection(collectionName)
          .doc(documentId(name));

      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);

        if (snapshot.exists) return;

        transaction.set(ref, {
          'name': name,
          'category': menu['category'] ?? 'Minuman',
          'image': menu['image'] ?? '',
          'status': menu['status'] ?? 'Tersedia',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    }
  }

  /// Memperbarui status menu di Firestore.
  static Future<void> updateStatus({
    required String name,
    required String status,
    String? category,
    String? image,
  }) {
    return _db
        .collection(collectionName)
        .doc(documentId(name))
        .set({
      'name': name,
      'category': ?category,
      'image': ?image,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Memantau perubahan menu secara realtime.
  static Stream<QuerySnapshot<Map<String, dynamic>>> watchMenus() {
    return _db.collection(collectionName).snapshots();
  }
}
