import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// App theme & styles
import 'package:tottouchordertastemobileapplication/core/config/app_colors.dart';
import 'package:tottouchordertastemobileapplication/core/config/text_styles.dart';
// BLoC and domain imports
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
// Widgets
import 'package:tottouchordertastemobileapplication/features/auth/presentation/widget/custom_text_field.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/widget/loading_overlay.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;

  final String _userType = 'customer';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final event = RegisterSubmitted(
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        userType: _userType,
        context: context,
        restaurantName: null,
        location: null,
        contactNumber: null,
        quote: null,
      );
      context.read<RegisterBloc>().add(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          context.read<SyncBloc>().add(StartSync());
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Registration successful! Please verify your email.'),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        // Off-white background behind the wave & card
        backgroundColor: AppColors.accent,
        body: LoadingOverlay(
          isLoading: context.watch<RegisterBloc>().state is RegisterLoading,
          child: Stack(
            children: [
              // The big red wave at the top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: _WaveClipper(),
                  child: Container(
                    height: 300, // Make it tall enough
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryDark,
                          AppColors.primary,
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
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        // Place the header text well within the wave
                        _buildHeader(),
                        const SizedBox(height: 40),
                        // Card for form
                        Card(
                          color: AppColors.surface, // White
                          elevation: 6.0, // Stronger shadow
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 0,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 32,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  _buildCustomerForm(context),
                                  const SizedBox(height: 24),
                                  _buildGradientButton(context),
                                  const SizedBox(height: 16),
                                  _buildLoginLink(context),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTermsAndPrivacy(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Replace with your brand icon if desired
        const Icon(
          Icons.restaurant_menu,
          color: Colors.white,
          size: 50,
        ),
        const SizedBox(height: 12),
        Text(
          "Join TOT",
          style: AppTextStyles.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Create an account and unlock personalized dining experiences!",
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerForm(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a username',
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Username is required';
            }
            if (value.trim().length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          hint: 'Enter your email',
          prefixIcon: const Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => !AuthEntity.isValidEmail(value ?? '')
              ? 'Invalid email format'
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          hint: 'Create a strong password',
          prefixIcon: const Icon(Icons.lock),
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) => !AuthEntity.isValidPassword(value ?? '')
              ? 'Password must be at least 8 characters'
              : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Repeat your password',
          prefixIcon: const Icon(Icons.lock_outline),
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              color: AppColors.primary,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  // Gradient button
  Widget _buildGradientButton(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        final isLoading = state is RegisterLoading;
        return GestureDetector(
          onTap: !isLoading ? _handleSubmit : null,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
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
                      'Sign Up',
                      style: AppTextStyles.buttonLarge,
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        TextButton(
          onPressed: () {
            context.read<RegisterBloc>().add(
                  NavigateToLoginEvent(context: context),
                );
          },
          child: Text(
            'Log In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            'By continuing, you agree to our',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.secondaryDark.withOpacity(0.7),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Navigate to Terms of Service
                },
                child: Text(
                  'Terms of Service',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.secondaryDark.withOpacity(0.7),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to Privacy Policy
                },
                child: Text(
                  'Privacy Policy',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.secondaryDark,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// A custom clipper for a gentle wave at the top.
class _WaveClipper extends CustomClipper<Path> {
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
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
