import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tottouchordertastemobileapplication/screens/onboarding_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  late VideoPlayerController _controller3;
  late VideoPlayerController _controller4;

  bool _showLogo = false;
  bool _transitioning = false;
  bool _videosLoaded = false;

  @override
  void initState() {
    super.initState();

    // Initialize video controllers
    _controller1 = VideoPlayerController.asset('assets/animations/video1.mp4');
    _controller2 = VideoPlayerController.asset('assets/animations/video2.mp4');
    _controller3 = VideoPlayerController.asset('assets/animations/video3.mp4');
    _controller4 = VideoPlayerController.asset('assets/animations/video4.mp4');

    // Play all videos simultaneously
    _initializeAndPlay(_controller1);
    _initializeAndPlay(_controller2);
    _initializeAndPlay(_controller3);
    _initializeAndPlay(_controller4);

    // Start the transition after 9 seconds
    Future.delayed(const Duration(seconds: 9), () {
      setState(() {
        _transitioning = true;
        _showLogo = true;
      });

      // After 3 seconds, navigate to the Onboarding screen
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      });
    });
  }

  // Function to initialize and play videos
  void _initializeAndPlay(VideoPlayerController controller) {
    controller.initialize().then((_) {
      setState(() {
        controller.play();
        controller.setVolume(0.0); // Mute the video
        if (_controller1.value.isInitialized &&
            _controller2.value.isInitialized &&
            _controller3.value.isInitialized &&
            _controller4.value.isInitialized) {
          _videosLoaded = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    _controller4.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4), // Light gray background (adjust if needed)
      body: Stack(
        children: [
          // Video 1 (top)
          if (_controller1.value.isInitialized && _videosLoaded)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 4,
              child: AnimatedOpacity(
                opacity: _transitioning ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: VideoPlayer(_controller1),
              ),
            ),
          // Video 2 (second video)
          if (_controller2.value.isInitialized && _videosLoaded)
            Positioned(
              top: MediaQuery.of(context).size.height / 4,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 4,
              child: AnimatedOpacity(
                opacity: _transitioning ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: VideoPlayer(_controller2),
              ),
            ),
          // Video 3 (third video)
          if (_controller3.value.isInitialized && _videosLoaded)
            Positioned(
              top: MediaQuery.of(context).size.height / 2,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 4,
              child: AnimatedOpacity(
                opacity: _transitioning ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: VideoPlayer(_controller3),
              ),
            ),
          // Video 4 (bottom)
          if (_controller4.value.isInitialized && _videosLoaded)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: MediaQuery.of(context).size.height / 4,
              child: AnimatedOpacity(
                opacity: _transitioning ? 0.0 : 1.0,
                duration: const Duration(seconds: 3),
                child: VideoPlayer(_controller4),
              ),
            ),
          // App Logo Animation
          if (_showLogo)
            AnimatedOpacity(
              opacity: _transitioning ? 1.0 : 0.0,
              duration: const Duration(seconds: 3),
              child: Center(
                child: AnimatedScale(
                  scale: _transitioning ? 2.0 : 1.0,
                  duration: const Duration(seconds: 3),
                  child: Image.asset(
                    'assets/images/AppLogo.png',
                    height: 150,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
