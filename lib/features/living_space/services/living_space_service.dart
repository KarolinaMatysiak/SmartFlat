import 'package:cloud_firestore/cloud_firestore.dart';

class LivingSpaceService {
  static final LivingSpaceService _instance = LivingSpaceService._internal();

  factory LivingSpaceService() {
    return _instance;
  }

  LivingSpaceService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<QuerySnapshot<Map<String, dynamic>>> getLivingSpacesByUser(
    String userId,
  ) {
    return _firestore
        .collection('livingSpaces')
        .where('memberIds', arrayContains: userId)
        .get();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchLivingSpaces(String userId) {
    return _firestore
        .collection('livingSpaces')
        .where('memberIds', arrayContains: userId)
        .snapshots();
  }

  Future<String> createLivingSpace({
    required String createdBy,
    required String name,
  }) async {
    final docRef = _firestore.collection('livingSpaces').doc();
    await docRef.set({
      'id': docRef.id,
      'createdBy': createdBy,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'memberIds': [createdBy],
    });
    return docRef.id;
  }

  Future<List<Map<String, dynamic>>> getMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) return [];

    final usersSnapshot = await _firestore
        .collection('userProfiles')
        .where('createdBy', whereIn: memberIds)
        .get();

    return usersSnapshot.docs.map((doc) => doc.data()).toList();
  }
}
