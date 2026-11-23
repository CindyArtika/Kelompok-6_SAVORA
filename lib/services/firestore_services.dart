
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // DATA USER
  // =========================

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    debugPrint('========== FIRESTORE ==========');
    debugPrint('MENGAMBIL DATA UID: $uid');

    final doc = await _db.collection('users').doc(uid).get();

    debugPrint('DOKUMEN DITEMUKAN: ${doc.exists}');
    debugPrint('DATA DOKUMEN: ${doc.data()}');

    if (!doc.exists) return null;

    return doc.data();
  }

  Future<void> createUserData({
    required String uid,
    required String nama,
    required String email,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).set({
      'nama': nama,
      'email': email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // =========================
  // DATA BAHAN SAVORA
  // =========================

  // Mengambil data dari koleksi stok_bahan
  Stream<QuerySnapshot<Map<String, dynamic>>> streamBahan() {
    return _db.collection('stok_bahan').snapshots();
  }

  // Mengubah format data database ke format tampilan lama
  Map<String, dynamic> konversiDataBahan(
    Map<String, dynamic> data,
  ) {
    return {
      ...data,
      'nama': data['name'] ?? '',
      'kategoriUtama': data['category'] ?? '',
      'kategori': data['category'] ?? '',
      'stok': data['stockQty'] ?? 0,
      'satuan': data['unit'] ?? '',
      'minimum': data['minimumThreshold'] ?? 0,
      'criticalThreshold': data['criticalThreshold'] ?? 0,
      'gambar': data['image'] ?? '',
      'harga': data['pricePerUnit'] ?? 0,
    };
  }

  // Mengubah format tampilan ke format database
  Map<String, dynamic> konversiKeFirestore(
    Map<String, dynamic> data,
  ) {
    final Map<String, dynamic> hasil = {
      'name': data['nama'] ?? data['name'] ?? '',
      'category': data['kategoriUtama'] ??
          data['category'] ??
          data['kategori'] ??
          '',
      'stockQty': data['stok'] ?? data['stockQty'] ?? 0,
      'unit': data['satuan'] ?? data['unit'] ?? '',
      'image': data['gambar'] ?? data['image'] ?? '',
      'pricePerUnit': data['harga'] ?? data['pricePerUnit'] ?? 0,
    };

    // Hitung batas kritis jika batas minimum tersedia.
    final minimum = data['minimum'] ?? data['minimumThreshold'];

    if (minimum != null) {
      hasil['minimumThreshold'] = minimum;
      hasil['criticalThreshold'] = (minimum as num) * 0.5;
    }

    // Pertahankan nilai color jika memang dikirim.
    if (data.containsKey('color')) {
      hasil['color'] = data['color'];
    }

    return hasil;
  }

  // Menambahkan bahan baru
  Future<String> tambahBahan(Map<String, dynamic> data) async {
    final nama = (data['nama'] ?? data['name'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    final id = nama
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');

    final docRef = _db.collection('stok_bahan').doc(id);

    // Cek apakah ID sudah digunakan
    final existingDoc = await docRef.get();

    if (existingDoc.exists) {
      throw Exception('Bahan dengan nama tersebut sudah tersedia.');
    }

    await docRef.set({
      ...konversiKeFirestore(data),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Mengubah data bahan
  Future<void> updateBahan(
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.collection('stok_bahan').doc(id).update({
      ...konversiKeFirestore(data),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Menghapus bahan
  Future<void> hapusBahan(String id) async {
    await _db.collection('stok_bahan').doc(id).delete();
  }
}
