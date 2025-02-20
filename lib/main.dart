import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tottouchordertastemobileapplication/app/app.dart';
import 'package:tottouchordertastemobileapplication/app/di/di.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/core/theme/theme_cubit.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/sync_hive_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // await Hive.deleteFromDisk();

  Hive.registerAdapter(AuthHiveModelAdapter());
  Hive.registerAdapter(UserProfileHiveModelAdapter());
  Hive.registerAdapter(AuthMetadataHiveModelAdapter());

  Hive.registerAdapter(SyncHiveModelAdapter());
  Hive.registerAdapter(SyncOperationAdapter());

  await initDependencies();
  await initNetwork();

  Bloc.observer = AppBlocObserver();

  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: const App(),
    ),
  );
}
