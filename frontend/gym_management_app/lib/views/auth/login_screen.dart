import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final result = await _authController.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      if (result['success'] != true && mounted) {
        Get.snackbar(
          'Login Failed',
          result['message'] ?? 'Invalid credentials',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.secondary],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.large),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fitness_center,
                            size: 80,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Gym Management System',
                            style: AppTextStyles.heading2,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Sign in to continue',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Username',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            prefixIcon: Icons.lock,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Obx(() {
                            if (_authController.isLoading.value) {
                              return const LoadingWidget();
                            }
                            return CustomButton(
                              text: 'Login',
                              onPressed: _handleLogin,
                              isFullWidth: true,
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
