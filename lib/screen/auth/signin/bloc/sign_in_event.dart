part of 'sign_in_bloc.dart';

abstract class SignInEvent extends Equatable {
  const SignInEvent();

  @override
  List<Object?> get props => [];
}

class EmailSignInRequested extends SignInEvent {
  final String email;
  final String password;

  const EmailSignInRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
