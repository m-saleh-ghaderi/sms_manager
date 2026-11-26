import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';

/// Entry point of the SMS Manager application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = AppDependencies.instance;
  await deps.themeController.load();
  deps.incomingSmsHandler.start();
  runApp(const SmsManagerApp());
}
