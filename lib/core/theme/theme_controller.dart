import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the application's [ThemeMode] state and persists user preference
/// locally on device storage (100% offline).
///
/// Follows Single Responsibility Principle (SRP): solely responsible for
/// reading, updating, notifying, and persisting the active theme mode.
class ThemeController extends ChangeNotifier {
  ThemeController({
    ThemeMode initialMode = ThemeMode.system,
    Future<Directory> Function()? directoryProvider,
  })  : _themeMode = initialMode,
        _directoryProvider =
            directoryProvider ?? getApplicationDocumentsDirectory;

  static const String _fileName = 'theme_mode.txt';

  final Future<Directory> Function() _directoryProvider;
  ThemeMode _themeMode;

  /// Current active theme mode (`system`, `light`, or `dark`).
  ThemeMode get themeMode => _themeMode;

  /// Returns `true` when dark appearance is currently active, taking
  /// [platformBrightness] into account if [themeMode] is [ThemeMode.system].
  bool isDarkActive(Brightness platformBrightness) {
    return switch (_themeMode) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformBrightness == Brightness.dark,
    };
  }

  /// Loads the persisted theme mode from local storage if present.
  Future<void> load() async {
    try {
      final file = await _getPreferenceFile();
      if (!await file.exists()) return;

      final saved = (await file.readAsString()).trim();
      final parsed = _parseThemeMode(saved);
      if (parsed != null && parsed != _themeMode) {
        _themeMode = parsed;
        notifyListeners();
      }
    } catch (_) {
      // Fallback safely to the default theme mode if disk read fails.
    }
  }

  /// Updates the active [ThemeMode], notifies listeners immediately, and
  /// persists the selection locally.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      final file = await _getPreferenceFile();
      await file.writeAsString(_serializeThemeMode(mode), flush: true);
    } catch (_) {
      // Non-fatal: in-memory state stays updated even if persistence fails.
    }
  }

  Future<File> _getPreferenceFile() async {
    final dir = await _directoryProvider();
    return File('${dir.path}/$_fileName');
  }

  static String _serializeThemeMode(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }

  static ThemeMode? _parseThemeMode(String raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }
}
