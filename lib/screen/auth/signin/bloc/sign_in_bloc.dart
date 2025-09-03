import 'package:bloc/bloc.dart';
import 'package:chat_app/screen/auth/signin/service/signin_service.dart';
import 'package:equatable/equatable.dart';

part 'sign_in_event.dart';
part 'sign_in_state.dart';

class SignInBloc extends Bloc<SignInEvent, SignInState> {
  final SignInService signInService;

  SignInBloc({required this.signInService}) : super(SignInInitial()) {
    on<EmailSignInRequested>(_onEmailSignInRequested);
  }

  Future<void> _onEmailSignInRequested(
      EmailSignInRequested event, Emitter<SignInState> emit) async {
    emit(SignInLoading());
    try {
      await signInService.signInWithEmail(event.email, event.password);
      emit(SignInSuccess());
    } catch (e) {
      emit(SignInFailure(e.toString()));
    }
  }
}
