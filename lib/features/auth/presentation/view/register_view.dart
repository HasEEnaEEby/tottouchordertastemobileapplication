import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_data.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/entity/auth_entity.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_state.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
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
  final _restaurantNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactNumberController = TextEditingController();
  final _quoteController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _animationController;
  String selectedRole = 'customer';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _restaurantNameController.dispose();
    _locationController.dispose();
    _contactNumberController.dispose();
    _quoteController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final event = RegisterSubmitted(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        userType: selectedRole,
        context: context, // Add context here
        restaurantName: selectedRole == 'restaurant'
            ? _restaurantNameController.text
            : null,
        location:
            selectedRole == 'restaurant' ? _locationController.text : null,
        contactNumber:
            selectedRole == 'restaurant' ? _contactNumberController.text : null,
        quote: selectedRole == 'restaurant' ? _quoteController.text : null,
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
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: context.watch<RegisterBloc>().state is RegisterLoading,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 32),
                    _buildRoleSelector(),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: selectedRole == 'customer'
                          ? _buildCustomerForm()
                          : _buildRestaurantForm(),
                    ),
                    const SizedBox(height: 24),
                    _buildSubmitButton(),
                    const SizedBox(height: 16),
                    _buildLoginLink(),
                    const SizedBox(height: 24),
                    _buildTermsAndPrivacy(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Join TOT",
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          selectedRole == 'customer'
              ? "Join the TOT Family and unlock personalized dining experiences!"
              : "Become a TOT Restaurant Partner and expand your customer reach.",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedRole = 'customer'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selectedRole == 'customer'
                    ? AppTheme.primaryColor.withAlpha(20)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedRole == 'customer'
                      ? AppTheme.primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: selectedRole == 'customer'
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedRole == 'customer'
                          ? AppTheme.primaryColor.withAlpha(30)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 32,
                      color: selectedRole == 'customer'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Customer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedRole == 'customer'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your favorite orders and preferences',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedRole == 'customer'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedRole = 'restaurant'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: selectedRole == 'restaurant'
                    ? AppTheme.primaryColor.withAlpha(20)
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedRole == 'restaurant'
                      ? AppTheme.primaryColor
                      : Colors.grey[300]!,
                  width: 2,
                ),
                boxShadow: selectedRole == 'restaurant'
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withAlpha(40),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedRole == 'restaurant'
                          ? AppTheme.primaryColor.withAlpha(30)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.restaurant_menu,
                      size: 32,
                      color: selectedRole == 'restaurant'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Restaurant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: selectedRole == 'restaurant'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your restaurant dashboard',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: selectedRole == 'restaurant'
                          ? AppTheme.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a username',
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
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
              color: AppTheme.primaryColor,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
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
              color: AppTheme.primaryColor,
            ),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) => value != _passwordController.text
              ? 'Passwords do not match'
              : null,
        ),
      ],
    );
  }

  Widget _buildRestaurantForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomTextField(
          controller: _usernameController,
          label: 'Username',
          hint: 'Choose a username',
          prefixIcon: const Icon(Icons.person),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _restaurantNameController,
          label: 'Restaurant Name',
          hint: 'Enter your restaurant name',
          prefixIcon: const Icon(Icons.store),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Restaurant name is required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _locationController,
          label: 'Location',
          hint: 'Restaurant address',
          prefixIcon: const Icon(Icons.location_on),
          validator: (value) =>
              value?.isEmpty ?? true ? 'Location is required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _contactNumberController,
          label: 'Contact Number',
          hint: 'Business contact number',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (value) =>
              value?.isEmpty ?? true ? 'Contact number is required' : null,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _quoteController,
          label: 'Restaurant Quote (Optional)',
          hint: 'Your restaurant\'s motto',
          prefixIcon: const Icon(Icons.format_quote),
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
              color: AppTheme.primaryColor,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
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
              color: AppTheme.primaryColor,
            ),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
          validator: (value) => value != _passwordController.text
              ? 'Passwords do not match'
              : null,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return BlocBuilder<RegisterBloc, RegisterState>(
      builder: (context, state) {
        return ElevatedButton(
          onPressed: state is! RegisterLoading ? _handleSubmit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: state is RegisterLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () {
            // Use the new NavigateToLoginEvent
            context.read<RegisterBloc>().add(
                  NavigateToLoginEvent(context: context),
                );
          },
          child: const Text(
            'Sign In',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsAndPrivacy() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            'By creating an account, you agree to our',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  // Handle Terms of Service navigation
                },
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                'and',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Handle Privacy Policy navigation
                },
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
