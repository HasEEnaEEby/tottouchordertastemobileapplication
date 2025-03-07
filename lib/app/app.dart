import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/deep_link_handler.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/light_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/splash/presentation/view/splash_view.dart';
import 'package:tottouchordertastemobileapplication/features/splash_onboarding_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  final Logger _logger = Logger('App');
  late NetworkInfo _networkInfo;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  CustomerDashboardBloc? _dashboardBloc;

  // Track if auto-theme based on light is enabled
  bool _isAutoThemeEnabled = false;

  // Track proximity sensor state
  bool _isNearDevice = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeCubit = context.read<ThemeCubit>();
      debugPrint("🔆 Current theme preference: ${themeCubit.preference}");

      if (themeCubit.preference == ThemePreference.auto) {
        debugPrint("🔆 Auto theme is enabled, starting sensors");
        // Start the sensors
        final sensorManager = GetIt.instance<SensorManager>();
        sensorManager.lightSensorService.startListening();
        sensorManager.proximitySensorService.startListening();
      }
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Configure logging
      _setupLogging();

      // Add lifecycle observer
      WidgetsBinding.instance.addObserver(this);

      // Initialize components after frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeAppComponents();
      });
    } catch (e) {
      _logger.severe('Error initializing app: $e');
    }
  }

  void _setupLogging() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  void _initializeAppComponents() {
    try {
      _initNetworkListener();
      _initSensors();
      DeepLinkHandler.init(navigatorKey: _navigatorKey);
    } catch (e) {
      _logger.severe('Error initializing components: $e');
    }
  }

  void _initSensors() {
    try {
      final sensorManager = GetIt.instance<SensorManager>();
      final lightSensorService = sensorManager.lightSensorService;
      final proximitySensorService = sensorManager.proximitySensorService;
      final motionSensorService = sensorManager.motionSensorService; // Add this

      // Start light sensor
      lightSensorService.startListening();
      lightSensorService.addListener(_handleLightChange);

      // Start proximity sensor
      proximitySensorService.startListening();
      proximitySensorService.addListener(_handleProximityChange);

      // Connect proximity sensor to motion sensor service
      proximitySensorService.addListener((isNear) {
        motionSensorService.handleProximityChange(isNear);
      });

      _logger.info('Sensors initialized successfully');
    } catch (e) {
      _logger.warning('Failed to initialize sensors: $e');
    }
  }

  void _handleProximityChange(bool isNear) {
    _logger.info('📱 Proximity changed: ${isNear ? 'NEAR' : 'FAR'}');
    setState(() {
      _isNearDevice = isNear;
    });

    // Optional: Additional logging or actions
    _logger.info('🔊 Proximity change may impact audio playback');
  }

  void _handleLightChange(int luxValue) {
    if (_isAutoThemeEnabled) {
      _logger.info('🔆 Light level changed: $luxValue lux, updating theme');

      // Get theme cubit
      final themeCubit = context.read<ThemeCubit>();

      // Get sensor manager and light service
      final sensorManager = GetIt.instance<SensorManager>();
      final lightSensorService = sensorManager.lightSensorService;

      // Update theme mode based on light level
      final recommendedThemeMode = lightSensorService.getRecommendedThemeMode();
      _logger.info(
          '🔆 Recommended theme mode: ${recommendedThemeMode.toString()}');

      // If theme changed, emit new state
      if (themeCubit.state != recommendedThemeMode) {
        _logger
            .info('🔆 Changing theme to: ${recommendedThemeMode.toString()}');
        themeCubit.updateThemeBasedOnLight(recommendedThemeMode);
      }
    }
  }

  void _initNetworkListener() {
    try {
      _networkInfo = GetIt.instance<NetworkInfo>();
      _networkInfo.onConnectivityChanged.listen(_handleConnectivityChange);
    } catch (e) {
      _logger.warning('Failed to initialize network listener: $e');
    }
  }

  void _handleConnectivityChange(bool isConnected) {
    _logger.info('Network connectivity changed: $isConnected');
    if (isConnected) {
      _handleNetworkConnected();
    }
  }

  void _handleNetworkConnected() {
    try {
      GetIt.instance<SyncBloc>().add(StartSync());
    } catch (e) {
      _logger.warning('Error handling network connection: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.info('App lifecycle state changed to: $state');
    switch (state) {
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _handleAppBackground();
        break;
    }
  }

  void _handleAppResumed() {
    _handleNetworkConnected();

    // Resume sensors when app is brought to foreground
    try {
      final sensorManager = GetIt.instance<SensorManager>();
      sensorManager.lightSensorService.startListening();
      sensorManager.proximitySensorService.startListening();
    } catch (e) {
      _logger.warning('Failed to resume sensors: $e');
    }
  }

  void _handleAppBackground() {
    // Stop sensors when app is backgrounded to save battery
    try {
      final sensorManager = GetIt.instance<SensorManager>();
      sensorManager.lightSensorService.stopListening();
      sensorManager.proximitySensorService.stopListening();
    } catch (e) {
      _logger.warning('Failed to stop sensors: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    _dashboardBloc?.close();

    // Clean up sensors
    try {
      final sensorManager = GetIt.instance<SensorManager>();
      sensorManager.lightSensorService.dispose();
      sensorManager.proximitySensorService.dispose();
    } catch (e) {
      _logger.warning('Failed to dispose sensors: $e');
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider<SplashOnboardingCubit>(
          create: (_) => GetIt.instance<SplashOnboardingCubit>(),
        ),
        BlocProvider<LoginBloc>(
          create: (_) => GetIt.instance<LoginBloc>(),
        ),
        BlocProvider<RegisterBloc>(
          create: (_) => GetIt.instance<RegisterBloc>(),
        ),
        BlocProvider<SyncBloc>(
          create: (_) => GetIt.instance<SyncBloc>(),
        ),
        BlocProvider<CustomerDashboardBloc>(
          create: (_) => GetIt.instance<CustomerDashboardBloc>(),
        ),
        BlocProvider<CustomerProfileBloc>(
          create: (_) => GetIt.instance<CustomerProfileBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return BlocListener<ThemeCubit, ThemeMode>(
            listener: (context, themeMode) {
              setState(() {
                _isAutoThemeEnabled = context.read<ThemeCubit>().preference ==
                    ThemePreference.auto;
              });
            },
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: 'TOT Restaurant Ordering',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: context.watch<ThemeCubit>().state,
              home: const SplashView(),
              builder: (context, child) {
                // Apply visual adjustments based on sensors
                return ScrollConfiguration(
                  behavior: const ScrollBehavior(),
                  child: _applyVisualAdjustments(context, child),
                );
              },
              navigatorObservers: [
                _AppNavigatorObserver(),
              ],
            ),
          );
        },
      ),
    );
  }

  // Combined method to apply all visual adjustments
  Widget _applyVisualAdjustments(BuildContext context, Widget? child) {
    Widget adjustedChild = child ?? const SizedBox();

    // Apply proximity-based adjustments
    if (_isNearDevice) {
      // Dim the screen when near (e.g., phone held to face)
      adjustedChild = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.5,
          0,
          0,
          0,
          0,
          0,
          0.5,
          0,
          0,
          0,
          0,
          0,
          0.5,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
        ]), // Dim the screen by reducing brightness
        child: adjustedChild,
      );
    }

    // Then apply light-based adjustments if enabled
    if (_isAutoThemeEnabled) {
      try {
        final sensorManager = GetIt.instance<SensorManager>();
        final lightService = sensorManager.lightSensorService;

        // For very bright environments, increase contrast slightly
        if (lightService.currentLux > LightSensorService.brightThreshold) {
          adjustedChild = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              1.1,
              0,
              0,
              0,
              0,
              0,
              1.1,
              0,
              0,
              0,
              0,
              0,
              1.1,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]), // Increase contrast
            child: adjustedChild,
          );
        }
        // For very dark environments, apply a warm filter to reduce eye strain
        else if (lightService.currentLux < LightSensorService.darkThreshold) {
          adjustedChild = ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0.9,
              0.1,
              0,
              0,
              0,
              0.1,
              0.9,
              0,
              0,
              0,
              0,
              0.1,
              0.9,
              0,
              0,
              0,
              0,
              0,
              1,
              0,
            ]), // Slight warm tint
            child: adjustedChild,
          );
        }
      } catch (e) {
        _logger.warning('Error applying light adjustments: $e');
      }
    }

    return adjustedChild;
  }
}

class _AppNavigatorObserver extends NavigatorObserver {
  final Logger _logger = Logger('NavigationObserver');

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.info('Navigated to: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _logger.info('Navigated back from: ${route.settings.name}');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _logger.info(
      'Route replaced. New: ${newRoute?.settings.name}, Old: ${oldRoute?.settings.name}',
    );
  }
}
