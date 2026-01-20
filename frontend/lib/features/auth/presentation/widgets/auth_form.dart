import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/widgets/plantify_text_field.dart';
import '../../../../core/widgets/plantify_button.dart';
import '../../../../core/constants/app_colors.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key});

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool get _isLoginMode {
    final state = context.read<AuthBloc>().state;
    if (state is AuthUnauthenticated) {
      return state.isLoginMode;
    }
    if (state is AuthError) {
      return state.isLoginMode;
    }
    return true;
  }

  void _toggleMode() {
    context.read<AuthBloc>().add(const AuthModeToggled());
    _animationController.reset();
    _animationController.forward();
    _formKey.currentState?.reset();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_isLoginMode) {
        context.read<AuthBloc>().add(
              LoginRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
              ),
            );
      } else {
        context.read<AuthBloc>().add(
              RegisterRequested(
                email: _emailController.text.trim(),
                password: _passwordController.text,
                name: _nameController.text.trim(),
              ),
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isLoginMode = _isLoginMode;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.08),
                  blurRadius: 30,
                  spreadRadius: 0,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                width: 1.5,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(isLoginMode),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 72,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, -0.2),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: !isLoginMode
                          ? Padding(
                              key: const ValueKey('name_field'),
                              padding: const EdgeInsets.only(bottom: 16),
                              child: PlantifyTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_outline_rounded,
                                validator: (value) {
                                  if (!isLoginMode && (value == null || value.trim().isEmpty)) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                            )
                          : const SizedBox(
                              key: ValueKey('no_name_field'),
                              height: 72,
                            ),
                    ),
                  ),
                  PlantifyTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PlantifyTextField(
                    controller: _passwordController,
                    label: 'Password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppColors.textLight,
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
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PlantifyButton(
                    onPressed: isLoading ? null : _submit,
                    isLoading: isLoading,
                    text: isLoginMode ? 'Sign In' : 'Sign Up',
                  ),
                  const SizedBox(height: 20),
                  _buildToggleButton(isLoginMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isLoginMode) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey(isLoginMode),
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreenLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 0,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isLoginMode ? Icons.login_rounded : Icons.person_add_rounded,
                  color: AppColors.backgroundWhite,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isLoginMode ? 'Welcome Back' : 'Create Account',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMedium,
                  letterSpacing: -1,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreenLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isLoginMode
                    ? 'Sign in to access your account'
                    : 'Start your journey with us today',
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textLight,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildToggleButton(bool isLoginMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isLoginMode ? "Don't have an account? " : 'Already have an account? ',
          style: const TextStyle(
            color: AppColors.textLight,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
        ),
        GestureDetector(
          onTap: _toggleMode,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isLoginMode ? 'Sign Up' : 'Sign In',
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 15,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

