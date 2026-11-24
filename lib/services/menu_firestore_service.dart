
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tubes_pemmob/kepala_dapur/menu_status_data.dart';

/// Sumber status ketersediaan menu bersama Kepala Dapur dan Kasir.
class MenuFirestoreService {
  MenuFirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = 'menus';

  static String documentId(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  /// Menentukan subkategori berdasarkan nama menu.
  static String getSubcategory(String name) {
    const coffee = [
      'Affogato',
      'Americano',
      'Caramel Latte',
      'Cafe Latte',
      'Cafe Mocha',
      'Hazelnut Latte',
      'Iced Cappuccino',
      'Kopi Susu Aren',
      'Red Velvet Latte',
      'Vanilla Latte',
    ];

    const nonCoffee = [
      'Chocolate Hazelnut',
      'Chocolate Milk',
      'Honey Milk',
      'Matcha Latte',
      'Strawberry Matcha',
      'Taro Milk',
      'Vanilla Milk',
    ];

    const tea = [
      'Green Tea Lemon',
      'Jasmine Milk Tea',
      'Lemon Tea',
      'Orange Tea',
      'Strawberry Tea',
    ];

    const fruitBased = [
      'Fresh Orange',
      'Honey Lemon',
      'Lemon Water',
      'Strawberry Juice',
      'Strawberry Lemon',
    ];

    if (coffee.contains(name)) return 'Coffee';
    if (nonCoffee.contains(name)) return 'Non-Coffee';
    if (tea.contains(name)) return 'Tea';
    if (fruitBased.contains(name)) return 'Fruit-Based';

    return '';
  }

  /// Migrasi subkategori seluruh dokumen menu yang sudah ada.
  /// Data lain seperti status, gambar, dan waktu tidak dihapus.
  static Future<int> migrateSubcategories() async {
    final snapshot = await _db.collection(collectionName).get();

    final batch = _db.batch();
    int updatedCount = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (data['category'] != 'Minuman') continue;

      final name = (data['name'] ?? '').toString();
      final subcategory = getSubcategory(name);

      if (subcategory.isEmpty) {
        continue;
      }

      if (data['subcategory'] == subcategory) {
        continue;
      }

      batch.update(doc.reference, {
        'subcategory': subcategory,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      updatedCount++;
    }

    if (updatedCount > 0) {
      await batch.commit();
    }

    return updatedCount;
  }

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

        final category = menu['category'] ?? 'Minuman';

        transaction.set(ref, {
          'name': name,
          'category': category,
          'subcategory': category == 'Minuman'
              ? getSubcategory(name)
              : '',
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
      ...?category != null ? {'category': category} : null,
      ...?image != null ? {'image': image} : null,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Memantau perubahan menu secara realtime.
  static Stream<QuerySnapshot<Map<String, dynamic>>> watchMenus() {
    return _db.collection(collectionName).snapshots();
  }
}
