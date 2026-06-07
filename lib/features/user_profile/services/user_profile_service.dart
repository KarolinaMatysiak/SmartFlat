import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() {
    return _instance;
  }

  UserProfileService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String createdBy) {
    return firestore.collection('userProfiles').doc(createdBy).get();
  }

  Future<void> createUserProfile({
    required String createdBy,
    required String firstName,
    required String userName,
  }) async {
    await firestore.collection('userProfiles').doc(createdBy).set(
      {
        'createdBy': createdBy,
        'firstName': firstName,
        'userName': userName,
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
