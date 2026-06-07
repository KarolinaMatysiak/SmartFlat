import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

class LivingSpaceProvider extends ChangeNotifier {
  final LivingSpaceService _livingSpaceService = LivingSpaceService();

  QuerySnapshot<Map<String, dynamic>>? _spacesSnapshot;
  StreamSubscription? _spacesSubscription;
  bool _isLoading = false;
  String? _currentUserId;

  QuerySnapshot<Map<String, dynamic>>? get spacesSnapshot => _spacesSnapshot;

  bool get isLoading => _isLoading;

  bool get hasSpaces =>
      _spacesSnapshot != null && _spacesSnapshot!.docs.isNotEmpty;

  String? get activeSpaceId =>
      hasSpaces ? _spacesSnapshot!.docs.first.id : null;

  void update(String? uid) {
    if (uid == null) {
      clear();
    } else if (_currentUserId != uid) {
      init(uid);
    }
  }

  void clear() {
    if (_currentUserId == null && _spacesSnapshot == null) return;
    _currentUserId = null;
    _spacesSubscription?.cancel();
    _spacesSnapshot = null;
    _isLoading = false;
    notifyListeners();
  }

  void init(String identityId) {
    _currentUserId = identityId;
    _spacesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _spacesSubscription = _livingSpaceService
        .watchLivingSpaces(identityId)
        .listen(
          (snapshot) {
            _spacesSnapshot = snapshot;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> createSpace({
    required String createdBy,
    required String name,
  }) async {
    await _livingSpaceService.createLivingSpace(
      createdBy: createdBy,
      name: name,
    );
  }

  @override
  void dispose() {
    _spacesSubscription?.cancel();
    super.dispose();
  }
}
