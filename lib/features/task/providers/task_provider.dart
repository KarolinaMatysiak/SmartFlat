import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smart_flat/features/task/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();

  QuerySnapshot<Map<String, dynamic>>? _tasksSnapshot;
  StreamSubscription? _tasksSubscription;
  bool _isLoading = true;

  QuerySnapshot<Map<String, dynamic>>? get tasksSnapshot => _tasksSnapshot;

  bool get isLoading => _isLoading;

  bool get hasTasks =>
      _tasksSnapshot != null && _tasksSnapshot!.docs.isNotEmpty;

  void init(String livingSpaceId) {
    _tasksSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSubscription = _taskService
        .watchTasks(livingSpaceId)
        .listen(
          (snapshot) {
            _tasksSnapshot = snapshot;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            print("Subscription error tasks: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> createTask({
    required String identityId,
    required String livingSpaceId,
    required String title,
    required String description,
  }) async {
    await _taskService.createTask(
      identityId: identityId,
      livingSpaceId: livingSpaceId,
      title: title,
      description: description,
    );
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
