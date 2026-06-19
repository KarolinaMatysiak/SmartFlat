import 'package:cloud_firestore/cloud_firestore.dart';

class ShoppingItemService {
  static final ShoppingItemService _instance = ShoppingItemService._internal();

  factory ShoppingItemService() {
    return _instance;
  }

  ShoppingItemService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchShoppingItems(String livingSpaceId) {
    return _firestore
        .collection('shoppingItems')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .snapshots();
  }

  Future<void> createShoppingItem({
    required String createdBy,
    required String livingSpaceId,
    required String title,
    required String description,
    String? assignedTo,
  }) async {
    await _firestore.collection('shoppingItems').add({
      'createdBy': createdBy,
      'livingSpaceId': livingSpaceId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'createdAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  Future<void> updateShoppingItemStatus(String shoppingItemId, String status) async {
    await _firestore.collection('shoppingItems').doc(shoppingItemId).update({
      'status': status,
    });
  }

  Future<void> updateShoppingItem(String shoppingItemId, Map<String, dynamic> data) async {
    await _firestore.collection('shoppingItems').doc(shoppingItemId).update(data);
  }

  Future<void> deleteShoppingItem(String shoppingItemId) async {
    await _firestore.collection('shoppingItems').doc(shoppingItemId).delete();
  }
}
