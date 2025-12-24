import 'package:core_dashboard/pages/authentication/logic/cubit/auth_cubit.dart';
import 'package:core_dashboard/pages/authentication/logic/cubit/auth_state.dart';
import 'package:core_dashboard/shared/constants/config.dart';
import 'package:core_dashboard/shared/constants/defaults.dart';
import 'package:core_dashboard/shared/constants/ghaps.dart';
import 'package:core_dashboard/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false; // المتغير المسؤول عن حالة الرؤية

  @override
  Widget build(BuildContext context) {
    // نستخدم BlocConsumer للربط بين الواجهة والمنطق
    return BlocConsumer<AuthCubit, myAuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // 1. الانتقال للداشبورد عند نجاح الدخول
          context.go('/entry-point');
        } else if (state is AuthError) {
          // 2. إظهار رسالة خطأ في حال فشل الدخول
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  // إضافة Form للتحقق من البيانات
                  key: _formKey,
                  child: SizedBox(
                    width: 296,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ... (اللوجو والعناوين كما هي)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppDefaults.padding * 1.5),
                          child: SvgPicture.asset(AppConfig.logo),
                        ),
                        Text('Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(fontWeight: FontWeight.bold)),
                        gapH24,

                        // حقل الإيميل مع إضافة الـ Validator
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value!.isEmpty ? 'Email is required' : null,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(
                                'assets/icons/mail_light.svg',
                                height: 16,
                                width: 20,
                                fit: BoxFit.none),
                            hintText: 'Your email',
                          ),
                        ),
                        gapH16,

                        // حقل كلمة المرور مع إضافة الـ Validator
                        /// PASSWORD TEXT FIELD
                        TextFormField(
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          obscureText:
                              !_isPasswordVisible, // يعتمد على حالة المتغير
                          validator: (value) =>
                              value!.length < 6 ? 'Password too short' : null,
                          decoration: InputDecoration(
                            prefixIcon: SvgPicture.asset(
                              'assets/icons/lock_light.svg',
                              height: 16,
                              width: 20,
                              fit: BoxFit.none,
                            ),
                            hintText: 'Password',
                            // إضافة أيقونة العين هنا
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: AppColors
                                    .textGrey, // أو أي لون تفضله من ثيم تطبيقك
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // تغيير الحالة عند الضغط
                                });
                              },
                            ),
                          ),
                        ),
                        gapH16,

                        /// زر تسجيل الدخول (SIGN IN BUTTON)
                        SizedBox(
                          width: 296,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null // تعطيل الزر أثناء التحميل
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      // استدعاء دالة تسجيل الدخول من الـ Cubit
                                      context.read<AuthCubit>().login(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );
                                    }
                                  },
                            child: state is AuthLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : const Text('Sign in'),
                          ),
                        ),
                        gapH24,

                        /// FOOTER TEXT (reCAPTCHA note)
                        Text(
                          'This site is protected by reCAPTCHA and the Google Privacy Policy.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textGrey,
                                  ),
                        ),
                        gapH24,

                        /// SIGNUP TEXT
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Don’t have an account?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textGrey),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    AppColors.primary, // لون الثيم الخاص بك
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => context.go('/register'),
                              child: const Text('Sign up'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
