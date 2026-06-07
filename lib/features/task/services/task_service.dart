import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();

  factory TaskService() {
    return _instance;
  }

  TaskService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTasks(String livingSpaceId) {
    return _firestore
        .collection('tasks')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .snapshots();
  }

  Future<void> createTask({
    required String createdBy,
    required String livingSpaceId,
    required String title,
    required String description,
  }) async {
    await _firestore.collection('tasks').add({
      'createdBy': createdBy,
      'livingSpaceId': livingSpaceId,
      'title': title,
      'description': description,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
