import 'package:cloud_firestore/cloud_firestore.dart';

class LivingSpaceInvitationService {
  static final LivingSpaceInvitationService _instance = LivingSpaceInvitationService._internal();

  factory LivingSpaceInvitationService() {
    return _instance;
  }

  LivingSpaceInvitationService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> generateInvitationCode(String spaceId) async {
    final code = (100000 + (999999 - 100000) * (DateTime.now().millisecondsSinceEpoch % 1000000) ~/ 1000000).toString();
    final invitationRef = _firestore.collection('invitations').doc(code);

    await invitationRef.set({
      'code': code,
      'spaceId': spaceId,
      'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(hours: 2))),
      'used': false,
    });

    return code;
  }

  Future<void> joinSpaceWithCode(String userId, String code) async {
    final invitationDoc = await _firestore.collection('invitations').doc(code).get();
    if (!invitationDoc.exists) {
      throw Exception('Invalid invitation code');
    }

    final data = invitationDoc.data()!;
    if (data['used'] == true) {
      throw Exception('Invitation code already used');
    }

    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (DateTime.now().isAfter(expiresAt)) {
      throw Exception('Invitation code expired');
    }

    final spaceId = data['spaceId'];

    await _firestore.collection('livingSpaces').doc(spaceId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
    });

    await invitationDoc.reference.update({'used': true});
  }
}
