import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:smart_flat/features/auth/common/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  StreamSubscription<User?>? _authSubscription;

  User? _currentUser;
  bool _isLoading = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider({AuthService? authService}) : _authService = authService ?? AuthService() {
    _authSubscription = _authService.authStateChanges.listen((User? user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> signIn({required String email, required String password}) async {
    await _authService.signIn(email: email, password: password);
  }

  Future<void> signUp({required String email, required String password}) async {
    await _authService.signUp(email: email, password: password);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}