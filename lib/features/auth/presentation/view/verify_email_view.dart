import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_event.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_state.dart';

class VerifyEmailView extends StatefulWidget {
  final String token;
  final String email;

  const VerifyEmailView({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  bool _showSuccessMessage = false;
  bool _isResendingEmail = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initiateVerification();
    });
  }

  void _initiateVerification() {
    if (!mounted) return;
    context
        .read<VerifyEmailBloc>()
        .add(VerifyEmailRequested(token: widget.token));
  }

  void _resendVerificationEmail() {
    if (!mounted) return;
    setState(() {
      _isResendingEmail = true;
    });
    context
        .read<VerifyEmailBloc>()
        .add(ResendVerificationEmailRequested(email: widget.email));
  }

  void _handleSuccess() {
    if (!mounted) return;

    setState(() {
      _showSuccessMessage = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email verified successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    _navigateToLogin();
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    });
  }

  Widget _buildContent(VerifyEmailState state) {
    if (state is VerifyEmailLoading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            _isResendingEmail
                ? 'Resending verification email...'
                : 'Verifying your email...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      );
    }

    if (state is VerifyEmailSuccess) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.green,
                ),
          ),
        ],
      );
    }

    if (state is VerifyEmailFailure) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 64),
          const SizedBox(height: 16),
          Text(
            state.error,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.red,
                ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _initiateVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Try Again'),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: _resendVerificationEmail,
                child: const Text('Resend Email'),
              ),
            ],
          ),
        ],
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Verification'),
        centerTitle: true,
      ),
      body: BlocConsumer<VerifyEmailBloc, VerifyEmailState>(
        listener: (context, state) {
          if (state is VerifyEmailSuccess && !_showSuccessMessage) {
            _handleSuccess();
          } else if (state is VerifyEmailFailure) {
            setState(() {
              _isResendingEmail = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildContent(state),
            ),
          );
        },
      ),
    );
  }
}
