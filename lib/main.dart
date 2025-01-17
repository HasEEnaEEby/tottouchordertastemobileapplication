import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tottouchordertastemobileapplication/features/auth/data/model/auth_hive_model.dart';

import 'app/app.dart';
import 'app/di/di.dart';

void main() async {
  await Hive
      .initFlutter(); 

  Hive.registerAdapter(AuthHiveModelAdapter());
  Hive.registerAdapter(UserProfileHiveModelAdapter());
  Hive.registerAdapter(AuthMetadataHiveModelAdapter());

  await init();

  runApp(const App());
}
