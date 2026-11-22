import 'package:permission_handler/permission_handler.dart';

/// Result status of the requested permissions.
enum AppPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
}

/// Abstract contract for permission handling (Dependency Inversion Principle).
abstract interface class IPermissionService {
  /// Checks if all essential permissions (SMS & Contacts) are already granted.
  Future<bool> hasRequiredPermissions();

  /// Requests the essential permissions (SMS and Contacts).
  Future<AppPermissionStatus> requestRequiredPermissions();

  /// Opens the device app settings screen when permissions are permanently denied.
  Future<bool> openAppSettingsScreen();
}

/// Concrete implementation of [IPermissionService] using `permission_handler`.
///
/// Follows Single Responsibility Principle (SRP): purely manages permission checks
/// and requests across the platform.
class PermissionService implements IPermissionService {
  const PermissionService();

  static const List<Permission> _requiredPermissions = [
    Permission.sms,
    Permission.contacts,
  ];

  @override
  Future<bool> hasRequiredPermissions() async {
    for (final permission in _requiredPermissions) {
      final status = await permission.status;
      if (!status.isGranted) {
        return false;
      }
    }
    return true;
  }

  @override
  Future<AppPermissionStatus> requestRequiredPermissions() async {
    final statuses = await _requiredPermissions.request();

    final allGranted = statuses.values.every((status) => status.isGranted);
    if (allGranted) {
      return AppPermissionStatus.granted;
    }

    final anyPermanentlyDenied =
        statuses.values.any((status) => status.isPermanentlyDenied);
    if (anyPermanentlyDenied) {
      return AppPermissionStatus.permanentlyDenied;
    }

    return AppPermissionStatus.denied;
  }

  @override
  Future<bool> openAppSettingsScreen() async {
    return openAppSettings();
  }
}
