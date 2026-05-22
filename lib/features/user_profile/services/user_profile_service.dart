import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfileService {
  static final UserProfileService _instance = UserProfileService._internal();

  factory UserProfileService() {
    return _instance;
  }

  UserProfileService._internal();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(String identityId) {
    return firestore.collection('usersProfiles').doc(identityId).get();
  }

  Future<void> createUserProfile({
    required String identityId,
    required String firstName,
    required String userName,
  }) async {
    await firestore.collection('usersProfiles').doc(identityId).set({
      'firstName': firstName,
      'userName': userName,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
