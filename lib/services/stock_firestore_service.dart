import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
/// Satu sumber data stok untuk Dashboard dan halaman Stok Bahan Dapur.
class StockFirestoreService {
  StockFirestoreService._();
  static Future<void> importStocksFromJson() async {
  final collection = _db.collection(collectionName);

  // Cegah data diimpor berulang kali.
  final existing = await collection.limit(1).get();

  if (existing.docs.isNotEmpty) {
    throw Exception(
      'Koleksi stok_bahan sudah memiliki data.',
    );
  }

  // Membaca file JSON dari assets.
  final jsonString = await rootBundle.loadString(
    'assets/data/data_stok_bahan_savora.json',
  );

  final List<dynamic> data = jsonDecode(jsonString);

  final batch = _db.batch();

  for (final item in data) {
    final stock = Map<String, dynamic>.from(item);

    final name = stock['name'].toString();

    final docId = documentId(name);
    final docRef = collection.doc(docId);

    stock['createdAt'] = FieldValue.serverTimestamp();
    stock['updatedAt'] = FieldValue.serverTimestamp();

    batch.set(docRef, stock);
  }

  await batch.commit();
}

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = 'stok_bahan';

  static String documentId(String name) => name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchStocks() =>
      _db.collection(collectionName).orderBy('name').snapshots();

  static Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final qty = (data['stockQty'] as num?)?.toDouble() ?? 0;
    final unit = (data['unit'] ?? 'Unit').toString();
    final critical = (data['criticalThreshold'] as num?)?.toDouble() ?? 0;
    final minimum = (data['minimumThreshold'] as num?)?.toDouble() ?? 0;
    final status = qty <= critical
        ? 'Kritis'
        : qty <= minimum
            ? 'Menipis'
            : 'Aman';
    return {
      ...data,
      'stockQty': qty,
      'unit': unit,
      'stock': '${_formatQty(qty)} $unit',
      'criticalThreshold': critical,
      'minimumThreshold': minimum,
      'status': status,
      'updated': _updatedLabel(data['updatedAt']),
    };
  }

  static String _formatQty(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  static String _updatedLabel(dynamic value) {
    if (value is Timestamp) {
      final diff = DateTime.now().difference(value.toDate());
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    }
    return 'Belum diperbarui';
  }

  /// Migrasi awal satu kali: hanya mengisi koleksi jika masih kosong.
  /// Batas awal bersifat nilai awal dan dapat disesuaikan per bahan di Firestore.
  static Future<void> initializeFromLegacy(
    List<Map<String, dynamic>> legacyItems,
  ) async {
    final collection = _db.collection(collectionName);
    final existing = await collection.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final item in legacyItems) {
      final name = (item['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      final rawStock = (item['stock'] ?? '0 Unit').toString().trim();
      final match = RegExp(r'^([0-9]+(?:[.,][0-9]+)?)\s*(.*)$').firstMatch(rawStock);
      final qty = double.tryParse((match?.group(1) ?? '0').replaceAll(',', '.')) ?? 0;
      final unit = (match?.group(2)?.trim().isNotEmpty ?? false)
          ? match!.group(2)!.trim()
          : 'Unit';
      final oldStatus = (item['status'] ?? 'Aman').toString();

      // Threshold awal mempertahankan tingkat status stok lama.
      final critical = oldStatus == 'Kritis'
          ? qty
          : oldStatus == 'Menipis'
              ? qty * 0.5
              : qty * 0.25;
      final minimum = oldStatus == 'Kritis'
          ? qty * 2
          : oldStatus == 'Menipis'
              ? qty
              : qty * 0.75;

      final ref = collection.doc(documentId(name));
      batch.set(ref, {
        'name': name,
        'stockQty': qty,
        'unit': unit,
        'category': item['category'] ?? 'Bahan Minuman',
        'image': item['image'] ?? '',
        'color': item['color'] ?? 0xFFE8F0EA,
        'criticalThreshold': critical,
        'minimumThreshold': minimum,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  static Future<void> updateStock({
    required String name,
    required double stockQty,
    required double criticalThreshold,
    required double minimumThreshold,
  }) async {
    if (stockQty < 0 || criticalThreshold < 0 || minimumThreshold < 0) {
      throw ArgumentError('Nilai stok dan batas tidak boleh negatif.');
    }
    if (criticalThreshold > minimumThreshold) {
      throw ArgumentError('Batas kritis tidak boleh lebih besar dari batas minimum.');
    }
    await _db.collection(collectionName).doc(documentId(name)).update({
      'stockQty': stockQty,
      'criticalThreshold': criticalThreshold,
      'minimumThreshold': minimumThreshold,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> createStockRequest({
    required String name,
    required String unit,
    required double quantity,
    required String note,
    required double currentStock,
  }) async {
    await _db.collection('pengajuan_stok_bahan').add({
      'namaBahan': name,
      'satuan': unit,
      'jumlahDiajukan': quantity,
      'stokSaatPengajuan': currentStock,
      'catatan': note,
      'status': 'Menunggu Diproses Admin',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
