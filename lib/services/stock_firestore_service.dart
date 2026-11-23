import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class StockFirestoreService {
  StockFirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String collectionName = 'stok_bahan';
  static const String requestCollectionName = 'pengajuan_stok_bahan';

  static Future<void> importStocksFromJson() async {
    final snapshot = await _db.collection(collectionName).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;
    final raw = await rootBundle.loadString('assets/data/data_stok_bahan_savora.json');
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Format JSON stok harus berupa List.');
    final batch = _db.batch();
    for (final value in decoded) {
      if (value is! Map) continue;
      final data = Map<String, dynamic>.from(value);
      final name = (data['name'] ?? data['nama'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      batch.set(_db.collection(collectionName).doc(documentId(name)), {
        ...data,
        'name': name,
        'stockQty': _asDouble(data['stockQty'] ?? data['stock'] ?? 0),
        'unit': (data['unit'] ?? data['satuan'] ?? 'Pcs').toString(),
        'category': (data['category'] ?? data['kategori'] ?? '').toString(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static String documentId(String name) => name.toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchStocks() =>
      _db.collection(collectionName).orderBy('name').snapshots();

  static Map<String, dynamic> normalize(Map<String, dynamic> data) {
    final qty = _asDouble(data['stockQty']);
    final min = _asDouble(data['minimumThreshold']);
    final critical = _asDouble(data['criticalThreshold']);
    final status = qty <= critical ? 'Kritis' : qty <= min ? 'Menipis' : 'Aman';
    return {
      ...data,
      'name': (data['name'] ?? '').toString(),
      'stockQty': qty,
      'unit': (data['unit'] ?? 'Pcs').toString(),
      'category': (data['category'] ?? '').toString(),
      'stock': '${_formatNumber(qty)} ${data['unit'] ?? 'Pcs'}',
      'status': status,
      'updated': _formatUpdated(data['updatedAt']),
    };
  }

  static Future<void> initializeFromLegacy(List<Map<String, dynamic>> legacyStocks) async {
    final snapshot = await _db.collection(collectionName).limit(1).get();
    if (snapshot.docs.isNotEmpty || legacyStocks.isEmpty) return;
    final batch = _db.batch();
    for (final item in legacyStocks) {
      final name = (item['name'] ?? '').toString().trim();
      if (name.isEmpty) continue;
      batch.set(_db.collection(collectionName).doc(documentId(name)), {
        ...item,
        'name': name,
        'stockQty': _asDouble(item['stockQty']),
        'unit': (item['unit'] ?? 'Pcs').toString(),
        'category': (item['category'] ?? '').toString(),
        'criticalThreshold': _asDouble(item['criticalThreshold']),
        'minimumThreshold': _asDouble(item['minimumThreshold']),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  static Future<void> updateStock({
    required String stockId,
    required double stockQty,
    required double criticalThreshold,
    required double minimumThreshold,
  }) async {
    if (stockQty < 0 || criticalThreshold < 0 || minimumThreshold < 0) {
      throw ArgumentError('Nilai stok dan batas stok tidak boleh negatif.');
    }
    if (criticalThreshold > minimumThreshold) {
      throw ArgumentError('Batas kritis tidak boleh lebih besar dari batas minimum.');
    }
    await _db.collection(collectionName).doc(stockId).update({
      'stockQty': stockQty,
      'criticalThreshold': criticalThreshold,
      'minimumThreshold': minimumThreshold,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<String> createStockRequest({
    required String name,
    required String unit,
    required double quantity,
    required String note,
    required double currentStock,
    String category = '',
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sesi pengguna tidak ditemukan. Silakan login ulang.');
    if (quantity <= 0 || currentStock < 0) throw ArgumentError('Jumlah pengajuan atau stok saat ini tidak valid.');
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final userData = userDoc.data() ?? <String, dynamic>{};
    final doc = await _db.collection(requestCollectionName).add({
      'requesterUid': user.uid,
      'requesterName': (userData['nama'] ?? user.displayName ?? '').toString(),
      'requesterEmail': user.email ?? '',
      'requesterRole': (userData['role'] ?? 'kepala_dapur').toString(),
      'namaBahan': name,
      'kategori': category,
      'satuan': unit,
      'jumlahDiajukan': quantity,
      'jumlahAwal': quantity,
      'jumlahRevisiAdmin': null,
      'stokSaatPengajuan': currentStock,
      'catatan': note,
      'status': 'Menunggu Konfirmasi Admin',
      'catatanAdmin': null,
      'adminUid': null,
      'adminName': null,
      'waktuKonfirmasiAdmin': null,
      'keputusanOwner': null,
      'catatanOwner': null,
      'ownerUid': null,
      'ownerName': null,
      'waktuKeputusanOwner': null,
      'supplier': null,
      'nomorPO': null,
      'detailPO': null,
      'waktuPO': null,
      'waktuBarangDiterima': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'riwayatStatus': [
        {'status': 'Menunggu Konfirmasi Admin', 'olehUid': user.uid, 'olehRole': 'kepala_dapur', 'waktu': Timestamp.now()}
      ],
    });
    return doc.id;
  }

  // Hanya pengaju sendiri yang dapat mengedit selama belum diproses Admin.
  static Future<void> updateStockRequest({
    required String requestId,
    required double quantity,
    required String note,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sesi pengguna tidak ditemukan.');
    if (quantity <= 0) throw ArgumentError('Jumlah pengajuan harus lebih dari 0.');
    final ref = _db.collection(requestCollectionName).doc(requestId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Pengajuan tidak ditemukan.');
      final data = snapshot.data()!;
      if (data['requesterUid'] != user.uid) throw StateError('Kamu tidak memiliki pengajuan ini.');
      if (data['status'] != 'Menunggu Konfirmasi Admin') {
        throw StateError('Pengajuan tidak bisa diedit karena sudah diproses Admin.');
      }
      final history = List<Map<String, dynamic>>.from(
        (data['riwayatStatus'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
      history.add({
        'status': 'Pengajuan Diperbarui',
        'olehUid': user.uid,
        'olehRole': 'kepala_dapur',
        'waktu': Timestamp.now(),
      });
      transaction.update(ref, {
        'jumlahDiajukan': quantity,
        'jumlahAwal': quantity,
        'catatan': note,
        'updatedAt': FieldValue.serverTimestamp(),
        'riwayatStatus': history,
      });
    });
  }

  // Pembatalan dicatat sebagai status, bukan menghapus dokumen riwayat.
  static Future<void> cancelStockRequest({required String requestId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('Sesi pengguna tidak ditemukan.');
    final ref = _db.collection(requestCollectionName).doc(requestId);
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Pengajuan tidak ditemukan.');
      final data = snapshot.data()!;
      if (data['requesterUid'] != user.uid) throw StateError('Kamu tidak memiliki pengajuan ini.');
      if (data['status'] != 'Menunggu Konfirmasi Admin') {
        throw StateError('Pengajuan tidak bisa dibatalkan karena sudah diproses Admin.');
      }
      final history = List<Map<String, dynamic>>.from(
        (data['riwayatStatus'] as List? ?? []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
      history.add({
        'status': 'Dibatalkan Kepala Dapur',
        'olehUid': user.uid,
        'olehRole': 'kepala_dapur',
        'waktu': Timestamp.now(),
      });
      transaction.update(ref, {
        'status': 'Dibatalkan Kepala Dapur',
        'updatedAt': FieldValue.serverTimestamp(),
        'riwayatStatus': history,
      });
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchMyStockRequests() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();
    return _db.collection(requestCollectionName)
        .where('requesterUid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> watchAllStockRequests() =>
      _db.collection(requestCollectionName).orderBy('createdAt', descending: true).snapshots();

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value == null) return 0;
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? 0;
  }

  static String _formatNumber(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();

  static String _formatUpdated(dynamic value) {
    if (value is Timestamp) {
      final diff = DateTime.now().difference(value.toDate());
      if (diff.inMinutes < 1) return 'Baru saja';
      if (diff.inHours < 1) return '${diff.inMinutes} menit lalu';
      if (diff.inDays < 1) return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    }
    return 'Belum diperbarui';
  }
}
