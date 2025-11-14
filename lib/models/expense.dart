import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String planId;
  final String title;
  final double amount;
  final String paidBy;
  final List<String> splitBetween;
  final String? description;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expense({
    required this.id,
    required this.planId,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.splitBetween,
    this.description,
    required this.date,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      planId: data['planId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      paidBy: data['paidBy'] ?? '',
      splitBetween: List<String>.from(data['splitBetween'] ?? []),
      description: data['description'],
      date: (data['date'] as Timestamp).toDate(),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'title': title,
      'amount': amount,
      'paidBy': paidBy,
      'splitBetween': splitBetween,
      'description': description,
      'date': Timestamp.fromDate(date),
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  double get amountPerPerson => amount / splitBetween.length;

  Expense copyWith({
    String? title,
    double? amount,
    String? paidBy,
    List<String>? splitBetween,
    String? description,
    DateTime? date,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id,
      planId: planId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      paidBy: paidBy ?? this.paidBy,
      splitBetween: splitBetween ?? this.splitBetween,
      description: description ?? this.description,
      date: date ?? this.date,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
