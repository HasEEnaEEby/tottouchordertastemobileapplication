import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart'
    as app_colors;
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/widget/custom_text_field.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view/customer_dashboard_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Toggling password visibility
  bool _obscurePassword = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // Fade-in animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: AppFonts.medium),
        ),
        backgroundColor: app_colors.AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CustomerDashboardView(
                userName: state.user.profile.username ?? '',
              ),
            ),
          );
        } else if (state is LoginError) {
          _showErrorSnackbar(context, state.message);
        }
      },
      child: Scaffold(
        // Light/white background to contrast with the red wave
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // 1) A tall wave at the top with a red gradient
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: _TopWaveClipper(),
                child: Container(
                  height: 320, // Increased for a more prominent wave
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        app_colors.AppColors.primary,
                        app_colors.AppColors.secondary,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _animationController,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      _buildHeader(),
                      const SizedBox(height: 60),
                      _buildLoginCard(context),
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

            // 4) Sync status or overlay if needed
            _buildSyncStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        // Replace with your TOT brand icon if you have one
        Icon(
          Icons.restaurant_menu,
          color: Colors.white,
          size: 50,
        ),
        SizedBox(height: 12),
        Text(
          "Welcome Back, Foodie!",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.bold,
            fontSize: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(240),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return Column(
              children: [
                // Email
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    // Optionally add your own email validation
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password + visibility toggle
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: app_colors.AppColors.primary,
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
                const SizedBox(height: 24),

                // Gradient "Log In" button
                _buildGradientLoginButton(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGradientLoginButton(LoginState state) {
    final isLoading = state is LoginLoading;

    return GestureDetector(
      onTap: () {
        if (!isLoading && _formKey.currentState!.validate()) {
          context.read<LoginBloc>().add(
                LoginSubmitted(
                  context: context,
                  email: _emailController.text.trim(),
                  password: _passwordController.text,
                  userType: 'customer',
                  adminCode: null,
                ),
              );
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              app_colors.AppColors.primaryDark,
              app_colors.AppColors.primary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Log In',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.medium,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildForgotPassword() {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, '/forgot-password'),
      style: TextButton.styleFrom(foregroundColor: Colors.black54),
      child: const Text('Forgot your password?'),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account? ",
          style: TextStyle(color: Colors.black54),
        ),
        TextButton(
          onPressed: () {
            context
                .read<LoginBloc>()
                .add(NavigateRegisterScreenEvent(context: context));
          },
          child: const Text(
            'Sign up',
            style: TextStyle(color: app_colors.AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return const Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.black54, fontSize: 12),
    );
  }

  Widget _buildSyncStatus() {
    // If you have some sync indicator logic, place it here
    return const SizedBox.shrink();
  }
}

// A custom clipper for the top wave
class _TopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Start from top-left
    final path = Path()..lineTo(0, size.height - 60);

    // Curve from left to right
    final controlPoint = Offset(size.width / 2, size.height);
    final endPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // Then go straight up to the top-right corner
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_TopWaveClipper oldClipper) => false;
}
