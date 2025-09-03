import 'package:chat_app/constant/app_image.dart';
import 'package:chat_app/constant/app_color.dart';
import 'package:chat_app/router/routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../auth/signin/service/signin_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));

    final isLoggedIn = await SignInService().isLoggedIn();
    if (isLoggedIn) {
      context.go(Routes.mainHome);
    } else {
      context.go(Routes.signIn);
    }

  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.royalBlue,
      body: Center(
        child: Image.asset(AppImage.splashLogo, height: height * 0.25),
      ),
    );
  }
}
