import 'package:chat_app/screen/auth/signup/ui/signUp_screen.dart';
import 'package:go_router/go_router.dart';
import '../screen/auth/signin/ui/signIn_screen.dart';
import '../screen/chat/ui/chat_screen.dart';
import '../screen/mianHome/ui/mainHome_screen.dart';
import '../screen/spash/splash_screen.dart';
import 'routes.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: Routes.initial,
    routes: [
      GoRoute(
        path: Routes.splash,
        name: Routes.splashName,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        name: Routes.signInName,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.signUp,
        name: Routes.signUpName,
        builder: (context, state) => SignupScreen(),
      ),
      GoRoute(
        path: Routes.mainHome,
        name: Routes.mainHomeName,
        builder: (context, state) => const MainHomeScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ChatScreen(
            userId: extra['id'],
            userName: extra['name'],
            userAvatarUrl: '', chatId: '',
          );
        },
      ),
    ],
  );
}