import 'package:chat_app/constant/app_color.dart';
import 'package:chat_app/router/routes.dart';
import 'package:chat_app/widget/build_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../widget/customText_field.dart';
import '../../../../widget/or_divider.dart';
import '../bloc/sign_up_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final formKey = GlobalKey<FormState>();

  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final fullNameFocusNode = FocusNode();
  final usernameFocusNode = FocusNode();
  final emailFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();
  final confirmPasswordFocusNode = FocusNode();

  @override
  void dispose() {
    fullNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    fullNameFocusNode.dispose();
    usernameFocusNode.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.white,
      body: SafeArea(
        child: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Sign up successful!")),
              );
              context.go(Routes.signIn);
            } else if (state is SignUpFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error)),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is SignUpLoading;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome",
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Signup into your account",
                    style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                  ),
                  SizedBox(height: 40.h),

                  Form(
                    key: formKey,
                    child: Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: AppColor.royalBlue,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(70.r),
                          bottomLeft: Radius.circular(10.r),
                          bottomRight: Radius.circular(70.r),
                          topRight: Radius.circular(70.r),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 16.h),

                          // Full Name
                          CustomTextField(
                            prefixIcon: const Icon(Icons.person_outline),
                            hint: "Full Name",
                            controller: fullNameController,
                            focusNode: fullNameFocusNode,
                            nextFocusNode: usernameFocusNode,
                          ),
                          SizedBox(height: 12.h),

                          // Username
                          CustomTextField(
                            prefixIcon: const Icon(Icons.account_circle_outlined),
                            hint: "Username",
                            controller: usernameController,
                            focusNode: usernameFocusNode,
                            nextFocusNode: emailFocusNode,
                          ),
                          SizedBox(height: 12.h),

                          // Email
                          CustomTextField(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hint: "Email",
                            controller: emailController,
                            focusNode: emailFocusNode,
                            nextFocusNode: passwordFocusNode,
                          ),
                          SizedBox(height: 12.h),

                          // Password
                          CustomTextField(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hint: "Password",
                            isPassword: true,
                            controller: passwordController,
                            focusNode: passwordFocusNode,
                            nextFocusNode: confirmPasswordFocusNode,
                          ),
                          SizedBox(height: 12.h),

                          // Confirm Password
                          CustomTextField(
                            prefixIcon: const Icon(Icons.lock_outline),
                            hint: "Confirm Password",
                            isPassword: true,
                            controller: confirmPasswordController,
                            focusNode: confirmPasswordFocusNode,
                          ),
                          SizedBox(height: 20.h),

                          buildButton(
                            text: isLoading ? "Signing Up..." : "Sign Up",
                            onPressed: isLoading
                                ? null
                                : () {
                              if (!formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please fill all required fields"),
                                    backgroundColor: Colors.red,
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                return;
                              }

                              context.read<SignUpBloc>().add(
                                SignUpSubmitted(
                                  fullName: fullNameController.text.trim(),
                                  userName: usernameController.text.trim(),
                                  email: emailController.text.trim(),
                                  password: passwordController.text.trim(),
                                  confirmPassword: confirmPasswordController.text.trim(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 16.h),

                          const OrDivider(text: "Or"),
                          SizedBox(height: 16.h),

                          buildButton(
                            text: "Continue with Google",
                            isGoogle: true,
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
