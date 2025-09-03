part of 'sign_up_bloc.dart';

abstract class SignUpEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignUpSubmitted extends SignUpEvent {
  final String fullName;
  final String userName;
  final String email;
  final String password;
  final String confirmPassword;

  SignUpSubmitted({
    required this.fullName,
    required this.userName,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [
    fullName,
    userName,
    email,
    password,
    confirmPassword,
  ];
}
