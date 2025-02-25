import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/app/deep_link_handler.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeApp();
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
      DeepLinkHandler.init(navigatorKey: _navigatorKey);
    } catch (e) {
      _logger.severe('Error initializing components: $e');
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
  }

  void _handleAppBackground() {
    // Handle background state
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    DeepLinkHandler.dispose();
    _dashboardBloc?.close();
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
          create: (_) => GetIt.instance<
              CustomerDashboardBloc>(), 
        ),
      ],
      child: Builder(
        builder: (context) {
          return MaterialApp(
            navigatorKey: _navigatorKey,
            title: 'TOT Restaurant Ordering',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: context.watch<ThemeCubit>().state,
            home: const FlashScreen(),
            builder: (context, child) {
              return ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: child ?? const SizedBox(),
              );
            },
            navigatorObservers: [
              _AppNavigatorObserver(),
            ],
          );
        },
      ),
    );
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
