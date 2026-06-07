import 'package:flutter/material.dart';
import 'package:smart_flat/features/user_profile/services/user_profile_service.dart';

class UserProfileProvider extends ChangeNotifier {
  final UserProfileService _profileService = UserProfileService();

  Map<String, dynamic>? _profileData;
  bool _isLoading = false;
  String? _currentUserId;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get profileData => _profileData;
  bool get hasProfile => _profileData != null;

  void update(String? uid) {
    if (uid == null) {
      clear();
    } else if (_currentUserId != uid) {
      init(uid);
    }
  }

  void clear() {
    if (_currentUserId == null && _profileData == null) return;
    _currentUserId = null;
    _profileData = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> init(String identityId) async {
    _currentUserId = identityId;
    _isLoading = true;
    notifyListeners();

    try {
      final doc = await _profileService.getUserProfile(identityId);
      if (doc.exists) {
        _profileData = doc.data();
      } else {
        _profileData = null;
      }
    } catch (e) {
      _profileData = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUserProfile({
    required String createdBy,
    required String firstName,
    required String userName,
  }) async {
    _isLoading = true;
    notifyListeners();

    await _profileService.createUserProfile(
      createdBy: createdBy,
      firstName: firstName,
      userName: userName,
    );

    _profileData = {
      'createdBy': createdBy,
      'firstName': firstName,
      'userName': userName,
    };

    _isLoading = false;
    notifyListeners();
  }
}
