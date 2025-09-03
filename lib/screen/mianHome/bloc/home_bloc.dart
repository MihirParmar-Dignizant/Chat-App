import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../service/home_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeService homeService;
  StreamSubscription? _usersSubscription;

  HomeBloc(this.homeService) : super(const HomeState()) {
    on<LoadUsersEvent>(_onLoadUsers);
    on<SearchUserEvent>(_onSearchUser);
    on<LogoutEvent>(_onLogout);
    on<OpenChatEvent>(_onOpenChat);
    on<ResetOpenedChatEvent>(_onResetOpenedChat);
  }

  Future<void> _onLoadUsers(
    LoadUsersEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: ''));

    await emit.forEach<List<Map<String, dynamic>>>(
      homeService.getAllUsers(),
      onData:
          (users) => state.copyWith(
            users: users,
            filteredUsers: users,
            isLoading: false,
          ),
      onError:
          (error, stackTrace) =>
              state.copyWith(isLoading: false, error: error.toString()),
    );
  }

  void _onSearchUser(SearchUserEvent event, Emitter<HomeState> emit) {
    final query = event.query.toLowerCase().trim();
    final filtered =
        state.users
            .where(
              (user) =>
                  user["fullName"].toString().toLowerCase().contains(query),
            )
            .toList();
    emit(state.copyWith(filteredUsers: filtered));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      await homeService.logout();
      emit(const HomeState()); // reset to initial state
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> _onOpenChat(OpenChatEvent event, Emitter<HomeState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final chatId = await homeService.createOrGetChat(
        event.otherUserId,
        event.otherUserName,
      );

      emit(
        state.copyWith(
          openedChatId: chatId,
          openedUserName: event.otherUserName,
          openedUserId: event.otherUserId,
          openedUserAvatar: event.otherUserAvatar,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void _onResetOpenedChat(ResetOpenedChatEvent event, Emitter<HomeState> emit) {
    emit(
      state.copyWith(
        openedChatId: '',
        openedUserName: '',
        openedUserId: '',
        openedUserAvatar: '',
      ),
    );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}
