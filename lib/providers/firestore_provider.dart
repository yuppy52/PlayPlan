import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../models/group.dart';
import '../models/plan.dart';
import '../models/message.dart';
import '../models/task.dart';
import '../models/expense.dart';

final firestoreServiceProvider = Provider((ref) => FirestoreService());

// Groups
final userGroupsProvider = StreamProvider.family<List<Group>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserGroups(userId);
});

// Plans
final groupPlansProvider = StreamProvider.family<List<Plan>, String>((ref, groupId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getGroupPlans(groupId);
});

final planProvider = StreamProvider.family<Plan, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlan(planId);
});

// Messages
final planMessagesProvider = StreamProvider.family<List<Message>, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlanMessages(planId);
});

// Tasks
final planTasksProvider = StreamProvider.family<List<PlanTask>, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlanTasks(planId);
});

// Expenses
final planExpensesProvider = StreamProvider.family<List<Expense>, String>((ref, planId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getPlanExpenses(planId);
});
