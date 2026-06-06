import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_flat/features/living_space/services/living_space_service.dart';

class LivingSpaceProvider extends ChangeNotifier {
  final LivingSpaceService _livingSpaceService = LivingSpaceService();

  QuerySnapshot<Map<String, dynamic>>? _spacesSnapshot;
  StreamSubscription? _spacesSubscription;
  bool _isLoading = true;

  QuerySnapshot<Map<String, dynamic>>? get spacesSnapshot => _spacesSnapshot;
  bool get isLoading => _isLoading;
  bool get hasSpaces => _spacesSnapshot != null && _spacesSnapshot!.docs.isNotEmpty;

  void init(String userId) {
    _spacesSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _spacesSubscription = _livingSpaceService.listenToLivingSpaces(userId).listen(
          (snapshot) {
        _spacesSnapshot = snapshot;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        print("Subscription error livingSpaces: $error");
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> createSpace({required String identityId, required String name}) async {
    await _livingSpaceService.createLivingSpace(identityId: identityId, name: name);
  }

  @override
  void dispose() {
    _spacesSubscription?.cancel();
    super.dispose();
  }
}