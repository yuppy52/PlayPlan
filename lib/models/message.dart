import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  system,
}

class Message {
  final String id;
  final String planId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final MessageType type;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.planId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    this.type = MessageType.text,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      planId: data['planId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      content: data['content'] ?? '',
      imageUrl: data['imageUrl'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'planId': planId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'type': type.name,
      'content': content,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
