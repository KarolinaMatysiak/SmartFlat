import 'package:cloud_firestore/cloud_firestore.dart';

class LivingSpaceService {
  static final LivingSpaceService _instance = LivingSpaceService._internal();

  factory LivingSpaceService() {
    return _instance;
  }

  LivingSpaceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getLivingSpacesByUser(
    String createdBy,
  ) {
    return _firestore
        .collection('livingSpaces')
        .where('createdBy', isEqualTo: createdBy)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLivingSpaces(String createdBy) {
    return _firestore
        .collection('livingSpaces')
        .where('createdBy', isEqualTo: createdBy)
        .snapshots();
  }

  Future<void> createLivingSpace({
    required String createdBy,
    required String name,
  }) async {
    final docRef = _firestore.collection('livingSpaces').doc();
    await docRef.set({
      'id': docRef.id,
      'createdBy': createdBy,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
