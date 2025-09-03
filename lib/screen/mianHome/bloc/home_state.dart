import 'package:equatable/equatable.dart';

class HomeState extends Equatable {
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> filteredUsers;
  final bool isLoading;
  final String error;

  final String openedChatId;
  final String openedUserName;
  final String openedUserId;
  final String openedUserAvatar;

  const HomeState({
    this.users = const [],
    this.filteredUsers = const [],
    this.isLoading = false,
    this.error = '',
    this.openedChatId = '',
    this.openedUserName = '',
    this.openedUserId = '',
    this.openedUserAvatar = '',
  });

  HomeState copyWith({
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? filteredUsers,
    bool? isLoading,
    String? error,
    String? openedChatId,
    String? openedUserName,
    String? openedUserId,
    String? openedUserAvatar,
  }) {
    return HomeState(
      users: users ?? this.users,
      filteredUsers: filteredUsers ?? this.filteredUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      openedChatId: openedChatId ?? this.openedChatId,
      openedUserName: openedUserName ?? this.openedUserName,
      openedUserId: openedUserId ?? this.openedUserId,
      openedUserAvatar: openedUserAvatar ?? this.openedUserAvatar,
    );
  }

  @override
  List<Object?> get props => [
    users,
    filteredUsers,
    isLoading,
    error,
    openedChatId,
    openedUserName,
    openedUserId,
    openedUserAvatar,
  ];
}
