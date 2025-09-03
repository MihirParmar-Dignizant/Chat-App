import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage(
    String chatId,
    String senderId,
    String receiverId,
    String message,
  ) async {
    final messageRef =
        _firestore.collection('chats').doc(chatId).collection('messages').doc();

    await messageRef.set({
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'type': 'text',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update last message in chat
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message,
      'lastMessageSender': senderId,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
