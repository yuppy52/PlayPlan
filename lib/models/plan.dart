import 'package:cloud_firestore/cloud_firestore.dart';

enum PlanStatus {
  planning,
  confirmed,
  ongoing,
  completed,
  cancelled,
}

class Plan {
  final String id;
  final String groupId;
  final String title;
  final String? description;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? location;
  final String? imageUrl;
  final PlanStatus status;
  final List<String> participantIds;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  Plan({
    required this.id,
    required this.groupId,
    required this.title,
    this.description,
    this.startDate,
    this.endDate,
    this.location,
    this.imageUrl,
    this.status = PlanStatus.planning,
    required this.participantIds,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Plan(
      id: doc.id,
      groupId: data['groupId'] ?? '',
      title: data['title'] ?? '',
      description: data['description'],
      startDate: data['startDate'] != null
          ? (data['startDate'] as Timestamp).toDate()
          : null,
      endDate: data['endDate'] != null
          ? (data['endDate'] as Timestamp).toDate()
          : null,
      location: data['location'],
      imageUrl: data['imageUrl'],
      status: PlanStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => PlanStatus.planning,
      ),
      participantIds: List<String>.from(data['participantIds'] ?? []),
      createdBy: data['createdBy'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'title': title,
      'description': description,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'location': location,
      'imageUrl': imageUrl,
      'status': status.name,
      'participantIds': participantIds,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Plan copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    String? imageUrl,
    PlanStatus? status,
    List<String>? participantIds,
    DateTime? updatedAt,
  }) {
    return Plan(
      id: id,
      groupId: groupId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      status: status ?? this.status,
      participantIds: participantIds ?? this.participantIds,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
