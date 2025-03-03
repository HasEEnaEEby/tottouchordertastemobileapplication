import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/app/constants/api_endpoints.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/app/shared_prefs/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_interceptor.dart';
import 'package:tottouchordertastemobileapplication/core/auth/auth_token_manager.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_box_manager.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/barometer_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/biometric_auth_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/light_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/location_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/motion_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/pedometer_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/proximity_sensor_service.dart';
import 'package:tottouchordertastemobileapplication/core/sensors/sensor_manager.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/remote_data_source/auth_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/repository/auth_local_repository/auth_local_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/verify_email_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/verify_email/verify_email_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/remote_data_source/customer_dashboard_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/remote_data_source/order_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/data_source/table_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/repository/customer_dashboard_repository_impl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/repository/order_repository_impl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/data/repository/table_repository_impl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/customer_dashboard_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/order_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/repository/table_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/domain/use_case/customer_dashboard_usecases.dart';
import 'package:tottouchordertastemobileapplication/features/customer_dashboard/presentation/view_model/customer_dashboard/customer_dashboard_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/customer_profile_data_source.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/local_data_source/customer_profile_local_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/data_source/remote_data_source/customer_profile_remote_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/data/repository/customer_profile_repository_impl.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/repository/customer_profile_repository.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/delete_customer_profile_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/fetch_customer_profile_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/update_customer_profile_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/domain/use_case/upload_profile_image_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/customer_profile/presentation/view_model/customer_profile/customer_profile_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/splash_onboarding_cubit.dart';

final getIt = GetIt.instance;
final _logger = Logger('DependencyInjection');

Future<void> initDependencies() async {
  try {
    _logger.info('🚀 Initializing dependencies...');

    await _initCore();
    await _initExternalDependencies();
    await _initServices();
    await _initDataSources();
    await _initRepositories();
    await _initUseCases();
    await _initBlocs();

    _logger.info('✅ Dependencies initialized successfully');
  } catch (e, stackTrace) {
    _logger.severe('❌ Failed to initialize dependencies', e, stackTrace);
    rethrow;
  }
}

Future<void> _initCore() async {
  try {
    _logger.info('Initializing core dependencies...');

    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();

    // Register Hive Adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(SyncHiveModelAdapter());
    }

    // Initialize SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    final sharedPreferencesService =
        SharedPreferencesService(sharedPreferences);
    getIt.registerSingleton<SharedPreferencesService>(sharedPreferencesService);

    // Register AuthTokenManager
    getIt.registerSingleton<AuthTokenManager>(
      AuthTokenManager(sharedPreferences),
    );

    // Register Logger
    getIt.registerSingleton<Logger>(Logger('TOTApp'));

    _logger.info('✅ Core dependencies initialized');
  } catch (e) {
    _logger.severe('Failed to initialize core dependencies', e);
    rethrow;
  }
}

Future<void> _initExternalDependencies() async {
  try {
    _logger.info('Initializing external dependencies...');

    getIt.registerLazySingleton<http.Client>(() => http.Client());
    _logger.info('Registered http.Client');

    // Internet Connection Checker
    getIt.registerLazySingleton<InternetConnectionChecker>(
      () => InternetConnectionChecker(),
    );

    getIt.registerLazySingleton<Dio>(() {
      final dio = Dio(BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: ApiEndpoints.connectionTimeout,
        receiveTimeout: ApiEndpoints.receiveTimeout,
        contentType: 'application/json',
        validateStatus: (status) => status! < 500,
      ));

      // Add interceptors
      dio.interceptors.addAll([
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          error: true,
          requestHeader: true,
          responseHeader: true,
        ),
        AuthInterceptor(
          tokenManager: getIt<AuthTokenManager>(),
          dio: dio,
        ),
      ]);

      return dio;
    });

    _logger.info('✅ External dependencies initialized');
  } catch (e) {
    _logger.severe('Failed to initialize external dependencies', e);
    rethrow;
  }
}

Future<void> _initServices() async {
  try {
    _logger.info('Initializing services...');

    // Network Info
    getIt.registerSingleton<NetworkInfo>(
      NetworkInfoImpl(getIt<InternetConnectionChecker>()),
    );

    // Hive Services
    getIt.registerSingleton<HiveBoxManager>(HiveBoxManager());
    getIt.registerSingleton<HiveService>(
      HiveService(hiveManager: getIt<HiveBoxManager>()),
    );

    // Sync Service
    getIt.registerSingleton<SyncService>(
      SyncService(
        networkInfo: getIt<NetworkInfo>(),
        hiveManager: getIt<HiveBoxManager>(),
        dio: getIt<Dio>(),
      ),
    );

    // Initialize Sync Service
    await getIt<SyncService>().initialize();

    // Register all sensor services first
    getIt.registerLazySingleton<MotionSensorService>(
        () => MotionSensorService());
    getIt.registerLazySingleton<LocationService>(() => LocationService());
    getIt.registerLazySingleton<ProximitySensorService>(
        () => ProximitySensorService());
    getIt.registerLazySingleton<LightSensorService>(() => LightSensorService());
    getIt.registerLazySingleton<BarometerService>(() => BarometerService());
    getIt.registerLazySingleton<PedometerService>(() => PedometerService());
    getIt.registerLazySingleton<BiometricAuthService>(
        () => BiometricAuthService());

    // Then register SensorManager with all dependencies
    getIt.registerSingleton<SensorManager>(
      SensorManager(
        motionSensorService: getIt<MotionSensorService>(),
        locationService: getIt<LocationService>(),
        proximitySensorService: getIt<ProximitySensorService>(),
        lightSensorService: getIt<LightSensorService>(),
        barometerService: getIt<BarometerService>(),
        pedometerService: getIt<PedometerService>(),
        biometricAuthService: getIt<BiometricAuthService>(),
      ),
    );

    _logger.info('✅ Services initialized');
  } catch (e) {
    _logger.severe('Failed to initialize services', e);
    rethrow;
  }
}

Future<void> _initDataSources() async {
  try {
    _logger.info('Initializing data sources...');

    // Auth Data Sources
    getIt.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(hiveService: getIt<HiveService>()),
    );

    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSource(
        dio: getIt<Dio>(),
        networkInfo: getIt<NetworkInfo>(),
        prefs: getIt<SharedPreferencesService>(),
      ),
    );

    getIt.registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        tokenManager: getIt<AuthTokenManager>(),
      ),
    );

    getIt.registerLazySingleton<CustomerProfileDataSource>(
      () => CustomerProfileRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        tokenManager: getIt<AuthTokenManager>(),
      ),
      instanceName: 'remote',
    );

    getIt.registerLazySingleton<CustomerProfileDataSource>(
      () => CustomerProfileLocalDataSourceImpl(
        hiveService: getIt<HiveService>(),
      ),
      instanceName: 'local',
    );

    // Customer Dashboard Data Source
    getIt.registerLazySingleton<CustomerDashboardRemoteDataSource>(
      () => CustomerDashboardRemoteDataSourceImpl(
        dio: getIt<Dio>(),
        prefs: getIt<SharedPreferencesService>(),
        tokenManager: getIt<AuthTokenManager>(),
      ),
    );

    _logger.info('✅ Data sources initialized');
  } catch (e) {
    _logger.severe('Failed to initialize data sources', e);
    rethrow;
  }
}

Future<void> _initRepositories() async {
  try {
    _logger.info('Initializing repositories...');

    // Auth Repository
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthLocalRepositoryImpl(
        localDataSource: getIt<AuthLocalDataSource>(),
        networkInfo: getIt<NetworkInfo>(),
        syncService: getIt<SyncService>(),
        dio: getIt<Dio>(),
      ),
    );

    // Create and register CustomerDashboardRepository
    final dashboardRepoImpl = CustomerDashboardRepositoryImpl(
      remoteDataSource: getIt<CustomerDashboardRemoteDataSource>(),
    );

    if (!getIt.isRegistered<CustomerDashboardRepository>()) {
      getIt.registerLazySingleton<CustomerDashboardRepository>(
        () => dashboardRepoImpl,
      );
    }

    if (!getIt.isRegistered<OrderRepository>()) {
      getIt.registerLazySingleton<OrderRepository>(
        () => OrderRepositoryImpl(
          remoteDataSource: getIt<OrderRemoteDataSource>(),
        ),
      );
    }

    if (!getIt.isRegistered<CustomerProfileRepository>()) {
      getIt.registerLazySingleton<CustomerProfileRepository>(
        () => CustomerProfileRepositoryImpl(
          remoteDataSource:
              getIt<CustomerProfileDataSource>(instanceName: 'remote'),
          localDataSource:
              getIt<CustomerProfileDataSource>(instanceName: 'local'),
        ),
      );
    }

    if (!getIt.isRegistered<TableDataSource>()) {
      getIt.registerLazySingleton<TableDataSource>(() => TableDataSourceImpl(
            client: getIt<http.Client>(),
          ));
      _logger.info('📡 Registered TableDataSource');
    }

    // Register TableRepository
    if (!getIt.isRegistered<TableRepository>()) {
      getIt.registerLazySingleton<TableRepository>(() => TableRepositoryImpl(
            dataSource: getIt<TableDataSource>(),
            networkInfo: getIt<NetworkInfo>(),
          ));
      _logger.info('🗄️ Registered TableRepository');
    }

    _logger.info('✅ Repositories initialized');
  } catch (e) {
    _logger.severe('Failed to initialize repositories', e);
    rethrow;
  }
}

Future<void> _initUseCases() async {
  try {
    _logger.info('Initializing use cases...');

    // Auth Use Cases
    getIt.registerLazySingleton(() => LoginUseCase(
          repository: getIt<AuthRepository>(),
        ));

    getIt.registerLazySingleton(() => RegisterUserUseCase(
          repository: getIt<AuthRepository>(),
        ));

    getIt.registerLazySingleton(() => VerifyEmailUseCase(
          getIt<AuthRepository>(),
        ));

    // Customer Dashboard Use Cases
    getIt.registerLazySingleton(() => GetAllRestaurantsUseCase(
          getIt<CustomerDashboardRepository>(),
        ));

    getIt.registerLazySingleton(() => GetRestaurantDetailsUseCase(
          getIt<CustomerDashboardRepository>(),
        ));

    getIt.registerLazySingleton(() => GetRestaurantMenuUseCase(
          getIt<CustomerDashboardRepository>(),
        ));

    getIt.registerLazySingleton(() => GetRestaurantTablesUseCase(
          getIt<CustomerDashboardRepository>(),
        ));

    getIt.registerLazySingleton(() => GetTableDetailsUseCase(
          getIt<CustomerDashboardRepository>(),
        ));

    // Order Use Cases
    getIt.registerLazySingleton(() => PlaceOrderUseCase(
          getIt<OrderRepository>(),
        ));

    getIt.registerLazySingleton(() => GetCustomerOrdersUseCase(
          getIt<OrderRepository>(),
        ));

    getIt.registerLazySingleton(() => GetOrderDetailsUseCase(
          getIt<OrderRepository>(),
        ));

    getIt.registerLazySingleton(() => GetOrderStatusUseCase(
          getIt<OrderRepository>(),
        ));

    getIt.registerLazySingleton(() => CancelOrderUseCase(
          getIt<OrderRepository>(),
        ));

    getIt.registerLazySingleton(() => FetchCustomerProfileUseCase(
          getIt<CustomerProfileRepository>(),
        ));

    getIt.registerLazySingleton(() => UpdateCustomerProfileUseCase(
          getIt<CustomerProfileRepository>(),
        ));

    getIt.registerLazySingleton(() => DeleteCustomerProfileUseCase(
          getIt<CustomerProfileRepository>(),
        ));

    // Add this new use case for image uploads
    getIt.registerLazySingleton(() => UploadProfileImageUseCase(
          getIt<CustomerProfileRepository>(),
        ));

    _logger.info('✅ Use cases initialized');
  } catch (e) {
    _logger.severe('Failed to initialize use cases', e);
    rethrow;
  }
}

Future<void> _initBlocs() async {
  try {
    _logger.info('Initializing blocs...');

    // Register SyncBloc as a singleton
    if (!getIt.isRegistered<SyncBloc>()) {
      getIt.registerLazySingleton<SyncBloc>(() => SyncBloc(
            syncService: getIt<SyncService>(),
            networkInfo: getIt<NetworkInfo>(),
          ));
    }

    // Improved CustomerDashboardBloc registration
    if (getIt.isRegistered<CustomerDashboardBloc>()) {
      // Close and unregister existing bloc if it exists
      try {
        final existingBloc = getIt<CustomerDashboardBloc>();
        await existingBloc.close();
        await getIt.unregister<CustomerDashboardBloc>();
      } catch (e) {
        _logger.warning('Error disposing existing CustomerDashboardBloc: $e');
      }
    }

    // Create a new CustomerDashboardBloc
    final dashboardBloc = CustomerDashboardBloc(
      getAllRestaurantsUseCase: getIt<GetAllRestaurantsUseCase>(),
      getRestaurantDetailsUseCase: getIt<GetRestaurantDetailsUseCase>(),
      getRestaurantMenuUseCase: getIt<GetRestaurantMenuUseCase>(),
      getRestaurantTablesUseCase: getIt<GetRestaurantTablesUseCase>(),
      placeOrderUseCase: getIt<PlaceOrderUseCase>(),
      tokenManager: getIt<AuthTokenManager>(),
      tableRepository: getIt<TableRepository>(),
    );

    // Register as a singleton with proper disposal
    getIt.registerSingleton<CustomerDashboardBloc>(
      dashboardBloc,
      dispose: (bloc) => bloc.close(),
    );
    _logger.info('📱 Registered CustomerDashboardBloc as singleton');

    // Register other blocs as factories
    getIt.registerFactory(() => RegisterBloc(
          repository: getIt<AuthRepository>(),
          registerUseCase: getIt<RegisterUserUseCase>(),
        ));

    getIt.registerFactory(() => VerifyEmailBloc(
          verifyEmailUseCase: getIt<VerifyEmailUseCase>(),
          tokenManager: getIt<AuthTokenManager>(),
        ));

    getIt.registerFactory(() => LoginBloc(
          authRepository: getIt<AuthRepository>(),
          customerDashboardRepository: getIt<CustomerDashboardRepository>(),
          loginUseCase: getIt<LoginUseCase>(),
          registerBloc: getIt<RegisterBloc>(),
          syncBloc: getIt<SyncBloc>(),
          tokenManager: getIt<AuthTokenManager>(),
          preferencesService: getIt<SharedPreferencesService>(),
          biometricAuthService: getIt<BiometricAuthService>(),
        ));

    getIt.registerLazySingleton(() => CustomerProfileBloc(
          fetchProfileUseCase: getIt<FetchCustomerProfileUseCase>(),
          updateProfileUseCase: getIt<UpdateCustomerProfileUseCase>(),
          uploadProfileImageUseCase: getIt<UploadProfileImageUseCase>(),
          tokenManager: getIt<AuthTokenManager>(),
        ));

    getIt.registerFactory(() => SplashOnboardingCubit());
    _logger.info('✅ Blocs initialized');
  } catch (e, stackTrace) {
    _logger.severe('Failed to initialize blocs', e, stackTrace);
    rethrow;
  }
}

Future<void> disposeDependencies() async {
  try {
    _logger.info('🧹 Starting cleanup of dependencies...');

    // Dispose CustomerDashboardBloc with more robust error handling
    if (getIt.isRegistered<CustomerDashboardBloc>()) {
      try {
        final bloc = getIt<CustomerDashboardBloc>();
        await bloc.close();
        await getIt.unregister<CustomerDashboardBloc>();
        _logger.info('✅ Successfully disposed CustomerDashboardBloc');
      } catch (e) {
        _logger.severe('Error disposing CustomerDashboardBloc', e);
      }
    }

    // Dispose SyncBloc
    if (getIt.isRegistered<SyncBloc>()) {
      final syncBloc = getIt<SyncBloc>();
      await syncBloc.close();
      await getIt.unregister<SyncBloc>();
      _logger.info('✅ Successfully disposed SyncBloc');
    }

    // Close all Hive boxes using the correct method name
    final hiveManager = getIt<HiveBoxManager>();
    await hiveManager
        .closeAllBoxes(); // Changed from closeBoxes to closeAllBoxes
    _logger.info('✅ Successfully closed all Hive boxes');

    // Reset GetIt instance
    await getIt.reset();
    _logger.info('✅ Successfully reset GetIt instance');
  } catch (e, stackTrace) {
    _logger.severe('❌ Error during dependency cleanup', e, stackTrace);
    rethrow;
  }
}

/// Enhanced BlocObserver for debugging and monitoring
class AppBlocObserver extends BlocObserver {
  final Logger _logger = Logger('AppBlocObserver');

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _logger.info('🎯 Bloc Created: ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    _logger.info('''
🔄 ${bloc.runtimeType} State Change:
  - From: ${change.currentState}
  - To: ${change.nextState}
''');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    _logger.info('''
📩 ${bloc.runtimeType} Event:
  - Event: $event
  - Current State: ${bloc.state}
''');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    _logger.info('''
🔁 ${bloc.runtimeType} Transition:
  - Event: ${transition.event}
  - From: ${transition.currentState}
  - To: ${transition.nextState}
''');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    _logger.severe('''
❌ ${bloc.runtimeType} Error:
  - Error: $error
  - Stack Trace: $stackTrace
''');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    _logger.info('🚫 Bloc Closed: ${bloc.runtimeType}');
    super.onClose(bloc);
  }
}

/// Extension method to safely get registered instances
extension GetItExtension on GetIt {
  T getRegistered<T extends Object>({String? instanceName}) {
    if (!isRegistered<T>(instanceName: instanceName)) {
      throw Exception('No instance of type $T registered');
    }
    return get<T>(instanceName: instanceName);
  }
}
