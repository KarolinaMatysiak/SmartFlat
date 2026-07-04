import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_flat/features/budget/services/budget_service.dart';
import 'package:smart_flat/features/task/services/task_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();

  QuerySnapshot<Map<String, dynamic>>? _budgetSnapshot;
  QuerySnapshot<Map<String, dynamic>>? _budgetHistorySnapshot;
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _budgetHistorySubscription;
  bool _isLoadingBudget = false;
  bool _isLoadingBudgetHistory = false;
  String? _currentSpaceId;

  QuerySnapshot<Map<String, dynamic>>? get budgetSnapshot => _budgetSnapshot;
  QuerySnapshot<Map<String, dynamic>>? get budgetHistorySnapshot => _budgetHistorySnapshot;

  bool get isLoadingBudget => _isLoadingBudget;
  bool get isLoadingBudgetHistory => _isLoadingBudgetHistory;

  bool get hasBudget =>
      _budgetSnapshot != null && _budgetSnapshot!.docs.isNotEmpty;

  bool get hasBudgetHistory =>
      _budgetHistorySnapshot != null && _budgetHistorySnapshot!.docs.isNotEmpty;

  void setCurrentSpaceId(String? spaceId) {
    if (spaceId == null) {
      clear();
    } else if (_currentSpaceId != spaceId) {
      init(spaceId);
    }
  }

  void clear() {
    if (_currentSpaceId == null && _budgetSnapshot == null) return;
    _currentSpaceId = null;
    _budgetSubscription?.cancel();
    _budgetHistorySubscription?.cancel();
    _budgetSnapshot = null;
    _budgetHistorySnapshot = null;
    _isLoadingBudget = false;
    _isLoadingBudgetHistory = false;
    notifyListeners();
  }

  void init(String livingSpaceId) {
    if (_currentSpaceId == livingSpaceId && _budgetSubscription != null) return;
    
    _currentSpaceId = livingSpaceId;
    _budgetSubscription?.cancel();
    _budgetHistorySubscription?.cancel();
    
    // Ustawiamy ładowanie tylko jeśli nie mamy jeszcze żadnych danych
    if (_budgetSnapshot == null) _isLoadingBudget = true;
    if (_budgetHistorySnapshot == null) _isLoadingBudgetHistory = true;
    notifyListeners();

    _budgetSubscription = _budgetService.watchBudget(livingSpaceId).listen(
      (snapshot) {
        _budgetSnapshot = snapshot;
        _isLoadingBudget = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingBudget = false;
        notifyListeners();
      },
    );

    _budgetHistorySubscription =
        _budgetService.watchBudgetHistory(livingSpaceId).listen(
      (snapshot) {
        _budgetHistorySnapshot = snapshot;
        _isLoadingBudgetHistory = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoadingBudgetHistory = false;
        notifyListeners();
      },
    );
  }

  Future<void> addOperation({
    required String createdBy,
    required String title,
    required double amount,
    required String type,
  }) async {
    if (_currentSpaceId == null) return;
    await _budgetService.addBudgetOperation(
      createdBy: createdBy,
      livingSpaceId: _currentSpaceId!,
      title: title,
      amount: amount,
      type: type,
    );
    // Po dodaniu operacji nie musimy robić nic więcej, 
    // bo stream powinien sam dostarczyć dane, ale upewnijmy się, 
    // że notifyListeners zostanie wywołane jeśli snapshoty się zmienią.
  }

  @override
  void dispose() {
    _budgetSubscription?.cancel();
    _budgetHistorySubscription?.cancel();
    super.dispose();
  }
}
