import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/customer_dashboard_view.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/restaurant_dashboard_view.dart';

import '../view_model/login/login_bloc.dart';
import '../view_model/login/login_event.dart';
import '../view_model/login/login_state.dart';
import '../view_model/sync/sync_bloc.dart';
import '../widget/custom_text_field.dart';
import '../widget/role_card.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _adminCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String _selectedUserType = 'customer';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          // Navigation will now be handled in the Bloc
          if (state.user.userType == 'customer') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => CustomerDashboardView(
                  userName: state.user.profile.username ?? '',
                ),
              ),
            );
          } else if (state.user.userType == 'restaurant') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const RestaurantDashboardView(),
              ),
            );
          }
        } else if (state is LoginError) {
          _showErrorSnackbar(context, state.message);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      _buildHeader(),
                      const SizedBox(height: 32),
                      _buildRoleSelector(),
                      const SizedBox(height: 32),
                      _buildLoginForm(),
                      const SizedBox(height: 24),
                      _buildForgotPassword(),
                      const SizedBox(height: 16),
                      _buildSignUpLink(),
                      const SizedBox(height: 32),
                      _buildTermsAndPrivacy(),
                    ],
                  ),
                ),
              ),
            ),
            _buildSyncStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncStatus() {
    return BlocBuilder<SyncBloc, SyncState>(
      buildWhen: (previous, current) => current is SyncInProgress,
      builder: (context, state) {
        if (state is SyncInProgress) {
          return Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color:
                  const Color.fromARGB(255, 214, 97, 43).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.fromARGB(255, 185, 18, 18),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Syncing data...',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: AppFonts.medium,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Welcome Back, ${_selectedUserType == 'customer' ? 'Foodie' : 'Restaurant Partner'}!",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontFamily: AppFonts.bold,
                fontSize: 24,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          _selectedUserType == 'customer'
              ? "Sign in to your personalized dining experience"
              : "Sign in to manage your restaurant dashboard",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontFamily: AppFonts.regular,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: RoleCard(
            title: 'Customer',
            description: 'Access your favorite orders and preferences',
            icon: Icons.person_outline,
            isSelected: _selectedUserType == 'customer',
            onTap: () {
              setState(() {
                _selectedUserType = 'customer';
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: RoleCard(
            title: 'Restaurant',
            description: 'Manage your restaurant dashboard',
            icon: Icons.restaurant_outlined,
            isSelected: _selectedUserType == 'restaurant',
            onTap: () {
              setState(() {
                _selectedUserType = 'restaurant';
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
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
                if (_selectedUserType == 'restaurant') ...[
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _adminCodeController,
                    label: 'Admin Code',
                    hint: 'Enter your admin code',
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your admin code';
                      }
                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 24),
                _buildLoginButton(state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginButton(LoginState state) {
    return ElevatedButton(
      onPressed: state is! LoginLoading
          ? () {
              if (_formKey.currentState!.validate()) {
                context.read<LoginBloc>().add(
                      LoginSubmitted(
                        context: context, // Pass the context
                        email: _emailController.text,
                        password: _passwordController.text,
                        userType: _selectedUserType,
                        adminCode: _selectedUserType == 'restaurant'
                            ? _adminCodeController.text
                            : null,
                      ),
                    );
              }
            }
          : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: state is LoginLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Log In',
              style: TextStyle(
                fontSize: 16,
                fontFamily: AppFonts.semiBold,
              ),
            ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
      child: const Text(
        'Forgot your password?',
        style: TextStyle(
          fontFamily: AppFonts.medium,
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.regular,
          ),
        ),
        TextButton(
          onPressed: () {
            // Use the bloc to handle navigation
            context.read<LoginBloc>().add(
                  NavigateRegisterScreenEvent(context: context),
                );
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: const Text(
            'Sign up',
            style: TextStyle(
              fontFamily: AppFonts.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontFamily: AppFonts.regular,
          ),
      textAlign: TextAlign.center,
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: AppFonts.medium,
          ),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
