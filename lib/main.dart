import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/app_dependencies.dart';

/// Entry point of the SMS Manager application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppDependencies.instance.themeController.load();
  runApp(const SmsManagerApp());
}
