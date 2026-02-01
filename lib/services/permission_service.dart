import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestStoragePermission() async {
    bool permissionGranted = false;

    // Check Android version
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        // Android 11+. Request MANAGE_EXTERNAL_STORAGE
        var status = await Permission.manageExternalStorage.status;
        if (status.isGranted) {
          permissionGranted = true;
        } else {
          status = await Permission.manageExternalStorage.request();
          permissionGranted = status.isGranted;
        }
      } else {
        // Android 10 and below. Request STORAGE
        var status = await Permission.storage.status;
        if (status.isGranted) {
          permissionGranted = true;
        } else {
          status = await Permission.storage.request();
          permissionGranted = status.isGranted;
        }
      }
    } else {
      // Not Android (e.g. testing?), assume true for now or handle appropriately
      // But requirement says Android only.
      return false;
    }

    return permissionGranted;
  }

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }
}
