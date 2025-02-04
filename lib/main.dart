import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tottouchordertastemobileapplication/app/di/di.dart';
import 'package:tottouchordertastemobileapplication/core/common/internet_checker.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapter(AuthHiveModelAdapter());
  Hive.registerAdapter(UserProfileHiveModelAdapter());
  Hive.registerAdapter(AuthMetadataHiveModelAdapter());

  await initDependencies();
  await initNetwork();

  Bloc.observer = AppBlocObserver();

  runApp(const App());
}
