import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/config/app_theme.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/splash/presentation/view/splash_view.dart';
import 'package:tottouchordertastemobileapplication/features/splash_onboarding_cubit.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Logger _logger = Logger('App');
  late NetworkInfo _networkInfo;

  @override
  void initState() {
    super.initState();
    _initNetworkListener();
  }

  void _initNetworkListener() {
    try {
      _networkInfo = GetIt.instance<NetworkInfo>();

      _networkInfo.onConnectivityChanged.listen((isConnected) {
        _logger.info('Network connectivity changed: $isConnected');

        if (isConnected) {
          _handleNetworkConnected();
        }
      });
    } catch (e) {
      _logger.warning('Failed to initialize network listener', e);
    }
  }

  void _handleNetworkConnected() {
    try {
      GetIt.instance<SyncBloc>().add(StartSync());
    } catch (e) {
      _logger.warning('Error handling network connection', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Provide the ThemeCubit globally so it can be accessed in the widget tree.
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<SplashOnboardingCubit>(
          create: (context) => GetIt.instance<SplashOnboardingCubit>(),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => GetIt.instance<LoginBloc>(),
        ),
        BlocProvider<RegisterBloc>(
          create: (context) => GetIt.instance<RegisterBloc>(),
        ),
        BlocProvider<SyncBloc>(
          create: (context) => GetIt.instance<SyncBloc>(),
        ),
      ],
      // Listen to ThemeCubit changes and rebuild MaterialApp accordingly.
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'TOT Restaurant Ordering',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const FlashScreen(),
            builder: (context, child) {
              return ScrollConfiguration(
                behavior: const ScrollBehavior(),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
