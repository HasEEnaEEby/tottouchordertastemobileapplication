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
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Hive.initFlutter();
    await Hive.deleteFromDisk();
    await _registerHiveAdapters();
    await initDependencies();
    await initNetwork();

    Bloc.observer = AppBlocObserver();

    runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit()),
        ],
        child: const App(),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Error initializing app: $e');
    debugPrint(stackTrace.toString());
    runApp(ErrorApp(error: e.toString()));
  }
}

Future<void> _registerHiveAdapters() async {
  try {
    const authTypeId = 0;
    const userProfileTypeId = 1;
    const authMetadataTypeId = 2;
    const syncTypeId = 4;
    const syncOperationTypeId = 5;

    if (!Hive.isAdapterRegistered(authTypeId)) {
      Hive.registerAdapter(AuthHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(userProfileTypeId)) {
      Hive.registerAdapter(UserProfileHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(authMetadataTypeId)) {
      Hive.registerAdapter(AuthMetadataHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(syncTypeId)) {
      Hive.registerAdapter(SyncHiveModelAdapter());
    }

    if (!Hive.isAdapterRegistered(syncOperationTypeId)) {
      Hive.registerAdapter(SyncOperationAdapter());
    }
  } catch (e) {
    debugPrint('Error registering Hive adapters: $e');
    rethrow;
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Error',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    main(); // Restart app
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
