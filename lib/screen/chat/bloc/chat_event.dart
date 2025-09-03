part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadChat extends ChatEvent {
  final String chatId;
  final String currentUserId;

  LoadChat(this.chatId, this.currentUserId);

  @override
  List<Object?> get props => [chatId, currentUserId];
}

class SendMessageEvent extends ChatEvent {
  final String chatId;
  final String senderId;
  final String receiverId;
  final String message;

  SendMessageEvent(this.chatId, this.senderId, this.receiverId, this.message);

  @override
  List<Object?> get props => [chatId, senderId, receiverId, message];
}

class MessagesUpdated extends ChatEvent {
  final List<Map<String, dynamic>> messages;

  MessagesUpdated(this.messages);

  @override
  List<Object?> get props => [messages];
}
