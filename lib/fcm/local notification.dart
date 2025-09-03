import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LocalNotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Keep track of message IDs we've already notified
  final Set<String> _notifiedMessageIds = {};

  // Initialize the local notification plugin
  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Show a notification
  Future<void> showNotification(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Messages',
      channelDescription: 'Notification channel for chat messages',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(0, title, body, platformDetails);
  }

  // Listen to new messages for this chat and notify only the receiver
  void listenToMessages(String chatId, String currentUserId) {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        final data = docChange.doc.data();
        final messageId = docChange.doc.id;

        // Only notify for receiver and messages not already notified
        if (docChange.type == DocumentChangeType.added &&
            data!['receiverId'] == currentUserId &&
            !_notifiedMessageIds.contains(messageId)) {

          _notifiedMessageIds.add(messageId); // mark as notified

          // Get sender name
          String senderName = '';
          if (data.containsKey('senderName') && data['senderName'] != null) {
            senderName = data['senderName'];
          } else {
            final senderDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(data['senderId'])
                .get();
            senderName = senderDoc.data()?['fullName'] ?? 'New message';
          }

          // Format timestamp
          Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
          String timeString = DateFormat('hh:mm a').format(timestamp.toDate());

          final messageText = data['message'] ?? '';
          final body = "$messageText\n$timeString"; // append time to message

          showNotification(senderName, body); // Notify receiver only
        }
      }
    });
  }
}
