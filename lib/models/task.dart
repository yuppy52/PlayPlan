import 'package:cloud_firestore/cloud_firestore.dart';

class PlanTask {
  final String id;
  final String planId;
  final String title;
  final String? description;
  final String? assignedTo;
  final bool isCompleted;
  final DateTime? dueDate;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  PlanTask({
    required this.id,
    required this.planId,
    required this.title,
    this.description,
    this.assignedTo,
    this.isCompleted = false,
    this.dueDate,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlanTask.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanTask(
      id: doc.id,
      planId: data['planId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      assignedTo: data['assignedTo'],
      isCompleted: data['isCompleted'] ?? false,
      dueDate: data['dueDate'] != null
          ? (data['dueDate'] as Timestamp).toDate()
          : null,
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'title': title,
      'description': description,
      'assignedTo': assignedTo,
      'isCompleted': isCompleted,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  PlanTask copyWith({
    String? title,
    String? description,
    String? assignedTo,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? updatedAt,
  }) {
    return PlanTask(
      id: id,
      planId: planId,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
