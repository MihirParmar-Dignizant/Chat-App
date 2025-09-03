part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatLoaded extends ChatState {
  final String chatId;
  final List<Map<String, dynamic>> messages;

  ChatLoaded({required this.chatId, required this.messages});

  @override
  List<Object> get props => [chatId, messages];
}

class ChatError extends ChatState {
  final String error;

  ChatError(this.error);

  @override
  List<Object> get props => [error];
}
