import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetService {
  static final BudgetService _instance = BudgetService._internal();

  factory BudgetService() {
    return _instance;
  }

  BudgetService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBudget(
    String livingSpaceId,
  ) {
    return _firestore
        .collection('budgets')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .snapshots(includeMetadataChanges: true);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchBudgetHistory(
    String livingSpaceId,
  ) {
    return _firestore
        .collection('budgetsHistory')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .orderBy('createdAt', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // FIXME: In regular workflow it should be handled by backend
  Future<void> createBudget({required String livingSpaceId}) async {
    final existing = await _firestore
        .collection('budgets')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .get();

    if (existing.docs.isEmpty) {
      await _firestore.collection('budgets').add({
        'livingSpaceId': livingSpaceId,
        'createdAt': FieldValue.serverTimestamp(),
        'amount': 0.0,
      });
    }
  }

  Future<void> addBudgetOperation({
    required String createdBy,
    required String livingSpaceId,
    required String title,
    required double amount,
    required String type, // 'top-up' or 'withdrawal'
  }) async {
    final budgetQuery = await _firestore
        .collection('budgets')
        .where('livingSpaceId', isEqualTo: livingSpaceId)
        .limit(1)
        .get();

    if (budgetQuery.docs.isEmpty) {
      throw Exception('Budget not found for this space');
    }

    final budgetDoc = budgetQuery.docs.first;
    final currentAmount = (budgetDoc.data()['amount'] ?? 0.0).toDouble();
    double newAmount;

    if (type == 'top-up') {
      newAmount = currentAmount + amount;
    } else if (type == 'withdrawal') {
      newAmount = currentAmount - amount;
      if (newAmount < 0) throw Exception('Insufficient funds');
    } else {
      throw Exception('Invalid operation type');
    }

    final batch = _firestore.batch();

    // Update main budget
    batch.update(budgetDoc.reference, {'amount': newAmount});

    // Add to history
    final historyRef = _firestore.collection('budgetsHistory').doc();
    batch.set(historyRef, {
      'livingSpaceId': livingSpaceId,
      'createdBy': createdBy,
      'createdAt': Timestamp.now(), // We use Timestamp.now() instead of serverTimestamp()
      'title': title,
      'amount': amount,
      'type': type,
    });

    await batch.commit();
  }
}
