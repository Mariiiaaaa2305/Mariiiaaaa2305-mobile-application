import 'package:flutter/services.dart';

import 'smart_flash_plugin_platform_interface.dart';

class SmartFlashPlugin {
  static Future<void> toggleFlash() async {
    try {
      await SmartFlashPluginPlatform.instance.toggleFlash();
    } on PlatformException {
      rethrow;
    } catch (_) {
      throw PlatformException(
        code: 'unsupported_platform',
        message: 'Ліхтарик підтримується лише на Android',
      );
    }
  }

  static Future<bool> isFlashSupported() async {
    try {
      return await SmartFlashPluginPlatform.instance.isFlashSupported();
    } catch (_) {
      return false;
    }
  }
}