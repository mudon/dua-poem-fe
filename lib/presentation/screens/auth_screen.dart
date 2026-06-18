import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:google_sign_in/google_sign_in.dart';
import '../blocs/auth_bloc/auth_bloc.dart';
import '../blocs/auth_bloc/auth_state.dart';
import '../blocs/auth_bloc/auth_event.dart';
import '../widgets/auth/auth_toggle_buttons.dart';
import '../widgets/auth/password_text_field.dart';
import '../widgets/auth/auth_error_widget.dart';
import '../widgets/auth/social_login_buttons.dart';
import '../widgets/common/gradient_button.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/auth_error_codes.dart';
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
  final _otpCodeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _isLoginMode = true;
  bool _termsAccepted = false;
  int _resendCooldown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _confirmPasswordController.addListener(() => setState(() {}));
    _otpCodeController.addListener(() => setState(() {}));
    _newPasswordController.addListener(() => setState(() {}));
    _confirmNewPasswordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _confirmPasswordController.dispose();
    _otpCodeController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  Widget _buildAppHeader() {
    return Column(
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
    );
  }

  Widget _buildOtpView(String email, bool isLoading, String? errorMessage) {
    return Column(
      children: [
        _buildAppHeader(),
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
                const Icon(Icons.mark_email_unread, size: 48, color: AppTheme.sage),
                const SizedBox(height: 16),
                const Text(
                  'Verify your email',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C4F34)),
                ),
                const SizedBox(height: 8),
                Text(
                  'We sent a code to',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                Text(
                  email,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF3C4F34)),
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

                TextField(
                  controller: _otpCodeController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    hintStyle: TextStyle(letterSpacing: 12, color: Colors.grey.shade300, fontSize: 28),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.sage, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GradientButton(
                  onPressed: isLoading || _otpCodeController.text.length != 6
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            VerifyEmailRequested(email, _otpCodeController.text.trim()),
                          );
                        },
                  text: 'Verify',
                  icon: Icons.check_circle_outline,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 16),
                _resendCooldown > 0
                    ? Text(
                        'Resend code in $_resendCooldown s',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      )
                    : TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                _startResendCooldown();
                                context.read<AuthBloc>().add(ResendOtpRequested(email));
                              },
                        child: const Text('Resend code', style: TextStyle(color: AppTheme.sage)),
                      ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(ReturnToAuth()),
                  child: const Text('Back to login', style: TextStyle(color: AppTheme.earthBrown)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordView(ForgotPasswordMode state) {
    if (state.step == ForgotPasswordStep.reset) {
      return _buildForgotPasswordReset(state);
    }
    return _buildForgotPasswordEmail(state);
  }

  Widget _buildForgotPasswordEmail(ForgotPasswordMode state) {
    return Column(
      children: [
        _buildAppHeader(),
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
                const Icon(Icons.lock_reset, size: 48, color: AppTheme.sage),
                const SizedBox(height: 16),
                const Text(
                  'Reset your password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C4F34)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your email to receive a verification code',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AuthErrorWidget(
                      message: state.error!,
                      onDismiss: () => context.read<AuthBloc>().add(ClearAuthError()),
                    ),
                  ),

                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: AppStrings.email,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  onPressed: state.isLoading || _emailController.text.trim().isEmpty
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            ForgotPasswordRequested(_emailController.text.trim()),
                          );
                        },
                  text: 'Send code',
                  icon: Icons.send,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(CancelForgotPassword()),
                  child: const Text('Back to login', style: TextStyle(color: AppTheme.earthBrown)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordReset(ForgotPasswordMode state) {
    final canSubmit = _otpCodeController.text.length == 6 &&
        _newPasswordController.text.length >= 8 &&
        _confirmNewPasswordController.text == _newPasswordController.text;

    return Column(
      children: [
        _buildAppHeader(),
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
                const Icon(Icons.lock_reset, size: 48, color: AppTheme.sage),
                const SizedBox(height: 16),
                const Text(
                  'Reset your password',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C4F34)),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the code sent to',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                Text(
                  state.email,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF3C4F34)),
                ),
                const SizedBox(height: 24),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AuthErrorWidget(
                      message: state.error!,
                      onDismiss: () => context.read<AuthBloc>().add(ClearAuthError()),
                    ),
                  ),

                TextField(
                  controller: _otpCodeController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    hintStyle: TextStyle(letterSpacing: 12, color: Colors.grey.shade300, fontSize: 28),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppTheme.sage, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  controller: _newPasswordController,
                  hint: 'New password',
                  prefixIcon: Icons.lock_outline,
                ),
                const SizedBox(height: 16),
                PasswordTextField(
                  controller: _confirmNewPasswordController,
                  hint: 'Confirm new password',
                  prefixIcon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 20),
                GradientButton(
                  onPressed: state.isLoading || !canSubmit
                      ? null
                      : () {
                          context.read<AuthBloc>().add(
                            ResetPasswordSubmitted(
                              state.email,
                              _otpCodeController.text.trim(),
                              _newPasswordController.text,
                            ),
                          );
                        },
                  text: 'Reset password',
                  icon: Icons.check_circle_outline,
                  isLoading: state.isLoading,
                ),
                const SizedBox(height: 16),
                _resendCooldown > 0
                    ? Text(
                        'Resend code in $_resendCooldown s',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                      )
                    : TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                _startResendCooldown();
                                context.read<AuthBloc>().add(ForgotPasswordRequested(state.email));
                              },
                        child: const Text('Resend code', style: TextStyle(color: AppTheme.sage)),
                      ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.read<AuthBloc>().add(CancelForgotPassword()),
                  child: const Text('Back to login', style: TextStyle(color: AppTheme.earthBrown)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordResetSuccess() {
    return Column(
      children: [
        _buildAppHeader(),
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
                const Icon(Icons.check_circle, size: 64, color: AppTheme.sage),
                const SizedBox(height: 16),
                const Text(
                  'Password reset successful',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF3C4F34)),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can now log in with your new password.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  onPressed: () => context.read<AuthBloc>().add(ReturnToAuth()),
                  text: 'Back to login',
                  icon: Icons.arrow_forward,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _startResendCooldown() {
    _resendCooldown = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) {
          _resendCooldown = 0;
          timer.cancel();
        }
      });
    });
  }

  void _showSetPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    var idToken = '';
    var signedIn = false;
    var loading = false;
    var errorMsg = '';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(signedIn ? 'Set Password' : 'Sign in with Google'),
          content: SizedBox(
            width: 400,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!signedIn) ...[
                const Text('This account uses Google Sign-In. Sign in with Google first, then set a password.'),
                const SizedBox(height: 16),
                if (errorMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(errorMsg, style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: loading ? null : () async {
                      setDialogState(() { loading = true; errorMsg = ''; });
                      try {
                        if (kIsWeb) {
                          final provider = fa.GoogleAuthProvider();
                          final result = await fa.FirebaseAuth.instance.signInWithPopup(provider);
                          idToken = await result.user?.getIdToken() ?? '';
                        } else {
                          final gsi = GoogleSignIn.instance;
                          await gsi.initialize();
                          final account = await gsi.authenticate();
                          final token = account.authentication.idToken;
                          if (token == null) throw Exception('No ID token');
                          final credential = fa.GoogleAuthProvider.credential(idToken: token);
                          await fa.FirebaseAuth.instance.signInWithCredential(credential);
                          idToken = await fa.FirebaseAuth.instance.currentUser?.getIdToken() ?? '';
                        }
                        if (idToken.isNotEmpty) {
                          emailController.text = fa.FirebaseAuth.instance.currentUser?.email ?? '';
                          setDialogState(() { signedIn = true; loading = false; });
                        }
                      } catch (e) {
                        final msg = e.toString().toLowerCase();
                        if (msg.contains('canceled') || msg.contains('cancelled')) {
                          setDialogState(() { loading = false; });
                          return;
                        }
                        setDialogState(() { loading = false; errorMsg = e.toString(); });
                      }
                    },
                    icon: loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.login),
                    label: const Text('Sign in with Google'),
                  ),
                ),
              ] else ...[
                const Text('Enter a password for email login.'),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  readOnly: true,
                  style: const TextStyle(overflow: TextOverflow.ellipsis),
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                PasswordTextField(
                  controller: passwordController,
                  hint: 'New password',
                  prefixIcon: Icons.lock_outline,
                ),
              ],
            ],
          ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            if (signedIn)
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  context.read<AuthBloc>().add(
                    SetPasswordRequested(emailController.text.trim(), passwordController.text, idToken),
                  );
                },
                child: const Text('Set Password'),
              ),
          ],
        ),
      ),
    );
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
              if (state is EmailNotVerified) {
                _otpCodeController.clear();
                _newPasswordController.clear();
                _confirmNewPasswordController.clear();
                _resendTimer?.cancel();
                _resendCooldown = 0;
              }
              if (state is ForgotPasswordMode) {
                _otpCodeController.clear();
                _newPasswordController.clear();
                _confirmNewPasswordController.clear();
                _resendTimer?.cancel();
                _resendCooldown = 0;
              }
              if (state is Authenticated) {
                ScaffoldMessenger.of(context).showSnackBar(AppTheme.successSnackBar('Welcome, ${state.user.firstName}!'));
              }
              if (state is PasswordResetSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(AppTheme.successSnackBar('Password has been reset successfully.'));
              }
              if (state is PasswordSetSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(AppTheme.successSnackBar('Password set successfully. You can now log in with email.'));
              }
              if (state is AuthError && state.code == AuthErrorCodes.googleOnlyAccount) {
                _showSetPasswordDialog(context);
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              final errorMessage = state is AuthError ? state.message : null;

              if (state is EmailNotVerified) {
                return _buildOtpView(state.email, state.isLoading, state.error);
              }

              if (state is ForgotPasswordMode) {
                return _buildForgotPasswordView(state);
              }

              if (state is PasswordResetSuccess) {
                return _buildPasswordResetSuccess();
              }

              return Column(
                children: [
                  _buildAppHeader(),
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
                              onPressed: () => context.read<AuthBloc>().add(ShowForgotPassword()),
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
                            onGoogleTap: () => context.read<AuthBloc>().add(GoogleLoginRequested()),
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
