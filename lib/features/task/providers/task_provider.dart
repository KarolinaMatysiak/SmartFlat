import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_flat/features/task/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  QuerySnapshot<Map<String, dynamic>>? _tasksSnapshot;
  StreamSubscription? _tasksSubscription;
  bool _isLoading = false;
  String? _currentSpaceId;

  QuerySnapshot<Map<String, dynamic>>? get tasksSnapshot => _tasksSnapshot;
  bool get isLoading => _isLoading;
  bool get hasTasks => _tasksSnapshot != null && _tasksSnapshot!.docs.isNotEmpty;

  void update(String? spaceId) {
    if (spaceId == null) {
      clear();
    } else if (_currentSpaceId != spaceId) {
      init(spaceId);
    }
  }

  void clear() {
    if (_currentSpaceId == null && _tasksSnapshot == null) return;
    _currentSpaceId = null;
    _tasksSubscription?.cancel();
    _tasksSnapshot = null;
    _isLoading = false;
    notifyListeners();
  }

  void init(String livingSpaceId) {
    _currentSpaceId = livingSpaceId;
    _tasksSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _taskService.watchTasks(livingSpaceId).listen(
      (snapshot) {
        _tasksSnapshot = snapshot;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addTask(String title, String description, {String? assignedTo}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _currentSpaceId == null) return;

    await _taskService.createTask(
      createdBy: uid,
      livingSpaceId: _currentSpaceId!,
      title: title,
      description: description,
      assignedTo: assignedTo,
    );
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
