
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
    try {
      final dataFirestore = konversiKeFirestore(data);

      final nama = (dataFirestore['name'] ?? '').toString().trim();

      if (nama.isEmpty) {
        throw Exception('Nama bahan tidak boleh kosong.');
      }

      // Membuat ID berdasarkan nama bahan.
      final id = nama
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');

      if (id.isEmpty) {
        throw Exception('Nama bahan tidak valid untuk Document ID.');
      }

      // Mengakses koleksi stok_bahan.
      final collection = _db.collection('stok_bahan');

      // Memeriksa nama bahan di seluruh dokumen lama.
      final snapshot = await collection.get();

      final namaSudahAda = snapshot.docs.any((doc) {
        final namaLama = (doc.data()['name'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        return namaLama == nama.toLowerCase();
      });

      if (namaSudahAda) {
        throw Exception(
          'Bahan "$nama" sudah tersedia di Firestore.',
        );
      }

      // Memeriksa apakah ID sudah digunakan.
      final docRef = collection.doc(id);
      final existingDoc = await docRef.get();

      if (existingDoc.exists) {
        throw Exception(
          'Document ID "$id" sudah digunakan. Data lama tidak diubah.',
        );
      }

      // Menyimpan bahan baru.
      await docRef.set({
        ...dataFirestore,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('BAHAN BERHASIL DISIMPAN');
      debugPrint('DOCUMENT ID: $id');
      debugPrint('NAMA BAHAN: $nama');

      return id;
    } catch (e, stackTrace) {
      debugPrint('GAGAL MENAMBAH BAHAN: $e');
      debugPrint('STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // Menambahkan stok ke bahan yang sudah terdaftar
  Future<void> tambahStokBahan({
    required String id,
    required double jumlah,
    String? catatan,
  }) async {
    if (jumlah <= 0) {
      throw Exception('Jumlah stok harus lebih dari 0.');
    }

    final docRef = _db.collection('stok_bahan').doc(id);
    final riwayatRef = docRef.collection('riwayat_stok').doc();

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw Exception('Data bahan tidak ditemukan.');
      }

      final data = snapshot.data()!;
      final stokLama = (data['stockQty'] as num?)?.toDouble() ?? 0;
      final stokBaru = stokLama + jumlah;
      final satuan = data['unit']?.toString() ?? '';

      // Perbarui jumlah stok
      transaction.update(docRef, {
        'stockQty': stokBaru,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Simpan riwayat penambahan stok
      transaction.set(riwayatRef, {
        'type': 'masuk',
        'quantity': jumlah,
        'stockBefore': stokLama,
        'stockAfter': stokBaru,
        'unit': satuan,
        'note': catatan ?? '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

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
