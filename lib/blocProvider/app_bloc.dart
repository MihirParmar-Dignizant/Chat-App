import 'package:chat_app/screen/auth/signin/service/signin_service.dart';
import 'package:chat_app/screen/auth/signup/bloc/sign_up_bloc.dart';
import 'package:chat_app/screen/mianHome/bloc/home_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../screen/auth/signin/bloc/sign_in_bloc.dart';
import '../screen/auth/signup/service/signup_service.dart';
import '../screen/mianHome/bloc/home_event.dart';
import '../screen/mianHome/service/home_service.dart';

class AppBlocProviders {
  static List<BlocProvider> get providers => [
    BlocProvider<SignUpBloc>(create: (context) => SignUpBloc(SignUpService())),
    BlocProvider<SignInBloc>(create: (context) => SignInBloc(signInService: SignInService())),
    BlocProvider<HomeBloc>(create: (context) => HomeBloc(HomeService())..add(LoadUsersEvent())),

  ];
}
