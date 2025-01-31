import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tottouchordertastemobileapplication/app/services/navigation_service.dart';
import 'package:tottouchordertastemobileapplication/app/services/sync_service.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_box_manager.dart';
import 'package:tottouchordertastemobileapplication/core/network/hive_service.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/data_source/local_data_source/auth_local_datasource.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/repository/auth_local_repository/auth_local_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/repository/auth_repository.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/login_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/domain/use_case/register_user_usecase.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/login/login_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/signup/register_bloc.dart';
import 'package:tottouchordertastemobileapplication/features/auth/presentation/view_model/sync/sync_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  _registerHiveAdapters();

  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  getIt.registerSingleton<NavigationService>(NavigationService());
  getIt.registerSingleton<HiveBoxManager>(HiveBoxManager());

  getIt.registerSingleton<HiveService>(
    HiveService(hiveManager: getIt<HiveBoxManager>()),
  );

  getIt.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(InternetConnectionChecker()),
  );

  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      networkInfo: getIt<NetworkInfo>(),
      hiveManager: getIt<HiveBoxManager>(),
    ),
  );

  await getIt<SyncService>().initialize();

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: getIt<HiveService>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthLocalRepositoryImpl(
      localDataSource: getIt<AuthLocalDataSource>(),
      networkInfo: getIt<NetworkInfo>(),
      syncService: getIt<SyncService>(),
    ),
  );

  getIt.registerLazySingleton(() => LoginUseCase(
        repository: getIt<AuthRepository>(),
      ));

  getIt.registerLazySingleton(() => RegisterUserUseCase(
        repository: getIt<AuthRepository>(),
      ));

  getIt.registerFactory(() => LoginBloc(
        useCase: getIt<LoginUseCase>(),
        authRepository: getIt<AuthRepository>(),
        navigationService: getIt<NavigationService>(),
      ));

  getIt.registerFactory(() => RegisterBloc(
        useCase: getIt<RegisterUserUseCase>(),
        repository: getIt<AuthRepository>(),
        navigationService: getIt<NavigationService>(),
        syncService: getIt<SyncService>(),
      ));

  getIt.registerFactory(() => SyncBloc(
        syncService: getIt<SyncService>(),
        networkInfo: getIt<NetworkInfo>(),
      ));

  if (kDebugMode) {
    Bloc.observer = AppBlocObserver();
  }
}

void _registerHiveAdapters() {
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(AuthHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(SyncHiveModelAdapter());
  }
  if (!Hive.isAdapterRegistered(5)) {
    Hive.registerAdapter(SyncOperationAdapter());
  }
}

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
