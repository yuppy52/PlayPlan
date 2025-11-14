import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import '../models/plan.dart';
import '../models/message.dart';
import '../models/task.dart';
import '../models/expense.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== Groups ==========

  Stream<List<Group>> getUserGroups(String userId) {
    return _firestore
        .collection('groups')
        .where('memberIds', arrayContains: userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Group.fromFirestore(doc)).toList());
  }

  Future<void> createGroup(Group group) async {
    await _firestore.collection('groups').doc(group.id).set(group.toFirestore());
  }

  Future<void> updateGroup(Group group) async {
    await _firestore
        .collection('groups')
        .doc(group.id)
        .update(group.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
  }

  Future<void> addGroupMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeGroupMember(String groupId, String userId) async {
    await _firestore.collection('groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([userId]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ========== Plans ==========

  Stream<List<Plan>> getGroupPlans(String groupId) {
    return _firestore
        .collection('plans')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Plan.fromFirestore(doc)).toList());
  }

  Stream<Plan> getPlan(String planId) {
    return _firestore
        .collection('plans')
        .doc(planId)
        .snapshots()
        .map((doc) => Plan.fromFirestore(doc));
  }

  Future<void> createPlan(Plan plan) async {
    await _firestore.collection('plans').doc(plan.id).set(plan.toFirestore());
  }

  Future<void> updatePlan(Plan plan) async {
    await _firestore
        .collection('plans')
        .doc(plan.id)
        .update(plan.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  Future<void> deletePlan(String planId) async {
    await _firestore.collection('plans').doc(planId).delete();
  }

  // ========== Messages ==========

  Stream<List<Message>> getPlanMessages(String planId) {
    return _firestore
        .collection('messages')
        .where('planId', isEqualTo: planId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(Message message) async {
    await _firestore
        .collection('messages')
        .doc(message.id)
        .set(message.toFirestore());
  }

  // ========== Tasks ==========

  Stream<List<PlanTask>> getPlanTasks(String planId) {
    return _firestore
        .collection('tasks')
        .where('planId', isEqualTo: planId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => PlanTask.fromFirestore(doc)).toList());
  }

  Future<void> createTask(PlanTask task) async {
    await _firestore.collection('tasks').doc(task.id).set(task.toFirestore());
  }

  Future<void> updateTask(PlanTask task) async {
    await _firestore
        .collection('tasks')
        .doc(task.id)
        .update(task.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  // ========== Expenses ==========

  Stream<List<Expense>> getPlanExpenses(String planId) {
    return _firestore
        .collection('expenses')
        .where('planId', isEqualTo: planId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  Future<void> createExpense(Expense expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .set(expense.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    await _firestore
        .collection('expenses')
        .doc(expense.id)
        .update(expense.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _firestore.collection('expenses').doc(expenseId).delete();
  }
}
