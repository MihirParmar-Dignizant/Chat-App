import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:chat_app/screen/chat/service/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatService chatService;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;

  ChatBloc({required this.chatService}) : super(ChatInitial()) {
    on<LoadChat>(_onLoadChat);
    on<SendMessageEvent>(_onSendMessage);
    on<MessagesUpdated>(_onMessagesUpdated);
  }

  void _onLoadChat(LoadChat event, Emitter<ChatState> emit) async {
    emit(ChatLoading());

    try {
      _messagesSubscription?.cancel();
      _messagesSubscription = chatService
          .getMessagesStream(event.chatId)
          .listen((snapshot) {
            final messages =
                snapshot.docs.map((doc) {
                  Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                  print("$data");
                  return {
                    'text': data['message'],
                    'senderId': data['senderId'],
                    'receiverId': data['receiverId'],
                    'isSent': data['senderId'] == event.currentUserId,
                  };
                }).toList();

            add(MessagesUpdated(messages));
          });

      emit(ChatLoaded(chatId: event.chatId, messages: []));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  void _onSendMessage(SendMessageEvent event, Emitter<ChatState> emit) async {
    await chatService.sendMessage(
      event.chatId,
      event.senderId,
      event.receiverId,
      event.message,
    );
  }

  void _onMessagesUpdated(MessagesUpdated event, Emitter<ChatState> emit) {
    if (state is ChatLoaded) {
      emit(
        ChatLoaded(
          chatId: (state as ChatLoaded).chatId,
          messages: event.messages,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
