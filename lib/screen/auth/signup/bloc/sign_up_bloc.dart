import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../service/signup_service.dart';

part 'sign_up_event.dart';
part 'sign_up_state.dart';

class SignUpBloc extends Bloc<SignUpEvent, SignUpState> {
  final SignUpService signUpService;

  SignUpBloc(this.signUpService) : super(SignUpInitial()) {
    on<SignUpSubmitted>(_onSignUpSubmitted);
  }

  Future<void> _onSignUpSubmitted(
    SignUpSubmitted event,
    Emitter<SignUpState> emit,
  ) async {
    if (event.password != event.confirmPassword) {
      emit(const SignUpFailure("Passwords do not match"));
      return;
    }

    emit(SignUpLoading());
    try {
      await signUpService.signUp(
        fullName: event.fullName,
        userName: event.userName,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      );
      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(e.toString()));
    }
  }
}
