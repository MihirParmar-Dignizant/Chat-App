import 'package:chat_app/screen/chat/service/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../../../constant/app_color.dart';
import '../../../constant/app_image.dart';
import '../../../fcm/local notification.dart';
import '../../../widget/chat_bubble.dart';
import '../bloc/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String userId; // other user
  final String userName;
  final String userAvatarUrl;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late ChatBloc _chatBloc;
  late String currentUserId;

  late final LocalNotificationService _localNotification;
  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    _chatBloc = ChatBloc(chatService: ChatService());
    _chatBloc.add(LoadChat(widget.chatId, currentUserId));

    // Initialize local notifications
    _localNotification = LocalNotificationService();
    _localNotification.init(); // no await needed in initState
    _localNotification.listenToMessages(widget.chatId, currentUserId);
  }

  // @override
  // void initState() {
  //   super.initState();
  //   currentUserId = FirebaseAuth.instance.currentUser!.uid;
  //   _chatBloc = ChatBloc(chatService: ChatService());
  //
  //   _chatBloc.add(LoadChat(widget.chatId, currentUserId));
  // }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isEmpty) return;

    _chatBloc.add(
      SendMessageEvent(
        widget.chatId,
        currentUserId,
        widget.userId,
        messageText,
      ),
    );

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatBloc, ChatState>(
      bloc: _chatBloc,
      builder: (context, state) {
        String chatId = widget.chatId;
        List messages = [];

        if (state is ChatLoaded) {
          chatId = state.chatId;
          messages = state.messages;
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.royalBlue,
            title: Text(
              widget.userName,
              style: TextStyle(fontSize: 20.sp, color: AppColor.white),
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  reverse: true,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    return ChatBubble(
                      message: message['text'],
                      avatarUrl:
                          message['isSent']
                              ? ''
                              : (widget.userAvatarUrl.isNotEmpty
                                  ? widget.userAvatarUrl
                                  : "https://ui-avatars.com/api/?name=${widget.userName}&background=0D8ABC&color=fff"),
                      isSent: message['isSent'],
                    );
                  },
                ),
              ),
              Container(
                height: 80.h,
                width: double.infinity,
                color: AppColor.royalBlue,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColor.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.emoji_emotions,
                                    color: AppColor.royalBlue,
                                    size: 35,
                                  ),
                                  hintText: 'Message...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 10.0,
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColor.royalBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  onPressed: _sendMessage,
                                  icon: SvgPicture.asset(
                                    AppImage.send,
                                    height: 20.h,
                                    width: 20.h,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
