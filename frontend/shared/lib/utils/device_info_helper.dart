import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Generate a unique device ID
  static Future<String> getDeviceId() async {
    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      return 'web_${webInfo.userAgent?.hashCode ?? 'unknown'}';
    }

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return 'android_${androidInfo.id}';
    }

    if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return 'ios_${iosInfo.identifierForVendor ?? 'unknown'}';
    }

    if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      return 'windows_${windowsInfo.computerName}';
    }

    if (Platform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      return 'linux_${linuxInfo.machineId ?? 'unknown'}';
    }

    if (Platform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      return 'macos_${macInfo.systemGUID ?? 'unknown'}';
    }

    return 'unknown_device';
  }

  /// Generate a device fingerprint (hash of device characteristics)
  static Future<String> getDeviceFingerprint() async {
    String deviceInfo = '';

    if (kIsWeb) {
      final webInfo = await _deviceInfo.webBrowserInfo;
      deviceInfo = '${webInfo.userAgent}_${webInfo.browserName}_${webInfo.platform}';
    } else if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      deviceInfo = '${androidInfo.id}_${androidInfo.model}_${androidInfo.device}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      deviceInfo = '${iosInfo.identifierForVendor}_${iosInfo.model}_${iosInfo.systemVersion}';
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      deviceInfo = '${windowsInfo.computerName}_${windowsInfo.numberOfCores}_${windowsInfo.systemMemoryInMegabytes}';
    } else if (Platform.isLinux) {
      final linuxInfo = await _deviceInfo.linuxInfo;
      deviceInfo = '${linuxInfo.machineId}_${linuxInfo.name}_${linuxInfo.version}';
    } else if (Platform.isMacOS) {
      final macInfo = await _deviceInfo.macOsInfo;
      deviceInfo = '${macInfo.systemGUID}_${macInfo.model}_${macInfo.osRelease}';
    }

    // Generate SHA-256 hash of device info
    final bytes = utf8.encode(deviceInfo);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
