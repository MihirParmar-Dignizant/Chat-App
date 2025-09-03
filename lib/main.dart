import 'package:chat_app/blocProvider/app_bloc.dart';
import 'package:chat_app/constant/app_color.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'router/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return MultiBlocProvider(
          providers: AppBlocProviders.providers,
          child: SafeArea(
            top: true,
            bottom: false,
            child: MaterialApp.router(
              title: 'Chat App',
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppColor.royalBlue,
                ),
              ),
              debugShowCheckedModeBanner: false,
              routerConfig: AppRouter.router,
            ),
          ),
        );
      },
    );
  }
}
