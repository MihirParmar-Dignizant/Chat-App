import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadUsersEvent extends HomeEvent {}

class SearchUserEvent extends HomeEvent {
  final String query;
  SearchUserEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LogoutEvent extends HomeEvent {}

class OpenChatEvent extends HomeEvent {
  final String otherUserId;
  final String otherUserName;
  final String otherUserAvatar;

  OpenChatEvent(this.otherUserId, this.otherUserName, this.otherUserAvatar);

  @override
  List<Object?> get props => [otherUserId, otherUserName, otherUserAvatar];
}

//  New event to reset after navigation
class ResetOpenedChatEvent extends HomeEvent {}
