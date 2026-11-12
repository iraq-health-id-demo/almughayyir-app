import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/app_database.dart';
import 'data/repository.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ar');

  runApp(
    ChangeNotifierProvider<AppState>(
      create: (_) => AppState(Repository(AppDatabase.instance))..load(),
      child: const MughayyirApp(),
    ),
  );
}
