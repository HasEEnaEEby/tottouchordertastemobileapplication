import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/app/shared_prefs/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_box_manager.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_service.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/repository/auth_local_repository/auth_local_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/remote_data_source/customer_dashboard_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/repository/customer_dashboard_repository_impl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/get_all_restaurants_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/splash_onboarding_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await _initCore();
  await _initExternalDependencies();
  await _initServices();
  await _initDataSources();
  await _initRepositories();
  await _initUseCases();
  await _initBlocs();
}

Future<void> _initCore() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register Hive Adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SyncHiveModelAdapter());
  }

  // 🔹 Register SharedPreferences & SharedPreferencesService
  final sharedPreferences = await SharedPreferences.getInstance();
  final sharedPreferencesService = SharedPreferencesService(sharedPreferences);
  getIt.registerSingleton<SharedPreferencesService>(sharedPreferencesService);

  // 🔹 Register SharedPreferences instance (optional, if needed separately)
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Logger
  getIt.registerSingleton<Logger>(Logger('TOTApp'));
}

Future<void> _initExternalDependencies() async {
  // Internet Connection Checker
  getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker());

  // Register Dio with proper options
  getIt.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: ApiEndpoints.connectionTimeout,
      receiveTimeout: ApiEndpoints.receiveTimeout,
      contentType: 'application/json',
      validateStatus: (status) => status! < 500,
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: true,
    ));
    return dio;
  });
}

Future<void> _initServices() async {
  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(getIt<InternetConnectionChecker>()),
  );

  // Hive Box Manager
  getIt.registerSingleton<HiveBoxManager>(HiveBoxManager());

  // Hive Service
  getIt.registerSingleton<HiveService>(
    HiveService(hiveManager: getIt<HiveBoxManager>()),
  );

  // Sync Service
  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      networkInfo: getIt<NetworkInfo>(),
      hiveManager: getIt<HiveBoxManager>(),
      dio: getIt<Dio>(),
    ),
  );

  // Initialize Sync Service
  await getIt<SyncService>().initialize();
}

Future<void> _initDataSources() async {
  // Auth Local Data Source
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );

  // ✅ Fixed: Added 'prefs' argument
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      dio: getIt<Dio>(),
      networkInfo: getIt<NetworkInfo>(),
      prefs: getIt<SharedPreferencesService>(),
    ),
  );

  // ✅ Fixed: Added 'prefs' argument
  getIt.registerLazySingleton<CustomerDashboardRemoteDataSource>(
    () => CustomerDashboardRemoteDataSourceImpl(
      dio: getIt<Dio>(),
      prefs: getIt<SharedPreferencesService>(),
    ),
  );
}

Future<void> _initRepositories() async {
  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthLocalRepositoryImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      syncService: getIt<SyncService>(),
      dio: getIt<Dio>(),
    ),
  );

  // Customer Dashboard Repository
  getIt.registerLazySingleton<CustomerDashboardRepository>(
    () => CustomerDashboardRepositoryImpl(
      remoteDataSource: getIt<CustomerDashboardRemoteDataSource>(),
    ),
  );
}

Future<void> _initUseCases() async {
  // Auth Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(
        repository: getIt<AuthRepository>(),
      ));

  getIt.registerLazySingleton(() => RegisterUserUseCase(
        repository: getIt<AuthRepository>(),
      ));

  // Customer Dashboard Use Case
  getIt.registerLazySingleton(() => GetAllRestaurantsUseCase(
        getIt<CustomerDashboardRepository>(),
      ));
}

Future<void> _initBlocs() async {
  // Sync Bloc
  getIt.registerFactory(() => SyncBloc(
        syncService: getIt<SyncService>(),
        networkInfo: getIt<NetworkInfo>(),
      ));

  // Customer Dashboard Bloc
  getIt.registerFactory(() => CustomerDashboardBloc(
        getAllRestaurantsUseCase: getIt<GetAllRestaurantsUseCase>(),
      ));

  // Register Bloc
  getIt.registerFactory(() => RegisterBloc(
        repository: getIt<AuthRepository>(),
        registerUseCase: getIt<RegisterUserUseCase>(),
        syncService: getIt<SyncService>(),
        syncBloc: getIt<SyncBloc>(),
      ));

  // Login Bloc
  getIt.registerFactory(() => LoginBloc(
        authRepository: getIt<AuthRepository>(),
        loginUseCase: getIt<LoginUseCase>(),
        registerBloc: getIt<RegisterBloc>(),
        syncBloc: getIt<SyncBloc>(),
      ));

  // Splash Onboarding Cubit
  getIt.registerFactory(() => SplashOnboardingCubit());
}

// Optional: Debug Bloc Observer
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('onClose -- ${bloc.runtimeType}');
  }
}
