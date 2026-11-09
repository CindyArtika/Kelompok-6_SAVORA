import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

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
}