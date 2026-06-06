import 'package:cloud_firestore/cloud_firestore.dart';

class LivingSpaceService {
  static final LivingSpaceService _instance = LivingSpaceService._internal();

  factory LivingSpaceService() {
    return _instance;
  }

  LivingSpaceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getLivingSpacesByUser(
    String identityId,
  ) {
    return _firestore
        .collection('livingSpaces')
        .where('ownerId', isEqualTo: identityId)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> listenToLivingSpaces(String identityId) {
    return _firestore
        .collection('livingSpaces')
        .where('ownerId', isEqualTo: identityId)
        .snapshots();
  }

  Future<void> createLivingSpace({
    required String identityId,
    required String name,
  }) async {
    await _firestore.collection('livingSpaces').add({
      'ownerId': identityId,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
