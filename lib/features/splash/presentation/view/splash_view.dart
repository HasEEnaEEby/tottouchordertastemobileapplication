import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view/login_view.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/onboarding.dart/onboarding_screen.dart';
import 'package:tottouchordertastemobileapplication/features/splash_onboarding_cubit.dart';
import 'package:video_player/video_player.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with SingleTickerProviderStateMixin {
  // Video Controllers
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;
  late VideoPlayerController _controller4;

  // Animation Controller for additional visual effects
  late AnimationController _animationController;

  // State Variables
  bool _showLogo = false;
  bool _transitioning = false;
  bool _videosLoaded = false;

  @override
  void initState() {
    super.initState();

    // Initialize Animation Controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Initialize Video Controllers
    _initializeVideoControllers();

    // Check Onboarding Status after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashOnboardingCubit>().checkOnboardingStatus();
    });

    // Video and Transition Logic
    _setupVideoTransition();
  }

  void _initializeVideoControllers() {
    _controller1 = VideoPlayerController.asset('assets/animations/video1.mp4');
    _controller2 = VideoPlayerController.asset('assets/animations/video3.mp4');
    _controller3 = VideoPlayerController.asset('assets/animations/video2.mp4');
    _controller4 = VideoPlayerController.asset('assets/animations/video4.mp4');

    // Initialize and play each video
    _initializeAndPlay(_controller1);
    _initializeAndPlay(_controller2);
    _initializeAndPlay(_controller3);
    _initializeAndPlay(_controller4);
  }

  void _initializeAndPlay(VideoPlayerController controller) {
    controller.initialize().then((_) {
      setState(() {
        controller.play();
        controller.setVolume(0.0);

        // Check if all videos are initialized
        if (_areAllVideosInitialized()) {
          _videosLoaded = true;
          context.read<SplashOnboardingCubit>().updateVideoLoadingState(true);
        }
      });
    }).catchError((error) {
      print('Video initialization error: $error');
    });
  }

  bool _areAllVideosInitialized() {
    return _controller1.value.isInitialized &&
        _controller2.value.isInitialized &&
        _controller3.value.isInitialized &&
        _controller4.value.isInitialized;
  }

  void _setupVideoTransition() {
    Future.delayed(const Duration(seconds: 9), () {
      setState(() {
        _transitioning = true;
        _showLogo = true;
      });

      _animationController.forward();

      Future.delayed(const Duration(seconds: 3), () {
        _navigateToNextScreen();
      });
    });
  }

  void _navigateToNextScreen() {
    final state = context.read<SplashOnboardingCubit>().state;

    if (state is OnboardingCompletedState) {
      // If onboarding is completed, navigate to login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<LoginBloc>()),
              BlocProvider.value(value: context.read<SyncBloc>()),
            ],
            child: const LoginView(),
          ),
        ),
      );
    } else {
      // If onboarding is not completed, navigate to onboarding screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<SplashOnboardingCubit>()),
              BlocProvider.value(value: context.read<SyncBloc>()),
            ],
            child: const OnboardingScreen(),
          ),
        ),
      );
    }

    // Log the navigation
    print('Navigating from FlashScreen - State: $state');
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashOnboardingCubit, SplashOnboardingState>(
      listener: (context, state) {
        if (state is SplashOnboardingErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Initialization Error: ${state.errorMessage}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: Stack(
          children: [
            // Quadrant Video Players
            _buildVideoQuadrant(
                _controller1, 0, MediaQuery.of(context).size.height / 4),
            _buildVideoQuadrant(
                _controller2,
                MediaQuery.of(context).size.height / 4,
                MediaQuery.of(context).size.height / 4),
            _buildVideoQuadrant(
                _controller3,
                MediaQuery.of(context).size.height / 2,
                MediaQuery.of(context).size.height / 4),
            _buildVideoQuadrant(
                _controller4,
                MediaQuery.of(context).size.height * 3 / 4,
                MediaQuery.of(context).size.height / 4),

            // Logo Transition
            if (_showLogo)
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _transitioning ? 1.0 : 0.0,
                    child: Center(
                      child: Transform.scale(
                        scale: _transitioning ? 2.0 : 1.0,
                        child: Image.asset(
                          'assets/images/AppLogo.png',
                          height: 150,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoQuadrant(
      VideoPlayerController controller, double topPosition, double height) {
    return Positioned(
      top: topPosition,
      left: 0,
      right: 0,
      height: height,
      child: controller.value.isInitialized && _videosLoaded
          ? AnimatedOpacity(
              opacity: _transitioning ? 0.0 : 1.0,
              duration: const Duration(seconds: 3),
              child: VideoPlayer(controller),
            )
          : const SizedBox.shrink(),
    );
  }
}
