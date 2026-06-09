import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../widgets/auth/auth_toggle_buttons.dart';
import '../widgets/auth/password_text_field.dart';
import '../widgets/auth/social_login_buttons.dart';
import '../widgets/auth/auth_error_widget.dart';
import '../widgets/common/gradient_button.dart';
import '../../core/constants/app_strings.dart';
import '../../core/themes/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoginMode = true;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Welcome, ${state.user.firstName}!')));
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final errorMessage = state is AuthError ? state.message : null;

              return Column(
                children: [
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.sage.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: AppTheme.sage,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.eco, color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.appName,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF3C4F34),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.tagline,
                        style: TextStyle(color: AppTheme.earthBrown, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.softCream,
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          AuthToggleButtons(
                            isLoginMode: _isLoginMode,
                            onToggle: (isLogin) => setState(() => _isLoginMode = isLogin),
                          ),
                          const SizedBox(height: 24),

                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: AuthErrorWidget(
                                message: errorMessage,
                                onDismiss: () => context.read<AuthBloc>().add(ClearAuthError()),
                              ),
                            ),

                          if (_isLoginMode) ...[
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: AppStrings.email,
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            PasswordTextField(
                              controller: _passwordController,
                              hint: AppStrings.password,
                              prefixIcon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset link would be sent (demo)'))),
                              child: Text(AppStrings.forgotPassword, style: TextStyle(color: AppTheme.earthBrown)),
                            ),
                            const SizedBox(height: 8),
                            GradientButton(
                              onPressed: isLoading ? null : () {
                                context.read<AuthBloc>().add(
                                  LoginRequested(
                                    _emailController.text.trim(),
                                    _passwordController.text,
                                  ),
                                );
                              },
                              text: AppStrings.login,
                              icon: Icons.arrow_forward,
                              isLoading: isLoading,
                            ),
                          ] else ...[
                            TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                hintText: AppStrings.firstName,
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                hintText: AppStrings.lastName,
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _emailController,
                              decoration: const InputDecoration(
                                hintText: AppStrings.email,
                                prefixIcon: Icon(Icons.email_outlined),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            PasswordTextField(
                              controller: _passwordController,
                              hint: AppStrings.password,
                              prefixIcon: Icons.lock_outline,
                            ),
                            const SizedBox(height: 16),
                            PasswordTextField(
                              controller: _confirmPasswordController,
                              hint: AppStrings.confirmPassword,
                              prefixIcon: Icons.check_circle_outline,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Checkbox(
                                  value: _termsAccepted,
                                  onChanged: (val) => setState(() => _termsAccepted = val ?? false),
                                  activeColor: AppTheme.sage,
                                ),
                                Expanded(
                                  child: Text(
                                    AppStrings.termsAgree,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            GradientButton(
                              onPressed: isLoading ? null : () {
                                if (_termsAccepted) {
                                  context.read<AuthBloc>().add(
                                    SignupRequested(
                                      _firstNameController.text.trim(),
                                      _lastNameController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text,
                                    ),
                                  );
                                }
                              },
                              text: AppStrings.signup,
                              icon: Icons.person_add,
                              isLoading: isLoading,
                            ),
                          ],

                          const SizedBox(height: 24),
                          const Divider(),
                          const SizedBox(height: 16),
                          Text(AppStrings.orContinueWith, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 12),
                          SocialLoginButtons(
                            onGoogleTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google login demo'))),
                            onAppleTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple login demo'))),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F3ED),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.science, size: 14, color: AppTheme.earthBrown),
                                const SizedBox(width: 6),
                                Text(AppStrings.demoNote, style: const TextStyle(fontSize: 11, color: Color(0xFFA69681))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
