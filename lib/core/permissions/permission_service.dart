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

  static const List<Permission> _startupPermissions = [
    Permission.sms,
    Permission.contacts,
    Permission.notification,
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
    final statuses = await _startupPermissions.request();

    final allGranted = _requiredPermissions.every(
      (permission) => statuses[permission]?.isGranted ?? false,
    );
    if (allGranted) {
      return AppPermissionStatus.granted;
    }

    final anyPermanentlyDenied = _requiredPermissions.any(
      (permission) => statuses[permission]?.isPermanentlyDenied ?? false,
    );
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
