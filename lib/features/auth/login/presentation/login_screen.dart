import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';
import 'package:smart_coach_new/core/utils/color_constants.dart';
import 'package:smart_coach_new/core/utils/image_utils.dart';
import 'package:smart_coach_new/core/utils/loader.dart';
import 'package:smart_coach_new/core/utils/toast_message_utils.dart';
import 'package:smart_coach_new/core/utils/utils.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_event.dart';
import 'package:smart_coach_new/features/auth/login/presentation/bloc/login_state.dart';
import 'package:smart_coach_new/routes/app_router.dart';
import 'dart:ui';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailOrNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  late LoginBloc _loginBloc;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _loginBloc = context.read<LoginBloc>();
    emailOrNumberController.text = "tester@example.com";
    passwordController.text = "123456";
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginLoading) {
          Loader.show();
        } else {
          Loader.dismiss();
        }
        if (state is LoginSuccess) {
          ToastMessageUtils.showMessage(context, state.message);
          context.go(AppRouter.dashboardRoute);
        }
        if (state is LoginFailure) {
          Utils.showApiErrorMessageOrList(context, message: state.message, errorList: state.errorList);
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F2027),
                Color(0xFF203A43),
                Color(0xFF2C5364),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Brand Logo Area
                    Container(
                      padding: EdgeInsets.all(2.h),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          )
                        ],
                      ),
                      child: SvgPicture.asset(
                        ImageUtils.icTrain,
                        height: 6.h,
                        width: 6.h,
                        colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Smart Coach",
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      "Next-gen railway management",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 5.h),

                    // Glassmorphism Login Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                        child: Container(
                          width: 85.w,
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 25,
                                spreadRadius: -5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 3.h),
                              
                              // Custom Email Field
                              _buildTextField(
                                controller: emailOrNumberController,
                                hint: "tester@example.com",
                                icon: Icons.email_outlined,
                              ),
                              SizedBox(height: 2.h),
                              
                              // Custom Password Field
                              _buildTextField(
                                controller: passwordController,
                                hint: "Password",
                                icon: Icons.lock_outline,
                                isPassword: true,
                              ),
                              SizedBox(height: 4.h),
                              
                              // Login Button
                              SizedBox(
                                width: double.infinity,
                                height: 6.5.h,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorConstants.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    elevation: 8,
                                    shadowColor: ColorConstants.primary.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () {
                                    String email = emailOrNumberController.text.trim();
                                    String password = passwordController.text.trim();
                                    if (_isValid(email, password)) {
                                      _loginBloc.add(LoginRequested(email, password));
                                    }
                                  },
                                  child: Text(
                                    "Continue to Dashboard",
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword && !_isPasswordVisible,
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white70,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  bool _isValid(String emailOrNumber, String password) {
    if (emailOrNumber.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter a valid email address');
      return false;
    } else if (password.isEmpty) {
      ToastMessageUtils.showMessage(context, 'Please enter a valid password');
      return false;
    } else {
      return true;
    }
  }
}