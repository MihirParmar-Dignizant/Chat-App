import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser!.uid;

  Stream<List<Map<String, dynamic>>> getAllUsers() {
    return _firestore.collection('users').snapshots().asyncMap((
      snapshot,
    ) async {
      final users = snapshot.docs.where((doc) => doc.id != currentUserId);

      List<Map<String, dynamic>> userList = [];

      for (var doc in users) {
        final userId = doc.id;
        final chatId = generateChatId(currentUserId, userId);

        // Instead of one-time fetch, listen to chat doc
        final chatDoc = await _firestore.collection("chats").doc(chatId).get();
        final chatData = chatDoc.data();

        userList.add({
          "id": userId,
          "fullName": doc['fullName'] ?? "No Name",
          // "avatarUrl": doc['avatarUrl'] ?? "",
          "lastMessage": chatData?["lastMessage"] ?? "",
          "lastMessageSender": chatData?["lastMessageSender"] ?? "",
          "lastMessageTimestamp": chatData?["lastMessageTimestamp"],
        });
      }

      userList.sort((a, b) {
        final tsA = a["lastMessageTimestamp"] as Timestamp?;
        final tsB = b["lastMessageTimestamp"] as Timestamp?;
        return (tsB?.millisecondsSinceEpoch ?? 0).compareTo(
          tsA?.millisecondsSinceEpoch ?? 0,
        );
      });

      return userList;
    });
  }

  String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return ids.join("_");
  }

  Future<String> createOrGetChat(
    String otherUserId,
    String otherUserName,
  ) async {
    final chatId = generateChatId(currentUserId, otherUserId);
    final chatDoc = _firestore.collection("chats").doc(chatId);

    final docSnapshot = await chatDoc.get();

    if (!docSnapshot.exists) {
      final currentUserDoc =
          await _firestore.collection("users").doc(currentUserId).get();

      final currentUserData = currentUserDoc.data() ?? {};
      final currentUserName = currentUserData["fullName"] ?? "Unknown User";
      final currentUserAvatar = currentUserData["avatarUrl"] ?? "";

      await chatDoc.set({
        "participants": [currentUserId, otherUserId],
        "participantDetails": {
          currentUserId: {
            "fullName": currentUserName,
            "avatarUrl": currentUserAvatar,
          },
          otherUserId: {"fullName": otherUserName},
        },
        "lastMessage": "",
        "lastMessageSender": "",
        "lastMessageTimestamp": FieldValue.serverTimestamp(),
      });
    }

    return chatId;
  }

  Future<void> logout() async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
