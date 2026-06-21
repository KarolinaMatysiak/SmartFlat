import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_flat/features/shopping_item/services/shopping_item_service.dart';

class ShoppingItemProvider extends ChangeNotifier {
  final ShoppingItemService _shoppingItemService = ShoppingItemService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  QuerySnapshot<Map<String, dynamic>>? _shoppingItemsSnapshot;
  StreamSubscription? _shoppingItemsSubscription;
  bool _isLoading = false;
  String? _currentSpaceId;

  QuerySnapshot<Map<String, dynamic>>? get shoppingItemsSnapshot => _shoppingItemsSnapshot;
  bool get isLoading => _isLoading;
  bool get hasShoppingItems => _shoppingItemsSnapshot != null && _shoppingItemsSnapshot!.docs.isNotEmpty;

  List<QueryDocumentSnapshot<Map<String, dynamic>>> get userShoppingItems {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _shoppingItemsSnapshot == null) return [];
    return _shoppingItemsSnapshot!.docs
        .where((doc) => doc.data()['assignedTo'] == uid)
        .toList();
  }

  bool get hasUserShoppingItems => userShoppingItems.isNotEmpty;

  void update(String? spaceId) {
    if (spaceId == null) {
      clear();
    } else if (_currentSpaceId != spaceId) {
      init(spaceId);
    }
  }

  void clear() {
    if (_currentSpaceId == null && _shoppingItemsSnapshot == null) return;
    _currentSpaceId = null;
    _shoppingItemsSubscription?.cancel();
    _shoppingItemsSnapshot = null;
    _isLoading = false;
    notifyListeners();
  }

  void init(String livingSpaceId) {
    _currentSpaceId = livingSpaceId;
    _shoppingItemsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _shoppingItemsSubscription = _shoppingItemService.watchShoppingItems(livingSpaceId).listen(
      (snapshot) {
        _shoppingItemsSnapshot = snapshot;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addShoppingItem(String title, String description, {String? assignedTo}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentSpaceId == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _shoppingItemService.createShoppingItem(
        createdBy: uid,
        livingSpaceId: _currentSpaceId!,
        title: title,
        description: description,
        assignedTo: assignedTo,
      );
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleShoppingItemStatus(String shoppingItemId, String currentStatus) async {
    final newStatus = currentStatus == 'completed' ? 'pending' : 'completed';
    await _shoppingItemService.updateShoppingItemStatus(shoppingItemId, newStatus);
  }

  Future<void> updateShoppingItem(String shoppingItemId, {String? title, String? description, String? assignedTo}) async {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    data['assignedTo'] = assignedTo;

    await _shoppingItemService.updateShoppingItem(shoppingItemId, data);
  }

  Future<void> deleteShoppingItem(String shoppingItemId) async {
    await _shoppingItemService.deleteShoppingItem(shoppingItemId);
  }

  @override
  void dispose() {
    _shoppingItemsSubscription?.cancel();
    super.dispose();
  }
}
